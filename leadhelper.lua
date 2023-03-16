script_name('Lead Helper')
script_version('0.1.0.2 alpha')
script_author('OS Prod, K. Fedosov') 
require "lib.moonloader"

--[[

			L I B R A R I E S

]]--
local imgui      = 	require "imgui"
local encoding   = 	require 'encoding'
local inicfg     =	require 'inicfg'
encoding.default =  'CP1251'
u8 			         =  encoding.UTF8

--[[

			D I R E C T O R I E S
			F I L E S
			C O N F I G U R A T I O N

]]--

local direct = 'LeadHelper\\config.ini'
local cfg = inicfg.load({
	settings = {
		antiblat = false,
	},
	userdata = {
		position = '',
		fraction = '',
	},
}, direct)

if not doesFileExist(direct) then inicfg.save(cfg, direct) end
if not doesDirectoryExist(getWorkingDirectory()..'\\config\\LeadHelper\\Авто-антиблат') then createDirectory(getWorkingDirectory()..'\\config\\LeadHelper\\Авто-антиблат') end
if not doesFileExist(getWorkingDirectory()..'\\config\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt') then 
	abfile = io.open(getWorkingDirectory()..'\\config\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt', 'a')
	abfile:write('')
  abfile:close()
end

--[[
			
			V A R I A B L E S

]]--

local scriptsettings = {
	color = '{5D00C0}',
	text_color = '{D3D3D3}',
	menu = 1,
}

local settings = {
	antiblat = imgui.ImBool(cfg.settings.antiblat)
}

local frames = {
	mainwindow = imgui.ImBool(false)
}

local userdata = {
	position = imgui.ImBuffer(''..cfg.userdata.position, 256),
	fraction = imgui.ImBuffer(''..cfg.userdata.fraction, 256),
}

--[[

			M A I N   F U N C T I O N

]]--

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  if not doesFileExist(direct) then inicfg.save(cfg, direct) end
	update("https://raw.githubusercontent.com/deveeh/leadhelper/master/update.json", '['..string.upper(thisScript().name)..']: ', "")
	themeSettings()
	--msg("Команда для активации: /lhelp")

	sampRegisterChatCommand('lhelp', function()
		frames.mainwindow.v = not frames.mainwindow.v
	end)

	sampRegisterChatCommand('rank', function(arg)
		local id, oldrank, newrank, reason = arg:match('(%d+) (%d+) (%d+) (.+)')
		if settings.antiblat.v then
			if id and oldrank and newrank and reason then
				if sampIsPlayerConnected(id) then
					abfile = io.open(getWorkingDirectory()..'\\config\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt', 'a')
					abfile:write(sampGetPlayerNickname(id)..' | '..oldrank..' -> '..newrank..' | Причина: '..reason..' | Время: '..os.date("%H:%M:%S"..'\n'))
				  abfile:close()
				  lua_thread.create(function()
					  sampSendChat('/do Личное дело сотрудника на столе.')
					  wait(2000)
					  sampSendChat('/me открыл личное дело сотрудника и внёс изменения о должности')
					  wait(500)
						sampSendChat('/giverank '..id..' '..newrank)
					end)
				else
					msg('Данный игрок не находится в игре.')
				end
			else
				msg('Правильное использование команды: {EB8C86}/giverank [id] [old rank] [new rank] [reason]')
			end
		else
			msg('Данное действие доступно только с включенной функцией Авто-антиблата')
		end
	end)

	sampRegisterChatCommand('inv', function(arg)
		local id, reason = arg:match('(%d+) (.+)')
		if settings.antiblat.v then
			if sampIsPlayerConnected(id) then
				if id and reason then
					abfile = io.open(getWorkingDirectory()..'\\config\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt', 'a')
					abfile:write(sampGetPlayerNickname(id)..' | Принят на 1-й ранг | Причина: '..reason..' | Время: '..os.date("%H:%M:%S"..'\n'))
					abfile:close()
					lua_thread.create(function()
						sampSendChat('/do Заявление на прием в руках.')
						wait(2000)
						sampSendChat('/me внимательно изучил заявление и расписался в нужной графе')
						wait(2000)
						sampSendChat('/do Документ подписан.')
						wait(2000)
						sampSendChat('/todo Поздравляю, вы приняты в нашу организацию!*передал новую форму человеку напротив')
						wait(500)
						sampSendChat('/invite '..id)
					end)
				else
					msg('Правильное использование команды: {EB8C86}/invite [id] [reason]')
				end
			else
				msg('Данный игрок не находится в игре.')
			end
		else
			msg('Данное действие доступно только с включенной функцией Авто-антиблата')
		end
	end)

	while true do
		wait(0)
		imgui.Process = frames.mainwindow.v
	end
end

