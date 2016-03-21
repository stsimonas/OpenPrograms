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


local mecomp = nil

if component.isAvailable("me_controller") then
    mecomp = component.me_controller
elseif component.isAvailable("me_interface") then
    mecomp = component.me_interface
else
    error("The computer is not connected to an ME Controller or an ME Interface.")
    return
end


local ae = {}

ae.component = mecomp

return ae