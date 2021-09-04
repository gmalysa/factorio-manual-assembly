-- SPDX-License-Identifier: BSD-3-Clause
--

---
 -- A control recipe is a potential sequence of circuit inputs that are needed to
 -- drive an assembler to produce its output
 --

local this = {}

local id = 0

local function build_recipe(recipe)
	local mID = id
	id = id + 1
	recipe.id = mID
	return recipe
end

local function generate_null_recipe()
	return build_recipe({
		id = mID,
		init = function() end,
		step = function() end
	})
end

---
 -- Enable recipes are the tier 1 of assembler control: drive them with a specific signal
 -- to enable the assembler, usually the single ingredient used
 --
local function generate_enable_recipe(signal)
	-- Initialize the state with the required signal array
	local init = function(state)
		state.signals = {{
			signal = signal,
			value = 1
		}}
	end

	-- Next state is same as previous state, these are not dynamic
	local step = function(state)
	end

	return build_recipe({
		init = init,
		step = step
	})
end

local iron_plate = {
	type = "item",
	name = "iron-plate"
}

local copper_plate = {
	type = "item",
	name = "copper-plate"
}

this["null-recipe"] = generate_null_recipe()
this["iron-gear-wheel"] = generate_enable_recipe(iron_plate)
this["iron-stick"] = generate_enable_recipe(iron_plate)
this["copper-cable"] = generate_enable_recipe(copper_plate)

return this
