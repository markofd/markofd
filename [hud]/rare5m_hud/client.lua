ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
    ESX.PlayerData = ESX.GetPlayerData()
end)

local toghud = true

local lastFadeOutDetection = 0

function getShowHud()
  if IsScreenFadedOut() then
    lastFadeOutDetection = GetGameTimer()
  end

  return toghud and GetGameTimer() > lastFadeOutDetection + 2000
end

RegisterCommand('hud', function(source, args, rawCommand)
    if toghud then
        toghud = false
    else
        toghud = true
    end

	SendNUIMessage({
		action = "updateStatusHud",
		show = getShowHud()
	})
end)

RegisterNetEvent('hud:toggleui')
AddEventHandler('hud:toggleui', function(show)
    if show == true then
        toghud = true
    else
        toghud = false
    end

	SendNUIMessage({
		action = "updateStatusHud",
		show = getShowHud()
	})
end)

local pauseMenu = false

Citizen.CreateThread(function()
    while true do
		if IsPauseMenuActive() and not pauseMenu then
			pauseMenu = true
			toghud = false
			SendNUIMessage({
				action = "updateStatusHud",
				show = false
			})
		elseif not IsPauseMenuActive() and pauseMenu then
			pauseMenu = false
			toghud = true
			SendNUIMessage({
				action = "updateStatusHud",
				show = getShowHud()
			})
		end


        if toghud == true then
            if (not IsPedInAnyVehicle(PlayerPedId(), false) )then
                DisplayRadar(0)
            else
                DisplayRadar(1)
            end
        else
            DisplayRadar(0)
        end

        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
	while true do
        TriggerEvent('esx_status:getStatus', 'hunger', function(hunger)
            TriggerEvent('esx_status:getStatus', 'thirst', function(thirst)
                local myhunger = hunger.getPercent()
                local mythirst = thirst.getPercent()
                SendNUIMessage({
                    action = "updateStatusHud",
                    show = getShowHud(),
                    hunger = myhunger,
                    thirst = mythirst,
                })
                TriggerEvent('esx_status:getStatus','stress',function(stress)
                    local mystress = stress.getPercent()

                    SendNUIMessage({
                        action = "updateStatusHud",
                        show = getShowHud(),
                        stress = mystress,
                    })
                end)
            end)
        end)
        Citizen.Wait(800)
	end
end)

AddEventHandler("playerSpawned", function()
	SendNUIMessage({
		action = 'updateStatusHud',
		show = getShowHud(),
		health = GetEntityHealth(PlayerPedId()) - 100
	})

	SendNUIMessage({
		action = 'updateStatusHud',
		show = getShowHud(),
		armour = GetPedArmour(PlayerPedId())
	})
end)

