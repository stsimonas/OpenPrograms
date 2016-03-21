local component = require("component")
local shell = require("shell")
local mei = component.me_interface

local args = shell.parse(...)

local items = mei.getAvailableItems()

for k, v in pairs(items) do
	local id = v.fingerprint.id
	if(id:find(args[1]) ~= nil) then
		print(string.format("%s\r\n\tCount: %s\r\n\tCraftable: %s\r\n", id, v.size, v.is_craftable))
	end
end