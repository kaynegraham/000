Config = {
    command = "000",
    emergencySystem = "command", -- How to get emergency personnel, either command or ace permissions (not yet available)
    emergencySystemCommand = "toggleavailable", -- If using the command system, this is the command to toggle duty
    emergencySystemPassword = "password", -- Password to toggle duty for all departments, will change in future.
    departments = {"police", "fire", "medic"}, -- Departments, do not change.
    minimumcalldescriptionLength = 10, -- How short a call description can be
    timebeforeblipDeletion = 300000, -- How long before deleting the blip, default: 5 Minutes
    callexpiryTime = 60000, -- How long before a callout expires, default: 1 Minute 
    callCooldown = 60000, -- Cooldown between a person making a 000 call, default: 1 Minute
}