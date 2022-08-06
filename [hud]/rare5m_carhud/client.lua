local cruisecontrol = false
local seatbeltState = false

local nosData = {
    amount = 0,
    active = false
}

local wantUi = true
local uiopen = false
local colorblind = false
local compass_on = false
local time = "12:00"

local zoneNames = {
    AIRP = "Los Santos International Airport",
    ALAMO = "Alamo Sea",
    ALTA = "Alta",
    ARMYB = "Fort Zancudo",
    BANHAMC = "Banham Canyon Dr",
    BANNING = "Banning",
    BAYTRE = "Baytree Canyon",
    BEACH = "Vespucci Beach",
    BHAMCA = "Banham Canyon",
    BRADP = "Braddock Pass",
    BRADT = "Braddock Tunnel",
    BURTON = "Burton",
    CALAFB = "Calafia Bridge",
    CANNY = "Raton Canyon",
    CCREAK = "Cassidy Creek",
    CHAMH = "Chamberlain Hills",
    CHIL = "Vinewood Hills",
    CHU = "Chumash",
    CMSW = "Chiliad Mountain State Wilderness",
    CYPRE = "Cypress Flats",
    DAVIS = "Davis",
    DELBE = "Del Perro Beach",
    DELPE = "Del Perro",
    DELSOL = "La Puerta",
    DESRT = "Grand Senora Desert",
    DOWNT = "Downtown",
    DTVINE = "Downtown Vinewood",
    EAST_V = "East Vinewood",
    EBURO = "El Burro Heights",
    ELGORL = "El Gordo Lighthouse",
    ELYSIAN = "Elysian Island",
    GALFISH = "Galilee",
    GALLI = "Galileo Park",
    golf = "GWC and Golfing Society",
    GRAPES = "Grapeseed",
    GREATC = "Great Chaparral",
    HARMO = "Harmony",
    HAWICK = "Hawick",
    HORS = "Vinewood Racetrack",
    HUMLAB = "Humane Labs and Research",
    JAIL = "Bolingbroke Penitentiary",
    KOREAT = "Little Seoul",
    LACT = "Land Act Reservoir",
    LAGO = "Lago Zancudo",
    LDAM = "Land Act Dam",
    LEGSQU = "Legion Square",
    LMESA = "La Mesa",
    LOSPUER = "La Puerta",
    MIRR = "Mirror Park",
    MORN = "Morningwood",
    MOVIE = "Richards Majestic",
    MTCHIL = "Mount Chiliad",
    MTGORDO = "Mount Gordo",
    MTJOSE = "Mount Josiah",
    MURRI = "Murrieta Heights",
    NCHU = "North Chumash",
    NOOSE = "N.O.O.S.E",
    OCEANA = "Pacific Ocean",
    PALCOV = "Paleto Cove",
    PALETO = "Paleto Bay",
    PALFOR = "Paleto Forest",
    PALHIGH = "Palomino Highlands",
    PALMPOW = "Palmer-Taylor Power Station",
    PBLUFF = "Pacific Bluffs",
    PBOX = "Pillbox Hill",
    PROCOB = "Procopio Beach",
    RANCHO = "Rancho",
    RGLEN = "Richman Glen",
    RICHM = "Richman",
    ROCKF = "Rockford Hills",
    RTRAK = "Redwood Lights Track",
    SanAnd = "San Andreas",
    SANCHIA = "San Chianski Mountain Range",
    SANDY = "Sandy Shores",
    SKID = "Mission Row",
    SLAB = "Stab City",
    STAD = "Maze Bank Arena",
    STRAW = "Strawberry",
    TATAMO = "Tataviam Mountains",
    TERMINA = "Terminal",
    TEXTI = "Textile City",
    TONGVAH = "Tongva Hills",
    TONGVAV = "Tongva Valley",
    VCANA = "Vespucci Canals",
    VESP = "Vespucci",
    VINE = "Vinewood",
    WINDF = "Ron Alternates Wind Farm",
    WVINE = "West Vinewood",
    ZANCUDO = "Zancudo River",
    ZP_ORT = "Port of South Los Santos",
    ZQ_UAR = "Davis Quartz"
}

RegisterNetEvent('preference:colorblind')
AddEventHandler('preference:colorblind',function()
    colorblind = not colorblind
    if colorblind then
        TriggerEvent("Notification:short", "Color Preferences Changed", 4)
    else
        TriggerEvent("Notification:short", "Color Preferences Reverted", 4)
    end
end)

RegisterNetEvent("svrp-carhud:seatbelt")
AddEventHandler("svrp-carhud:seatbelt", function(belt)
    seatbeltState = belt
end)

RegisterNetEvent("svrp-carhud:cruise")
AddEventHandler("svrp-carhud:cruise", function(state)
    cruisecontrol = state
end)

RegisterNetEvent("timeheader")
AddEventHandler("timeheader", function(h,m)
	h = tonumber(h)
	m = tonumber(m)
    if h < 10 then
        h = "0"..h
    end
    if m < 10 then
        m = "0"..m
    end
    time = h .. ":" .. m
end)

