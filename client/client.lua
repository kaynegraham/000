-- Variables -- 
local clockedOn = false 
activeUnits = {}

-- Commands -- 
RegisterCommand(Config.emergencySystemCommand, function(source, args)
    if not args[1] or not args[2] then 
        showAlert("You must enter a password and department.", 3500)
        return 
    end 

    TriggerEvent('000:clockon', args)
end)

RegisterCommand("dutystatus", function()
    if clockedOn then 
        showAlert("You are clocked on in: " .. LocalPlayer.state.department, 3500)
    else
        showAlert("You are not clocked on.") 
    end
end)


-- Functions -- 
function showAlert(message, duration)
    AddTextEntry('000:alert', message)
    BeginTextCommandDisplayHelp('000:alert')
    EndTextCommandDisplayHelp(0, false, true, duration)
end


-- Events --
-- Client-Side Event: Clocking on and sending the active unit data
RegisterNetEvent('000:clockon')
AddEventHandler('000:clockon', function(args)
    -- Logic for clocking in and setting the department (same as before)

    local requesteddepartment = tostring(args[2])
    local departments = Config.departments
    local departmentName = ""

    if requesteddepartment == departments[1] then 
        departmentName = "leo"
        LocalPlayer.state:set("department", departmentName)
    elseif requesteddepartment == departments[2] then 
        departmentName = "fire"
        LocalPlayer.state:set("department", departmentName)
    elseif requesteddepartment == departments[3] then 
        departmentName = "medic"
        LocalPlayer.state:set("department", departmentName)
    end

    -- Create a table with player ID and department name and send to the server
    if departmentName ~= "" then
        table.insert(activeUnits, { id = PlayerId(), department = departmentName })
    end

    -- Send the activeUnits table to the server
    TriggerServerEvent('000:getactiveunits', activeUnits)
end)

RegisterNetEvent('000:getStreets')
AddEventHandler('000:getStreets', function(coords)
    local streetName, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    streetName = GetStreetNameFromHashKey(streetName)
    crossing = GetStreetNameFromHashKey(crossing)
    TriggerServerEvent('000:fetchNearbyStreets', streetName, crossing)
end)