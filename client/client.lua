local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local xSound = exports.xsound

local AlarmBellBlips = {}
local CreatedBells = {}


Citizen.CreateThread(function()
    local BellPromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local RingBellPrompt = BellPromptGroup:RegisterPrompt(_U('RingBell'), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'}) -- KEY G

        -- Create Blips
        for h,v in pairs(Config.AlarmBells) do
            if v.CreateBlip then
                local BellBlip = BccUtils.Blips:SetBlip(v.AlarmName, v.BlipSprite, v.BlipSize, v.Coords.x,v.Coords.y,v.Coords.z)
                AlarmBellBlips[#AlarmBellBlips + 1] = BellBlip
            end
        end

        -- Create Props
        for h,v in pairs(Config.AlarmBells) do
            if v.CreateProp then
                local AlarmBellProp = CreateObject(v.PropModel, v.Coords.x,v.Coords.y,v.Coords.z -1,true,true,false)
                PlaceObjectOnGroundProperly(AlarmBellProp)
                SetEntityInvincible(AlarmBellProp,true)
                FreezeEntityPosition(AlarmBellProp,true)
                SetEntityAlwaysPrerender(AlarmBellProp,false)
                CreatedBells[#CreatedBells + 1] = AlarmBellProp
            end
        end

    while true do
        Wait(3)
        for h,v in pairs(Config.AlarmBells) do
            local MyPos = GetEntityCoords(PlayerPedId())
            local Distance = #(MyPos - v.Coords)
            if Distance < 3 then
                BellPromptGroup:ShowGroup(v.AlarmName)

                if RingBellPrompt:HasCompleted() then
                    local BellPos = v.Coords
                    local CurrentBell = v
                    local HasCooldown = false
                    local BellsInCooldown = VORPcore.Callback.TriggerAwait('mms-alarmbell:server:GetBellsInCooldown')
                    if #BellsInCooldown > 0 then
                        for h,v in ipairs(BellsInCooldown) do
                            if v.BellCoords == BellPos and v.BellInCooldown then
                                HasCooldown = true
                            end
                        end
                    end
                    if not HasCooldown and v.RingBell then
                        TriggerServerEvent('mms-alarmbell:server:SyncSoundToClient',CurrentBell)
                    elseif HasCooldown then
                        VORPcore.NotifyRightTip(_U('BellInCooldown'),5000)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mms-alarmbell:client:PlayBellSound',function(CurrentBell)
    xSound:PlayUrlPos(CurrentBell.AlarmName, CurrentBell.BellLink, CurrentBell.BellVolume, CurrentBell.Coords, 0)
    xSound:Distance(CurrentBell.AlarmName,CurrentBell.BellRadius)
    Citizen.Wait(CurrentBell.BellDuration*1000)
    xSound:Destroy(CurrentBell.AlarmName)
end)

----------------- Utilities -----------------

---- CleanUp on Resource Restart 

RegisterNetEvent('onResourceStop',function(resource)
    if resource == GetCurrentResourceName() then
        for _, Bell in ipairs(CreatedBells) do
            DeleteObject(Bell)
        end
        for _, blips in ipairs(AlarmBellBlips) do
            blips:Remove()
        end
    end
end)