Citizen.CreateThread(function ()
	while true do
	Citizen.Wait(0)
--		local posPlayer = GetEntityCoords(GetPlayerPed(-1))
		affiche("TEST ~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_DOWN~ ~INPUT_CELLPHONE_RIGHT~ ~INPUT_CELLPHONE_LEFT~")
	end
end)

function affiche(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end