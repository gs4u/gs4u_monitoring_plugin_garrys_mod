include("sha1.lua")
monversion = "3.6.9.3"


--______________________________________________________________________________________________
--
--							[	Настройка аддона для мониторинга	]							
--
--‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

local APIUrl					= 	"https://api.gs4u.net/"
local IDServer 					=	"136828" --ID Сервера
local WeaponsAddons				= 	"M9K" --M9K, SWBase, FAS и тд
local ServerToken				=	"FNiD3o4W2K6if4uKvIhAGAcsfvIh1DAEYJPdQRXY2uCeTW3NpgQpY1O57ibSCONq" --Токен Сервера
local LangIndex_Monitoring 		= 	"ru"

--[[
	Языки/Langs
	en - English
	ru - Русский
	de - Deutsch
]]

MoneysName				=	"₽" --Валюта - Для DarkRP

print("[ GS4u ] Starting Addons - Monitoring")
timer.Create("RefreshTimer_Timer", 1, 1, function()
	print("[ GS4u ] GetCoolDown")
	http.Fetch(APIUrl.. "?cmd=getCoolDown&data={\"cmd\":\"updateServer\"}", function(CallBack)
		print("[ GS4u ] TakeCoolDown: "..tonumber(CallBack).."s")
		timer.Create("RefreshTimer_Timer", tonumber(CallBack), 0, function()
			local PlayerList 	= ""
			local CommandsList 	= ""
			local CategoryJobs 	= ""

			local OSList 		= ""
			local iPassword		= ""
			if (system.IsLinux()) then
				OSList = "Linux"
			elseif (system.IsWindows()) then
				OSList = "Windows"
			elseif (system.IsOSX()) then
				OSList = "OSX"
			end

			iBotsCount = 0
			for k, v in pairs(player.GetBots()) do
				iBotsCount = iBotsCount + 1
			end

			if (GetConVarString("sv_password") == "") then
				iPassword = "0"
			else
				iPassword = "1"
			end

			CommandsList = "{\"sv_cheats\":\"" 	..GetConVarNumber("sv_cheats").. "\",\
							\"tickrate\":\"" 	..math.floor(FrameTime()).. "\",\
							\"uptime\":\"" 		..CurTime().. "\",\
							\"appid\":\"4000\",\
							\"gamename\":\"Garry\'s Mod\",\
							\"game\":\"garrysmod\",\
							\"countbots\":" 	..iBotsCount.. ",\
							\"password\":" 		..iPassword.. ",\
							\"os\":\"" 			..OSList.. "\",\
							\"plversion\":\"" 	..monversion.. "\"}"
			-- 				[ Краш тест ]			--
			--[[for i = 1, 900, 1 do
				PlayerList = string.format("{\"name\":\"TEASASDASD" ..i.. "\",\"kills\":\"" ..i.. "\",\"deaths\":\"" ..i.. "\",\"ping\":\"BOTCrash\"}," ..PlayerList.. "")
			end]]
			--										--
			for k,v in pairs(RPExtraTeams) do
				szdescription = string.Replace(v.description, "\t", "")
				szdescription = string.Replace(szdescription, "\n", "[br]")
				szdescription = string.Replace(szdescription, "\"", "")
				szdescription = string.Replace(szdescription, "\\", "")

				CategoryJobs = ("{\"name\":\"" ..v.category.. "\",\"data\":[{\"name\":\"" ..v.name.. "\",\"description\":\"" ..szdescription.. "\",\"salary\":\"" ..v.salary.. " " ..MoneysName.. "\"}]}," ..CategoryJobs.. "")
			end

			CategoryJobs = "[" ..CategoryJobs.. "]"
			CategoryJobs = string.Replace(CategoryJobs, ",]", "]")

			--print(CategoryJobs) 

			for k, v in pairs(player.GetAll()) do
				Ping = 0
				if (v:Ping() <= 1) then
					Ping = "BOT"
				else
					Ping = v:Ping()
				end

				PlayerList = string.format("{\"ulxadmins\":\"" ..v:GetUserGroup().. "\",\
							\"name\":\"" 	..v:Nick().. "\",\
							\"kills\":" 	..v:Frags().. ",\
							\"deaths\":" 	..v:Deaths().. ",\
							\"ping\":\"" 	..Ping.. "\",\
							\"job\":\"" 	..v:getDarkRPVar("job").. "\",\
							\"moneys\":\"" 	..v:getDarkRPVar("money").. "\"}," ..PlayerList.. "")
			end

			PlayerList = "[" ..PlayerList.. "]"
			PlayerList = string.Replace(PlayerList, ",]", "]")

			PostUrl = "{\"n\":\"" 	..GetHostName().. "\",\
			\"id\":\"" 				..IDServer.. "\",\
			\"t\":\"sdk2013\",\
			\"m\":\"" 				..game.GetMap().. "\",\
			\"gamemode\":\"" 		..engine.ActiveGamemode().. "\",\
			\"pc\":\"" 				..player.GetCount().. "\",\
			\"pm\":\"" 				..game.MaxPlayers().. "\",\
			\"e\":" 				..CommandsList.. ",\
			\"p\":" 				..PlayerList.. ",\
				\"tabs\":[{\"name\":\"jobs\",\"data\":"..CategoryJobs.. "}]}"

			HashCode 	= sha1(PostUrl .. ServerToken)
			--PostUrl 	= string.Replace(PostUrl, " ", "%20")

			http.Post("" ..APIUrl.. "index.php", { cmd = "updateServer", data = PostUrl, s = HashCode, hash = "sha1" }, 
			function(CallBack_Information)
				print(CallBack_Information)
				if (CallBack_Information ~= "0" or CallBack_Information == "") then
					if (LangIndex_Monitoring == "ru") then
						print("Monitoring | " .. "Ошибка: Код " ..CallBack_Information)
						print("Monitoring | " .. "Прочтите документацию аддона на сайте.")
					elseif (LangIndex_Monitoring == "de") then
						print("Monitoring | " .. "Fehler: Code " ..CallBack_Information)
						print("Monitoring | " .. "Lesen Sie die Dokumentation des Plugins.")
					else
						print("Monitoring | " .. "Error: Code " ..CallBack_Information)
						print("Monitoring | " .. "Read the addon documentation on the site.")
					end
				end
			end,
			function(CallBack_ErrorMessage)
				print(CallBack_ErrorMessage)
			end)
			CategoryJobs= ""
			PlayerList 	= ""
			PostUrl 	= ""
			HashCode 	= ""
		end,
			function(CallBack_Error)
				print(CallBack_Error);
		end)
	end,
	function(errors)
		print(errors)
	end)
end)
