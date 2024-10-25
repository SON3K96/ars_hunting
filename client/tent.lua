if not Config.Tent.enable then return end

local ox_inventory = exports.ox_inventory
local ped = cache.ped
local stashId


local function openTentMenu(tent)
    lib.registerContext({
        id = 'tent_menu',
        title = locale("tent_menu_title"),
        options = {
            {
                title = locale("open_stash"),
                icon = Config.ImagesPath .. "tent.png",
                onSelect = function()
                    --print("Opening Tent Stash Event Triggered, Stash ID: " .. stashId)  -- Debug
                    ox_inventory:openInventory('stash', { id = stashId })
                end
            },
            {
                title = locale("take_tent"),
                icon = "fa-solid fa-xmark",
                iconColor = "#fc8803",
                onSelect = function()
                    lib.progressBar({
                        duration = 1000,
                        label = locale("taking_tent"),
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true
                        },
                        anim = {
                            dict = 'pickup_object',
                            clip = 'pickup_low'
                        },
                    })
                    local data = {
                        coords = GetEntityCoords(tent)
                    }
                    DeleteEntity(tent)
                    TriggerServerEvent("ars_hunting:takeTent", data)
                end
            }
        }
    })

    lib.showContext("tent_menu")
end


local function useTent()
    lib.requestModel("prop_skid_tent_cloth")

    lib.progressBar({
        duration = 1000,
        label = locale("placing_tent"),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true
        },
        anim = {
            dict = 'pickup_object',
            clip = 'pickup_low'
        },
    })

    
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.5, 5.0)
    local tent = CreateObjectNoOffset("prop_skid_tent_cloth", coords.x, coords.y, coords.z, true, true, true)

    PlaceObjectOnGroundProperly(tent)
    stashId = "Zelt-" .. GetPlayerServerId(PlayerId())
    TriggerServerEvent('ars_hunting:registerTentStash', stashId)

    if Config.Target then
        if Config.Target == "ox_target" then
            exports.ox_target:addLocalEntity(tent, {
                {
                    name = "tent_stash",
                    label = locale('interact_tent'),
                    icon = 'fa-solid fa-box',
                    onSelect = function(data)
                        openTentMenu(tent)
                    end
                },
            })
        elseif Config.Target == "qb-target" then
            exports['qb-target']:AddTargetEntity(tent, {
                options = {
                    {
                        num = 1,
                        type = "client",
                        icon = 'fas fa-box',
                        label = locale('interact_tent'),
                        action = function()
                            openTentMenu(tent)
                        end,
                    }
                },
                distance = 2.5,
            })
        end
    else
        local tentPoint = lib.points.new({
            coords = GetEntityCoords(tent),
            distance = 5,
        })
        
        function tentPoint:nearby()
            if self.currentDistance <= 3.0 then
                utils.drawText3D(GetEntityCoords(tent), locale("interact_tent"), 1, 0)

                if IsControlJustReleased(0, 38) then
                    openTentMenu(tent, tentPoint)
                end
            end
        end
    end
end


RegisterNetEvent("ars_hunting:useTent", useTent)
