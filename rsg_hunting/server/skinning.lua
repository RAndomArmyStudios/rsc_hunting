RegisterNetEvent("rsg_hunting:skinAnimal")
AddEventHandler("rsg_hunting:skinAnimal", function(model)
    local src = source
    local animal = Config.Animals[model] or Config.SmallAnimals[model]

    if not animal then
        print("[rsg_hunting] Unknown animal model: " .. tostring(model))
        return
    end

    local items = animal.givenItem
    local amounts = animal.givenAmount or {}

    if type(items) ~= "table" then items = { items } end
    if type(amounts) ~= "table" then amounts = { amounts } end
    while #amounts < #items do table.insert(amounts, 1) end

    for i = 1, #items do
        local item = items[i]
        local amount = amounts[i]
        print(("[rsg_hunting] Giving %s x%s to %s"):format(item, amount, src))
        exports["rsg-inventory"]:AddItem(src, item, amount)
    end
end)
