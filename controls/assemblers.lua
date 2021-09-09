-- SPDX-License-Identifier: BSD-3-Clause
--

---
 -- A control recipe is a potential sequence of circuit inputs that are needed to
 -- drive an assembler to produce its output
 --

---
 -- Remember that a SignalID is {type=, name=},
 -- and a Signal is {signal=SignalID, count=}
 --

require("util")
local glog = require("scripts.glog")

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

---
 -- Look up a recipe by recipe name and either find it or the null recipe
 -- @param[in] name recipe string name
 -- @return control recipe definition
 --
function this.get_by_name(name)
	return this[name] or this["null-recipe"]
end

local function build_recipe(recipe)
	local mID = id
	id = id + 1
	recipe.id = mID
	this["__recipe-by-id"][recipe.id] = recipe
	return recipe
end

---
 -- Null versions of functions to plug into recipes that don't use them
 --
local function null_init(state)
	state.signals = {}
end
local function null_step() end
local function null_desired() return {} end
local function null_feedback() return {} end

---
 -- Generate the null recipe controller that we expect if no recipe is set for
 -- an assembler
 --
local function generate_null_recipe()
	return build_recipe({
		init = null_init,
		step = null_step,
		desired = null_desired,
		feedback = null_feedback
	})
end

---
 -- Make Signal object from SignalID and count
 --
local function make_signal(id, count)
	return {
		signal = id,
		count = count
	}
end

---
 -- Enable continue operation by driving a single constant signal with the specified
 -- value on it
 --
local function generate_enable_recipe(signal)
	local signals = {signal}
	local desired = {signal}
	desired[1].index = 1

	-- Initialize the state with the required signal array
	local init = function(state)
		state.signals = signals
	end

	-- Next state is same as previous state, these are not dynamic
	local step = function(state)
	end

	-- Obtain the next desired value for this assembler, a constant
	local desiredfn = function(state)
		return desired
	end

	return build_recipe({
		init = init,
		step = step,
		desired = desiredfn,
		feedback = null_feedback
	})
end

---
 -- Sequence recipes are like tier 2, drive them with a specific order of changing
 -- signals to enable the assembler
 -- @param[in] signals Array of signal requirements, where each signal requirement
 --                    is an array of Signals for that stage in sequence
 --
local function generate_sequence_recipe(signals)
	local desired = table.deepcopy(signals)

	-- Format a copy of the signals in each state as combinator parameters
	for _, state in pairs(desired) do
		idx = 1
		for _, v in pairs(state) do
			v.index = idx
			idx = idx + 1
		end
	end

	-- Start in the first state
	local init = function(state)
		state.index = 1
		state.signals = signals[1]
		state.count = table_size(signals)
	end

	-- Loop through states in order
	local step = function(state)
		state.index = state.index + 1
		if state.index > state.count then
			state.index = 1
		end
		state.signals = signals[state.index]
	end

	-- Use precomputed state desired table
	local desiredfn = function(state)
		return desired[state.index]
	end

	return build_recipe({
		init = init,
		step = step,
		desired = desiredfn,
		feedback = null_feedback
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
this["iron-gear-wheel"] = generate_enable_recipe(make_signal(iron_plate, 1))
this["iron-stick"] = generate_enable_recipe(make_signal(iron_plate, 1))
this["copper-cable"] = generate_enable_recipe(make_signal(copper_plate, 1))

this["inserter"] = generate_sequence_recipe({
	{make_signal(iron_plate, 1)},
	{make_signal(copper_plate, 1)}
})

return this
