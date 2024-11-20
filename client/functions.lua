-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local timeSpent = 0

local function setCrutchTime(target, item)
	local input = lib.inputDialog(Strings.crutch_time_dialog, {Strings.minutes_dialog})
    if input then
        local amount = math.floor(input[1])
        if amount < 1 then
            TriggerEvent('wasabi_crutch:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
        elseif Config.maxAssignTime.crutch and amount > Config.maxAssignTime.crutch then
            TriggerEvent('wasabi_crutch:notify', Strings.invalid_entry, (Strings.invalid_entry_max):format(Config.maxAssignTime.crutch), 'error')
        else
            TriggerServerEvent('wasabi_crutch:giveCrutch', target, amount)
            if item then
                TriggerServerEvent('wasabi_crutch:removeItem', Config.usableCrutchItem.item)
            end
        end
    else
        TriggerEvent('wasabi_crutch:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
    end
end

local function setChairTime(target, item)
	local input = lib.inputDialog(Strings.chair_time_dialog, {Strings.minutes_dialog})
    if input then
        local amount = math.floor(input[1])
        if amount < 1 then
            TriggerEvent('wasabi_crutch:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
        elseif Config.maxAssignTime.wheelchair and amount > Config.maxAssignTime.wheelchair then
            TriggerEvent('wasabi_crutch:notify', Strings.invalid_entry, (Strings.invalid_entry_max):format(Config.maxAssignTime.wheelchair), 'error')
        else
            TriggerServerEvent('wasabi_crutch:giveChair', target, amount)
            if item then
                TriggerServerEvent('wasabi_crutch:removeItem', Config.usableWheelchairItem.item)
            end
        end
    else
        TriggerEvent('wasabi_crutch:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
    end
end

function StartCrutchLoop(time)
    CreateThread(function()
        local animSetRequested, oldWalk, obj
        if LoopStarted then BreakLoop = true end
        TriggerEvent('wasabi_crutch:notify', Strings.crutch_added, (Strings.crutch_added_desc):format(time), 'inform')
        while true do
            local sleep = 1000
            if BreakLoop == true then
                ResetPedMovementClipset(cache.ped)
                if DoesEntityExist(obj) then DeleteObject(obj) end
                LoopStarted, BreakLoop, DisableKeys, timeSpent = nil, nil, {}, 0
                break
            end
            if not LoopStarted then LoopStarted = true end
            if not DisableKeys then DisableKeys = {} end
            DisableKeys.crutch = true
            if not animSetRequested then
                oldWalk = GetPedMovementClipset(cache.ped)
                local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(cache.ped,0.0,2.0,0.55))
                lib.requestModel('crutch', 100)
                obj = CreateObjectNoOffset('crutch', x, y, z, true, false)
                SetModelAsNoLongerNeeded('crutch')
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`)
                AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped, 43810), 0.93, -0.15, -0.03, 9.31, -88.64, 177.48, true, true, false, true, 1, true)
                lib.requestAnimSet('move_lester_caneup', 100)
                animSetRequested = true
            end
            if InVehicle and DoesEntityExist(obj) then DeleteObject(obj) end
            if not DoesEntityExist(obj) and not InVehicle then
                lib.requestModel('crutch', 100)
                obj = CreateObjectNoOffset('crutch', x, y, z, true, false)
                SetModelAsNoLongerNeeded('crutch')
                AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped, 43810), 0.93, -0.15, -0.03, 9.31, -88.64, 177.48, true, true, false, true, 1, true)
            end
            if IsPedArmed(cache.ped, 1) or IsPedArmed(cache.ped, 2) or IsPedArmed(cache.ped, 4) then
                TriggerEvent('wasabi_crutch:notify', Strings.cant_wield, Strings.cant_wield_desc, 'error')
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`)
            end
            if GetPedMovementClipset(cache.ped) == oldWalk then
                SetPedMovementClipset(cache.ped, 'move_lester_caneup', 1.0)
            end
            timeSpent = timeSpent + sleep
            if timeSpent >= 60000 then
                TriggerServerEvent('wasabi_crutch:updateCrutch', 1, cache.serverId)
                timeSpent = 0
            end
            Wait(sleep)
        end
    end)
end

function StartChairLoop(time)
    CreateThread(function()
        local chairVeh
        if LoopStarted then BreakLoop = true end
        TriggerEvent('wasabi_crutch:notify', Strings.chair_added, (Strings.chair_added_desc):format(time), 'inform')
        while true do
            local sleep = 1000
            if BreakLoop == true then
                if DoesEntityExist(chairVeh) then
                    ESX.Game.DeleteVehicle(chairVeh)
                end
                LoopStarted, BreakLoop, DisableKeys, timeSpent = nil, nil, {}, 0
                break
            end
            if not LoopStarted then LoopStarted = true end
            if not DisableKeys then DisableKeys = {} end
            DisableKeys.chair = true
            local heading = GetEntityHeading(cache.ped)
            if not DoesEntityExist(chairVeh) and not InVehicle then
                local coords = GetEntityCoords(cache.ped)
                local hash = `iak_wheelchair`
                lib.requestModel('iak_wheelchair', 100)
                chairVeh = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, 1, 0)
                TaskWarpPedIntoVehicle(cache.ped, chairVeh, -1)
                local plate = GetVehicleNumberPlateText(chairVeh)
                if Config.CustomCarKeyScript then
                    AddCarKeys(plate)
                end
                SetModelAsNoLongerNeeded(hash)
            elseif not InVehicle then
                local eCoords = GetEntityCoords(chairVeh)
                SetEntityCoords(chairVeh, eCoords.x, eCoords.y, eCoords.z+1.0, true, false, false, false)
                SetVehicleOnGroundProperly(chairVeh)
                TaskWarpPedIntoVehicle(cache.ped, chairVeh, -1)
            end
            if IsPedArmed(cache.ped, 1) or IsPedArmed(cache.ped, 2) or IsPedArmed(cache.ped, 4) then
                TriggerEvent('wasabi_crutch:notify', Strings.cant_wield, Strings.cant_wield_desc, 'error')
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`)
            end
            timeSpent = timeSpent + sleep
            if timeSpent >= 60000 then
                TriggerServerEvent('wasabi_crutch:updateChair', 1, cache.serverId)
                timeSpent = 0
            end
            Wait(sleep)
        end
    end)
end

function OpenCrutchMenu(item)
    local coords = GetEntityCoords(cache.ped)
    local closestPlayers = lib.getNearbyPlayers(vector3(coords.x, coords.y, coords.z), 10.0, false)
    if #closestPlayers < 1 then
        TriggerEvent('wasabi_crutch:notify', Strings.no_one_nearby, Strings.no_one_nearby_desc, 'error')
        return
    end
    local playerList = {}
    for i=1, #closestPlayers do
        playerList[#playerList + 1] = {
            id = GetPlayerServerId(closestPlayers[i].id)
        }
    end
    local nearbyPlayers = lib.callback.await('wasabi_crutch:getPlayerData', 100, playerList)
    local Options = {}
    for _,v in pairs(nearbyPlayers) do
        Options[#Options + 1] = {
            icon = 'user',
            label = v.name,
            description = Strings.player_id..' '..v.id,
            args = { id= v.id }
        }
    end
    lib.registerMenu({
        id = 'give_crutch_menu',
        title = Strings.select_patient,
        position = Config.menuPosition,
        options = Options
    }, function(selected, scrollIndex, args)
        if selected then
            setCrutchTime(args.id, true)
        end
    end)
    lib.showMenu('give_crutch_menu')
end

function OpenChairMenu(item)
    local coords = GetEntityCoords(cache.ped)
    local closestPlayers = lib.getNearbyPlayers(vector3(coords.x, coords.y, coords.z), 10.0, false)
    if #closestPlayers < 1 then
        TriggerEvent('wasabi_crutch:notify', Strings.no_one_nearby, Strings.no_one_nearby_desc, 'error')
        return
    end
    local playerList = {}
    for i=1, #closestPlayers do
        playerList[#playerList + 1] = {
            id = GetPlayerServerId(closestPlayers[i].id)
        }
    end
    local nearbyPlayers = lib.callback.await('wasabi_crutch:getPlayerData', 100, playerList)
    local Options = {}
    for _,v in pairs(nearbyPlayers) do
        Options[#Options + 1] = {
            icon = 'user',
            label = v.name,
            description = Strings.player_id..' '..v.id,
            args = { id= v.id }
        }
    end
    lib.registerMenu({
        id = 'give_chair_menu',
        title = Strings.select_patient,
        position = Config.menuPosition,
        options = Options
    }, function(selected, scrollIndex, args)
        if selected then
            setChairTime(args.id, true)
        end
    end)
    lib.showMenu('give_chair_menu')
end

function RemoveCrutch(target)
    TriggerServerEvent('wasabi_crutch:updateCrutch', false, target)
end

function SetCrutchTime(target, amount)
    TriggerServerEvent('wasabi_crutch:giveCrutch', target, amount)
end

function RemoveChair(target)
    TriggerServerEvent('wasabi_crutch:updateChair', false, target)
end

function SetChairTime(target, amount)
    TriggerServerEvent('wasabi_crutch:giveChair', target, amount)
end


--Exports
exports('OpenCrutchMenu', OpenCrutchMenu)
exports('RemoveCrutch', RemoveCrutch)
exports('SetCrutchTime', SetCrutchTime)

exports('OpenChairMenu', OpenChairMenu)
exports('RemoveChair', RemoveChair)
exports('SetChairTime', SetChairTime)
