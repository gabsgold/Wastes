                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    -- v0.3
-- misspellings  fixed
-- Blip fixed
-- added testingmission
-- better button selection (slower)
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

--use this for debugging
function Chat(t)
	TriggerEvent("chatMessage", 'TRUCKER', { 0, 255, 255}, "" .. tostring(t))
end

--locations
--arrays
local TruckingCompany = {}
-- {1738.63891601563,-1597.203125,112.053657531738},
TruckingCompany[0] = {["x"] = 1738.63891601563,["y"] = -1597.203125, ["z"] = 112.053657531738}

local Truck = {"RUBBLE", "TIPTRUCK", "TIPTRUCK2"}


local MissionData = {
    [0] = {2686.35375976563,2816.76416015625,40.3907356262207}, --x,y,z
    [1] = {84.7447052001953,6516.17236328125,31.3199501037598}, --x,y,z
}
local MISSION = {}
MISSION.start = false
MISSION.tailer = false
MISSION.truck = false

MISSION.hashTruck = 0

local currentMission = -1

local playerCoords
local playerPed

local GUI = {}
GUI.loaded          = false
GUI.showStartText   = false
GUI.showMenu        = false
GUI.selected        = {}
GUI.menu            = -1 --current menu

GUI.title           = {}
GUI.titleCount      = 0

GUI.desc            = {}
GUI.descCount       = 0

GUI.button          = {}
GUI.buttonCount     = 0

GUI.time            = 0

--text for mission
local text1 = false
local text2 = false
local text3 = false

items = 0
maxitems = 25

--blips
local BLIP = {}

BLIP.company = 0

BLIP.trailer = {}
BLIP.trailer.i = 0

BLIP.destination = {}
BLIP.destination.i = 0

--focus button color
local r = 0
local g= 128
local b = 192
local alpha = 200

function clear()    
    MISSION.start = false

    SetBlipRoute(BLIP.destination[BLIP.destination.i], false) 
    SetEntityAsNoLongerNeeded(BLIP.destination[BLIP.destination.i])
    
    --if ( DoesEntityExist(MISSION.trailer) ) then
    --     SetEntityAsNoLongerNeeded(MISSION.trailer)
    --end
    if ( DoesEntityExist(MISSION.truck) ) then
         SetEntityAsNoLongerNeeded(MISSION.truck)
         SetModelAsNoLongerNeeded(MISSION.hashTruck)
    end
    --Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(MISSION.trailer))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(MISSION.truck))

    --MISSION.trailer = 0
    MISSION.truck = 0
    MISSION.hashTruck = 0
    --MISSION.hashTrailer = 0
    currentMission = -1
    items = 0
end

local initload = false
Citizen.CreateThread(function() 
    while true do
       Wait(0)
       playerPed = GetPlayerPed(-1)
       playerCoords = GetEntityCoords(playerPed, 0)
        if (not initload) then
            init()
            initload = true
        end
        tick()
    end
    
end)

function init()
    BLIP.company = AddBlipForCoord(TruckingCompany[0]["x"], TruckingCompany[0]["y"], TruckingCompany[0]["z"])
    SetBlipSprite(BLIP.company, 67)
    SetBlipDisplay(BLIP.company, 4)
    SetBlipScale(BLIP.company, 0.8)
    Citizen.Trace("Truck Blip added.")
   -- GUI.loaded = true
end

--Draw Text / Menus
function tick()    
    
    --Show menu, when player is near
    if( MISSION.start == false) then
    if( GetDistanceBetweenCoords( playerCoords, TruckingCompany[0]["x"], TruckingCompany[0]["y"], TruckingCompany[0]["z"] ) < 10) then
            if(GUI.showStartText == false) then
--                GUI.drawStartText()
				affiche("Appuie sur ~INPUT_CONTEXT~ pour commencer le métier de Mineur")
            end
                --key controlling
                if(IsControlJustPressed(1, 51) and GUI.showMenu == false) then
                    --clear()
                    GUI.showMenu = true
                    GUI.menu = 0
