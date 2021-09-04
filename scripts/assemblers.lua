-- SPDX-License-Identifier: BSD-3-Clause
--

local glog = require("scripts.glog")
local controls = require("controls.assemblers")

local this = {}

function this.init()
	global.assemblers = {}
end

this.on_built_match = {
	"manual-assembler"
}

function this.set_recipe(asm, recipe)
	asm.state = {}
	asm.recipe = recipe.id
	recipe.init(asm.state)
end

function this.on_built(e)
	local uid = e.unit_number

	-- create and attach controller
	local c = e.surface.create_entity{
		name = "assembler-controller",
		position = {x = e.position.x + 1, y = e.position.y + 0.75},
		force = e.force,
		create_build_effect_smoke = false
	}
	c.operable = false

	-- create reference for desired inputs
	local d = e.surface.create_entity{
		name = "assembler-needs",
		position = {x = e.position.x + 1, y = e.position.y - 0.75},
		force = e.force,
		create_build_effect_smoke = false
	}
	d.operable = false

	-- todo create sensor node for feedback in designs

	global.assemblers[uid] = {
		assembler = e,
		controller = c,
		desired = d,
		sensor = nil,
	}

	this.set_recipe(global.assemblers[uid], controls["null-recipe"])
end

function this.on_tick()
	for uid,asm in pairs(global.assemblers) do
		local controller = asm.controller
		local assembler = asm.assembler
		local recipe = assembler.get_recipe()

		-- skip assemblers that aren't doing anything
		-- @todo need to deal with full assemblers and input shortage to skip them
		if recipe == nil then
			return
		end

		-- check if recipe changed and reinitialize controller if so
		local next_control = controls[recipe.name]
		if next_control.id ~= asm.recipe then
			this.set_recipe(asm, next_control)
		end

		local control_recipe = controls.get_by_id(asm.recipe)

		-- check if every expected signal is satisfied
		disable = false
		local matched = {}
		for k,v in pairs(asm.state.signals) do
			-- use direct lookup as in_signals doesn't have keys for signals
			local signal = controller.get_merged_signal(v.signal)
			if signal ~= v.value then
				disable = true
			else
				matched[v.signal.name] = true
			end
		end

		-- check we don't have extra signals to avoid some all inputs approach
		if not disable then
			local in_signals = controller.get_merged_signals()
			for k, v in pairs(in_signals) do
				if matched[v.signal.name] == nil then
					disable = true
				end
			end
		end

		-- if enabled, run assembler and step recipe state
		if disable then
			assembler.active = false
		else
			assembler.active = true
			control_recipe.step(asm.state)
		end

		-- update desired input display
		local desired = asm.desired
		local ref = desired.get_or_create_control_behavior()
		local params = {}
		local idx = 1
		for k,v in pairs(asm.state.signals) do
			table.insert(params, {
				signal = v.signal,
				count = v.value,
				index = idx
			})
			idx = idx + 1
		end
		ref.parameters = params
	end
end

return this
