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

local function on_manual_assembler_built(event)
	local e = event.created_entity or event.entity

	if not e.valid then
		return
	end

	-- create and attach controller
	local c = e.surface.create_entity{
		name = "assembler-controller",
		position = {x = e.position.x + 1, y = e.position.y},
		force = e.force,
		create_build_effect_smoke = false
	}
	c.operable = false

	track_controller(c, e)

	-- todo another output combinator that shows what this assembler needs to progress?
end

local function on_tick()
	for k,c in pairs(global.controllers) do
		local assembler = global.assemblers[c.unit_number]
		local signal = c.get_merged_signal({
			type = "virtual",
			name = "signal-blue"
		})

		if signal == 1 then
			assembler.active = true
		else
			assembler.active = false
		end
	end
end

return this
