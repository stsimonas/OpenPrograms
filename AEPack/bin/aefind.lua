--[[
    Name:
        aefind - AEPack

    Description:
        aefind is a search tool for querying the ME network, useful for quickly finding items and their detailed information.

    Author:
        st.simonas
]]

local component = require("component")
local shell = require("shell")

local ae = assert(require("ae"))

local args = shell.parse(...)


local function printUsage()
  print("aefind is a search tool for querying the ME network, useful for quickly finding items and their detailed information.")
  print("Usage:")
  print("'aefind <term>' to find all items containing the given term in any field.")
end

local function findItems(term)
    term = term:lower()
    print(string.format("Searching for '%s'...", term))
    print("")

    local items = ae.getAvailableItems()
    local matchingCount = 0

    for k, v in pairs(items) do
        local fingerprint = v.fingerprint
        local names = ae.getItemNames(fingerprint)

	    local id = fingerprint.id
        local dmg = fingerprint.dmg
        local displayName = names.display_name
        local rawname = names.raw_name

	    if id:lower():find(term) ~= nil or displayName:lower():find(term) ~= nil or rawname:lower():find(term) ~= nil then
            matchingCount = matchingCount + 1
            print(string.format("Display name: %s", displayName))
            print(string.format("\tRaw Name: %s", rawname))
            print(string.format("\tFingerprint Id: %s", id))
            print(string.format("\tFingerprint Dmg: %s", dmg))
            print(string.format("\tCount: %s", v.size))
            print(string.format("\tCraftable: %s", v.is_craftable))
            print("")
	    end
    end

    print(string.format("Found %s matching records out of %s total records.", matchingCount, #items))
end

if #args > 0 then
    findItems(table.concat(args, " "))
else
    printUsage()
    return
end