ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('fgs-automat:buyItem')
AddEventHandler('fgs-automat:buyItem', function(item, label, value, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if xPlayer then
        if isNear(_src) then
            if (xPlayer.getMoney() - price) > price then 
                xPlayer.addInventoryItem(item, value)
                xPlayer.removeMoney(price)
                TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = string.format('Zakoupil/a jsi %sx %s za $%s.', value, label, price) })
            else 
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'Error', text = 'Nemáš dostatek peněz!' })
            end
        else
            print(string.format('[^1fgs-automat^0]: Player: %s is probably cheating because his distance between the trade place is very large!', GetPlayerName(_src)))
        end
    end
end)

function isNear(id)
    local coords = GetEntityCoords(GetPlayerPed(id))
    for k, v in pairs(Config.Zones) do
        local dist = #(v.Pos - coords)
        if dist <= (Config.DrawDistance + 1.0) then
            return true
        end
    end
    return false
end