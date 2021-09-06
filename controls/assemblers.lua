-- SPDX-License-Identifier: BSD-3-Clause
--

---
 -- A control recipe is a potential sequence of circuit inputs that are needed to
 -- drive an assembler to produce its output
 --

local this = {}

this["__recipe-by-id"] = {}
local id = 0

---
 -- Look up a recipe by id and either find it or the null recipe
 -- @param[in] id recipe id number
 -- @return control recipe definition
 --
function this.get_by_id(id)
	return this["__recipe-by-id"][id] or this["null-recipe"]
end

local function build_recipe(recipe)
	local mID = id
	id = id + 1
	recipe.id = mID
	this["__recipe-by-id"][recipe.id] = recipe
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
 -- Enable recipes are the tier 1 of assembler control: drive them with a specific
 -- signal to enable the assembler, usually the single ingredient used
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

---
 -- Sequence recipes are like tier 2, drive them with a specific order of changing
 -- signals to enable the assembler
 -- @param[in] signals Array of signal requirements, where each signal requirement
 --                    is an array of {signal, value}. So,
 --                    { { {signal, value}, {signal, value} }, { ... }, { ... } }
 --                    for three states, where the first has two required signals
 --
local function generate_sequence_recipe(signals)
	local init = function(state)
		state.index = 1
		state.signals = signals[1]
		state.count = table_size(signals)
	end

	local step = function(state)
		state.index = state.index + 1
		if state.index > state.count then
			state.index = 1
		end
		state.signals = signals[state.index]
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

this["inserter"] = generate_sequence_recipe({
	{{
		signal = iron_plate,
		value = 1
	}},
	{{
		signal = copper_plate,
		value = 1
	}}
})

return this
