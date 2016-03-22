--[[
    Name:
        ae - AEPack

    Description:
        The core library for the AEPack

    Author:
        st.simonas
]]

local component = require("component")
local shell = require("shell")
local fs = require("filesystem")
local serial = require("serialization")

local cachePath = "/etc/aecache"
local cacheDefault = {
    names = {}
}

local mecomp

if component.isAvailable("me_controller") then
    mecomp = component.me_controller
elseif component.isAvailable("me_interface") then
    mecomp = component.me_interface
else
    error("The computer is not connected to an ME Controller or an ME Interface.")
    return
end

local function purgeCache()
    if fs.exists(cachePath) then
        fs.remove(cachePath)
    end
end

local function loadCache()
    if not fs.exists(cachePath) then
        return cacheDefault
    end

    local file, msg = io.open(cachePath, "rb")
    if not file then
        io.stderr:write(string.format("Could not load ae cache file for reading, path: %s, error: %s", cachePath, msg))
        return cacheDefault
    end

    local content = file:read("*a")
    file:close()
    local cache = serial.unserialize(content)

    for k,v in pairs(cacheDefault) do
        if not cache[k] then
            io.stderr:write("Cache corrupted or outdated - purging cache.")
            purgeCache()
            return cacheDefault
        end
    end

    return cache
end

local function saveCache(cache)
    local file, msg = io.open(cachePath, "wb")
    if not file then
        io.stderr:write(string.format("Could not load ae cache file for writing, path: %s, error: %s", cachePath, msg))
        return
    end

    local content = serial.serialize(cache)
    file:write(content)
    file:close()
end


local ae = mecomp
ae.cache = loadCache()

function ae.purgeCache()
    purgeCache()
end

function ae.getItemNames(fingerprint)
    local cachedNamesKey = string.format("%s:%s", fingerprint.id, fingerprint.dmg)
    local cachedNames = ae.cache.names[cachedNamesKey] 
    if not cachedNames then
        local realDetails = ae.getItemDetail(fingerprint).basic()

        cachedNames = {
            display_name = realDetails.display_name,
            raw_name = realDetails.raw_name
        }

        ae.cache.names[cachedNamesKey] = cachedNames

        saveCache(ae.cache)
    end

    return cachedNames
end

return ae