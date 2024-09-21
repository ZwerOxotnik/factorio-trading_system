local M = {} -- models/trading_system.can:2
local _mod_data -- models/trading_system.can:9
local _global_sell_prices -- models/trading_system.can:14
local _global_buy_prices -- models/trading_system.can:19
local _sell_prices -- models/trading_system.can:24
local _buy_prices -- models/trading_system.can:29
local _last_sell_id -- models/trading_system.can:33
local _last_buy_id -- models/trading_system.can:37
local _buy_markets -- models/trading_system.can:42
local _sell_markets -- models/trading_system.can:47
local _buy_catalogue -- models/trading_system.can:52
local _sell_catalogue -- models/trading_system.can:57
local _all_markets -- models/trading_system.can:68
local _all_hidden_markets -- models/trading_system.can:78
local tremove = table["remove"] -- models/trading_system.can:84
local call = remote["call"] -- models/trading_system.can:85
local floor = math["floor"] -- models/trading_system.can:86
local print_to_rcon = rcon["print"] -- models/trading_system.can:87
local DESTROY_PARAM = { ["raise_destroy"] = true } -- models/trading_system.can:96
local MARKETS_TYPES = { -- models/trading_system.can:97
	["TSZO_sell_container_3x2"] = 2, -- models/trading_system.can:1
	["TSZO_buy_container_3x2"] = 1 -- models/trading_system.can:1
} -- models/trading_system.can:1
local HIDDEN_MARKETS_TYPES = { -- models/trading_system.can:101
	["TSZO_hidden_sell_market_3x2"] = 2, -- models/trading_system.can:1
	["TSZO_hidden_buy_market_3x2"] = 1 -- models/trading_system.can:1
} -- models/trading_system.can:1
local MARKETS_TO_HIDDEN = { -- models/trading_system.can:105
	["TSZO_sell_container_3x2"] = "TSZO_hidden_sell_market_3x2", -- models/trading_system.can:106
	["TSZO_buy_container_3x2"] = "TSZO_hidden_buy_market_3x2" -- models/trading_system.can:107
} -- models/trading_system.can:107
local DEFAULT_SELL_PRICES = {} -- models/trading_system.can:111
for mod_name in pairs(script["active_mods"]) do -- models/trading_system.can:112
	local _is_ok, _price_list = pcall(require, string["format"]("__%s__/sell_prices_for_trading_system", mod_name)) -- models/trading_system.can:113
	if _is_ok and type(_price_list) == "table" then -- models/trading_system.can:114
		for name, price in pairs(_price_list) do -- models/trading_system.can:115
			if type(name) == "string" and type(price) == "number" and price >= 1 then -- models/trading_system.can:116
				DEFAULT_SELL_PRICES[name] = math["floor"](price) -- models/trading_system.can:117
			end -- models/trading_system.can:117
		end -- models/trading_system.can:117
	end -- models/trading_system.can:117
end -- models/trading_system.can:117
local DEFAULT_BUY_PRICES = {} -- models/trading_system.can:124
for mod_name in pairs(script["active_mods"]) do -- models/trading_system.can:125
	local _is_ok, _price_list = pcall(require, string["format"]("__%s__/buy_prices_for_trading_system", mod_name)) -- models/trading_system.can:126
	if _is_ok and type(_price_list) == "table" then -- models/trading_system.can:127
		for name, price in pairs(_price_list) do -- models/trading_system.can:128
			if type(name) == "string" and type(price) == "number" and price >= 1 then -- models/trading_system.can:129
				DEFAULT_BUY_PRICES[name] = math["floor"](price) -- models/trading_system.can:130
			end -- models/trading_system.can:130
		end -- models/trading_system.can:130
	end -- models/trading_system.can:130
end -- models/trading_system.can:130
local _update_buy_tick = settings["global"]["TSZO_update-buy-tick"]["value"] -- models/trading_system.can:140
local _update_sell_tick = settings["global"]["TSZO_update-sell-tick"]["value"] -- models/trading_system.can:141
local _buy_stack = { -- models/trading_system.can:147
	["name"] = "", -- models/trading_system.can:147
	["count"] = 0 -- models/trading_system.can:147
} -- models/trading_system.can:147
local _sell_stack = { -- models/trading_system.can:151
	["name"] = "", -- models/trading_system.can:151
	["count"] = 4000000000 -- models/trading_system.can:151
} -- models/trading_system.can:151
print_force_data = function(target, getter) -- models/trading_system.can:158
	if getter then -- models/trading_system.can:159
		if not getter["valid"] then -- models/trading_system.can:160
			log("Invalid object") -- models/trading_system.can:161
			return  -- models/trading_system.can:162
		end -- models/trading_system.can:162
	else -- models/trading_system.can:162
		getter = game -- models/trading_system.can:165
	end -- models/trading_system.can:165
	local index -- models/trading_system.can:168
	local object_name = target["object_name"] -- models/trading_system.can:169
	if object_name == "LuaPlayer" then -- models/trading_system.can:170
		index = target["force_index"] -- models/trading_system.can:171
	elseif object_name == "LuaForce" then -- models/trading_system.can:172
		index = target["index"] -- models/trading_system.can:173
	else -- models/trading_system.can:173
		log("Invalid type") -- models/trading_system.can:175
		return  -- models/trading_system.can:176
	end -- models/trading_system.can:176
	local print_to_target = getter["print"] -- models/trading_system.can:179
	print_to_target("") -- models/trading_system.can:180
	print_to_target("Sell prices:" .. serpent["line"](_sell_prices[index])) -- models/trading_system.can:181
	print_to_target("Buy prices:" .. serpent["line"](_buy_prices[index])) -- models/trading_system.can:182
	print_to_target("Sell markets:" .. serpent["line"](_sell_markets[index])) -- models/trading_system.can:183
	print_to_target("Buy markets:" .. serpent["line"](_buy_markets[index])) -- models/trading_system.can:184
	print_to_target("Sell catalogue:" .. serpent["line"](_sell_catalogue[index])) -- models/trading_system.can:185
	print_to_target("Buy catalogue:" .. serpent["line"](_buy_catalogue[index])) -- models/trading_system.can:186
	print_to_target("_last_sell_id:" .. tostring(_last_sell_id[index] or "")) -- models/trading_system.can:187
	print_to_target("_last_buy_id:" .. tostring(_last_buy_id[index] or "")) -- models/trading_system.can:188
end -- models/trading_system.can:188
check_local_and_global_data = function(local_data, global_data_name, receiver) -- models/trading_system.can:196
	if (type(global_data_name) == "string" and local_data ~= global["TSZO"][global_data_name]) then -- models/trading_system.can:197
		local message = string["format"]("!WARNING! Desync has been detected in __%s__ %s. Please report and send log files to %s and try to load your game again or use /sync", script["mod_name"], "mod_data[\"" .. global_data_name .. "\"]", "ZwerOxotnik") -- models/trading_system.can:198
		log(message) -- models/trading_system.can:199
		if game and (game["is_multiplayer"]() == false or receiver) then -- models/trading_system.can:200
			message = { -- models/trading_system.can:201
				"EasyAPI.report-desync", -- models/trading_system.can:201
				script["mod_name"], -- models/trading_system.can:202
				"mod_data[\"" .. global_data_name .. "\"]", -- models/trading_system.can:202
				"ZwerOxotnik" -- models/trading_system.can:202
			} -- models/trading_system.can:202
			receiver = receiver or game -- models/trading_system.can:204
			receiver["print"](message) -- models/trading_system.can:205
		end -- models/trading_system.can:205
		return true -- models/trading_system.can:207
	end -- models/trading_system.can:207
	return false -- models/trading_system.can:209
end -- models/trading_system.can:209
detect_desync = function(receiver) -- models/trading_system.can:214
	check_local_and_global_data(_sell_prices, "sell_prices", receiver) -- models/trading_system.can:215
	check_local_and_global_data(_buy_prices, "buy_prices", receiver) -- models/trading_system.can:216
	check_local_and_global_data(_buy_markets, "buy_markets", receiver) -- models/trading_system.can:217
	check_local_and_global_data(_sell_markets, "sell_markets", receiver) -- models/trading_system.can:218
	check_local_and_global_data(_buy_catalogue, "buy_catalogue", receiver) -- models/trading_system.can:219
	check_local_and_global_data(_sell_catalogue, "sell_catalogue", receiver) -- models/trading_system.can:220
	check_local_and_global_data(_last_sell_id, "last_sell_id", receiver) -- models/trading_system.can:221
	check_local_and_global_data(_last_buy_id, "last_buy_id", receiver) -- models/trading_system.can:222
	check_local_and_global_data(_global_sell_prices, "global_sell_prices", receiver) -- models/trading_system.can:223
	check_local_and_global_data(_global_buy_prices, "global_buy_prices", receiver) -- models/trading_system.can:224
	check_local_and_global_data(_all_markets, "all_markets", receiver) -- models/trading_system.can:225
	check_local_and_global_data(_all_hidden_markets, "all_hidden_markets", receiver) -- models/trading_system.can:226
end -- models/trading_system.can:226
getRconData = function(name) -- models/trading_system.can:235
	print_to_rcon(game["table_to_json"](_mod_data[name])) -- models/trading_system.can:236
end -- models/trading_system.can:236
getRconForceData = function(name, force) -- models/trading_system.can:241
	if not force["valid"] then -- models/trading_system.can:242
		return  -- models/trading_system.can:242
	end -- models/trading_system.can:242
	print_to_rcon(game["table_to_json"](_mod_data[name][force["index"]])) -- models/trading_system.can:243
