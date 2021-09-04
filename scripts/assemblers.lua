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
	-- create and attach controller
	local c = e.surface.create_entity{
		name = "assembler-controller",
		position = {x = e.position.x + 1, y = e.position.y},
		force = e.force,
		create_build_effect_smoke = false
	}
	c.operable = false

	local uid = e.unit_number
	global.assemblers[uid] = {
		assembler = e,
		controller = c,
		signal = {
			type = "virtual",
			name = "signal-blue"
		}
	}

	-- todo another output combinator that shows what this assembler needs to progress?
end

function this.on_tick()
	for uid,asm in pairs(global.assemblers) do
		local controller = asm.controller
		local assembler = asm.assembler
		local signal = controller.get_merged_signal(asm.signal)

		if signal == 1 then
			assembler.active = true
		else
			assembler.active = false
		end
	end
end

return this
