local function notify(msg)
    print(msg) -- Replace with your client-side notification logic if needed
end

-- Check if player has a knife equipped
local function hasKnifeEquipped()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    return weapon == GetHashKey("weapon_melee_knife")
end

-- Detect dead animals and attach target if knife is equipped
CreateThread(function()
    while true do
        Wait(1000)
        local pedList = GetGamePool("CPed")

        for _, ped in pairs(pedList) do
            if IsEntityDead(ped) and not IsPedAPlayer(ped) and not Entity(ped).state.skinned then
                local model = GetEntityModel(ped)

                if Config.Animals[model] or Config.SmallAnimals[model] then
                    -- Only allow target if player has a knife
                    if hasKnifeEquipped() then
                        Entity(ped).state:set("skinned", true, true)

                        exports["rsg-target"]:AddTargetEntity(ped, {
                            options = {
                                {
                                    label = "Skin Animal",
                                    icon = "fas fa-cut",
                                    action = function(entity)
                                        local dict = "amb_work@world_human_butchery@table@male@base"
                                        RequestAnimDict(dict)
                                        while not HasAnimDictLoaded(dict) do Wait(100) end
                                        TaskPlayAnim(PlayerPedId(), dict, "base", 8.0, -8.0, 15000, 1, 0, false, false, false)

                                        local model = GetEntityModel(entity)
                                        TriggerServerEvent("rsg_hunting:skinAnimal", model)
                                        Wait(1500)
                                        DeleteEntity(entity)
                                    end,
                                }
                            },
                            distance = 2.0
                        })
                    end
                end
            end
        end
    end
end)
