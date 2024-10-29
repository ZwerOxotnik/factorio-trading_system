local container_template = table.deepcopy(data.raw.market.market)
container_template.type = "container"
container_template.inventory_size = 11
container_template.minable = nil
container_template.name = nil

local hidden_market_template = table.deepcopy(data.raw.market.market)
hidden_market_template.picture = {
	filename = "__core__/graphics/empty.png",
	width  = 1,
	height = 1
}
hidden_market_template.selection_box = {{-1.8, -1.7}, {0.8, 0.9}}
hidden_market_template.collision_box = nil
hidden_market_template.minable = nil
hidden_market_template.name = nil

local market_as_item_template = {
	type = "item",
	icon = "__base__/graphics/icons/market.png",
	icon_size = 64, icon_mipmaps = 4,
	stack_size = 10,
}

local market_recipe_template = {
  type = "recipe",
  enabled = true,
  ingredients = {
	{type = "item", name = "steel-plate",  amount = 100},
	{type = "item", name = "copper-plate", amount = 100}
  },
  energy_required = 15,
}


---@param name string
---@param scale number?
local function create_market(name, scale)
	local market_name = "TSZO_" .. name .. "_container"
	local posfix
	-- if scale == nil then
		posfix = "_3x2"
	-- end
	market_name = market_name .. posfix

	local market_as_container = table.deepcopy(container_template)
	market_as_container.name = market_name
	market_as_container.minable = {mining_time = 1, result = market_name}
	market_as_container.localised_name = {"entity-name.TSZO-" .. name .. "-container"}

	local market_as_item = table.deepcopy(market_as_item_template)
	market_as_item.name = market_name
	market_as_item.place_result = market_name

	local hidden_market = table.deepcopy(hidden_market_template)
	hidden_market.name = "TSZO_hidden_" .. name .. "_market" .. posfix
	hidden_market.localised_name = {"entity-name.TSZO-hidden-" .. name .. "-market"}


	local market_recipe = table.deepcopy(market_recipe_template)
	market_recipe.results = {{type = "item", name = market_name, amount = 1}}
	market_recipe.name = market_name

	data:extend{market_as_container, market_as_item, hidden_market, market_recipe}
end


create_market("sell")
create_market("buy")