--                end
                elseif(IsControlJustPressed(1, 51) and GUI.showMenu == true) then
                    GUI.showMenu = false
                end
            else
                GUI.showStartText = false
        end --if GetDistanceBetweenCoords ...

        --menu
        if( GUI.loaded == false ) then
            GUI.init()
        end

        if( GUI.showMenu == true and GUI.menu ~= -1) then
            if( GUI.time == 0) then
                GUI.time = GetGameTimer()
            end
            if( (GetGameTimer() - GUI.time) > 10) then
                GUI.updateSelectionMenu(GUI.menu)
                GUI.time = 0
            end
            GUI.renderMenu(GUI.menu)
        end --if GUI.loaded == false
    elseif( MISSION.start == true ) then
        
        if(text1 == false) then
            TriggerEvent("mt:missiontext", "Conduis jusqu'à la ~g~Carrière~w~.", 5000)
            MISSION.markerUpdate1()
            text1 = true
            text3 = false
            DrawMarker(1, 2686.35375976563, 2816.76416015625, 40.3907356262207, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 2.0, 0, 157, 0, 155, 0, 0, 2, 0, 0, 0, 0)
        end



			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 2686.35375976563,2816.76416015625,40.3907356262207, true ) < 50 then 
					SetVehicleDirtLevel(GetVehiclePedIsUsing(GetPlayerPed(-1)))
					SetVehicleUndriveable(GetVehiclePedIsUsing(GetPlayerPed(-1)), false)

function additems(num)

items = items + num

end

                if(items < maxitems) then

                        TriggerEvent("mt:missiontext", "+ ~g~1~w~ Fer.", 1000)
                        Wait(5000)
                        additems(1)

                elseif(items == maxitems) then

                    if(text3 == false) then

    		            TriggerEvent("mt:missiontext", "Inventaire ~r~complet~w~.", 1000)
    		            Wait(5000)
                        text3 = true

                    elseif(text3 == true) then

                        TriggerEvent("mt:missiontext", "Minage du fer terminé, conduis jusqu'au ~g~Chantier~w~.", 150000)
                        --[[ UPDATE MARKER TO END OF MISSION]]
                        MISSION.removeMarker()
                        MISSION.markerUpdate2()
                        DrawMarker(1, 84.7447052001953, 6516.17236328125, 31.3199501037598, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 2.0, 0, 157, 0, 155, 0, 0, 2, 0, 0, 0, 0)
                    
                    end
                end
            end

				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 84.7447052001953,6516.17236328125,31.3199501037598, true ) < 25 then 
			
					SetVehicleDirtLevel(GetVehiclePedIsUsing(GetPlayerPed(-1)))
					SetVehicleUndriveable(GetVehiclePedIsUsing(GetPlayerPed(-1)), false)
				    TriggerEvent("mt:missiontext", "Tu as gagné ~o~10000$~w~", 5000)
				    MISSION.removeMarker()

				    TriggerServerEvent('mineurJOB:success',tonumber(10000))
				    clear()

					
				end	
-- MISSION.removeMarker()
        
        if ( IsEntityDead(MISSION.truck) ) then
            MISSION.removeMarker()
            clear()
        end
    end --if MISSION.start == false
end



---------------------------------------
---------------------------------------
---------------------------------------
----------------MISSON-----------------
---------------------------------------   
---------------------------------------  
---------------------------------------
function GUI.optionMisson(trailerN)
    

    --select random truck
    local randomTruck = GetRandomIntInRange(1, #Truck)
    
    MISSION.hashTruck = GetHashKey(Truck[randomTruck])
	RequestModel(MISSION.hashTruck)
    
    while not HasModelLoaded(MISSION.hashTruck) do
        Wait(1)
    end
end

function GUI.mission1(missionN)
    --currently one destination per ride
    BLIP.destination.i = BLIP.destination.i + 1
    currentMission1 = MissionData[missionN]
    GUI.showMenu = false
    --mission start
    MISSION.start = true
    MISSION.spawnTruck()    
end

function GUI.mission2(missionN)
    --currently one destination per ride
    BLIP.destination.i = BLIP.destination.i + 1
    currentMission2 = MissionData[missionN]
    GUI.showMenu = false
    --mission start
    MISSION.start = true
    MISSION.spawnTruck()    
end

function MISSION.spawnTruck()
    
    -- -444.805511474609, -2791.45458984375, 6.00038290023804, 0.0, true, false)
    MISSION.truck = CreateVehicle(MISSION.hashTruck, 1725.32446289063, -1571.9560546875, 112.609275817871, 0.0, true, false)
    SetVehicleNumberPlateText(MISSION.truck, "D56912")
    SetVehRadioStation(MISSION.truck, "OFF")
	SetPedIntoVehicle(playerPed, MISSION.truck, -1)
    SetVehicleEngineOn(MISSION.truck, true, false, false)
    
    --important
    --SetEntityAsMissionEntity(MISSION.truck, true, true);



