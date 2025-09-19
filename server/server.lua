-- Server Side
local VORPcore = exports.vorp_core:GetCore()
local BellsInCooldown = {}

RegisterServerEvent('mms-alarmbell:server:SyncSoundToClient',function(CurrentBell)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Job = Character.job
    if CurrentBell.JoblockActive then
        local CanUseBell = false
        for h,v in ipairs(CurrentBell.Jobs) do
            if v.Job == Job then
                CanUseBell = true
            end
        end
        if CanUseBell then
            for h,v in ipairs(GetPlayers()) do
                TriggerClientEvent('mms-alarmbell:client:PlayBellSound',v,CurrentBell)
            end
            local BellData = { BellCoords = CurrentBell.Coords, BellCooldown = CurrentBell.BellCooldown * 1000, BellInCooldown = true }
            table.insert(BellsInCooldown,BellData)
        else
            VORPcore.NotifyRightTip(src,_U('NotTheRightJob'),5000)
        end
    else
        for h,v in ipairs(GetPlayers()) do
            TriggerClientEvent('mms-alarmbell:client:PlayBellSound',v,CurrentBell)
        end
        local BellData = { BellCoords = CurrentBell.Coords, BellCooldown = CurrentBell.BellCooldown * 1000, BellInCooldown = true }
        table.insert(BellsInCooldown,BellData)
    end
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5000)
        if #BellsInCooldown > 0 then
            for h,v in ipairs(BellsInCooldown) do
                v.BellCooldown = v.BellCooldown - 5000
                if v.BellCooldown <= 0 then
                    v.BellInCooldown = false
                    table.remove(BellsInCooldown,h)
                end
            end
        end
    end
end)

VORPcore.Callback.Register('mms-alarmbell:server:GetBellsInCooldown', function(source,cb)
    return cb(BellsInCooldown)
end)