local hudswitch
Citizen.CreateThread(function()
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
    currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    zone = tostring(GetNameOfZone(x, y, z))
    playerStreetsLocation = zoneNames[tostring(zone)]

    if not zone then
        zone = exports.localization:getLocale("CarhudZoneUnknown")
        zoneNames['UNKNOWN'] = zone
    elseif not zoneNames[tostring(zone)] then
        local undefinedZone = zone .. " " .. x .. " " .. y .. " " .. z
        zoneNames[tostring(zone)] = exports.localization:getLocale("CarhudZoneUndefined")
    end

    if intersectStreetName ~= nil and intersectStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. " | " .. intersectStreetName .. " | [" .. zoneNames[tostring(zone)] .. "]"
    elseif currentStreetName ~= nil and currentStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. " | [" .. zoneNames[tostring(zone)] .. "]"
    else
        playerStreetsLocation = "[" .. zoneNames[tostring(zone)] .. "]"
    end

    while true do
        Citizen.Wait(500)
		if IsPedInAnyVehicle(PlayerPedId()) then
			local player = PlayerPedId()
			local x, y, z = table.unpack(GetEntityCoords(player, true))
			local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
			currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
			intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
			zone = tostring(GetNameOfZone(x, y, z))
			playerStreetsLocation = zoneNames[tostring(zone)]

			if not zone then
				zone = exports.localization:getLocale("CarhudZoneUnknown")
				zoneNames['UNKNOWN'] = zone
			elseif not zoneNames[tostring(zone)] then
				local undefinedZone = zone .. " " .. x .. " " .. y .. " " .. z
				zoneNames[tostring(zone)] = exports.localization:getLocale("CarhudZoneUndefined")
			end

			if intersectStreetName ~= nil and intersectStreetName ~= "" then
				playerStreetsLocation = currentStreetName .. " | " .. intersectStreetName .. " | [" .. zoneNames[tostring(zone)] .. "]"
			elseif currentStreetName ~= nil and currentStreetName ~= "" then
				playerStreetsLocation = currentStreetName .. " | [" .. zoneNames[tostring(zone)] .. "]"
			else
				playerStreetsLocation = "[".. zoneNames[tostring(zone)] .. "]"
			end

			street = playerStreetsLocation

			if IsVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), false)) then
				TriggerEvent("svrp-carhud:engineStatus", true)

				if not uiopen and wantUi then
					uiopen = true
					SendNUIMessage({
						open = 1,
					})
					TriggerEvent("svrp:uiQueryNos")
				end

                seatBeltType = "belt"

				local fuel =  GetVehicleFuelLevel(GetVehiclePedIsIn(PlayerPedId(), false))
				local mph = math.ceil(GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6)

				TriggerEvent("svrp-carhud:carData", {gas = math.ceil(fuel), mph = mph, nos = nosData.amount})

				local hours = GetClockHours()
				if string.len(tostring(hours)) == 1 then
					trash = '0'..hours
				else
					trash = hours
				end

				local mins = GetClockMinutes()
				if string.len(tostring(mins)) == 1 then
					mins = '0'..mins
				else
					mins = mins
				end

				if not IsThisModelABicycle(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(),false))) then
					SendNUIMessage({
						open = 2,
						colorblind = colorblind,
						time = hours .. ':' .. mins,
						location = street,
						speed = mph,
						fuel = math.ceil(fuel),
						cruise = cruisecontrol,
						seatbelt = seatbeltState,
						belttype = seatBeltType,
						nos = nosData,
					})
				else
					SendNUIMessage({
						open = 5,
						time = hours .. ':' .. mins,
						location = street,
						speed = mph,
					})
				end
			else
				TriggerEvent("svrp-carhud:engineStatus", false)
				if uiopen and not compass_on then
					SendNUIMessage({
						open = 3,
					})
					uiopen = false
				end
			end
		else
			if uiopen and not compass_on then
				SendNUIMessage({
					open = 3,
				})
				uiopen = false
			end
		end
    end
end)

AddEventHandler("svrp:uiNosUpdate", function(amount, active)
	nosData.active = active
	nosData.amount = amount
end)

local pauseMenu = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)

		if IsPauseMenuActive() and not pauseMenu then
			pauseMenu = true
			toghud = false
			SendNUIMessage({
				open = 30,
			})
		elseif not IsPauseMenuActive() and pauseMenu then
			pauseMenu = false
			toghud = true
			SendNUIMessage({
				open = 31,
			})
		end

        local player = PlayerPedId()
        if IsVehicleEngineOn(GetVehiclePedIsIn(player, false)) then
            -- inside vehicle and engine on, show full UI
            SendNUIMessage({
                open = 2,
                direction = math.floor(calcHeading(-GetEntityHeading(player) % 360)),
            })
        elseif compass_on  == true then

            -- compass toggled
            if not uiopen and wantUi then
                uiopen = true
                SendNUIMessage({
                    open = 1,
                })
            end
            -- inside vehicle, engine off, show compass UI

            local hours = GetClockHours()
            if string.len(tostring(hours)) == 1 then
                trash = '0'..hours
            else
                trash = hours
            end

            local mins = GetClockMinutes()
            if string.len(tostring(mins)) == 1 then
                mins = '0'..mins
            else
                mins = mins
            end

            SendNUIMessage({
                open = 4,
                time = hours .. ":" .. mins,
                direction = math.floor(calcHeading(-GetEntityHeading(player) % 360)),
            })
        else
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent('svrp-carhud:compass')
AddEventHandler('svrp-carhud:compass', function()
    -- if HasCompass() then
    --     compass_on = not compass_on
    -- end
end)