end


local oneTime = false



function MISSION.markerUpdate1()

       -- BLIP.destination.i = BLIP.destination.i + 1 this happens in GUI.mission()
        BLIP.destination[BLIP.destination.i]  = AddBlipForCoord(2686.35375976563,2816.76416015625,40.3907356262207)
        SetBlipSprite(BLIP.destination[BLIP.destination.i], 1)
        SetBlipColour(BLIP.destination[BLIP.destination.i], 2)
        SetBlipRoute(BLIP.destination[BLIP.destination.i], true)
    
    Wait(50)
end
function MISSION.markerUpdate2()

       -- BLIP.destination.i = BLIP.destination.i + 1 this happens in GUI.mission()
        BLIP.destination[BLIP.destination.i]  = AddBlipForCoord(84.7447052001953,6516.17236328125,31.3199501037598)
        SetBlipSprite(BLIP.destination[BLIP.destination.i], 1)
        SetBlipColour(BLIP.destination[BLIP.destination.i], 2)
        SetBlipRoute(BLIP.destination[BLIP.destination.i], true)
    
    Wait(50)
end
function MISSION.removeMarker()
    SetBlipSprite(BLIP.destination[BLIP.destination.i], 2)--invisible
end

function MISSION.getMoney()
end
---------------------------------------
---------------------------------------
---------------------------------------
-----------------MENU------------------
---------------------------------------   
---------------------------------------  
---------------------------------------
function GUI.drawStartText()
    TriggerEvent("mt:missiontext", "Appuie sur ~r~+~w~ pour commencer le métier de Mineur", 500)
    --GUI.showStartText = true
end

