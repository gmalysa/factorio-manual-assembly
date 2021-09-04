-- SPDX-License-Identifier: BSD-3-Clause
local controllerprop = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])

-- the connection points are purely visual, constant combinator doesn't have selectable bounding box
-- for connections and doesn't use the i/o props

-- need to move the assembler selection box over slightly so that the combinator can be placed
-- next to it with a different selection box and that lets us access it

controllerprop.type = "constant-combinator"
controllerprop.name = "assembler-controller"
controllerprop.order = "a-controller"
controllerprop.icon = "__base__/graphics/icons/constant-combinator.png"
controllerprop.flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable"}
controllerprop.minable = nil
controllerprop.collision_mask = {}
controllerprop.selection_box = {{0, -1.5}, {0.5, 1.5}}
controllerprop.circuit_wire_connection_points = {
	{
		shadow = {red = {0, 0}, green = {0, 0}},
		wire = {red = {0, 0}, green = {0, 0}}
	},
	{
		shadow = {red = {0, 0}, green = {0, 0}},
		wire = {red = {0, 0}, green = {0, 0}}
	},
	{
		shadow = {red = {0, 0}, green = {0, 0}},
		wire = {red = {0, 0}, green = {0, 0}}
	},
	{
		shadow = {red = {0, 0}, green = {0, 0}},
		wire = {red = {0, 0}, green = {0, 0}}
	}
}
controllerprop.circuit_wire_max_distance = 9

local assembler = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
assembler.name = "manual-assembler"
assembler.minable = {mining_time = 0.2, result = "manual-assembler"}
assembler.energy_usage = "1kW"
assembler.circuit_wire_max_distance = 1
assembler.order = "z-manual-assembler-1"
assembler.selection_box = {{-1.5, -1.5}, {1, 1.5}}

data:extend({
	controllerprop,
	assembler,

	{
		type = "item",
		name = "manual-assembler",
		icon = "__base__/graphics/icons/assembling-machine-1.png",
		icon_size = 64, icon_mipmaps = 4,
		subgroup = "production-machine",
		order = "z-manual-assembler",
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