function imgui.OnDrawFrame()
	if frames.mainwindow.v then
		local width, height = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(width / 2 , height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 325), imgui.Cond.FirstUseEver)
		imgui.Begin("v"..thisScript().version.."##mainwindow", frames.mainwindow, imgui.WindowFlags.NoResize)
			imgui.BeginChild("left", imgui.ImVec2(150, 290), true)
				imgui.CenterText(u8'LeadHelper')
				if imgui.Selectable(u8'Персонализация', scriptsettings.menu == 1) then scriptsettings.menu = 1
				elseif imgui.Selectable(u8'Функции', scriptsettings.menu == 2) then scriptsettings.menu = 2
				elseif imgui.Selectable(u8'Настройки', scriptsettings.menu == 3) then scriptsettings.menu = 3
				elseif imgui.Selectable(u8'Информация', scriptsettings.menu == 4) then scriptsettings.menu = 4
				end
			imgui.EndChild() imgui.SameLine()
			imgui.BeginChild('right', imgui.ImVec2(325, 290), true)
				if scriptsettings.menu == 1 then
					imgui.Text(u8'Ваша фракция:    ')
					imgui.SameLine()
					imgui.PushItemWidth(37.5) 
					if imgui.InputTextWithHint(u8"##userdata.fraction", u8"ФСБ", userdata.fraction) then cfg.userdata.fraction = userdata.fraction.v end
					imgui.PopItemWidth()
					imgui.Text(u8'Ваша должность: ')
					imgui.SameLine()
					imgui.PushItemWidth(102.5) 
					if imgui.InputTextWithHint(u8"##userdata.position", u8"Зам. Директора", userdata.position) then cfg.userdata.position = userdata.position.v end
					imgui.PopItemWidth() 
				elseif scriptsettings.menu == 2 then
					if imgui.Checkbox(u8'Авто-антиблат', settings.antiblat) then cfg.settings.antiblat = settings.antiblat.v end
				elseif scriptsettings.menu == 3 then
				elseif scriptsettings.menu == 4 then
				end
			imgui.EndChild()
		imgui.End()
	end
end

--[[

			  W O R K I N G 

			F U N C T I O N S
]]--

function update(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                msg('Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion)
                wait(0)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      msg('Скрипт успешно обновился до версии '..updateversion..'.')
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        msg('Не получается обновиться, запускаю старую версию ('..thisScript().version..')')
                        imgui.ShowCursor = true
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              imgui.ShowCursor = true
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function msg(arg)
	sampAddChatMessage(scriptsettings.color.."[LeadHelper]: "..scriptsettings.text_color..arg.."", -1)
end

--[[

		   V I S U A L
	
		F U N C T I O N S

]]--

function imgui.InputTextWithHint(label, hint, buf, flags, callback, user_data)
    local l_pos = {imgui.GetCursorPos(), 0}
    local handle = imgui.InputText(label, buf, flags, callback, user_data)
    l_pos[2] = imgui.GetCursorPos()
    local t = (type(hint) == 'string' and buf.v:len() < 1) and hint or '\0'
    local t_size, l_size = imgui.CalcTextSize(t).x, imgui.CalcTextSize('A').x
    imgui.SetCursorPos(imgui.ImVec2(l_pos[1].x + 6, l_pos[1].y + 2))
    imgui.TextDisabled((imgui.CalcItemWidth() and t_size > imgui.CalcItemWidth()) and t:sub(1, math.floor(imgui.CalcItemWidth() / l_size)) or t)
    imgui.SetCursorPos(l_pos[2])
    return handle
end

function imgui.CenterText(text)
    local iWidth = imgui.GetWindowWidth()
    local iTextSize = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( iWidth / 2 - iTextSize.x / 2 )
    imgui.Text(text)
end

function themeSettings()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local ImVec2 = imgui.ImVec2
	style.WindowPadding = imgui.ImVec2(8, 8)
	style.WindowRounding = 6
	style.ChildWindowRounding = 5
	style.FramePadding = imgui.ImVec2(5, 3)
	style.FrameRounding = 3.0
	style.ItemSpacing = imgui.ImVec2(5, 4)
	style.ItemInnerSpacing = imgui.ImVec2(4, 4)
	style.IndentSpacing = 21
	style.ScrollbarSize = 10.0
	style.ScrollbarRounding = 13
	style.GrabMinSize = 8
	style.GrabRounding = 1
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
	colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
	colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
	colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
	colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
	colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
	colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
	colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
	colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
	colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
	colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
	colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
	colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.12, 0.12, 0.12, 1.00);
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.36, 0.36, 0.36, 1.00);
	colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
	colors[clr.CheckMark]              = ImVec4(0.37, 0.00, 0.75, 1.00);
	colors[clr.SliderGrab]             = ImVec4(0.37, 0.00, 0.75, 1.00);
	colors[clr.SliderGrabActive]       = ImVec4(0.31, 0.00, 0.71, 1.00);
	colors[clr.Button]                 = ImVec4(0.37, 0.00, 0.75, 1.00);
	colors[clr.ButtonHovered]          = ImVec4(0.47, 0.00, 0.94, 1.00);
	colors[clr.ButtonActive]           = ImVec4(0.31, 0.00, 0.71, 1.00);
	colors[clr.Header]                 = ImVec4(0.37, 0.00, 0.75, 1.00);
	colors[clr.HeaderHovered]          = ImVec4(0.47, 0.00, 0.94, 1.00);
	colors[clr.HeaderActive]           = ImVec4(0.31, 0.00, 0.71, 1.00);
	colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
	colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
	colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
	colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
	colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
	colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
	colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
	colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
	colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end	