function affiche(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function GUI.renderMenu(menu)
    GUI.renderTitle()
    GUI.renderDesc()
    GUI.renderButtons(menu)
end

function GUI.init()
    GUI.loaded = true
    GUI.addTitle("Mineur", 0.09, 0.35, 0.2, 0.05 )
    --menu, title, function, position
    --[[ GUI.addButton(0, "Remorque Ã  essence", GUI.optionMisson, 0.35, 0.25, 0.3, 0.05 )
    GUI.addButton(0, "Remorque conteneur", GUI.optionMisson, 0.35, 0.30, 0.3, 0.05 )
    GUI.addButton(0, "Remorque Ã  marchandise", GUI.optionMisson, 0.35, 0.35, 0.3, 0.05 )
    GUI.addButton(0, "Remorque Ã  bois", GUI.optionMisson, 0.35, 0.40, 0.3, 0.05 )
    GUI.addButton(0, " ", GUI.null, 0.35, 0.45, 0.3, 0.05)
    GUI.addButton(0, "Annuler", GUI.exit, 0.35, 0.50, 0.3, 0.05 ) ]]

    GUI.addButton(0, "Mineur", GUI.optionMisson, 0.09, 0.40, 0.2, 0.05 )
    GUI.addButton(0, " ", GUI.null, 0.09, 0.45, 0.2, 0.05)
    GUI.addButton(0, "Annuler", GUI.exit, 0.09, 0.50, 0.2, 0.05 ) 

    GUI.buttonCount = 0

    GUI.addButton(1, "Session de minage [6500$]", GUI.mission1, 0.09, 0.40, 0.2, 0.05 )
    GUI.addButton(1, " ", GUI.null, 0.09, 0.45, 0.2, 0.05)
    GUI.addButton(1, "Annuler", GUI.exit, 0.09, 0.50, 0.2, 0.05 )
end

--Render stuff
function GUI.renderTitle()
    for id, settings in pairs(GUI.title) do
        local screen_w = 0
        local screen_h = 0
        screen_w, screen_h = GetScreenResolution(0,0)
        boxColor = {0,0,0,255}
		SetTextFont(0)
		SetTextScale(0.0, 0.40)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		SetTextDropshadow(0, 0, 0, 0, 0)
		SetTextEdge(0, 0, 0, 0, 0)
		SetTextEntry("STRING")
        AddTextComponentString(settings["name"])
        DrawText((settings["xpos"] + 0.001), (settings["ypos"] - 0.015))
        --AddTextComponentString(settings["name"])
        GUI.renderBox(
            settings["xpos"], settings["ypos"], settings["xscale"], settings["yscale"],
            boxColor[1], boxColor[2], boxColor[3], boxColor[4]
        )
    end
end

function GUI.renderDesc()
end

function GUI.renderButtons(menu)
	for id, settings in pairs(GUI.button[menu]) do
		local screen_w = 0
		local screen_h = 0
		screen_w, screen_h =  GetScreenResolution(0, 0)
		boxColor = {0,0,0,100}
		if(settings["active"]) then
			boxColor = {r,g,b,alpha}
		end
		SetTextFont(0)
		SetTextScale(0.0, 0.35)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		SetTextDropShadow(0, 0, 0, 0, 0)
		SetTextEdge(0, 0, 0, 0, 0)
		SetTextEntry("STRING")
		AddTextComponentString(settings["name"])
		DrawText((settings["xpos"] + 0.001), (settings["ypos"] - 0.015))
		--AddTextComponentString(settings["name"])
		GUI.renderBox(
            settings["xpos"], settings["ypos"], settings["xscale"],
            settings["yscale"], boxColor[1], boxColor[2], boxColor[3], boxColor[4]
        )
	 end     
end

function GUI.renderBox(xpos, ypos, xscale, yscale, color1, color2, color3, color4)
	DrawRect(xpos, ypos, xscale, yscale, color1, color2, color3, color4);
end

--adding stuff
function GUI.addTitle(name, xpos, ypos, xscale, yscale)
	GUI.title[GUI.titleCount] = {}
	GUI.title[GUI.titleCount]["name"] = name
	GUI.title[GUI.titleCount]["xpos"] = xpos
	GUI.title[GUI.titleCount]["ypos"] = ypos 	
	GUI.title[GUI.titleCount]["xscale"] = xscale
	GUI.title[GUI.titleCount]["yscale"] = yscale
end

function GUI.addDesc(name, xpos, ypos, xscale, yscale)
	GUI.desc[GUI.descCount] = {}
	GUI.desc[GUI.descCount]["name"] = name
	GUI.desc[GUI.descCount]["xpos"] = xpos
	GUI.desc[GUI.descCount]["ypos"] = ypos 	
	GUI.desc[GUI.descCount]["xscale"] = xscale
	GUI.desc[GUI.descCount]["yscale"] = yscale
end

function GUI.addButton(menu, name, func, xpos, ypos, xscale, yscale)
    if(not GUI.button[menu]) then
        GUI.button[menu] = {}
        GUI.selected[menu] = 0
    end
    GUI.button[menu][GUI.buttonCount] = {}
	GUI.button[menu][GUI.buttonCount]["name"] = name
	GUI.button[menu][GUI.buttonCount]["func"] = func
	GUI.button[menu][GUI.buttonCount]["xpos"] = xpos
	GUI.button[menu][GUI.buttonCount]["ypos"] = ypos 	
	GUI.button[menu][GUI.buttonCount]["xscale"] = xscale
	GUI.button[menu][GUI.buttonCount]["yscale"] = yscale
    GUI.button[menu][GUI.buttonCount]["active"] = 0
    GUI.buttonCount = GUI.buttonCount + 1
end

function GUI.null()
end

function GUI.exit()
    GUI.showMenu = false
	print("Exit menu")
end

--update stuff
function GUI.updateSelectionMenu(menu)
    if( IsControlPressed(0, Keys["DOWN"]) ) then
        if( GUI.selected[menu] < #GUI.button[menu] ) then
            GUI.selected[menu] = GUI.selected[menu] + 1
        end
    elseif( IsControlPressed(0, Keys["TOP"]) ) then
        if( GUI.selected[menu] > 0 ) then
            GUI.selected[menu] = GUI.selected[menu] - 1 
        end
    elseif( IsControlPressed(0, Keys["ENTER"]) ) then
        if( type(GUI.button[menu][GUI.selected[menu]]["func"]) == "function" ) then
            --remember variable GUI.selected[menu]
            
            --call mission functions
            GUI.button[menu][GUI.selected[menu]]["func"](GUI.selected[menu])
            
            GUI.menu = 1
            GUI.selected[menu] = 0
            if( not GUI.menu ) then
                GUI.menu = -1
            end
            Wait(100)
            
            --GUI.button[menu][GUI.selected[menu]]["func"](GUI.selected[menu])
        else
            Citizen.Trace("\n Failes to call function! - Selected Menu: "..GUI.selected[menu].." \n")
        end
        GUI.time = 0
    end
    local i = 0
    for id, settings in ipairs(GUI.button[menu]) do
        GUI.button[menu][i]["active"] = false
        if( i == GUI.selected[menu] ) then
            GUI.button[menu][i]["active"] = true
        end
        i = i + 1
    end
end