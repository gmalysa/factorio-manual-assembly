-- SPDX-License-Identifier: BSD-3-Clause
--

-- @todo
-- general cleanup of this mess
-- assembler sensor node? for reading current status that is not equal to desired

local zerowire = {
	shadow = {red = {0, 0}, green = {0, 0}},
	wire = {red = {0, 0}, green = {0, 0}}
}

local controllerprop = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])

-- the connection points are purely visual, constant combinator doesn't have selectable bounding box
-- for connections and doesn't use the i/o props

controllerprop.name = "assembler-controller"
controllerprop.flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable"}
controllerprop.minable = nil
controllerprop.collision_mask = {}
controllerprop.selection_box = {{0, -0.75}, {0.5, 0.75}}
controllerprop.circuit_wire_connection_points = {
	zerowire, zerowire, zerowire, zerowire
}
controllerprop.circuit_wire_max_distance = 9

local desired = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])

desired.name = "assembler-needs"
controllerprop.flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable"}
controllerprop.minable = nil
controllerprop.collision_mask = {}
controllerprop.selection_box = {{0, -0.75}, {0.5, 0.75}}
controllerprop.circuit_wire_connection_points = {
	zerowire, zerowire, zerowire, zerowire
}
desired.circuit_wire_max_distance = 0

local assembler = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
assembler.name = "manual-assembler"
assembler.minable = {mining_time = 0.2, result = "manual-assembler"}
assembler.selection_box = {{-1.5, -1.5}, {1, 1.5}}

data:extend({
	controllerprop,
	desired,
	assembler,

	{
		type = "item",
		name = "manual-assembler",
		icon = "__base__/graphics/icons/assembling-machine-1.png",
		icon_size = 64, icon_mipmaps = 4,
		subgroup = "production-machine",
		order = "a[manual-assembler-1]",
		place_result = "manual-assembler",
		stack_size = 50
	},

	{
		type = "item",
		name = "assembler-controller",
		icon = "__base__/graphics/icons/constant-combinator.png",
		icon_size = 64, icon_mipmaps = 4,
		subgroup = "production-machine",
		order = "b[assembler-controller-1]",
		place_result = "assembler-controller",
		stack_size = 50
	},

	{
		type = "recipe",
		name = "manual-assembler",
		enabled = true,
		ingredients = {
			{ "iron-plate", 1}
		},
		energy_required = 1,
		result = "manual-assembler"
	}
})

data.raw['mining-drill']['burner-mining-drill'].mining_speed = 0