local stats = {
	playerHealth = 0,
	playerArmor = 0,
	playerOxygen = 0,
	inVehicle = false,
	enteringVehicle = false
}

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1000)
		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped, false) then
			if not stats.inVehicle then
				stats.inVehicle = true
				stats.enteringVehicle = false

				TriggerEvent("svrp-gameplay:enteredVehicle")

				local v = GetVehiclePedIsIn(ped)

				Citizen.CreateThread(function()
					while stats.inVehicle do
						local player = PlayerPedId()
						local vehicle = GetVehiclePedIsIn(player)

						SetPlayerCanDoDriveBy(PlayerId(), true)

						if GetVehicleEngineHealth(vehicle) <= 0 then
							SetVehicleUndriveable(vehicle, true)
						else
							SetVehicleUndriveable(vehicle, false)
						end

						if GetPedInVehicleSeat(vehicle, -1) == player then
							if IsEntityInAir(vehicle) then
								local model = GetEntityModel(vehicle)
								if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and not IsThisModelABike(model) and not IsThisModelABicycle(model) then
									DisableControlAction(0, 59)
									DisableControlAction(0, 60)
								end
							end
						end

						Citizen.Wait(0)
					end
				end)
			end
		else
			if stats.inVehicle then
				TriggerEvent("svrp-gameplay:exitVehicle")
			end
			stats.inVehicle = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)

		local ped = PlayerPedId()
		local health = GetEntityHealth(ped)
		local armor = GetPedArmour(ped)
		local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 4

		if health ~= stats.playerHealth then
			stats.playerHealth = health
			TriggerEvent("svrp-gameplay:statUpdate", "health", stats.playerHealth)
		end

		if armor ~= stats.playerArmor then
			stats.playerArmor = armor
			TriggerEvent("svrp-gameplay:statUpdate", "armor", stats.playerArmor)
			if maySave then
				TriggerServerEvent("svrp-gameplay:setServerArmor", stats.playerArmor)
			end
		end

		if oxygen ~= stats.playerOxygen then
			stats.playerOxygen = oxygen
			if IsPedSwimmingUnderWater(PlayerPedId()) then
				TriggerEvent("svrp-gameplay:statUpdate", "oxygen", stats.playerOxygen)
			else
				TriggerEvent("svrp-gameplay:statUpdate", "oxygen", 0)
			end
		end

		if IsPedBeingStunned(ped) then
			SetPedMinGroundTimeForStungun(ped, timer)
			SetPedCanRagdoll(ped, true)
		end
	end
end)

AddEventHandler("svrp-gameplay:enteredVehicle", function()
	SendNUIMessage({action = "hudCarPos"})
end)

AddEventHandler("svrp-gameplay:exitVehicle", function()
	SendNUIMessage({action = "regularPos"})
end)

AddEventHandler("svrp-gameplay:statUpdate", function(name, value)
	if name == "health" then
        SendNUIMessage({
            action = 'updateStatusHud',
            show = getShowHud(),
            health = value - 100
        })
	elseif name == "armor" then
        SendNUIMessage({
            action = 'updateStatusHud',
            show = getShowHud(),
            armour = value
        })
	elseif name == "oxygen" then
        SendNUIMessage({
            action = 'updateStatusHud',
            show = getShowHud(),
            oxygen = value
        })
	end
end)

Citizen.CreateThread(function ()
	while true do
		local isTalking = NetworkIsPlayerTalking(PlayerId())

		if isTalking then
			TriggerEvent('svrp-mumble:voiceState', true)
		elseif not isTalking then
			TriggerEvent('svrp-mumble:voiceState', false)
		end
		
		Citizen.Wait(100)
	end
end)

AddEventHandler("svrp-mumble:voiceState", function(state)
	SendNUIMessage({
		action = 'voicestate',
		state = state
	})
end)

AddEventHandler("svrp-mumble:voiceMode", function(mode)
	SendNUIMessage({
		action = 'voicemode',
		mode = (mode == 1) and "whisper" or (mode == 2) and "speak" or "loud"
	})
end)

AddEventHandler("svrp-carhud:carData", function(data)
	SendNUIMessage({
		action = 'updateStatusHud',
		show = getShowHud(),
		mph = data.mph,
		gas = data.gas,
		nos = data.nos
	})
end)

AddEventHandler("svrp-carhud:engineStatus", function(status)
	SendNUIMessage({
		action = 'toggleCarHud',
		toggle = status,
	})
end)

AddEventHandler("svrp-ui:adjust", function(field, value)
	SendNUIMessage({
		action = 'adjust',
		field = field,
		value = value
	})
end)

AddEventHandler("svrphealthui:saveToServer", function()
	SendNUIMessage({action = 'postvalues'})
end)

RegisterNUICallback('postValues', function(data, cb)
    TriggerServerEvent("svrphealthui:save", data)
    cb('ok')
end)

AddEventHandler("svrp-userinterface:queryFromServer", function()
	ESX.TriggerServerCallback("svrphealthui:getOffsets", function(data)
		SendNUIMessage({action = 'readvalues', values = data})
	end)
end)