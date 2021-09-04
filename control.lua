-- SPDX-License-Identifier: BSD-3-Clause
--

-- @todo:
-- need to handle: on_pre_player_mined_item, on_robot_pre_mined,
--                 on_entity_died, script_raised_entity_destroy
-- for performance at some point split things into active and inactive lists

local glog = require("scripts.glog")
local assemblers = require("scripts.assemblers")
local drills = require("scripts.drills")

script.on_init(function()
	glog.init()
	assemblers.init()
	drills.init()
end)

---
 -- Register a new set of matches to call the given function when entities are built
 -- @param[inout] list Modify this list of filter definitions
 -- @param[in] mod Module object that must have on_built_match containing a list of
 --                entity names and on_built as a function to call when one is built
 -- @return void
 --
local function register_built_filters(list, mod)
	for k, v in pairs(mod.on_built_match) do
		table.insert(list, {
			name = v,
			fn = mod.on_built
		})
	end
end

---
 -- Convert our master filter list (which includes callbacks, for example) into a
 -- filter that can be passed on_built to search for only the entities we care about
 -- @param[in] filter Filter defined above, each entry has "name" at least which is an
 --                   entity name
 -- @return filter table suitable for script.on_event
 --
local function to_event_filter(filter)
	local rtn = {}
	for k, v in pairs(filter) do
		table.insert(rtn, {filter = "name", name = v.name, mode = "or"})
	end
	return rtn
end

local all_filters = {}
register_built_filters(all_filters, drills)
register_built_filters(all_filters, assemblers)

---
 -- Event handler for the on built class of events, which forwards to the appropriate
 -- module to configure itself based on the entity name to callback relationships
 -- established earlier
 -- @param[in] event Event object/table with details
 -- @return void
 --
local function on_built(event)
	local e = event.created_entity or event.entity
	local found = false

	if not e.valid then
		return
	end

	for k,v in pairs(all_filters) do
		if e.name == v.name then
			v.fn(e)
			found = true
		end
	end

	if not found then
		glog.log("filter matched entity named "..e.name.." without a matching handler")
	end
end

---
 -- Handle all of the built events the same way
 -- @param fn Function to call when the entity was built
 -- @param filter Filter to use for event registration
 -- @return void
 --
local function register_built_handler(fn, filter)
	script.on_event(defines.events.on_built_entity, fn, filter)
	script.on_event(defines.events.on_robot_built_entity, fn, filter)
	script.on_event(defines.events.script_raised_built, fn, filter)
	script.on_event(defines.events.script_raised_revive, fn, filter)
end

---
 -- Called once per tick to do updates
 -- @param event Event representing the tick
 -- @return void
 --
local function on_tick_handler(event)
	assemblers.on_tick()
	drills.on_tick()
end

register_built_handler(on_built, to_event_filter(all_filters))
script.on_event(defines.events.on_tick, on_tick_handler)

local function on_load(event)
end

script.on_load(on_load)
