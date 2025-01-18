-- Variables -- 
local clockedOn = false 
local suggestionsAdded = false
activeUnits = {}

-- Commands -- 
RegisterCommand(Config.emergencySystemCommand, function(source, args)
    if clockedOn then 

        if LocalPlayer.state.department == args[1] then 
            TriggerEvent('chat:addMessage', {color = {0, 255, 0}, args = {"[Dispatch]", "You are already clocked in as " .. args[1]}})
            return 
        else 
        TriggerEvent('chat:addMessage', {color = {0, 255, 0}, args = {"[Dispatch]", "You are now clocked off"}})
        LocalPlayer.state:set("department", nil)
        clockedOn = false
    end 
end

    if not args[1] or not args[2] then 
        TriggerEvent('chat:addMessage', {color = {0, 255, 0}, args = {"[Dispatch]", "You must enter a department and/or password."}})
        return 
    end 

    TriggerEvent('000:clockon', args)
end)

RegisterCommand("dutystatus", function()
    if clockedOn then 
        TriggerEvent('chat:addMessage', { color = {0, 255, 0}, args = {"[Dispatch]", "You are clocked on as: " .. LocalPlayer.state.department}})
    else
        TriggerEvent('chat:addMessage', { color = {0, 255, 0}, args = {"[Dispatch]", "You are not clocked on."}})
    end
end)

-- Events --
RegisterNetEvent('000:clockon')
AddEventHandler('000:clockon', function(args)
    -- Check Password
    if tostring(args[2]) == Config.emergencySystemPassword then 
        TriggerEvent('chat:addMessage', { color = {0, 255, 0}, args = {"[Dispatch]", "You are now clocked in as: " .. tostring(args[1])}})
        clockedOn = true 
    else 
        TriggerEvent('chat:addMessage', { color = {0, 255, 0}, args = {"[Dispatch]", "You entered the incorrect password."}})
        return 
    end

    local requesteddepartment = tostring(args[1])
    local departments = Config.departments
    local departmentName = ""

    if requesteddepartment == departments[1] then 
        departmentName = "police"
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
        local networkId = GetPlayerServerId(PlayerId())
        local pos = 1
        table.insert(activeUnits, pos, { id = networkId, department = departmentName })
        pos = pos + 1
    end

    -- Send the activeUnits table to the server
    TriggerServerEvent('000:getactiveunits', activeUnits)
end)

-- Get Nearby Streets -- 
RegisterNetEvent('000:getStreets')
AddEventHandler('000:getStreets', function(coords)
    local streetName, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    streetName = GetStreetNameFromHashKey(streetName)
    crossing = GetStreetNameFromHashKey(crossing)
    TriggerServerEvent('000:fetchNearbyStreets', streetName, crossing)
end)

-- Phone Animation --
RegisterNetEvent('000:phoneAnimation')
AddEventHandler('000:phoneAnimation', function()
    local dict = "cellphone@"
    local clip = "cellphone_text_to_call"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end

    PhoneProp()
    TaskPlayAnim(PlayerPedId(), dict, clip, 1.0, 1.0, 2500, 50, false, false, false)
    Wait(3000)
    DeleteObject(phone)
end)

-- Phone Prop -- 
function PhoneProp()
    local phoneProp = `prop_amb_phone`
    local coords = GetEntityCoords(PlayerPedId())
    local bone = GetPedBoneIndex(PlayerPedId(), 28422) 
    RequestModel(phoneProp)
    while not HasModelLoaded(phoneProp) do 
        Wait(1)
    end 
    phone = CreateObject(phoneProp, coords.x, coords.y, coords.z, true, false, false)
    AttachEntityToEntity(phone, PlayerPedId(), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
end

-- Add Blip -- 
RegisterNetEvent('000:addBlip')
AddEventHandler('000:addBlip', function(coords, callid)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z) 
    SetBlipRotation(blip, 0)
    SetBlipSprite(blip, 66)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("~h~000~h~ Call: " .. callid) 
    EndTextCommandSetBlipName(blip)
    SetBlipDisplay(blip, 4)
    SetNewWaypoint(coords.x, coords.y)
    Wait(Config.timebeforeblipDeletion) -- 5 minutes
    RemoveBlip(blip)
end)

-- Input Check -- 
currentCall = nil 
callActive = false 

RegisterNetEvent('000:dispatchUnit')
AddEventHandler('000:dispatchUnit', function(callId, description, location, coords)
    callActive = true 
    currentCall = callId

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {"[Dispatch]", "Call ID: **" .. string.upper(callId) .. "** has been generated, caller reports " .. description .. " at: " .. location .. "   Press (Y) to accept the callout"}
    })

    CreateThread(function()
        local callAccepted = false 
        local expireTime = GetGameTimer() + Config.callexpiryTime 
        while GetGameTimer() < expireTime do 
            Wait(0)
            if IsControlJustPressed(1, 246) then
                if currentCall == callId then 
                callAccepted = true 
                TriggerServerEvent('000:acceptCall', callId)
                break 
                end
            end
        end

        if not callAccepted then 
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {"[Dispatch]:", "Call ID: **" .. callId ..  "** has expired."}
            })
        end

        Wait(500)
    end)
end)


-- Threads -- 
CreateThread(function()
    while not suggestionsAdded do 
        TriggerEvent('chat:addSuggestions', {
            {
                name = "/" .. Config.emergencySystemCommand,
                help = "Toggle Duty for 000",
                params = {
                    { name = "department", help="Name of Department (police, fire, medic)"},
                    { name = "password", help="Password for Toggling Duty"}
                }
            },
            {
                name = "/" .. Config.command,
                help = "Call 000",
                params = {
                    { name = "department", help="Department you require, (police, fire, medic)"},
                    { name = "report", help="What are you reporting? (eg Bar Fight), location doesn't need to be included."}
                }
            }
        })
        Wait(1000)
    end
end)

-- Event Handlers -- 
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    ClearGpsPlayerWaypoint()
    DeleteWaypoint()
  end)
  