end -- models/trading_system.can:243
getRconForceDataByIndex = function(name, force_index) -- models/trading_system.can:248
	print_to_rcon(game["table_to_json"](_mod_data[name][force_index])) -- models/trading_system.can:249
end -- models/trading_system.can:249
import_global_prices = function(json_text, table_data) -- models/trading_system.can:260
	local table_data = table_data or game["json_to_table"](json_text) -- models/trading_system.can:261
	if table_data == nil or type(table_data) ~= "table" then -- models/trading_system.can:262
		return  -- models/trading_system.can:262
	end -- models/trading_system.can:262
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:264
	if table_data["global_buy_prices"] then -- models/trading_system.can:265
		local new_prices = table_data["global_buy_prices"] -- models/trading_system.can:266
		for item_name in pairs(new_prices) do -- models/trading_system.can:267
			if not item_prototypes[item_name] then -- models/trading_system.can:268
				new_prices[item_name] = nil -- models/trading_system.can:269
			end -- models/trading_system.can:269
		end -- models/trading_system.can:269
		_mod_data["global_buy_prices"] = new_prices -- models/trading_system.can:273
		_global_buy_prices = _mod_data["global_buy_prices"] -- models/trading_system.can:274
		for force_index in pairs(_buy_markets) do -- models/trading_system.can:276
			_buy_markets[force_index] = {} -- models/trading_system.can:277
		end -- models/trading_system.can:277
		for force_index in pairs(_buy_prices) do -- models/trading_system.can:280
			local new_price_list = { nil } -- models/trading_system.can:282
			for item_name, price in pairs(new_prices) do -- models/trading_system.can:283
				new_price_list[item_name] = price -- models/trading_system.can:284
			end -- models/trading_system.can:284
			_buy_prices[force_index] = new_price_list -- models/trading_system.can:286
		end -- models/trading_system.can:286
		for force_index in pairs(_buy_catalogue) do -- models/trading_system.can:289
			local new_catalogue = { nil } -- models/trading_system.can:291
			for item_name in pairs(new_prices) do -- models/trading_system.can:292
				new_catalogue[# new_catalogue + 1] = item_name -- models/trading_system.can:293
			end -- models/trading_system.can:293
			_buy_catalogue[force_index] = new_catalogue -- models/trading_system.can:295
			_last_buy_id[force_index] = _last_buy_id[force_index] + 1 -- models/trading_system.can:296
		end -- models/trading_system.can:296
		for _, market_data in pairs(_all_markets) do -- models/trading_system.can:299
			if market_data[3] == 1 then -- models/trading_system.can:1
				local market = market_data[2] -- models/trading_system.can:301
				local item_name = market_data[4] -- models/trading_system.can:302
				if item_name then -- models/trading_system.can:303
					if new_prices[item_name] then -- models/trading_system.can:304
						M["set_force_buy_market"](item_name, market_data[1]) -- models/trading_system.can:305
					else -- models/trading_system.can:305
						market_data[4] = nil -- models/trading_system.can:307
					end -- models/trading_system.can:307
				end -- models/trading_system.can:307
				_all_hidden_markets[market["unit_number"]][3] = nil -- models/trading_system.can:310
			end -- models/trading_system.can:310
		end -- models/trading_system.can:310
	end -- models/trading_system.can:310
	if table_data["global_sell_prices"] then -- models/trading_system.can:315
		local new_prices = table_data["global_sell_prices"] -- models/trading_system.can:316
		for item_name in pairs(new_prices) do -- models/trading_system.can:317
			if not item_prototypes[item_name] then -- models/trading_system.can:318
				new_prices[item_name] = nil -- models/trading_system.can:319
			end -- models/trading_system.can:319
		end -- models/trading_system.can:319
		_mod_data["global_sell_prices"] = new_prices -- models/trading_system.can:323
		_global_sell_prices = _mod_data["global_sell_prices"] -- models/trading_system.can:324
		for force_index in pairs(_sell_markets) do -- models/trading_system.can:326
			_sell_markets[force_index] = {} -- models/trading_system.can:327
		end -- models/trading_system.can:327
		for force_index in pairs(_sell_prices) do -- models/trading_system.can:330
			local new_price_list = { nil } -- models/trading_system.can:332
			for item_name, price in pairs(new_prices) do -- models/trading_system.can:333
				new_price_list[item_name] = price -- models/trading_system.can:334
			end -- models/trading_system.can:334
			_sell_prices[force_index] = new_price_list -- models/trading_system.can:336
		end -- models/trading_system.can:336
		for force_index in pairs(_sell_catalogue) do -- models/trading_system.can:339
			local new_catalogue = { nil } -- models/trading_system.can:341
			for item_name in pairs(new_prices) do -- models/trading_system.can:342
				new_catalogue[# new_catalogue + 1] = item_name -- models/trading_system.can:343
			end -- models/trading_system.can:343
			_sell_catalogue[force_index] = new_catalogue -- models/trading_system.can:345
			_last_sell_id[force_index] = _last_sell_id[force_index] + 1 -- models/trading_system.can:346
		end -- models/trading_system.can:346
		for _, market_data in pairs(_all_markets) do -- models/trading_system.can:349
			if market_data[3] == 2 then -- models/trading_system.can:1
				local market = market_data[2] -- models/trading_system.can:351
				local item_name = market_data[4] -- models/trading_system.can:352
				if item_name then -- models/trading_system.can:353
					if new_prices[item_name] then -- models/trading_system.can:354
						M["set_force_sell_market"](item_name, market_data[1]) -- models/trading_system.can:355
					else -- models/trading_system.can:355
						market_data[4] = nil -- models/trading_system.can:357
					end -- models/trading_system.can:357
				end -- models/trading_system.can:357
				_all_hidden_markets[market["unit_number"]][3] = nil -- models/trading_system.can:360
			end -- models/trading_system.can:360
		end -- models/trading_system.can:360
	end -- models/trading_system.can:360
end -- models/trading_system.can:360
clear_force_data = function(index) -- models/trading_system.can:368
	local force = game["forces"][index] -- models/trading_system.can:369
	if force then -- models/trading_system.can:370
		for _, market_data in pairs(_all_markets) do -- models/trading_system.can:371
			local storage = market_data[1] -- models/trading_system.can:372
			if storage["valid"] and storage["force"] == force then -- models/trading_system.can:373
				local market = market_data[2] -- models/trading_system.can:374
				if market["valid"] then -- models/trading_system.can:375
					_all_hidden_markets[market["unit_number"]][3] = nil -- models/trading_system.can:376
				end -- models/trading_system.can:376
				market_data[4] = nil -- models/trading_system.can:378
			end -- models/trading_system.can:378
		end -- models/trading_system.can:378
	end -- models/trading_system.can:378
	_buy_catalogue[index] = nil -- models/trading_system.can:383
	_sell_catalogue[index] = nil -- models/trading_system.can:384
	_sell_prices[index] = nil -- models/trading_system.can:385
	_buy_prices[index] = nil -- models/trading_system.can:386
	_buy_markets[index] = nil -- models/trading_system.can:387
	_sell_markets[index] = nil -- models/trading_system.can:388
	_last_sell_id[index] = nil -- models/trading_system.can:389
	_last_buy_id[index] = nil -- models/trading_system.can:390
end -- models/trading_system.can:390
init_force_data = function(index) -- models/trading_system.can:395
	_buy_catalogue[index] = _buy_catalogue[index] or {} -- models/trading_system.can:396
	_sell_catalogue[index] = _sell_catalogue[index] or {} -- models/trading_system.can:397
	_sell_prices[index] = _sell_prices[index] or {} -- models/trading_system.can:398
	_buy_prices[index] = _buy_prices[index] or {} -- models/trading_system.can:399
	_buy_markets[index] = _buy_markets[index] or {} -- models/trading_system.can:400
	_sell_markets[index] = _sell_markets[index] or {} -- models/trading_system.can:401
	_last_sell_id[index] = _last_sell_id[index] or 0 -- models/trading_system.can:402
	_last_buy_id[index] = _last_buy_id[index] or 0 -- models/trading_system.can:403
end -- models/trading_system.can:403
disable_mod_recipes = function(force_index) -- models/trading_system.can:409
	_mod_data["is_recipes_disabled"] = false -- models/trading_system.can:410
	if force_index == nil then -- models/trading_system.can:412
		for _, force in pairs(game["forces"]) do -- models/trading_system.can:413
			force["recipes"]["TSZO_sell_container_3x2"]["enabled"] = false -- models/trading_system.can:414
			force["recipes"]["TSZO_buy_container_3x2"]["enabled"] = false -- models/trading_system.can:415
		end -- models/trading_system.can:415
	end -- models/trading_system.can:415
	local force = game["forces"][force_index] -- models/trading_system.can:419
	if not (force and force["valid"]) then -- models/trading_system.can:420
		return  -- models/trading_system.can:420
	end -- models/trading_system.can:420
	force["recipes"]["TSZO_sell_container_3x2"]["enabled"] = false -- models/trading_system.can:421
	force["recipes"]["TSZO_buy_container_3x2"]["enabled"] = false -- models/trading_system.can:422
end -- models/trading_system.can:422
enable_mod_recipes = function(force_index) -- models/trading_system.can:428
	_mod_data["is_recipes_disabled"] = true -- models/trading_system.can:429
	if force_index == nil then -- models/trading_system.can:431
		for _, force in pairs(game["forces"]) do -- models/trading_system.can:432
			force["recipes"]["TSZO_sell_container_3x2"]["enabled"] = true -- models/trading_system.can:433
			force["recipes"]["TSZO_buy_container_3x2"]["enabled"] = true -- models/trading_system.can:434
		end -- models/trading_system.can:434
	end -- models/trading_system.can:434
	local force = game["forces"][force_index] -- models/trading_system.can:438
	if not (force and force["valid"]) then -- models/trading_system.can:439
		return  -- models/trading_system.can:439
	end -- models/trading_system.can:439
	force["recipes"]["TSZO_sell_container_3x2"]["enabled"] = true -- models/trading_system.can:440
	force["recipes"]["TSZO_buy_container_3x2"]["enabled"] = true -- models/trading_system.can:441
end -- models/trading_system.can:441
M["find_item_in_text"] = function(text) -- models/trading_system.can:447
	local args = {} -- models/trading_system.can:448
	for arg in string["gmatch"](text, "%g+") do -- models/trading_system.can:449
		args[# args + 1] = arg -- models/trading_system.can:449
	end -- models/trading_system.can:449
	local item_name -- models/trading_system.can:451
	local count_index = 1 -- models/trading_system.can:452
	local count = tonumber(args[count_index]) -- models/trading_system.can:453
	if count == nil then -- models/trading_system.can:454
		count_index = 2 -- models/trading_system.can:455
		count = tonumber(args[count_index]) -- models/trading_system.can:456
	end -- models/trading_system.can:456
	if count == nil then -- models/trading_system.can:460
		item_name = text -- models/trading_system.can:461
	else -- models/trading_system.can:461
		if count_index == 1 then -- models/trading_system.can:463
			item_name = args[2] -- models/trading_system.can:464
		elseif count_index == 2 then -- models/trading_system.can:465
			item_name = args[1] -- models/trading_system.can:466
		end -- models/trading_system.can:466
	end -- models/trading_system.can:466
	local prototype = game["item_prototypes"][item_name] -- models/trading_system.can:470
	if prototype == nil then -- models/trading_system.can:471
		item_name = string["gsub"](item_name, ".*%[item=(.+)%].*", "%1") -- models/trading_system.can:472
		if item_name == nil then -- models/trading_system.can:473
			return  -- models/trading_system.can:474
		end -- models/trading_system.can:474
		prototype = game["item_prototypes"][item_name] -- models/trading_system.can:476
		if prototype == nil then -- models/trading_system.can:477
			return  -- models/trading_system.can:478
		end -- models/trading_system.can:478
	end -- models/trading_system.can:478
	if count and count <= 0 then -- models/trading_system.can:481
		count = nil -- models/trading_system.can:482
	end -- models/trading_system.can:482
	return item_name, count -- models/trading_system.can:485
end -- models/trading_system.can:485
set_buy_price_globally = function(item_name, price) -- models/trading_system.can:491
	_global_buy_prices[item_name] = price -- models/trading_system.can:492
	for force_index in pairs(_buy_prices) do -- models/trading_system.can:493
		set_force_buy_price(force_index, item_name, price) -- models/trading_system.can:494
	end -- models/trading_system.can:494
end -- models/trading_system.can:494
set_sell_price_globally = function(item_name, price) -- models/trading_system.can:501
	_global_sell_prices[item_name] = price -- models/trading_system.can:502
	for force_index in pairs(_sell_prices) do -- models/trading_system.can:503
		set_force_sell_price(force_index, item_name, price) -- models/trading_system.can:504
	end -- models/trading_system.can:504
end -- models/trading_system.can:504
set_force_sell_price = function(force_index, item_name, price) -- models/trading_system.can:512
	local f_sell_prices = _sell_prices[force_index] -- models/trading_system.can:513
	if f_sell_prices == nil then -- models/trading_system.can:514
		return  -- models/trading_system.can:514
	end -- models/trading_system.can:514
	local prev_price = f_sell_prices[item_name] -- models/trading_system.can:517
	f_sell_prices[item_name] = price -- models/trading_system.can:518
	if (prev_price == nil and price) or (prev_price and price == nil) then -- models/trading_system.can:519
		local new_catalogue = { nil } -- models/trading_system.can:521
		local prices = _sell_prices[force_index] -- models/trading_system.can:522
		for _item_name in pairs(prices) do -- models/trading_system.can:523
			new_catalogue[# new_catalogue + 1] = _item_name -- models/trading_system.can:524
		end -- models/trading_system.can:524
		_sell_catalogue[force_index] = new_catalogue -- models/trading_system.can:526
	end -- models/trading_system.can:526
	if price == nil then -- models/trading_system.can:529
		local markets = _sell_markets[force_index] -- models/trading_system.can:530
		if markets and markets[item_name] then -- models/trading_system.can:531
			markets[item_name] = nil -- models/trading_system.can:532
		end -- models/trading_system.can:532
	end -- models/trading_system.can:532
	_last_sell_id[force_index] = _last_sell_id[force_index] + 1 -- models/trading_system.can:536
end -- models/trading_system.can:536
set_force_buy_price = function(force_index, item_name, price) -- models/trading_system.can:543
	local f_buy_prices = _buy_prices[force_index] -- models/trading_system.can:544
	if f_buy_prices == nil then -- models/trading_system.can:545
		return  -- models/trading_system.can:545
	end -- models/trading_system.can:545
	local prev_price = f_buy_prices[item_name] -- models/trading_system.can:547
	f_buy_prices[item_name] = price -- models/trading_system.can:548
	if prev_price == nil and price or prev_price and price == nil then -- models/trading_system.can:549
		local new_catalogue = { nil } -- models/trading_system.can:551
		local prices = _buy_prices[force_index] -- models/trading_system.can:552
		for _item_name in pairs(prices) do -- models/trading_system.can:553
			new_catalogue[# new_catalogue + 1] = _item_name -- models/trading_system.can:554
		end -- models/trading_system.can:554
		_buy_catalogue[force_index] = new_catalogue -- models/trading_system.can:556
	end -- models/trading_system.can:556
	if price == nil then -- models/trading_system.can:559
		local markets = _buy_markets[force_index] -- models/trading_system.can:560
		if markets and markets[item_name] then -- models/trading_system.can:561
			markets[item_name] = nil -- models/trading_system.can:562
		end -- models/trading_system.can:562
	end -- models/trading_system.can:562
	_last_buy_id[force_index] = _last_buy_id[force_index] + 1 -- models/trading_system.can:566
end -- models/trading_system.can:566
M["remove_hidden_market"] = function(entity) -- models/trading_system.can:571
	if entity["valid"] then -- models/trading_system.can:572
		_all_hidden_markets[entity["unit_number"]] = nil -- models/trading_system.can:573
		entity["destroy"](DESTROY_PARAM) -- models/trading_system.can:574
	end -- models/trading_system.can:574
end -- models/trading_system.can:574
M["remove_market_from_markets"] = function(entity, markets_data, market_data) -- models/trading_system.can:582
	local force_index = entity["force_index"] -- models/trading_system.can:583
	market_data = market_data or _all_markets[entity["force_index"]] -- models/trading_system.can:584
	local item_name = market_data[4] -- models/trading_system.can:585
	if item_name == nil then -- models/trading_system.can:586
		return  -- models/trading_system.can:586
	end -- models/trading_system.can:586
	local markets = markets_data[force_index] -- models/trading_system.can:587
	local entities = markets[item_name] -- models/trading_system.can:588
	if entities == nil then -- models/trading_system.can:589
		return  -- models/trading_system.can:589
	end -- models/trading_system.can:589
	for i = # entities, 1, - 1 do -- models/trading_system.can:591
		if entities[i] == entity then -- models/trading_system.can:592
			if # entities == 1 then -- models/trading_system.can:593
				markets[item_name] = nil -- models/trading_system.can:594
			else -- models/trading_system.can:594
				tremove(entities, i) -- models/trading_system.can:596
			end -- models/trading_system.can:596
			return  -- models/trading_system.can:598
		end -- models/trading_system.can:598
	end -- models/trading_system.can:598
end -- models/trading_system.can:598
M["remove_certain_buy_market"] = function(entity, market_data) -- models/trading_system.can:606
	_all_markets[entity["unit_number"]] = nil -- models/trading_system.can:607
	M["remove_market_from_markets"](entity, _buy_markets, market_data) -- models/trading_system.can:608
	M["remove_hidden_market"](market_data[2]) -- models/trading_system.can:609
end -- models/trading_system.can:609
M["remove_certain_sell_market"] = function(entity, market_data) -- models/trading_system.can:615
	_all_markets[entity["unit_number"]] = nil -- models/trading_system.can:616
	M["remove_market_from_markets"](entity, _sell_markets, market_data) -- models/trading_system.can:617
	M["remove_hidden_market"](market_data[2]) -- models/trading_system.can:618
end -- models/trading_system.can:618
local function clear_invalid_global_prices(prices) -- models/trading_system.can:623
	if prices == nil then -- models/trading_system.can:624
		clear_invalid_global_prices(_global_sell_prices) -- models/trading_system.can:625
		clear_invalid_global_prices(_global_buy_prices) -- models/trading_system.can:626
		return  -- models/trading_system.can:627
	end -- models/trading_system.can:627
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:631
	for item_name in pairs(prices) do -- models/trading_system.can:632
		if item_prototypes[item_name] == nil then -- models/trading_system.can:633
			prices[item_name] = nil -- models/trading_system.can:634
		end -- models/trading_system.can:634
	end -- models/trading_system.can:634
end -- models/trading_system.can:634
local function clear_invalid_prices(prices) -- models/trading_system.can:641
	if prices == nil then -- models/trading_system.can:642
		clear_invalid_prices(_buy_prices) -- models/trading_system.can:643
		clear_invalid_prices(_sell_prices) -- models/trading_system.can:644
		return  -- models/trading_system.can:645
	end -- models/trading_system.can:645
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:649
	local forces = game["forces"] -- models/trading_system.can:650
	for index, forces_data in pairs(prices) do -- models/trading_system.can:651
		if forces[index] == nil then -- models/trading_system.can:652
			prices[index] = nil -- models/trading_system.can:653
		else -- models/trading_system.can:653
			for item_name in pairs(forces_data) do -- models/trading_system.can:655
				if item_prototypes[item_name] == nil then -- models/trading_system.can:656
					forces_data[item_name] = nil -- models/trading_system.can:657
				end -- models/trading_system.can:657
			end -- models/trading_system.can:657
		end -- models/trading_system.can:657
	end -- models/trading_system.can:657
end -- models/trading_system.can:657
clear_invalid_markets_data = function(markets) -- models/trading_system.can:666
	if markets == nil then -- models/trading_system.can:667
		clear_invalid_markets_data(_sell_markets) -- models/trading_system.can:668
		clear_invalid_markets_data(_buy_markets) -- models/trading_system.can:669
		return  -- models/trading_system.can:670
	end -- models/trading_system.can:670
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:674
	local forces = game["forces"] -- models/trading_system.can:675
	for force_index, force_data in pairs(markets) do -- models/trading_system.can:676
		if forces[force_index] == nil then -- models/trading_system.can:677
			clear_force_data(force_index) -- models/trading_system.can:678
		else -- models/trading_system.can:678
			for item_name, entities in pairs(force_data) do -- models/trading_system.can:680
				if item_prototypes[item_name] == nil then -- models/trading_system.can:681
					force_data[item_name] = nil -- models/trading_system.can:682
					goto continue -- models/trading_system.can:683
				end -- models/trading_system.can:683
				for i = # entities, 1, - 1 do -- models/trading_system.can:685
					local entity = entities[i] -- models/trading_system.can:686
					if entity["valid"] == false then -- models/trading_system.can:687
						tremove(entities, i) -- models/trading_system.can:688
					else -- models/trading_system.can:688
						local _market_data = _all_markets[entity["unit_number"]] -- models/trading_system.can:690
						if _market_data == nil then -- models/trading_system.can:691
							tremove(entities, i) -- models/trading_system.can:692
						elseif entity ~= _market_data[1] then -- models/trading_system.can:693
							_all_markets[entity["unit_number"]] = nil -- models/trading_system.can:694
							tremove(entities, i) -- models/trading_system.can:695
						end -- models/trading_system.can:695
					end -- models/trading_system.can:695
				end -- models/trading_system.can:695
				if # entities == 0 then -- models/trading_system.can:699
					force_data[item_name] = nil -- models/trading_system.can:700
				end -- models/trading_system.can:700
				::continue:: -- models/trading_system.can:702
			end -- models/trading_system.can:702
		end -- models/trading_system.can:702
	end -- models/trading_system.can:702
end -- models/trading_system.can:702
clear_invalid_catalogue = function(catalogue) -- models/trading_system.can:709
	if catalogue == nil then -- models/trading_system.can:710
		clear_invalid_catalogue(_sell_catalogue) -- models/trading_system.can:711
		clear_invalid_catalogue(_buy_catalogue) -- models/trading_system.can:712
		return  -- models/trading_system.can:713
	end -- models/trading_system.can:713
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:717
	local forces = game["forces"] -- models/trading_system.can:718
	for index, items in pairs(catalogue) do -- models/trading_system.can:719
		if forces[index] == nil then -- models/trading_system.can:720
			catalogue[index] = nil -- models/trading_system.can:721
			goto continue -- models/trading_system.can:722
		end -- models/trading_system.can:722
		for i = # items, 1, - 1 do -- models/trading_system.can:724
			local item_name = items[i] -- models/trading_system.can:725
			if item_prototypes[item_name] == nil then -- models/trading_system.can:726
				tremove(items, i) -- models/trading_system.can:727
			end -- models/trading_system.can:727
		end -- models/trading_system.can:727
		::continue:: -- models/trading_system.can:730
	end -- models/trading_system.can:730
end -- models/trading_system.can:730
clear_invalid_entities = function() -- models/trading_system.can:734
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:735
	for unit_number, data in pairs(_all_markets) do -- models/trading_system.can:736
		local storage = data[1] -- models/trading_system.can:737
		if not storage["valid"] then -- models/trading_system.can:738
			_all_markets[unit_number] = nil -- models/trading_system.can:739
		elseif not data[2]["valid"] then -- models/trading_system.can:740
			M["remove_hidden_market"](data[2]) -- models/trading_system.can:741
			_all_markets[unit_number] = nil -- models/trading_system.can:742
		else -- models/trading_system.can:742
			local item_name = data[4] -- models/trading_system.can:744
			if item_name and item_prototypes[item_name] == nil then -- models/trading_system.can:745
				local market_type = data[3] -- models/trading_system.can:746
				if market_type == 1 then -- models/trading_system.can:1
					M["remove_market_from_markets"](storage, _buy_markets, data) -- models/trading_system.can:748
				elseif market_type == 2 then -- models/trading_system.can:1
					M["remove_market_from_markets"](storage, _sell_markets, data) -- models/trading_system.can:750
				end -- models/trading_system.can:750
				data[4] = nil -- models/trading_system.can:752
			end -- models/trading_system.can:752
		end -- models/trading_system.can:752
	end -- models/trading_system.can:752
	for unit_number, data in pairs(_all_hidden_markets) do -- models/trading_system.can:757
		local market = data[1] -- models/trading_system.can:758
		if not market["valid"] or not data[2]["valid"] then -- models/trading_system.can:759
			_all_hidden_markets[unit_number] = nil -- models/trading_system.can:760
		end -- models/trading_system.can:760
	end -- models/trading_system.can:760
	clear_invalid_markets_data() -- models/trading_system.can:764
end -- models/trading_system.can:764
clear_invalid_data = function() -- models/trading_system.can:768
	clear_invalid_global_prices() -- models/trading_system.can:769
	clear_invalid_prices() -- models/trading_system.can:770
	clear_invalid_catalogue() -- models/trading_system.can:771
	clear_invalid_entities() -- models/trading_system.can:772
end -- models/trading_system.can:772
M["create_force_market"] = function(storage, market_type) -- models/trading_system.can:778
	local hidden_market = storage["surface"]["create_entity"]({ -- models/trading_system.can:779
		["name"] = MARKETS_TO_HIDDEN[storage["name"]], -- models/trading_system.can:780
		["force"] = storage["force"], -- models/trading_system.can:781
		["position"] = storage["position"] -- models/trading_system.can:782
	}) -- models/trading_system.can:782
	hidden_market["minable"] = false -- models/trading_system.can:784
	hidden_market["destructible"] = false -- models/trading_system.can:785
	hidden_market["rotatable"] = false -- models/trading_system.can:786
	_all_markets[storage["unit_number"]] = { -- models/trading_system.can:788
		storage, -- models/trading_system.can:789
		hidden_market, -- models/trading_system.can:789
		market_type, -- models/trading_system.can:789
		nil -- models/trading_system.can:789
	} -- models/trading_system.can:789
	_all_hidden_markets[hidden_market["unit_number"]] = { -- models/trading_system.can:791
		hidden_market, -- models/trading_system.can:792
		storage, -- models/trading_system.can:792
		nil -- models/trading_system.can:792
	} -- models/trading_system.can:792
end -- models/trading_system.can:792
M["set_force_buy_market"] = function(item_name, entity, count) -- models/trading_system.can:800
	local market_data = _all_markets[entity["unit_number"]] -- models/trading_system.can:803
	local force_index = entity["force"]["index"] -- models/trading_system.can:804
	local f_buy_markets = _buy_markets[force_index] -- models/trading_system.can:805
	local prev_item_name = market_data[4] -- models/trading_system.can:806
	if prev_item_name then -- models/trading_system.can:807
		if prev_item_name == item_name then -- models/trading_system.can:808
			return  -- models/trading_system.can:808
		end -- models/trading_system.can:808
		local _entities = f_buy_markets[prev_item_name] -- models/trading_system.can:809
		for i = # _entities, 1, - 1 do -- models/trading_system.can:810
			if _entities[i] == entity then -- models/trading_system.can:811
				if # _entities == 1 then -- models/trading_system.can:812
					f_buy_markets[prev_item_name] = nil -- models/trading_system.can:813
				else -- models/trading_system.can:813
					tremove(_entities, i) -- models/trading_system.can:815
				end -- models/trading_system.can:815
				break -- models/trading_system.can:817
			end -- models/trading_system.can:817
		end -- models/trading_system.can:817
	end -- models/trading_system.can:817
	local entities = f_buy_markets[item_name] -- models/trading_system.can:822
	if entities == nil then -- models/trading_system.can:823
		f_buy_markets[item_name] = { entity } -- models/trading_system.can:824
	else -- models/trading_system.can:824
		entities[# entities + 1] = entity -- models/trading_system.can:826
	end -- models/trading_system.can:826
	market_data[4] = item_name -- models/trading_system.can:829
end -- models/trading_system.can:829
M["set_force_sell_market"] = function(item_name, entity) -- models/trading_system.can:835
	local market_data = _all_markets[entity["unit_number"]] -- models/trading_system.can:836
	local force_index = entity["force"]["index"] -- models/trading_system.can:837
	local f_sell_markets = _sell_markets[force_index] -- models/trading_system.can:838
	local prev_item_name = market_data[4] -- models/trading_system.can:839
	if prev_item_name then -- models/trading_system.can:840
		if prev_item_name == item_name then -- models/trading_system.can:841
			return  -- models/trading_system.can:841
		end -- models/trading_system.can:841
		local _entities = f_sell_markets[prev_item_name] -- models/trading_system.can:842
		for i = # _entities, 1, - 1 do -- models/trading_system.can:843
			if _entities[i] == entity then -- models/trading_system.can:844
				if # _entities == 1 then -- models/trading_system.can:845
					f_sell_markets[prev_item_name] = nil -- models/trading_system.can:846
				else -- models/trading_system.can:846
					tremove(_entities, i) -- models/trading_system.can:848
				end -- models/trading_system.can:848
				break -- models/trading_system.can:850
			end -- models/trading_system.can:850
		end -- models/trading_system.can:850
	end -- models/trading_system.can:850
	local entities = f_sell_markets[item_name] -- models/trading_system.can:855
	if entities == nil then -- models/trading_system.can:856
		f_sell_markets[item_name] = { entity } -- models/trading_system.can:857
	else -- models/trading_system.can:857
		entities[# entities + 1] = entity -- models/trading_system.can:859
	end -- models/trading_system.can:859
	market_data[4] = item_name -- models/trading_system.can:862
end -- models/trading_system.can:862
local _market_buy_f_price = { -- models/trading_system.can:867
	"coin", -- models/trading_system.can:867
	0 -- models/trading_system.can:867
} -- models/trading_system.can:867
local _market_buy_f_offer = { -- models/trading_system.can:869
	["type"] = "give-item", -- models/trading_system.can:869
	["item"] = "" -- models/trading_system.can:869
} -- models/trading_system.can:869
local _market_f_buy_trade = { -- models/trading_system.can:871
	["price"] = { _market_buy_f_price }, -- models/trading_system.can:872
	["offer"] = _market_buy_f_offer -- models/trading_system.can:873
} -- models/trading_system.can:873
M["add_force_items_for_buy_market"] = function(entity, market_data) -- models/trading_system.can:877
	local force_index = entity["force"]["index"] -- models/trading_system.can:878
	local prices = _buy_prices[force_index] -- models/trading_system.can:880
	local add_market_item = entity["add_market_item"] -- models/trading_system.can:881
	for item_name, price in pairs(prices) do -- models/trading_system.can:882
		_market_buy_f_price[2] = price -- models/trading_system.can:883
		_market_buy_f_offer["item"] = item_name -- models/trading_system.can:884
		add_market_item(_market_f_buy_trade) -- models/trading_system.can:885
	end -- models/trading_system.can:885
	market_data[3] = _last_buy_id[force_index] -- models/trading_system.can:887
end -- models/trading_system.can:887
local _market_sell_f_price = { -- models/trading_system.can:892
	"", -- models/trading_system.can:892
	1 -- models/trading_system.can:892
} -- models/trading_system.can:892
local _market_sell_f_offer = { -- models/trading_system.can:894
	["type"] = "give-item", -- models/trading_system.can:894
	["item"] = "coin", -- models/trading_system.can:894
	["count"] = 1 -- models/trading_system.can:894
} -- models/trading_system.can:894
local _market_f_sell_trade = { -- models/trading_system.can:896
	["price"] = { _market_sell_f_price }, -- models/trading_system.can:897
	["offer"] = _market_sell_f_offer -- models/trading_system.can:898
} -- models/trading_system.can:898
M["add_force_items_for_sell_market"] = function(entity, market_data) -- models/trading_system.can:902
	local force_index = entity["force"]["index"] -- models/trading_system.can:903
	local prices = _sell_prices[force_index] -- models/trading_system.can:905
	local add_market_item = entity["add_market_item"] -- models/trading_system.can:906
	for item_name, price in pairs(prices) do -- models/trading_system.can:907
		_market_sell_f_price[1] = item_name -- models/trading_system.can:908
		_market_sell_f_offer["count"] = price -- models/trading_system.can:909
		add_market_item(_market_f_sell_trade) -- models/trading_system.can:910
	end -- models/trading_system.can:910
	market_data[3] = _last_sell_id[force_index] -- models/trading_system.can:912
end -- models/trading_system.can:912
local REMOVE_MARKETS_FUNCS = { -- models/trading_system.can:916
	[1] = M["remove_certain_buy_market"], -- models/trading_system.can:917
	[2] = M["remove_certain_sell_market"] -- models/trading_system.can:918
} -- models/trading_system.can:918
clear_market_data_by_entity = function(entity) -- models/trading_system.can:921
	local market_data = _all_markets[entity["unit_number"]] -- models/trading_system.can:922
	if market_data == nil then -- models/trading_system.can:923
		return  -- models/trading_system.can:923
	end -- models/trading_system.can:923
	REMOVE_MARKETS_FUNCS[market_data[3]](entity, market_data) -- models/trading_system.can:925
	return true -- models/trading_system.can:926
end -- models/trading_system.can:926
M["clear_market_data"] = function(event) -- models/trading_system.can:934
	local entity = event["entity"] -- models/trading_system.can:935
	if not entity["valid"] then -- models/trading_system.can:936
		return  -- models/trading_system.can:936
	end -- models/trading_system.can:936
	local market_data = _all_markets[entity["unit_number"]] -- models/trading_system.can:937
	if market_data == nil then -- models/trading_system.can:938
		return  -- models/trading_system.can:938
	end -- models/trading_system.can:938
	REMOVE_MARKETS_FUNCS[market_data[3]](entity, market_data) -- models/trading_system.can:940
end -- models/trading_system.can:940
M["on_player_joined_game"] = function(event) -- models/trading_system.can:944
	local player = game["get_player"](event["player_index"]) -- models/trading_system.can:945
	if not (player and player["valid"]) then -- models/trading_system.can:946
		return  -- models/trading_system.can:946
	end -- models/trading_system.can:946
	if # game["connected_players"] == 1 then -- models/trading_system.can:948
		detect_desync() -- models/trading_system.can:949
	end -- models/trading_system.can:949
end -- models/trading_system.can:949
M["on_force_created"] = function(event) -- models/trading_system.can:954
	local force = event["force"] -- models/trading_system.can:955
	if not force["valid"] then -- models/trading_system.can:956
		return  -- models/trading_system.can:956
	end -- models/trading_system.can:956
	local force_index = force["index"] -- models/trading_system.can:958
	init_force_data(force_index) -- models/trading_system.can:959
	if _mod_data["is_recipes_disabled"] then -- models/trading_system.can:961
		disable_mod_recipes(force_index) -- models/trading_system.can:962
	end -- models/trading_system.can:962
end -- models/trading_system.can:962
M["on_forces_merging"] = function(event) -- models/trading_system.can:967
	local source_force = event["source"] -- models/trading_system.can:968
	if not source_force["valid"] then -- models/trading_system.can:969
		return  -- models/trading_system.can:969
	end -- models/trading_system.can:969
	local source_index = source_force["index"] -- models/trading_system.can:971
	clear_force_data(source_index) -- models/trading_system.can:972
end -- models/trading_system.can:972
M["on_built_entity"] = function(event) -- models/trading_system.can:977
	local entity = event["created_entity"] -- models/trading_system.can:978
	if not entity["valid"] then -- models/trading_system.can:979
		return  -- models/trading_system.can:979
	end -- models/trading_system.can:979
	local market_type = MARKETS_TYPES[entity["name"]] -- models/trading_system.can:980
	if market_type == nil then -- models/trading_system.can:981
		return  -- models/trading_system.can:981
	end -- models/trading_system.can:981
	M["create_force_market"](entity, market_type) -- models/trading_system.can:983
end -- models/trading_system.can:983
M["script_raised_built"] = function(event) -- models/trading_system.can:988
	local entity = event["entity"] -- models/trading_system.can:989
	if not entity["valid"] then -- models/trading_system.can:990
		return  -- models/trading_system.can:990
	end -- models/trading_system.can:990
	local market_type = MARKETS_TYPES[entity["name"]] -- models/trading_system.can:992
	if market_type == nil then -- models/trading_system.can:993
		return  -- models/trading_system.can:993
	end -- models/trading_system.can:993
	M["create_force_market"](entity, market_type) -- models/trading_system.can:995
end -- models/trading_system.can:995
M["on_entity_cloned"] = function(event) -- models/trading_system.can:1000
	local source = event["source"] -- models/trading_system.can:1001
	if not source["valid"] then -- models/trading_system.can:1002
		return  -- models/trading_system.can:1002
	end -- models/trading_system.can:1002
	local destination = event["destination"] -- models/trading_system.can:1004
	if not destination["valid"] then -- models/trading_system.can:1005
		return  -- models/trading_system.can:1005
	end -- models/trading_system.can:1005
	local market_data -- models/trading_system.can:1007
	if source["type"] == "market" then -- models/trading_system.can:1008
		if _all_hidden_markets[source["unit_number"]] then -- models/trading_system.can:1009
			destination["destroy"](DESTROY_PARAM) -- models/trading_system.can:1010
		end -- models/trading_system.can:1010
	else -- models/trading_system.can:1010
		market_data = _all_markets[source["unit_number"]] -- models/trading_system.can:1013
	end -- models/trading_system.can:1013
	if market_data == nil then -- models/trading_system.can:1015
		return  -- models/trading_system.can:1015
	end -- models/trading_system.can:1015
	M["create_force_market"](destination, MARKETS_TYPES[destination["name"]]) -- models/trading_system.can:1017
end -- models/trading_system.can:1017
M["on_market_item_purchased"] = function(event) -- models/trading_system.can:1022
	local entity = event["market"] -- models/trading_system.can:1023
	if not (entity and entity["valid"]) then -- models/trading_system.can:1024
		return  -- models/trading_system.can:1024
	end -- models/trading_system.can:1024
	local market_type = HIDDEN_MARKETS_TYPES[entity["name"]] -- models/trading_system.can:1026
	if market_type == nil then -- models/trading_system.can:1027
		return  -- models/trading_system.can:1027
	end -- models/trading_system.can:1027
	local player = game["get_player"](event["player_index"]) -- models/trading_system.can:1028
	if not (player and player["valid"]) then -- models/trading_system.can:1029
		return  -- models/trading_system.can:1029
	end -- models/trading_system.can:1029
	local market_data = _all_hidden_markets[entity["unit_number"]] -- models/trading_system.can:1030
	if not market_data then -- models/trading_system.can:1031
		return  -- models/trading_system.can:1031
	end -- models/trading_system.can:1031
	local force_index = entity["force"]["index"] -- models/trading_system.can:1033
	if market_type == 1 then -- models/trading_system.can:1
		local item_name = _buy_catalogue[force_index][event["offer_index"]] -- models/trading_system.can:1035
		M["set_force_buy_market"](item_name, market_data[2]) -- models/trading_system.can:1036
	elseif market_type == 2 then -- models/trading_system.can:1
		local item_name = _sell_catalogue[force_index][event["offer_index"]] -- models/trading_system.can:1038
		M["set_force_sell_market"](item_name, market_data[2]) -- models/trading_system.can:1039
	end -- models/trading_system.can:1039
end -- models/trading_system.can:1039
M["on_gui_opened"] = function(event) -- models/trading_system.can:1046
	local entity = event["entity"] -- models/trading_system.can:1047
	if not (entity and entity["valid"]) then -- models/trading_system.can:1048
		return  -- models/trading_system.can:1048
	end -- models/trading_system.can:1048
	local market_type = HIDDEN_MARKETS_TYPES[entity["name"]] -- models/trading_system.can:1049
	if market_type == nil then -- models/trading_system.can:1050
		return  -- models/trading_system.can:1050
	end -- models/trading_system.can:1050
	local player = game["get_player"](event["player_index"]) -- models/trading_system.can:1051
	if not (player and player["valid"]) then -- models/trading_system.can:1052
		return  -- models/trading_system.can:1052
	end -- models/trading_system.can:1052
	local market_data = _all_hidden_markets[entity["unit_number"]] -- models/trading_system.can:1053
	if not market_data then -- models/trading_system.can:1054
		return  -- models/trading_system.can:1054
	end -- models/trading_system.can:1054
	local entity_force = entity["force"] -- models/trading_system.can:1055
	if entity_force ~= player["force"] then -- models/trading_system.can:1056
		player["opened"] = nil -- models/trading_system.can:1057
		return  -- models/trading_system.can:1058
	end -- models/trading_system.can:1058
	local market_buy_id = market_data[2] -- models/trading_system.can:1061
	if market_buy_id ~= nil then -- models/trading_system.can:1062
		entity["clear_market_items"]() -- models/trading_system.can:1063
	elseif market_type == 1 then -- models/trading_system.can:1
		if _last_buy_id[entity_force["index"]] == market_buy_id then -- models/trading_system.can:1065
			return  -- models/trading_system.can:1066
		end -- models/trading_system.can:1066
	elseif market_type == 2 then -- models/trading_system.can:1
		if _last_sell_id[entity_force["index"]] == market_buy_id then -- models/trading_system.can:1069
			return  -- models/trading_system.can:1070
		end -- models/trading_system.can:1070
	end -- models/trading_system.can:1070
	if market_type == 1 then -- models/trading_system.can:1
		M["add_force_items_for_buy_market"](entity, market_data) -- models/trading_system.can:1075
	elseif market_type == 2 then -- models/trading_system.can:1
		M["add_force_items_for_sell_market"](entity, market_data) -- models/trading_system.can:1077
	end -- models/trading_system.can:1077
end -- models/trading_system.can:1077
M["check_buy_markets"] = function() -- models/trading_system.can:1082
	local last_checked_index = _mod_data["last_checked_index"] -- models/trading_system.can:1083
	local buyer_index -- models/trading_system.can:1084
	buyer_index, buyer_index = next(_buy_markets, last_checked_index) -- models/trading_system.can:1085
	_mod_data["last_checked_index"] = buyer_index -- models/trading_system.can:1086
	if buyer_index == nil then -- models/trading_system.can:1087
		return  -- models/trading_system.can:1088
	end -- models/trading_system.can:1088
	local items_data = _buy_markets[buyer_index] -- models/trading_system.can:1091
	if items_data == nil then -- models/trading_system.can:1093
		return  -- models/trading_system.can:1093
	end -- models/trading_system.can:1093
	local forces_money = call("EasyAPI", "get_forces_money") -- models/trading_system.can:1095
	local buyer_money = forces_money[buyer_index] -- models/trading_system.can:1097
	if buyer_money == nil or buyer_money <= 0 then -- models/trading_system.can:1098
		return  -- models/trading_system.can:1099
	end -- models/trading_system.can:1099
	local stack_count = 0 -- models/trading_system.can:1102
	local f_buy_prices = _buy_prices[buyer_index] -- models/trading_system.can:1103
	local inserted_count_in_total = 0 -- models/trading_system.can:1104
	for item_name, entities in pairs(items_data) do -- models/trading_system.can:1105
		if 0 >= buyer_money then -- models/trading_system.can:1106
			goto not_enough_money -- models/trading_system.can:1108
		end -- models/trading_system.can:1108
		local buy_price = f_buy_prices[item_name] -- models/trading_system.can:1110
		if buy_price and buyer_money >= buy_price then -- models/trading_system.can:1111
			for i = # entities, 1, - 1 do -- models/trading_system.can:1112
				local buy_market = entities[i] -- models/trading_system.can:1113
				local purchasable_count = buyer_money / buy_price -- models/trading_system.can:1120
				if purchasable_count < 1 then -- models/trading_system.can:1121
					goto skip_buy -- models/trading_system.can:1122
				else -- models/trading_system.can:1122
					purchasable_count = floor(purchasable_count) -- models/trading_system.can:1124
				end -- models/trading_system.can:1124
				local need_count = 60 * 11 -- models/trading_system.can:1126
				if purchasable_count < need_count then -- models/trading_system.can:1127
					need_count = purchasable_count -- models/trading_system.can:1128
				end -- models/trading_system.can:1128
				local count = buy_market["get_item_count"](item_name) -- models/trading_system.can:1130
				_buy_stack["name"] = item_name -- models/trading_system.can:1131
				if need_count >= count then -- models/trading_system.can:1132
					need_count = need_count - count -- models/trading_system.can:1133
					if need_count <= 0 then -- models/trading_system.can:1134
						goto skip_buy -- models/trading_system.can:1135
					end -- models/trading_system.can:1135
				end -- models/trading_system.can:1135
				local found_items = need_count - stack_count -- models/trading_system.can:1138
				if found_items > 0 then -- models/trading_system.can:1139
					_buy_stack["count"] = found_items -- models/trading_system.can:1140
					local inserted_count = buy_market["insert"](_buy_stack) -- models/trading_system.can:1141
					inserted_count_in_total = inserted_count_in_total + inserted_count -- models/trading_system.can:1142
					buyer_money = buyer_money - (inserted_count * buy_price) -- models/trading_system.can:1143
				end -- models/trading_system.can:1143
				::skip_buy:: -- models/trading_system.can:1145
			end -- models/trading_system.can:1145
		end -- models/trading_system.can:1145
	end -- models/trading_system.can:1145
	::not_enough_money:: -- models/trading_system.can:1149
	forces_money[buyer_index] = buyer_money -- models/trading_system.can:1150
	local forces = game["forces"] -- models/trading_system.can:1152
	call("EasyAPI", "set_forces_money", forces_money) -- models/trading_system.can:1153
	for _force_index, money in pairs(forces_money) do -- models/trading_system.can:1154
		local prev_money = forces_money[_force_index] -- models/trading_system.can:1155
		if prev_money ~= money then -- models/trading_system.can:1156
			local force = forces[_force_index] -- models/trading_system.can:1157
			force["item_production_statistics"]["on_flow"]("trading", money - prev_money) -- models/trading_system.can:1158
		end -- models/trading_system.can:1158
	end -- models/trading_system.can:1158
end -- models/trading_system.can:1158
M["check_sell_markets"] = function() -- models/trading_system.can:1164
	local forces_money = call("EasyAPI", "get_forces_money") -- models/trading_system.can:1165
	for force_index, _items_data in pairs(_sell_markets) do -- models/trading_system.can:1168
		local money = forces_money[force_index] -- models/trading_system.can:1169
		if money == nil then -- models/trading_system.can:1170
			goto skip_force -- models/trading_system.can:1171
		end -- models/trading_system.can:1171
		local prices = _sell_prices[force_index] -- models/trading_system.can:1174
		for item_name, entities in pairs(_items_data) do -- models/trading_system.can:1175
			local sell_price = prices[item_name] -- models/trading_system.can:1176
			_sell_stack["name"] = item_name -- models/trading_system.can:1177
			for i = 1, # entities do -- models/trading_system.can:1178
				local entity = entities[i] -- models/trading_system.can:1179
				money = money + sell_price * entity["remove_item"](_sell_stack) -- models/trading_system.can:1186
				::skip_selling:: -- models/trading_system.can:1187
			end -- models/trading_system.can:1187
		end -- models/trading_system.can:1187
		forces_money[force_index] = money -- models/trading_system.can:1190
		::skip_force:: -- models/trading_system.can:1192
	end -- models/trading_system.can:1192
	call("EasyAPI", "set_forces_money", forces_money) -- models/trading_system.can:1195
end -- models/trading_system.can:1195
M["on_player_changed_force"] = function(event) -- models/trading_system.can:1200
	local player_index = event["player_index"] -- models/trading_system.can:1201
	local player = game["get_player"](player_index) -- models/trading_system.can:1202
	if not (player and player["valid"]) then -- models/trading_system.can:1203
		return  -- models/trading_system.can:1203
	end -- models/trading_system.can:1203
	local force_index = player["force_index"] -- models/trading_system.can:1205
	if _buy_markets[force_index] == nil then -- models/trading_system.can:1206
		init_force_data(force_index) -- models/trading_system.can:1207
	end -- models/trading_system.can:1207
end -- models/trading_system.can:1207
local mod_settings = { -- models/trading_system.can:1211
	["TSZO_update-buy-tick"] = function(value) -- models/trading_system.can:1212
		if _update_sell_tick == value then -- models/trading_system.can:1213
			settings["global"]["TSZO_update-buy-tick"] = { ["value"] = value + 1 } -- models/trading_system.can:1215
			return  -- models/trading_system.can:1217
		end -- models/trading_system.can:1217
		script["on_nth_tick"](_update_buy_tick, nil) -- models/trading_system.can:1219
		_update_buy_tick = value -- models/trading_system.can:1220
		script["on_nth_tick"](value, M["check_buy_markets"]) -- models/trading_system.can:1221
	end, -- models/trading_system.can:1221
	["TSZO_update-sell-tick"] = function(value) -- models/trading_system.can:1223
		if _update_buy_tick == value then -- models/trading_system.can:1224
			settings["global"]["TSZO_update-sell-tick"] = { ["value"] = value + 1 } -- models/trading_system.can:1226
			return  -- models/trading_system.can:1228
		end -- models/trading_system.can:1228
		script["on_nth_tick"](_update_sell_tick, nil) -- models/trading_system.can:1230
		_update_sell_tick = value -- models/trading_system.can:1231
		script["on_nth_tick"](value, M["check_buy_markets"]) -- models/trading_system.can:1232
	end -- models/trading_system.can:1232
} -- models/trading_system.can:1232
M["on_runtime_mod_setting_changed"] = function(event) -- models/trading_system.can:1235
	local setting_name = event["setting"] -- models/trading_system.can:1236
	local f = mod_settings[setting_name] -- models/trading_system.can:1237
	if f == nil then -- models/trading_system.can:1238
		return  -- models/trading_system.can:1238
	end -- models/trading_system.can:1238
	if event["setting_type"] == "runtime-global" then -- models/trading_system.can:1240
		f(settings["global"][setting_name]["value"]) -- models/trading_system.can:1241
	else -- models/trading_system.can:1241
		local player = game["get_player"](event["player_index"]) -- models/trading_system.can:1243
		if player and player["valid"] then -- models/trading_system.can:1244
			f(player) -- models/trading_system.can:1245
		end -- models/trading_system.can:1245
	end -- models/trading_system.can:1245
end -- models/trading_system.can:1245
local function add_remote_interface() -- models/trading_system.can:1255
	remote["remove_interface"]("trading_system") -- models/trading_system.can:1257
	remote["add_interface"]("trading_system", { -- models/trading_system.can:1258
		["get_mod_data"] = function() -- models/trading_system.can:1259
			return _mod_data -- models/trading_system.can:1259
		end, -- models/trading_system.can:1259
		["get_internal_data"] = function(name) -- models/trading_system.can:1260
			return _mod_data[name] -- models/trading_system.can:1260
		end, -- models/trading_system.can:1260
		["import_global_prices"] = import_global_prices, -- models/trading_system.can:1261
		["clear_invalid_data"] = clear_invalid_data, -- models/trading_system.can:1262
		["clear_invalid_entities"] = clear_invalid_entities, -- models/trading_system.can:1263
		["remove_certain_sell_market"] = M["remove_certain_sell_market"], -- models/trading_system.can:1264
		["remove_certain_buy_market"] = M["remove_certain_buy_market"], -- models/trading_system.can:1265
		["clear_market_data_by_entity"] = clear_market_data_by_entity, -- models/trading_system.can:1266
		["clear_force_data"] = clear_force_data, -- models/trading_system.can:1267
		["init_force_data"] = init_force_data, -- models/trading_system.can:1268
		["set_force_sell_market"] = M["set_force_sell_market"], -- models/trading_system.can:1269
		["set_force_buy_market"] = M["set_force_buy_market"], -- models/trading_system.can:1270
		["set_sell_price_globally"] = set_sell_price_globally, -- models/trading_system.can:1271
		["set_buy_price_globally"] = set_buy_price_globally, -- models/trading_system.can:1272
		["set_force_sell_price"] = set_force_sell_price, -- models/trading_system.can:1273
		["set_force_buy_price"] = set_force_buy_price, -- models/trading_system.can:1274
		["disable_mod_recipes"] = disable_mod_recipes, -- models/trading_system.can:1275
		["enable_mod_recipes"] = enable_mod_recipes, -- models/trading_system.can:1276
		["create_force_market"] = M["create_force_market"], -- models/trading_system.can:1277
		["remove_market_from_markets"] = M["remove_market_from_markets"], -- models/trading_system.can:1278
		["get_sell_markets"] = function() -- models/trading_system.can:1279
			return _sell_markets -- models/trading_system.can:1279
		end, -- models/trading_system.can:1279
		["get_buy_markets"] = function() -- models/trading_system.can:1280
			return _buy_markets -- models/trading_system.can:1280
		end, -- models/trading_system.can:1280
		["get_sell_prices"] = function() -- models/trading_system.can:1281
			return _sell_prices -- models/trading_system.can:1281
		end, -- models/trading_system.can:1281
		["get_buy_prices"] = function() -- models/trading_system.can:1282
			return _buy_prices -- models/trading_system.can:1282
		end, -- models/trading_system.can:1282
		["get_all_markets"] = function() -- models/trading_system.can:1283
			return _all_markets -- models/trading_system.can:1283
		end -- models/trading_system.can:1283
	}) -- models/trading_system.can:1283
end -- models/trading_system.can:1283
local function link_data() -- models/trading_system.can:1287
	_mod_data = global["TSZO"] -- models/trading_system.can:1288
	_buy_markets = _mod_data["buy_markets"] -- models/trading_system.can:1289
	_sell_markets = _mod_data["sell_markets"] -- models/trading_system.can:1290
	_buy_catalogue = _mod_data["buy_catalogue"] -- models/trading_system.can:1291
	_sell_catalogue = _mod_data["sell_catalogue"] -- models/trading_system.can:1292
	_last_sell_id = _mod_data["last_sell_id"] -- models/trading_system.can:1293
	_last_buy_id = _mod_data["last_buy_id"] -- models/trading_system.can:1294
	_sell_prices = _mod_data["sell_prices"] -- models/trading_system.can:1295
	_buy_prices = _mod_data["buy_prices"] -- models/trading_system.can:1296
	_global_sell_prices = _mod_data["global_sell_prices"] -- models/trading_system.can:1297
	_global_buy_prices = _mod_data["global_buy_prices"] -- models/trading_system.can:1298
	_all_hidden_markets = _mod_data["all_hidden_markets"] -- models/trading_system.can:1299
	_all_markets = _mod_data["all_markets"] -- models/trading_system.can:1300
end -- models/trading_system.can:1300
local function update_global_data() -- models/trading_system.can:1303
	global["TSZO"] = global["TSZO"] or {} -- models/trading_system.can:1304
	_mod_data = global["TSZO"] -- models/trading_system.can:1305
	_mod_data["is_recipes_disabled"] = _mod_data["is_recipes_disabled"] or false -- models/trading_system.can:1306
	_mod_data["buy_markets"] = _mod_data["buy_markets"] or {} -- models/trading_system.can:1307
	_mod_data["sell_markets"] = _mod_data["sell_markets"] or {} -- models/trading_system.can:1308
	_mod_data["buy_catalogue"] = _mod_data["buy_catalogue"] or {} -- models/trading_system.can:1309
	_mod_data["sell_catalogue"] = _mod_data["sell_catalogue"] or {} -- models/trading_system.can:1310
	_mod_data["sell_prices"] = _mod_data["sell_prices"] or {} -- models/trading_system.can:1311
	_mod_data["buy_prices"] = _mod_data["buy_prices"] or {} -- models/trading_system.can:1312
	local item_prototypes = game["item_prototypes"] -- models/trading_system.can:1314
	if _mod_data["global_sell_prices"] == nil then -- models/trading_system.can:1315
		local new_price_list = {} -- models/trading_system.can:1316
		for name, price in pairs(DEFAULT_SELL_PRICES) do -- models/trading_system.can:1317
			if item_prototypes[name] then -- models/trading_system.can:1318
				new_price_list[name] = price -- models/trading_system.can:1319
			end -- models/trading_system.can:1319
		end -- models/trading_system.can:1319
		_mod_data["global_sell_prices"] = new_price_list -- models/trading_system.can:1322
	end -- models/trading_system.can:1322
	if _mod_data["global_buy_prices"] == nil then -- models/trading_system.can:1324
		local new_price_list = {} -- models/trading_system.can:1325
		for name, price in pairs(DEFAULT_BUY_PRICES) do -- models/trading_system.can:1326
			if item_prototypes[name] then -- models/trading_system.can:1327
				new_price_list[name] = price -- models/trading_system.can:1328
			end -- models/trading_system.can:1328
		end -- models/trading_system.can:1328
		_mod_data["global_buy_prices"] = new_price_list -- models/trading_system.can:1331
	end -- models/trading_system.can:1331
	_mod_data["last_sell_id"] = _mod_data["last_sell_id"] or {} -- models/trading_system.can:1334
	_mod_data["last_buy_id"] = _mod_data["last_buy_id"] or {} -- models/trading_system.can:1335
	_mod_data["all_hidden_markets"] = _mod_data["all_hidden_markets"] or {} -- models/trading_system.can:1336
	_mod_data["all_markets"] = _mod_data["all_markets"] or {} -- models/trading_system.can:1337
	link_data() -- models/trading_system.can:1339
	clear_invalid_data() -- models/trading_system.can:1341
	for _, force in pairs(game["forces"]) do -- models/trading_system.can:1345
		if force["valid"] then -- models/trading_system.can:1346
			init_force_data(force["index"]) -- models/trading_system.can:1348
		end -- models/trading_system.can:1348
	end -- models/trading_system.can:1348
	detect_desync(game) -- models/trading_system.can:1353
end -- models/trading_system.can:1353
local function on_configuration_changed(event) -- models/trading_system.can:1356
	update_global_data() -- models/trading_system.can:1357
end -- models/trading_system.can:1357
do -- models/trading_system.can:1366
	local function set_filters() -- models/trading_system.can:1366
		local filters = { { -- models/trading_system.can:1368
			["filter"] = "type", -- models/trading_system.can:1368
			["mode"] = "or", -- models/trading_system.can:1368
			["type"] = "container" -- models/trading_system.can:1368
		} } -- models/trading_system.can:1368
		local filters_clone = { -- models/trading_system.can:1371
			{ -- models/trading_system.can:1372
				["filter"] = "type", -- models/trading_system.can:1372
				["mode"] = "or", -- models/trading_system.can:1372
				["type"] = "container" -- models/trading_system.can:1372
			}, -- models/trading_system.can:1372
			{ -- models/trading_system.can:1373
				["filter"] = "type", -- models/trading_system.can:1373
				["mode"] = "or", -- models/trading_system.can:1373
				["type"] = "market" -- models/trading_system.can:1373
			} -- models/trading_system.can:1373
		} -- models/trading_system.can:1373
		script["set_event_filter"](defines["events"]["script_raised_built"], filters) -- models/trading_system.can:1376
		script["set_event_filter"](defines["events"]["on_robot_built_entity"], filters) -- models/trading_system.can:1377
		script["set_event_filter"](defines["events"]["on_built_entity"], filters) -- models/trading_system.can:1378
		script["set_event_filter"](defines["events"]["on_entity_died"], filters) -- models/trading_system.can:1379
		script["set_event_filter"](defines["events"]["on_robot_mined_entity"], filters) -- models/trading_system.can:1380
		script["set_event_filter"](defines["events"]["script_raised_destroy"], filters) -- models/trading_system.can:1381
		script["set_event_filter"](defines["events"]["on_player_mined_entity"], filters) -- models/trading_system.can:1382
		script["set_event_filter"](defines["events"]["on_entity_cloned"], filters_clone) -- models/trading_system.can:1383
		local EasyAPI_events = call("EasyAPI", "get_events") -- models/trading_system.can:1385
		if EasyAPI_events["on_fix_bugs"] then -- models/trading_system.can:1386
			script["on_event"](EasyAPI_events["on_fix_bugs"], function() -- models/trading_system.can:1387
				clear_invalid_entities() -- models/trading_system.can:1388
				detect_desync(game) -- models/trading_system.can:1390
			end) -- models/trading_system.can:1390
		end -- models/trading_system.can:1390
		if EasyAPI_events["on_sync"] then -- models/trading_system.can:1393
			script["on_event"](EasyAPI_events["on_sync"], function() -- models/trading_system.can:1394
				link_data() -- models/trading_system.can:1395
			end) -- models/trading_system.can:1395
		end -- models/trading_system.can:1395
	end -- models/trading_system.can:1395
	M["on_load"] = function() -- models/trading_system.can:1400
		link_data() -- models/trading_system.can:1401
		set_filters() -- models/trading_system.can:1402
	end -- models/trading_system.can:1402
	M["on_init"] = function() -- models/trading_system.can:1404
		update_global_data() -- models/trading_system.can:1405
		set_filters() -- models/trading_system.can:1406
	end -- models/trading_system.can:1406
end -- models/trading_system.can:1406
M["on_configuration_changed"] = on_configuration_changed -- models/trading_system.can:1409
M["add_remote_interface"] = add_remote_interface -- models/trading_system.can:1410
M["events"] = { -- models/trading_system.can:1415
	[defines["events"]["on_surface_deleted"]] = clear_invalid_entities, -- models/trading_system.can:1416
	[defines["events"]["on_surface_cleared"]] = clear_invalid_entities, -- models/trading_system.can:1417
	[defines["events"]["on_chunk_deleted"]] = clear_invalid_entities, -- models/trading_system.can:1418
	[defines["events"]["on_player_joined_game"]] = M["on_player_joined_game"], -- models/trading_system.can:1419
	[defines["events"]["on_player_changed_force"]] = M["on_player_changed_force"], -- models/trading_system.can:1420
	[defines["events"]["on_gui_opened"]] = M["on_gui_opened"], -- models/trading_system.can:1421
	[defines["events"]["on_market_item_purchased"]] = M["on_market_item_purchased"], -- models/trading_system.can:1422
	[defines["events"]["on_force_created"]] = M["on_force_created"], -- models/trading_system.can:1423
	[defines["events"]["on_forces_merging"]] = M["on_forces_merging"], -- models/trading_system.can:1424
	[defines["events"]["script_raised_built"]] = M["script_raised_built"], -- models/trading_system.can:1425
	[defines["events"]["on_robot_built_entity"]] = M["on_built_entity"], -- models/trading_system.can:1426
	[defines["events"]["on_built_entity"]] = M["on_built_entity"], -- models/trading_system.can:1427
	[defines["events"]["on_entity_cloned"]] = M["on_entity_cloned"], -- models/trading_system.can:1428
	[defines["events"]["on_runtime_mod_setting_changed"]] = M["on_runtime_mod_setting_changed"], -- models/trading_system.can:1429
	[defines["events"]["on_player_mined_entity"]] = M["clear_market_data"], -- models/trading_system.can:1443
	[defines["events"]["on_robot_mined_entity"]] = M["clear_market_data"], -- models/trading_system.can:1444
	[defines["events"]["script_raised_destroy"]] = M["clear_market_data"], -- models/trading_system.can:1445
	[defines["events"]["on_entity_died"]] = M["clear_market_data"] -- models/trading_system.can:1446
} -- models/trading_system.can:1446
M["on_nth_tick"] = { -- models/trading_system.can:1449
	[_update_buy_tick] = M["check_buy_markets"], -- models/trading_system.can:1450
	[_update_sell_tick] = M["check_sell_markets"] -- models/trading_system.can:1451
} -- models/trading_system.can:1451
M["commands"] = { -- models/trading_system.can:1454
	["set-sell-price-globally"] = function(cmd) -- models/trading_system.can:1456
		local item_name, count = M["find_item_in_text"](cmd["parameter"]) -- models/trading_system.can:1457
		if item_name == nil then -- models/trading_system.can:1458
			return  -- models/trading_system.can:1458
		end -- models/trading_system.can:1458
		set_sell_price_globally(item_name, count) -- models/trading_system.can:1463
	end, -- models/trading_system.can:1463
	["set-buy-price-globally"] = function(cmd) -- models/trading_system.can:1466
		local item_name, count = M["find_item_in_text"](cmd["parameter"]) -- models/trading_system.can:1467
		if item_name == nil then -- models/trading_system.can:1468
			return  -- models/trading_system.can:1468
		end -- models/trading_system.can:1468
		set_buy_price_globally(item_name, count) -- models/trading_system.can:1473
	end, -- models/trading_system.can:1473
	["export-global-prices-for-trading-system"] = function(cmd) -- models/trading_system.can:1476
		local data = game["table_to_json"]({ -- models/trading_system.can:1477
			["global_sell_prices"] = _global_sell_prices, -- models/trading_system.can:1478
			["global_buy_prices"] = _global_buy_prices -- models/trading_system.can:1479
		}) -- models/trading_system.can:1479
		local file_name = "global-prices-for-trading-system.json" -- models/trading_system.can:1482
		game["write_file"](file_name, data, false, cmd["player_index"]) -- models/trading_system.can:1483
		local message = "Saved data in script-output/" .. file_name -- models/trading_system.can:1485
		if cmd["player_index"] == 0 then -- models/trading_system.can:1486
			print(message) -- models/trading_system.can:1487
		else -- models/trading_system.can:1487
			local player = game["get_player"](cmd["player_index"]) -- models/trading_system.can:1489
			player["print"](message) -- models/trading_system.can:1491
		end -- models/trading_system.can:1491
	end, -- models/trading_system.can:1491
	["import-global-prices-from-trading-system"] = function(cmd) -- models/trading_system.can:1495
		local data = game["json_to_table"](cmd["parameter"]) -- models/trading_system.can:1496
		if type(data) ~= "table" or (data["global_buy_prices"] == nil and data["global_sell_prices"] == nil) then -- models/trading_system.can:1497
			local message = "Invalid data" -- models/trading_system.can:1498
			if cmd["player_index"] == 0 then -- models/trading_system.can:1499
				print(message) -- models/trading_system.can:1500
			else -- models/trading_system.can:1500
				local player = game["get_player"](cmd["player_index"]) -- models/trading_system.can:1502
				player["print"](message) -- models/trading_system.can:1504
			end -- models/trading_system.can:1504
			return  -- models/trading_system.can:1506
		end -- models/trading_system.can:1506
		import_global_prices(nil, data) -- models/trading_system.can:1509
	end -- models/trading_system.can:1509
} -- models/trading_system.can:1509
return M -- models/trading_system.can:1514
