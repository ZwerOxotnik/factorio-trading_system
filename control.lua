if script.level.campaign_name then return end -- Don't init if it's a campaign

local event_handler
if script.active_mods["zk-lib"] then
	-- Same as Factorio "event_handler", but slightly better performance
	local is_ok, zk_event_handler = pcall(require, "__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
	if is_ok then
		event_handler = zk_event_handler
	end
end
event_handler = event_handler or require("event_handler")


---@type table<string, module>
local modules = {}
modules.better_commands = require("models/BetterCommands/control")


local version = settings.startup["trading_system-version"].value
if version == "stable" then
	modules.trading_system = require("models/trading_system-stable")
elseif version == "debug" then
	modules.trading_system = require("models/trading_system-debug")
elseif version == "extra-stable" then
	modules.trading_system = require("models/trading_system-extra-stability")
end


modules.better_commands:handle_custom_commands(modules.trading_system) -- adds commands

event_handler.add_libraries(modules)


-- This is a part of "gvv", "Lua API global Variable Viewer" mod. https://mods.factorio.com/mod/gvv
-- It makes possible gvv mod to read sandboxed variables in the map or other mod if following code is inserted at the end of empty line of "control.lua" of each.
if script.active_mods["gvv"] then require("__gvv__.gvv")() end
