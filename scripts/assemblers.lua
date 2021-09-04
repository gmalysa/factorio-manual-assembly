-- SPDX-License-Identifier: BSD-3-Clause
--

local glog = require("scripts.glog")

local this = {}

function this.init()
	global.controllers = {}
	global.assemblers = {}
end

local function track_controller(c, e)
	local uid = c.unit_number
	global.controllers[uid] = c
	global.assemblers[uid] = e
end

this.on_built_match = {
	"manual-assembler"
}

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

	-- todo create sensor node for feedback in designs

	global.assemblers[uid] = {
		assembler = e,
		controller = c,
		desired = d,
		sensor = nil,
		signal = {
			type = "virtual",
			name = "signal-blue"
		}
	}
end

function this.on_tick()
	for uid,asm in pairs(global.assemblers) do
		local controller = asm.controller
		local assembler = asm.assembler
		local desired = asm.desired
		local signal = controller.get_merged_signal(asm.signal)

		local ref = desired.get_or_create_control_behavior()
		ref.parameters = {{
			signal = asm.signal,
			index = 1,
			count = 1
		}}

		if signal == 1 then
			assembler.active = true
		else
			assembler.active = false
		end
	end
end

return this
