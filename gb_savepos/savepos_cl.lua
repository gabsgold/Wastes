Citizen.CreateThread(function ()
	while true do
	Citizen.Wait(10000)
		local posPlayer = GetEntityCoords(GetPlayerPed(-1))
		TriggerServerEvent('gabs:savepos', posPlayer.x, posPlayer.y, posPlayer.z)
	end
end)
-- Si utilisé seul :
AddEventHandler('onClientMapStart', function()
		exports.spawnmanager:setAutoSpawn(true)
		exports.spawnmanager:forceRespawn()
		exports.spawnmanager:setAutoSpawnCallback(function()
			if spawnLock then
				return
			end
			spawnLock = false
			TriggerServerEvent('gabs:spawn')
		end)
end)
-- Si utilisé avec un mod qui override l'AutoSpawnCallBack :
AddEventHandler('onClientMapStart', function()
		TriggerServerEvent('gabs:spawn')
end)

Citizen.CreateThread(function ()
	while true do
        Wait(0)
        local player = PlayerId()
        if NetworkIsPlayerActive(player) then
            local ped = PlayerPedId()
		    if IsPedFatallyInjured(ped) then
				exports.spawnmanager:setAutoSpawnCallback(function()
			        if spawnLock then
				        return
			        end
			        spawnLock = false
			        TriggerServerEvent('gabs:hopital')
			        TriggerEvent('gabs:hopital')
		        end)
			end
		end
	end
end)