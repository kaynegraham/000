-- Events --
RegisterNetEvent('000:getactiveunits')
AddEventHandler('000:getactiveunits', function(activeUnits)
            for k, v in ipairs(activeUnits) do
                playerId = k
                department = v.department  
                local player = GetPlayerPed(playerId)  

                if player then
                    print("Player ID:", playerId, "Department:", department)
                else
                    print("Player not found for ID:", playerId)
        end
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
    if not args[1] and not args[2] then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "You need to select a department and add a call description"}})
        return 
    end 

    if string.len(tostring(args[1])) > 5 then
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "That is not a valid department."}})
        return 
    end 

    local desc = table.concat(args,"", 2)

    if string.len(tostring(desc)) < Config.minimumcalldescriptionLength then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]:", "Please add more detail to your call description."}})
        return 
    end

    local departmentRequired = tostring(args[1])
    local callDescription = table.concat(args, " ", 2)
    local callId = source
    local coords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('000:getStreets', source, coords)

    if departmentRequired == "leo" then 
        if department == "leo" then
            TriggerClientEvent('chat:addMessage', playerId, {
                color = {0,0,255},
                args = {"[VKG]:", "Attention all units, help is required at " .. location}
            })
        end
    end

    -- finish other departments

end)