RegisterNetEvent('svrp-carhud:seatswap')
AddEventHandler('svrp-carhud:seatswap', function(seatNumber)
    local seat = tonumber(seatNumber)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)

    if seat < maxSeats then
        if IsEntityAVehicle(vehicle) then
            if IsVehicleSeatFree(vehicle, seat) then
                Citizen.Wait(100)
                SetPedIntoVehicle(PlayerPedId(),vehicle, seat)
            end
        end
    else
        TriggerEvent("Notification", exports.localization:getLocale("CarhudNoSeatPosFound"), 2)
        return
    end
end)

RegisterNetEvent('svrp-carcontrol:toggle:engine')
AddEventHandler('svrp-carcontrol:toggle:engine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    print("Driver Seat: "..tostring(GetPedInVehicleSeat(vehicle, -1)))
    if GetPedInVehicleSeat(vehicle, -1) then
		local t = not IsVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), false))
    	SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), false), t, false, true)
		SetVehicleJetEngineOn(GetVehiclePedIsIn(PlayerPedId(), false), t)
	else
        print("Not the driver")
    end
end)

AddEventHandler('svrp-carhud:toggle', function(t)
	wantUi = t
	if not wantUi then
		SendNUIMessage({
			open = 3
		})
	else
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			SendNUIMessage({
				open = 1
			})
			uiopen = true
		end
	end
end)

local movieview = false
local UI = {
    x =  0.000,
    y = -0.001,
}

RegisterNetEvent('svrp-carhud:cinematic')
AddEventHandler('svrp-carhud:cinematic', function()
    movieview = not movieview
    if movieview then
        TriggerEvent('hud:toggleui', false)
        TriggerEvent('svrp-mumble:toggleUi', false)
        TriggerEvent('svrp-carhud:toggle', false)
        TriggerEvent('chat:toggleChat')
        TriggerEvent('Notification:togglenotify', false)
        Citizen.CreateThread(function()
            while movieview do
                Citizen.Wait(0)
                HideHUDThisFrame()
                drawRct(UI.x + 0.0,     UI.y + 0.0, 1.0,0.15,0,0,0,255) -- Top Bar
                drawRct(UI.x + 0.0,     UI.y + 0.85, 1.0,0.151,0,0,0,255) -- Bottom Bar
            end
        end)
    else
        movieview = false
        TriggerEvent('hud:toggleui', true)
        TriggerEvent('svrp-mumble:toggleUi', true)
        TriggerEvent('svrp-carhud:toggle', true)
        TriggerEvent('chat:toggleChat')
        TriggerEvent('Notification:togglenotify', true)
    end
end)

function drawRct(x,y,width,height,r,g,b,a)
    DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end

function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    HideHudComponentThisFrame(1)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(8)
    HideHudComponentThisFrame(9)
    HideHudComponentThisFrame(13)
    HideHudComponentThisFrame(11)
    HideHudComponentThisFrame(12)
    HideHudComponentThisFrame(15)
    HideHudComponentThisFrame(18)
    HideHudComponentThisFrame(19)
end

local imageWidth = 100
local containerWidth = 100

local width =  0;
local south = (-imageWidth) + width
local west = (-imageWidth * 2) + width
local north = (-imageWidth * 3) + width
local east = (-imageWidth * 4) + width
local south2 = (-imageWidth * 5) + width

function calcHeading(direction)
    if (direction < 90) then
        return lerp(north, east, direction / 90)
    elseif (direction < 180) then
        return lerp(east, south2, rangePercent(90, 180, direction))
    elseif (direction < 270) then
        return lerp(south, west, rangePercent(180, 270, direction))
    elseif (direction <= 360) then
        return lerp(west, north, rangePercent(270, 360, direction))
    end
end


function rangePercent(min, max, amt)
    return (((amt - min) * 100) / (max - min)) / 100
end

function lerp(min, max, amt)
    return (1 - amt) * min + amt * max
end

AddEventHandler("carhudIconsSetup", function()
	SetNuiFocus(true, true)
	SendNUIMessage({
		open = 31,
		tutorial = true
	})
end)

RegisterNUICallback('saveCarhudStuff', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("svrp-carhud:saveOffsets", data)
    TriggerEvent("svrp-userinterface:carhudDone")
    cb('ok')
end)


AddEventHandler("svrp-userinterface:queryFromServer", function()
	ESX.TriggerServerCallback("svrp-carhud:getOffsets", function(data)
		SendNUIMessage({action = 'readvalues', values = data})
	end)
end)
