--[[
    Name:
        aemon - AEPack

    Description:
        aemon is a program which runs in an infinite loop, constantly checking the count of specific items in the attached AE network if and the levels are lower than required places crafting orders.

    Author:
        st.simonas
]]

local shell = require("shell")
local fs = require("filesystem")
local serial = require("serialization")

local ae = assert(require("ae"))

local configPath = "/etc/aemon.cfg"
local configDefault = {}

local args = shell.parse(...)


local function printUsage()
    print("aemon is a program which runs in an infinite loop, constantly checking the count of specific items in the attached AE network if and the levels are lower than required places crafting orders.")
    print("Usage:")
    print("'aemon' to start the infinite loop/monitoring.")
    print("'aemon print|view|list' to print the currently configured items.")
    print("'aemon remove|delete <searchTerm>' to remove the specified item from configuration. The <searchTerm> is used to find the full item id.")
    print("'aemon add <searchTerm> <count>' to add the specified item to configuration. The <searchTerm> is used to find the full item id.")
    print("'aemon clear' clears the configuration, removing all configured items in the file.")
end

local function loadConfig()
    local file, msg = io.open(configPath, "rb")
    if not file then
        io.stderr:write(string.format("Could not open config file for reading, path: %s, error: %s", configPath, msg))
        return configDefault
    end

    local content = file:read("*a")
    file:close()
    local config = serial.unserialize(content)

    if not config then
        return configDefault
    end

    return config
end

local function saveConfig(config)
    local file, msg = io.open(configPath, "wb")
    if not file then
        io.stderr:write(string.format("Could not open config file for writing, path: %s, error: %s", configPath, msg))
        return
    end

    local content = serial.serialize(config)
    file:write(content)
    file:close()
end

local function addToConfig(fingerprint, count)
    local config = loadConfig()

    local key = string.format("%s::%s", fingerprint.id, fingerprint.dmg)
    config[key] = count

    saveConfig(config)
end

local function clearConfig()
    saveConfig(configDefault)
end

local function removeFromConfig(fingerprint)
    local config = loadConfig()

    local key = string.format("%s::%s", fingerprint.id, fingerprint.dmg)
    config[key] = nil

    saveConfig(config)
end

local function printConfig()
    local config = loadConfig()
    
    for key, requiredCount in pairs(config) do
        local id = key:sub(0, key:find("::") - 1)
        local dmg = key:sub(key:find("::") + 2)
        local fp = {id = id, dmg = dmg}

        local displayName = ae.getItemNames(fp).display_name

        print(string.format("%s : %s", displayName, requiredCount))
    end
end

local function loop()
    local config = loadConfig()
    local requests = {}

    while true do
	    for key, requiredCount in pairs(config) do
            local id = key:sub(0, key:find("::") - 1)
            local dmg = tonumber(key:sub(key:find("::") + 2))

            local fingerprint = {id = id, dmg = dmg}
            
		    local itemDetails = ae.getItemDetail(fingerprint).basic()
		    local displayName = itemDetails.display_name
		
            local currentCount = itemDetails.qty
		    local diff = requiredCount - currentCount
		    local msg = ""
		
		    if diff > 0 then
                local craftingFingerprint = {name = id, damage = dmg}

                local ammount = math.min(diff, 10)
			    local request = requests[key]
			    local performCrafting = request == nil
			
			    if request ~= nil then
				    performCrafting = request.isCanceled() or request.isDone()
			    end
			
			    if performCrafting then
				    requests[key] = ae.getCraftables(craftingFingerprint)[1].request(ammount)
				    msg = string.format("crafting %s", ammount)
			    end
		    end
		
		    print(string.format("%s : %s / %s %s", displayName, currentCount, requiredCount, msg))
		    os.sleep(1)
	    end
        os.sleep(1)
    end
end


if #args == 0 then
    loop()
elseif args[1] == "add" then
    local fingerprint = ae.findItemFingerprint(args[2])
    if not fingerprint then
        error("No item found with the given search term")
    end
    addToConfig(fingerprint, args[3])
elseif args[1] == "print" or args[1] == "view" or args[1] == "list" then
    printConfig()
elseif args[1] == "remove" or args[1] == "delete" then
    local fingerprint = ae.findItemFingerprint(args[2])
    if not fingerprint then
        error("No item found with the given search term")
    end
    removeFromConfig(fingerprint)
elseif args[1] == "clear" then
    clearConfig()
else
    printUsage()
end