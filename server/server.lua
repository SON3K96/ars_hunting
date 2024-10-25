function getRarity(items)
    local chance = math.random(1, 100)
    local eligibleItems = {}

    for _, item in pairs(items) do
        if item.chance >= chance then
            print(item.item, item.chance, chance)
            table.insert(eligibleItems, item)
        end
    end

    if #eligibleItems > 0 then
        local selectedIdx = math.random(1, #eligibleItems)
        print(selectedIdx)
        return eligibleItems[selectedIdx]
    else
        return getRarity(items)
    end
end

RegisterNetEvent("ars_hunting:harvestAnimal", function(data)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    local dist = #(playerCoords - data.coords)

    if dist > 8.0 then return print("ARS HUNTING >> PLAYER MIGHT BE CHEATING ID: " .. source) end


    local skin = getRarity(data.items.skins)
    local meat = getRarity(data.items.meat)

    framework.addItems({ target = source, items = { { item = skin.item, quantity = math.random(1, skin.maxQuantity) } } })
    framework.addItems({ target = source, items = { { item = meat.item, quantity = math.random(1, meat.maxQuantity) } } })

    if 0.3 >= math.random() then
        local extraItem = getRarity(data.items.extra)
        framework.addItems({ target = source, items = { { item = extraItem.item, quantity = math.random(1, extraItem.maxQuantity) } } })
    end
end)

RegisterNetEvent("ars_hunting:cookItem", function(data)
    for _, item in pairs(data.required) do
        framework.removeItem({ target = source, item = item.item, count = item.quantity })
    end
    framework.addItems({ target = source, items = data.give })
end)

RegisterNetEvent("ars_hunting:takeCampfire", function(data)
    local sourcePed = GetPlayerPed(source)

    if #(GetEntityCoords(sourcePed) - data.coords) > 4.0 then return print("ARS HUNTING >> PLAYER MIGHT BE CHEATING ID: " .. source) end
    framework.addItems({ target = source, items = Config.Campfire.campfireItem })
end)


RegisterNetEvent("ars_hunting:sellBuyItem", function(data)
    local source = source
    if data.buy then
        if framework.hasMoney(source) >= data.price then
            framework.removeMoney({ target = source, amount = data.price })
            framework.addItems({ target = source, items = { { item = data.item, quantity = data.quantity } } })
        else
            TriggerClientEvent("ars_hunting:showNotification", source, locale("not_enough_money"))
        end
    else
        if framework.hasItems({ target = source, items = { { item = data.item, quantity = data.quantity } } }) then
            framework.removeItem({ target = source, item = data.item, count = data.quantity })
            framework.addMoney({ target = source, amount = data.price })
        else
            TriggerClientEvent("ars_hunting:showNotification", source, locale("not_enough_item"))
        end
    end
end)

RegisterNetEvent("ars_hunting:finishMission", function(data)
    local source = source
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local dist = #(playerCoords - Config.HuntMaster.coords.xyz)
    if dist > 3.0 then return print("ARS HUNTING >> PLAYER MIGHT BE CHEATING ID: " .. source) end

    framework.addItems({ target = source, items = data.rewards })

    if data.requirements then
        for _, item in pairs(data.requirements) do
            framework.removeItem({ target = source, item = item.item, count = item.quantity })
        end
    end
end)

RegisterNetEvent("ars_hunting:missionTime", function(data)
    local playerIdentifier = GetPlayerIdentifierByType(source, "license")
    local time = os.time()

    if data.method == "set" then
        SetResourceKvp(data.id .. "_" .. playerIdentifier, tostring(time))
    end
end)

lib.callback.register('ars_hunting:canDoMission', function(source, id, delay)
    local playerIdentifier = GetPlayerIdentifierByType(source, "license")
    local missionStartTime = GetResourceKvpString(id .. "_" .. playerIdentifier) or 0
    local currentTime = os.time()

    local timeDifference = currentTime - missionStartTime

    if timeDifference >= (delay * 60) then return true end

    return (delay * 60) - timeDifference
end)

lib.callback.register('ars_hunting:hasItems', function(source, items)
    return framework.hasItems({ target = source, items = items })
end)

local registeredStashes = {}
local ox_inventory = exports.ox_inventory


RegisterNetEvent("ars_hunting:takeTent", function(data)
    local sourcePed = GetPlayerPed(source)

    if #(GetEntityCoords(sourcePed) - data.coords) > 4.0 then
        print("ARS HUNTING >> PLAYER MIGHT BE CHEATING ID: " .. source)
        return
    end

    framework.addItems({ target = source, items = Config.Tent.tentItem })
end)


RegisterServerEvent('ars_hunting:registerTentStash')
AddEventHandler('ars_hunting:registerTentStash', function(stashId)
    if not registeredStashes[stashId] then

        local stashLabel = 'Stash (' .. stashId .. ')'

        ox_inventory:RegisterStash(stashId, stashLabel, 50, 100000, true)
        registeredStashes[stashId] = true
        --print("Tent Stash registered: " .. stashId)  -- Debug-Ausgabe
    end
end)


RegisterNetEvent('inventory:openStash', function(stashId)
    local source = source
    --print("Stash Event Received on Server, Stash ID: " .. stashId)  -- Debug
    TriggerClientEvent('ox_inventory:client:OpenStash', source, stashId)
end)

lib.versionCheck('Arius-Development/ars_hunting')
