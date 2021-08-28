ESX = nil

local isOpened = false

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end
end)

CreateThread(function()
    local sleepTime = 0
    while true do
        Wait(sleepTime)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        for k, v in pairs(Config.Zones) do
            local dist = #(v.Pos - coords)
            if dist > Config.DrawDistance or isOpened then
                sleepTime = 500
            end

            if dist <= Config.DrawDistance and not isOpened then
                sleepTime = 0
                DrawText3D(v.Pos.x, v.Pos.y, v.Pos.z, Config.Text.Open)
                if IsControlJustPressed(0, Config.OpenKey) then
                    isOpened = true
                    buyMenu(Config.Text.MenuTitle, v.Items)
                end
            end
        end
    end
end)

function buyMenu(menuTitle, items)
    local elements = {}
    for i=1, #items do
        local itemLabel = string.format('<span style="color:red;">%s</span> - <span style="color:green;">%s$</span>', items[i].label, items[i].price)
        table.insert(elements, {defaultLabel = items[i].label, label = itemLabel, item = items[i].item, amount = items[i].amount, price = items[i].price})
    end

    createMenu(elements, 'buymenu', menuTitle, Config.Align, function(data, menu)
        secondMenu(data.current.item, data.current.defaultLabel, data.current.amount, data.current.price)
        menu.close()
    end)
end

function secondMenu(item, label, amount, price)
    local elements = {
        {label = Config.Text.Yes, value = 'yes'},
        {label = Config.Text.No, value = 'no'}
    }
    createMenu(elements, 'secondmenu', Config.Text.Buy, Config.Align, function(data, menu)
        if data.current.value == 'yes' then
            TriggerServerEvent('fgs-automat:buyItem', item, label, amount, price)
            menu.close()
            isOpened = false
        elseif data.current.value == 'no' then
            menu.close()
            isOpened = false
        end
    end)
end

function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local p = GetGameplayCamCoords()
	local distance = #(p - vector3(x, y, z))
	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov
	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
		local factor = (string.len(text)) / 370
		DrawRect(_x,_y+0.0135, 0.025+ factor, 0.03, 0, 0, 0, 150)
	end
end

function createMenu(elements, menuName, title, align, cb)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), menuName, {
        title = title,
		align = align,
		elements = elements
	}, function(data, menu)
		cb(data, menu)
	end, function(data, menu)
		menu.close()
        isOpened = false
	end)
end