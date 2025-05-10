local peltz = {}

function DataViewNativeGetEventData(eventGroup, index, argStructSize)
    local buffer = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, eventGroup, index, Citizen.PointerValueInt(), argStructSize, Citizen.ResultAsInteger())
    local result = {}
    for i = 0, argStructSize - 1 do
        result[tostring(i)] = Citizen.InvokeNative(0xA8E3F467A2F04DDE, buffer + (i * 4), Citizen.ResultAsInteger())
    end
    return result
end

local function notify(msg)
    print(msg) -- replace with client notification if needed
end

function sellAnimal()
    local ped = PlayerPedId()
    local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
    local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
    local model = GetEntityModel(holding)
    local horse = Citizen.InvokeNative(0x4C8B59171957BCF7, ped)

    local function payOut(animal, actualQuality)
        local givenItem = animal.givenItem
        local givenAmount = animal.givenAmount
        local money = animal.money or 0
        local gold = animal.gold or 0
        local cent = animal.cent or 0
        local xp = animal.xp or 0

        local multiplier = 1.0
        if actualQuality == animal.perfect then
            multiplier = animal.perfectQualityMultiplier or 2
        elseif actualQuality == animal.good then
            multiplier = animal.goodQualityMultiplier or 1.5
        elseif actualQuality == animal.poor then
            multiplier = animal.poorQualityMultiplier or 1.0
        end

        if type(givenItem) ~= "table" then givenItem = { givenItem } end
        if type(givenAmount) ~= "table" then givenAmount = { givenAmount } end
        while #givenAmount < #givenItem do table.insert(givenAmount, 1) end

        TriggerServerEvent("rsg_hunting:giveReward", givenItem, money * multiplier, gold * multiplier, xp * multiplier, givenAmount)
        notify("You received $" .. math.floor(money * multiplier))
    end

    if holding and Config.Animals[model] then
        payOut(Config.Animals[model], quality)
        DeleteEntity(holding)
        return
    end

    notify(Config.Language.NotHoldingAnimal)
end

function setupTargetZones()
    for i, v in ipairs(Config.Butchers) do
        local x, y, z = table.unpack(v.coords)

        exports['rsg-target']:AddBoxZone("butcher_zone_" .. i, vector3(x, y, z), 2.0, 2.0, {
            name = "butcher_zone_" .. i,
            heading = v.heading,
            minZ = z - 1.0,
            maxZ = z + 2.0,
        }, {
            options = {
                {
                    label = "Sell Animal",
                    icon = "fas fa-drumstick-bite",
                    action = function()
                        sellAnimal()
                    end,
                }
            },
            distance = 2.5
        })

        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)
        SetBlipSprite(blip, v.blip, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.butchername)
    end
end

CreateThread(setupTargetZones)

-- Small animal handler
CreateThread(function()
    while true do
        Wait(2)
        local size = GetNumberOfEvents(0)
        if size > 0 then
            for index = 0, size - 1 do
                local event = GetEventAtIndex(0, index)
                if event == 1376140891 then
                    local buffer = DataViewNativeGetEventData(0, index, 3)
                    local pedGathered = buffer['2']
                    local ped = buffer['0']
                    local model = GetEntityModel(pedGathered)

                    if model and Config.SmallAnimals[model] and PlayerPedId() == ped then
                        local animal = Config.SmallAnimals[model]
                        local givenItem = animal.givenItem
                        local givenAmount = animal.givenAmount
                        local money = animal.money or 0
                        local gold = animal.gold or 0
                        local xp = animal.xp or 0

                        if type(givenItem) ~= "table" then givenItem = { givenItem } end
                        if type(givenAmount) ~= "table" then givenAmount = { givenAmount } end
                        while #givenAmount < #givenItem do table.insert(givenAmount, 1) end

                        TriggerServerEvent("rsg_hunting:giveReward", givenItem, money, gold, xp, givenAmount)

                        local output = (#givenItem == 1 and #givenAmount == 1 and givenAmount[1] > 1)
                            and (givenItem[1] .. "s") or givenItem[1] or "items"
                        notify("You received " .. output)
                    end
                end
            end
        end
    end
end)
