-- SPDX-License-Identifier: BSD-3-Clause
--

-- @todo
-- add comment blocks

local glog = require("scripts.glog")

local drills = {}

---
 -- @param drill LuaEntity representing in game drill to check
 -- @return bool true if we should process this drill
 --
function drills.is_drill_ready(drill)
	return drill.valid and drill.status == defines.entity_status.working
end

function drills.init()
	global.drills = {}
end

drills.on_built_match = {
	"burner-mining-drill"
}

function drills.on_built(e)
	local uid = e.unit_number

	glog.log("new drill"..uid)

	global.drills[uid] = {
		drill = e,
		tracking = 1000,
		drift = 5,
		speed = 0.25
	}
end

function drills.on_tick()
	for k, drill in pairs(global.drills) do
		if drills.is_drill_ready(drill.drill) then
			local roll = math.random(-drill.drift, drill.drift)
			local diff = 1 - (math.abs(drill.tracking - 1000) / 1000)
			local progress = 0

			if diff < 0 then
				diff = 0
			end

			progress = drill.speed * diff / 60

			glog.log("delta-tracking["..k.."] = "..drill.tracking.." + "..roll)

			drill.drill.mining_progress = drill.drill.mining_progress + progress
			drill.tracking = drill.tracking + roll
		end
	end
end

return drills
