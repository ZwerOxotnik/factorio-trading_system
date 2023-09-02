-- This example is for scenarios, but you don't need "control.lua" for mods!


local _is_ok, SELL_PRICE_LIST = pcall(require, "sell_prices_for_trading_system")
if not (_is_ok and type(SELL_PRICE_LIST) == "table") then
	SELL_PRICE_LIST = {}
end
local _is_ok, BUY_PRICE_LIST = pcall(require, "buy_prices_for_trading_system")
if not (_is_ok and type(BUY_PRICE_LIST) == "table") then
	BUY_PRICE_LIST = {}
end

script.on_event(defines.events.on_game_created_from_scenario, function (event)
	local interface = remote.interfaces["trading_system"]
	if interface then
		if interface["set_sell_price_globally"] then
			for name, price in pairs(SELL_PRICE_LIST) do
				remote.call("trading_system", "set_sell_price_globally", name, price)
			end
		else
			log("Error, there's no trading_system.set_sell_price_globally")
		end
		if interface["set_buy_price_globally"] then
			for name, price in pairs(BUY_PRICE_LIST) do
				remote.call("trading_system", "set_buy_price_globally", name, price)
			end
		else
			log("Error, there's no trading_system.set_buy_price_globally")
		end
	end
end)
