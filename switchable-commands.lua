-- Recommended to know about https://lua-api.factorio.com/latest/LuaCommandProcessor.html#LuaCommandProcessor.add_command

--[[
Returns tables of commands without functions as command "settings". All parameters are optional!
  Contains:
    name :: string: The name of your /command. (default: key of the table)
    description :: string or LocalisedString: The description of your command. (default: nil)
    is_allowed_empty_args :: boolean: Ignores empty parameters in commands, otherwise stops the command. (default: true)
    input_type :: string: filter for parameters by type of input. (default: nil)
      possible variants:
        "player" - Stops execution if can't find a player by parameter
        "team" - Stops execution if can't find a team (force) by parameter
    allow_for_server :: boolean: Allow execution of a command from a server (default: false)
    only_for_admin :: boolean: The command can be executed only by admins (default: false)
		default_value :: boolean: default value for settings (default: true)
]]--
---@type table<string, table>
return {
	["set-sell-price-globally"] = {is_allowed_empty_args = false, only_for_admin = true, allow_for_server = true},
	["set-buy-price-globally"]  = {is_allowed_empty_args = false, only_for_admin = true, allow_for_server = true},
	["import-global-prices-from-trading-system"] = {is_allowed_empty_args = false, only_for_admin = true, allow_for_server = true},
	["export-global-prices-for-trading-system"]  = {is_allowed_empty_args = true,  only_for_admin = true, allow_for_server = true},
}
