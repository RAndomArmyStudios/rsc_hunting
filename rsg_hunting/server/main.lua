RegisterNetEvent("rsg_hunting:giveReward", function(items, money, gold, xp, amounts)
    local src = source

    -- Give money as item
    if money and money > 0 then
        exports["rsg-inventory"]:AddItem(src, "dollar", money)
    end

    if cent and cent > 0 then
        exports["rsg-inventory"]:AddItem(src, "cent", cent)
    end

    -- Optional XP handling
    if xp and xp > 0 then
        -- You can replace this with your own XP system if you have one
        print(("Gave %s XP to player %s"):format(xp, src))
    end

    -- Give actual items (pelts, feathers, etc.)
    if items and type(items) == "table" and amounts and type(amounts) == "table" then
        for i = 1, #items do
            local item = items[i]
            local amt = amounts[i] or 1
            if item then
                exports["rsg-inventory"]:AddItem(src, item, amt)
            end
        end
    end
end)