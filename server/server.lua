
-- Events --
globalActiveUnits = {}
RegisterNetEvent('000:getactiveunits')
AddEventHandler('000:getactiveunits', function(activeUnits)
    if type(activeUnits) == "table" then
        for _, unit in ipairs(activeUnits) do
                table.insert(globalActiveUnits, unit)
            end
    else
        print("Received data is not a valid table!")
    end
end)

RegisterNetEvent('000:fetchNearbyStreets')
AddEventHandler('000:fetchNearbyStreets', function(street, crossing)
    location = ""
    if crossing ~= "" then
        location = street .. " / " .. crossing
    else
        location = street
    end
end)

-- Commands --
RegisterCommand(Config.command, function(source, args, raw)
    -- Input Checks -- 
    if not args[1] or not args[2] then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "You need to select a department and add a call description"}})
        return 
    end 

    if string.len(tostring(args[1])) > 6 then
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "That is not a valid department."}})
        return 
    end 

    local desc = table.concat(args,"", 2)

    if string.len(tostring(desc)) < Config.minimumcalldescriptionLength then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "Please add more detail to your call description."}})
        return 
    end

    -- Use Animation

    local departmentRequired = tostring(args[1])
    local callDescription = table.concat(args, " ", 2)
    local callId = math.random(1000, 9000)
    local coords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('000:getStreets', source, coords)
    Wait(500)

    if departmentRequired == "police" then 
        TriggerClientEvent('000:phoneAnimation', source)
        for _, unit in ipairs(globalActiveUnits) do 
            if unit.department == "police" then
            TriggerClientEvent('chat:addMessage', unit.id, {
                color = {0,0,255},
                args = {"[Police Dispatch]:", "Call ID: **" .. string.upper(callId) .. "** has been generated, caller reports " .. callDescription .. " at: " .. location .. "   A GPS location has been sent to your MDT."},
                multiline = true
            })
            TriggerClientEvent('000:addBlip', unit.id, coords, callId)
        end
        end
    end

    if departmentRequired == "medic" then 
        TriggerClientEvent('000:phoneAnimation', source)
        for _, unit in ipairs(globalActiveUnits) do 
            if unit.department == "medic" then 
                TriggerClientEvent('chat:addMessage', unit.id, {
                    color = {255, 193, 203},
                    args = {"[Medic Dispatch]:", "Call ID: **" .. string.upper(callId) .. "** has been generated, caller reports " .. callDescription .. " at: " .. location .. "   A GPS location has been sent to your MDT."},
                })
                TriggerClientEvent('000:addBlip', unit.id, coords, callId)
            end
        end
    end

    if departmentRequired == "fire" then
        TriggerClientEvent('000:phoneAnimation', source)
        for _, unit in ipairs(globalActiveUnits) do 
            if unit.department == "fire" then 
                TriggerClientEvent('chat:addMessage', unit.id, {
                    color = {255,0,0},
                    args = {"[Fire Dispatch]:", "Call ID: **" .. string.upper(callId) .. "** has been generated, caller reports " .. callDescription .. " at: " .. location .. "   A GPS location has been sent to your MDT."},
                })
                TriggerClientEvent('000:addBlip', unit.id, coords, callId)
            end
        end
    end

    if departmentRequired ~= "police" and departmentRequired ~= "medic" and departmentRequired ~= "fire" then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "That is not a valid department."}})
        return
    end 
end)