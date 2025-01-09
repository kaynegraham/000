Config = {
    command = "000",
    emergencySystem = "command", -- How to get emergency personnel, either command or ace permissions (not yet available)
    emergencySystemCommand = "toggleduty", -- If using the command system, this is the command to toggle duty
    emergencySystemPassword = "leo", -- Password to toggle duty for all departments, will change in future.
    departments = {"leo", "fire", "medic"}, -- Departments, do not change.
    minimumcalldescriptionLength = 10 -- How short a call description can be
}