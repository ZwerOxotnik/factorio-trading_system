require("models/BetterCommands/control"):create_settings() -- Adds switchable commands


data:extend({
	{type = "int-setting", name = "TSZO_update-buy-tick",  setting_type = "runtime-global", default_value = 120, minimum_value = 1, maximum_value = 8e4},
	{type = "int-setting", name = "TSZO_update-sell-tick", setting_type = "runtime-global", default_value = 360, minimum_value = 1, maximum_value = 8e4},
})

--TODO: change setting_type!
data:extend({
	{
		type = "string-setting",
		name = "trading_system-version",
		setting_type = "startup",
		default_value = "extra-stable",
		localised_name = {"gui-mod-info.version"},
		allowed_values = {"debug", "stable", "extra-stable"}
	}
})
