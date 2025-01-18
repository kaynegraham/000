-- Variables
globalActiveUnits = {}
activeCalls = {}
callMade = false 

-- Events --
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
    -- Prevent Spam -- 
    if callMade then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]", "You recently made a 000 call, please wait."}})
        return 
    end

    -- Input Checks -- 
    if not args[1] or not args[2] then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]", "You need to select a department and add a call description"}})
        return 
    end 

    if string.len(tostring(args[1])) > 6 then
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]", "That is not a valid department."}})
        return 
    end 

    local desc = table.concat(args,"", 2)

    if string.len(tostring(desc)) < Config.minimumcalldescriptionLength then 
        TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]", "Please add more detail to your call description."}})
        return 
    end

        -- Input checking
        local departmentRequired = tostring(args[1])
        if departmentRequired ~= "police" and departmentRequired ~= "medic" and departmentRequired ~= "fire" then 
            TriggerClientEvent("chat:addMessage", source, { color = { 255,0,0}, args = {"[000]", "That is not a valid department."}})
            return
        end 

            -- Create Callout
    local callDescription = table.concat(args, " ", 2)
    local callId = math.random(1000, 9000)
    local coords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('000:getStreets', source, coords)
    Wait(500)
    callMade = true

    -- Insert into table
    activeCalls[callId] = {
        id = callId,
        description = callDescription,
        location = location,
        coords = coords, 
        acceptedBy = nil,
        expiresAt = os.time() + Config.callexpiryTime
    }

    if departmentRequired == "police" then 
        TriggerClientEvent('000:phoneAnimation', source)
        for _, unit in ipairs(globalActiveUnits) do 
            if unit.department == "police" then
            TriggerClientEvent('000:dispatchUnit', unit.id, callId, callDescription, location, coords)
             end
        end
    end

    if departmentRequired == "medic" then 
        TriggerClientEvent('000:phoneAnimation', source)
        for _, unit in ipairs(globalActiveUnits) do 
            if unit.department == "medic" then 
                TriggerClientEvent('000:dispatchUnit', unit.id, callId, callDescription, location, coords)
            end
        end
    end

    if departmentRequired == "fire" then
        TriggerClientEvent('000:phoneAnimation', source)
        for _, unit in ipairs(globalActiveUnits) do 
            if unit.department == "fire" then 
                TriggerClientEvent('000:dispatchUnit', unit.id, callId, callDescription, location, coords)
            end
        end
    end

    -- If callout not accepted then remove 
    CreateThread(function()
        Wait(Config.callexpiryTime)
        if activeCalls[callId] and not activeCalls[callId].acceptedBy then 
            activeCalls[callId] = nil 
        end
    end)

    -- Cooldown before making another 000 call 
    CreateThread(function()
        while callMade do 
            Wait(Config.callCooldown)
            callMade = false
        end
    end)
end)

-- Call Accepted
RegisterNetEvent('000:acceptCall')
AddEventHandler('000:acceptCall', function(callId)
    local src =  source 
    if activeCalls[callId] and not activeCalls[callId].acceptedBy then 
        activeCalls[callId].acceptedBy = src 
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            args = {"[Dispatch]", "You accepted Call ID: **" .. callId .. "** near: " .. activeCalls[callId].location}
        })
        TriggerClientEvent('000:addBlip', src, activeCalls[callId].coords, callId)
    else 
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            args = {"[Dispatch]", "Callout: **" .. activeCalls[callId].callId .. "** is no longer available."}
        })
    end 
end)