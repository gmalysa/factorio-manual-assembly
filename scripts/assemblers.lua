-- SPDX-License-Identifier: BSD-3-Clause
--

local glog = require("scripts.glog")
local controls = require("controls.assemblers")

local this = {}

function this.init()
	global.assemblers = {}
end

this.on_built_match = {
	"manual-assembler",
	"feedback-assembler"
}

function this.set_recipe(asm, recipe)
	asm.state = {}
	asm.recipe = recipe.id
	recipe.init(asm.state)
end

function this.on_built(e)
	local uid = e.unit_number
	local c = nil
	local d = nil

	-- create and attach controller
	local c = e.surface.create_entity{
		name = "assembler-controller",
		position = {x = e.position.x + 1.25, y = e.position.y + 1.25},
		force = e.force,
		create_build_effect_smoke = false
	}
	c.operable = false

	if e.name == "manual-assembler" then
		-- create reference for desired inputs
		d = e.surface.create_entity{
			name = "assembler-needs",
			position = {x = e.position.x + 1.25, y = e.position.y - 1.25},
			force = e.force,
			create_build_effect_smoke = false
		}
		d.operable = false
	elseif e.name == "feedback-assembler" then
		-- create feedback sensor node instead
		d = e.surface.create_entity{
			name = "assembler-feedback",
			position = {x = e.position.x + 1.25, y = e.position.y - 1.25},
			force = e.force,
			create_build_effect_smoke = false
		}
	end

	global.assemblers[uid] = {
		assembler = e,
		controller = c,
		feedback = d,
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
		local next_control = controls.get_by_name(recipe.name)
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
			if signal ~= v.count then
				disable = true
			else
				matched[v.signal.name] = true
			end
		end

		-- check we don't have extra signals to avoid some all inputs approach
		if not disable then
			local in_signals = controller.get_merged_signals() or {}
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
		local ref = asm.feedback.get_or_create_control_behavior()
		ref.parameters = control_recipe.desired(asm.state)
	end
end

return this
