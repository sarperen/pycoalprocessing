Recipe {
    type = "recipe",
    name = "syngas",
    category = "gasifier",
    enabled = "false",
    energy_required = 3,
    ingredients = {
        {type = "fluid", name = "coal-gas", amount = 40},
        {type = "fluid", name = "water", amount = 100}
    },
    results = {
        {type = "fluid", name = "syngas", amount = 70},
        {type = "fluid", name = "tar", amount = 30},
        {type = "item", name = "ash", amount = 1}
    },
    main_product = "syngas",
}

Fluid {
    type = "fluid",
    name = "syngas",
    icon = "__pycoalprocessing__/graphics/icons/syngas.png",
    icon_size = 32,
    default_temperature = 15,
    heat_capacity = "1KJ",
    base_color = {r = 0.8, g = 0.564, b = 0.129},
    flow_color = {r = 0.8, g = 0.564, b = 0.129},
    max_temperature = 100,
    gas_temperature = 15,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    subgroup = "py-syngas",
    order = "a-a-[syn-gas]"
}
