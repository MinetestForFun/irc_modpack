-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.


irc.config = {}

local function setting(stype, name, default)
	local value
	if stype == "bool" then
		value = minetest.setting_getbool("irc."..name)
	elseif stype == "string" then
		value = minetest.setting_get("irc."..name)
	elseif stype == "number" then
		value = tonumber(minetest.setting_get("irc."..name))
	end
	if value == nil then
		value = default
	end
	irc.config[name] = value
end

-------------------------
-- BASIC USER SETTINGS --
-------------------------

setting("string", "nick") -- Nickname (default "MT-<hash>", <hash> 6 random hexidecimal characters)
setting("string", "server", "irc.freenode.net") -- Server to connect on joinplayer
setting("number", "port", 6667) -- Port to connect on joinplayer
setting("string", "NSPass") -- NickServ password
setting("string", "sasl.user", irc.config.nick) -- SASL username
setting("string", "sasl.pass") -- SASL password
setting("string", "channel", "##mt-irc-mod") -- Channel to join
setting("string", "key") -- Key for the channel
setting("bool",   "send_join_part", true) -- Whether to send player join and part messages to the channel

-----------------------
-- ADVANCED SETTINGS --
-----------------------

setting("string", "password") -- Server password
setting("bool",   "secure", false) -- Enable a TLS connection, requires LuaSEC
setting("number", "timeout", 60) -- Underlying socket timeout in seconds.
setting("string", "command_prefix", "/") -- Prefix to use for bot commands
setting("bool",   "debug", false) -- Enable debug output
setting("bool",   "enable_player_part", true) -- Whether to enable players joining and parting the channel
setting("bool",   "auto_join", true) -- Whether to automatically show players in the channel when they join
setting("bool",   "auto_connect", true) -- Whether to automatically connect to the server on mod load

-- Generate a random nickname if one isn't specified.
if not irc.config.nick then
	local pr = PseudoRandom(os.time())
	-- Workaround for bad distribution in minetest PRNG implementation.
	irc.config.nick = ("MT-%02X%02X%02X"):format(
		pr:next(0, 255),
		pr:next(0, 255),
		pr:next(0, 255)
	)
end


local config_file = minetest.get_worldpath() .. "/irc.txt"

function irc.save_config()
	local input, err = io.open(config_file, "w")
	if input then
		local conf = {server = irc.config.server}
		input:write(minetest.serialize(conf))
		input:close()
	else
		minetest.log("error", "open(" .. config_file .. ", 'w') failed: " .. err)
	end
end

function irc.load_config()
	local file = io.open(config_file, "r")
	local settings = {}
	if file then
		settings = minetest.deserialize(file:read("*all"))
		file:close()
		if settings and type(settings) == "table" then
			if settings["server"] ~= nil then
				 irc.config.server = settings["server"]
			end
		end
	end
end

irc.load_config()

