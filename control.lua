-- SPDX-License-Identifier: BSD-3-Clause
--

-- @todo:
-- assembler stuff needs to be reintegrated and made to actually work
-- code formatting, comment blocks, etc
-- for performance at some point split things into active and inactive lists

local glog = require("scripts.glog")
local drills = require("scripts.drills")

script.on_init(function()
	global.controllers = {}
	global.assemblers = {}
	drills.init()
	glog.init()
end)

local function track_controller(c, e)
	local uid = c.unit_number
	global.controllers[uid] = c
	global.assemblers[uid] = e
end

local function on_built(event)
	local e = event.created_entity or event.entity
	local found = false

	if not e.valid then
		return
	end

	for k,v in pairs(drills.on_built_match) do
		if e.name == v then
			drills.on_built(e)
			found = true
		end
	end

	if not found then
		glog.log("filter matched entity named "..e.name.." without a matching handler")
	end
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

local function register_build_handler(fn, filter)
	script.on_event(defines.events.on_built_entity, fn, filter)
	script.on_event(defines.events.on_robot_built_entity, fn, filter)
	script.on_event(defines.events.script_raised_built, fn, filter)
	script.on_event(defines.events.script_raised_revive, fn, filter)
end

-- need to handle on_pre_player_mined_item, on_robot_pre_mined, on_entity_died, script_raised_entity_destroy

local filter = {}
for k, v in pairs(drills.on_built_match) do
	table.insert(filter, {filter = "name", name = v, mode = "or"})
end

register_build_handler(on_built, filter)

local function on_tick_handler(event)
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

	drills.on_tick()
end

script.on_event(defines.events.on_tick, on_tick_handler)
