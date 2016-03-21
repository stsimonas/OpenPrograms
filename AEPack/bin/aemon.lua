local component = require("component")
local mei = component.me_interface

local items = {
	["minecraft:bread"] = 200
	,["minecraft:torch"] = 200
	,["minecraft:iron_ingot"] = 100
	,["minecraft:gold_ingot"] = 100
	,["ExtraUtilities:colorStoneBrick"] = 200
}
local sleepTime = 1

local requests = {}

while true do
	for itemId, requiredCount in pairs(items) do
		local itemDetails = mei.getItemDetail({id=itemId}).basic()
		local currentCount = itemDetails.qty
		local displayName = itemDetails.display_name
		
		local diff = requiredCount - currentCount
		local msg = ""
		
		if diff > 0 then
			local request = requests[itemId]
			local performCrafting = request == nil
			
			if request ~= nil then
				performCrafting = request.isCanceled() or request.isDone()
			end
			
			if performCrafting then
				requests[itemId] = mei.getCraftables({name=itemId})[1].request(diff)
				msg = string.format("crafting %s", diff)
			end
		end
		
		print(string.format("%s : %s / %s %s", displayName, currentCount, requiredCount, msg))
		os.sleep(sleepTime)
	end
end