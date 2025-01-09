-- Variables -- 
local clockedOn = false 
local suggestionsAdded = false
activeUnits = {}

-- Commands -- 
RegisterCommand(Config.emergencySystemCommand, function(source, args)
    if clockedOn then 
        showAlert("You are now off duty", 3500)
        LocalPlayer.state:set("department", nil)
        clockedOn = false
        return
    end 

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
RegisterNetEvent('000:clockon')
AddEventHandler('000:clockon', function(args)
    -- Check Password
    if tostring(args[2]) == Config.emergencySystemPassword then 
        showAlert("You are now on duty", 3500)
        clockedOn = true 
    else 
        showAlert("Incorrect Password.", 3500)
        return 
    end

    local requesteddepartment = tostring(args[1])
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

    TaskPlayAnim(PlayerPedId(), dict, clip, 1.0, -1, 2500, 50, false, false, false)
end)

-- Add Blip -- 
RegisterNetEvent('000:addBlip')
AddEventHandler('000:addBlip', function(coords, callid)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z) 
    SetBlipRotation(blip, 0)
    SetBlipSprite(blip, 93)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("~h~000~h~ Call: " .. callid) 
    EndTextCommandSetBlipName(blip)
    SetBlipDisplay(blip, 4)
    SetNewWaypoint(coords.x, coords.y)
    Wait(30000)
    ClearGpsPlayerWaypoint()
    RemoveBlip(blip)
end)


-- Threads -- 
CreateThread(function()
    while not suggestionsAdded do 
        TriggerEvent('chat:addSuggestions', {
            {
                name = "/" .. Config.emergencySystemCommand,
                help = "Toggle Duty for 000",
                params = {
                    { name = "department", help="Name of Department (leo, fire, medic)"},
                    { name = "password", help="Password for Toggling Duty"}
                }
            },
            {
                name = "/" .. Config.command,
                help = "Call 000",
                params = {
                    { name = "department", help="Department you require, (leo, fire, medic)"},
                    { name = "report", help="What are you reporting? (eg Bar Fight), location doesn't need to be included."}
                }
            }
        })
        Wait(1000)
    end
end)