script_name('Lead Helper')
script_version('0.1.0.2 alpha')
script_author('OS Prod, K. Fedosov') 
require "lib.moonloader"

--[[

			L I B R A R I E S

]]--

local imgui      = 	require "imgui"
local sampev     =  require 'lib.samp.events'
local requests   =  require 'requests'
local encoding   = 	require 'encoding'
local inicfg     =	require 'inicfg'
encoding.default =  'CP1251'
u8 			         =  encoding.UTF8

--[[

			C O N F I G U R A T I O N

]]--

local direct = 'LeadHelper.ini'
local cfg = inicfg.load({
	settings = {
		antiblat = false,
		department = false,
		autoscreen = false,
		rp = false,
	},
	userdata = {
		position = '',
		fraction = '',
	},
}, direct)

if not doesFileExist(direct) then inicfg.save(cfg, direct) end

--[[
			
			V A R I A B L E S

]]--

local scriptsettings = {
	color = '{007ABE}',
	text_color = '{D3D3D3}',
	menu = 1,
	accept = false,
	password = '1',
}

local settings = {
	antiblat = imgui.ImBool(cfg.settings.antiblat),
	department = imgui.ImBool(cfg.settings.department),
	autoscreen = imgui.ImBool(cfg.settings.autoscreen),
	rp = imgui.ImBool(cfg.settings.rp),
}

local frames = {
	mainwindow = imgui.ImBool(false),
	callstatus = imgui.ImBool(false),
	password = imgui.ImBool(false),

}

local userdata = {
	position = imgui.ImBuffer(''..cfg.userdata.position, 256),
	fraction = imgui.ImBuffer(''..cfg.userdata.fraction, 256),
	inputpassword = imgui.ImBuffer('', 13),
}

--[[

			D I R E C T O R I E S
			F I L E S

]]--

if not doesDirectoryExist('\\LeadHelper\\Авто-антиблат') then createDirectory(getWorkingDirectory()..'\\LeadHelper\\Авто-антиблат') end
if settings.antiblat.v and not doesFileExist('\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt') then 
	abfile = io.open(getWorkingDirectory()..'\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt', 'a')
	abfile:write('')
  abfile:close()
end

--[[

			M A I N   F U N C T I O N (+variables=funcs)

]]--

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  if not doesFileExist(direct) then inicfg.save(cfg, direct) end
	update("https://raw.githubusercontent.com/deveeh/leadhelper/master/update.json", '['..string.upper(thisScript().name)..']: ', "")
	updatepassword("https://raw.githubusercontent.com/deveeh/leadhelper/master/password.json", '['..string.upper(thisScript().name)..']: ', "")
	themeSettings()
	msg("Команда активации: /lhelp")

	sampRegisterChatCommand('lhelp', function()
		if scriptsettings.accept then
			frames.mainwindow.v = not frames.mainwindow.v
		elseif not scriptsettings.accept then
			frames.password.v = not frames.password.v
		end
	end)

	sampRegisterChatCommand('giverank', function(arg)
		local id, oldrank, newrank, reason = arg:match('(%d+) (%d+) (%d+) (.+)')
		if settings.antiblat.v then
			if id and oldrank and newrank and reason then
				if sampIsPlayerConnected(id) then
					abfile = io.open(getWorkingDirectory()..'\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt', 'a')
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
				msg('Правильное использование команды: {EB8C86}/giverank [id] [старый ранг] [новый ранг] [причина]')
			end
		else
			msg('Данное действие доступно только с включенной функцией Авто-антиблата')
		end
	end)

	sampRegisterChatCommand('invite', function(arg)
		local id, reason = arg:match('(%d+) (.+)')
		if settings.antiblat.v then
			if sampIsPlayerConnected(id) then
				if id and reason then
					abfile = io.open(getWorkingDirectory()..'\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y")..'.txt', 'a')
					abfile:write(sampGetPlayerNickname(id)..' | Принят на 1-й ранг | Причина: '..reason..' | Время: '..os.date("%H:%M:%S"..'\n'))
					abfile:close()
					lua_thread.create(function()
						sampSendChat('/do Заявление на прием в руках.')
						wait(2000)
						sampSendChat('/me внимательно изучил(а) заявление и расписался(ась) в нужной графе')
						wait(2000)
						sampSendChat('/do Документ подписан.')
						wait(2000)
						sampSendChat('/todo Поздравляю, вы приняты в нашу организацию!*передавая новую форму человеку напротив')
						wait(500)
						sampSendChat('/invite '..id)
					end)
				else
					msg('Правильное использование команды: {EB8C86}/invite [id] [причина]')
				end
			else
				msg('Данный игрок не находится в игре.')
			end
		else
			msg('Данное действие доступно только с включенной функцией Авто-антиблата')
		end
	end)

	sampRegisterChatCommand('uninvite', function(arg)
		local id, reason = arg:match('(%d+) (.+)')
		if settings.rp.v then
			if sampIsPlayerConnected(id) then
				if id and reason then
					lua_thread.create(function()
						sampSendChat('/me достав КПК зашёл в базу данных сотрудников "'..u8:decode(userdata.fraction.v)..'".')
						wait(2000)
						sampSendChat('/do База данных открыта.')
						wait(1200)
						sampSendChat('/me внёс изменения в базу данных cотрудников "'..u8:decode(userdata.fraction.v)..'".')
						wait(2200)
						sampSendChat('/do Сотрудник уволен.')
						wait(500)
						sampSendChat('/uninvite '..id..' '..reason)
					end)
				else
					msg('Правильное использование команды: {EB8C86}/uninvite [id] [причина]')
				end
			else
				msg('Данный игрок не находится в игре.')
			end
		else
			msg('Данное действие доступно только с включенной функцией "RP отыгровки"')
		end
	end)

	sampRegisterChatCommand('fwarn', function(arg)
		local id, reason = arg:match('(%d+) (.+)')
		if settings.rp.v then
			if sampIsPlayerConnected(id) then
				if id and reason then
					lua_thread.create(function()
						sampSendChat('/me достав КПК зафиксировал нарушение сотрудника')
						wait(2000)
						sampSendChat('/do Нарушение зафиксировано.')
						wait(1150)
						sampSendChat('/me внёс изменения в базу данных cотрудников '..u8:decode(userdata.fraction.v))
						wait(2120)
						sampSendChat('/do Изменения в базу данных внесены.')
						wait(1150)
						sampSendChat('/fwarn '..id..' '..reason)
					end)
				else
					msg('Правильное использование команды: {EB8C86}/fwarn [id] [причина]')
				end
			else
				msg('Данный игрок не находится в игре.')
			end
		else
			msg('Данное действие доступно только с включенной функцией "RP отыгровки"')
		end
	end)

	sampRegisterChatCommand('unfwarn', function(arg)
		local id = arg:match('(%d+)')
		if settings.rp.v then
			if sampIsPlayerConnected(id) then
				if id then
					lua_thread.create(function()
						sampSendChat('/me достав КПК зашёл в личное дело сотрудника '..u8:decode(userdata.fraction.v))
						wait(2000)
						sampSendChat('/do Личное дело открыто.')
						wait(1200)
						sampSendChat('/me внёс изменения в базу данных cотрудников '..u8:decode(userdata.fraction.v))
						wait(2200)
						sampSendChat('/do Изменения в базу данных внесены.')
						wait(1200)
						sampSendChat('/unfwarn '..id)
					end)
				else
					msg('Правильное использование команды: {EB8C86}/unfwarn [id]')
				end
			else
				msg('Данный игрок не находится в игре.')
			end
		else
			msg('Данное действие доступно только с включенной функцией "RP отыгровки"')
		end
	end)

	sampRegisterChatCommand('d', function(arg)
		local called_fraction, text = arg:match('(.+); (.+)')
		if settings.rp.v then
			if sampIsPlayerConnected(id) then
				if called_fraction and text then
					lua_thread.create(function()
						sampSendChat('/do В левом ухе находится гарнитура с пометкой "Департамент".')
						wait(1000)
						sampSendChat('/me нажал кнопку наушника и что-то передал')
						wait(500)
						sampSendChat('/d ['..u8:decode(userdata.fraction.v)..'] - ['..called_fraction..']: '..text)
					end)
				else
						msg('Правильное использование команды: {EB8C86}/d [тэг фракции (к которой обращаетесь)]; [текст]')
						msg('Между тэгом фракции и текстом нужно обязательно поставить ТОЧКУ С ЗАПЯТОЙ!!!')	
				end
			else
				msg('Данный игрок не находится в игре.')
			end
		else
			msg('Данное действие доступно только с включенной функцией "Авто-департамент"')
		end
	end)

	sampRegisterChatCommand('r', function(arg)
		local text = arg:match('(.+)')
		if settings.rp.v then
			if text then
				lua_thread.create(function()
					sampSendChat('/do В правом ухе находится гарнитура с пометкой "'..u8:decode(userdata.fraction.v)..'".')
					wait(1000)
					sampSendChat('/me нажал кнопку наушника и что-то передал')
					wait(3000)
					sampSendChat('/r ['..u8:decode(userdata.position.v)..'] '..text)
				end)
			else
				msg('Правильное использование команды: {EB8C86}/r [текст(без тэга)]')
			end
		else
			msg('Данное действие доступно только с включенной функцией "RP отыгровки"')
		end
	end)

	while true do
		wait(0)
		imgui.Process = frames.mainwindow.v or frames.callstatus.v or frames.password.v
	end
end

function imgui.OnDrawFrame()
	local width, height = getScreenResolution()

	if frames.callstatus.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowPos(imgui.ImVec2(width / 2 , height - 50), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(215, 85), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.14, 0.14, 0.14, 0.50))
		imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0.00, 0.46, 0.71, 0.90))
		imgui.Begin(u8"Department##callstatuswindow", frames.callstatus.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
		imgui.CenterText(u8'Нажмите на Y для ответа')
		imgui.CenterText(u8'Нажмите на N для игнорирования')
		imgui.End()
		imgui.PopStyleColor(2)
	end

	if frames.mainwindow.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(width / 2 , height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 325), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.00, 0.46, 0.71, 0.85))
		imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0.00, 0.46, 0.71, 0.90))
		imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.12, 0.12, 0.12, 0.90))
		imgui.Begin("v"..thisScript().version.."##mainwindow", frames.mainwindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove)
			imgui.BeginChild("left", imgui.ImVec2(150, 290), true)
				imgui.CenterText(u8'LeadHelper')
				if imgui.Selectable(u8'Персонализация', scriptsettings.menu == 1) then scriptsettings.menu = 1
				elseif imgui.Selectable(u8'Функции', scriptsettings.menu == 2) then scriptsettings.menu = 2
				elseif imgui.Selectable(u8'Информация', scriptsettings.menu == 3) then scriptsettings.menu = 3
				--elseif imgui.Selectable(u8'Информация', scriptsettings.menu == 4) then scriptsettings.menu = 4
				end
				imgui.SetCursorPosY(265)
				if imgui.Button(u8'Сохранить', imgui.ImVec2(135, 20)) then
			      inicfg.save(cfg, direct)
						msg('Все настройки сохранены.')
			  end
			imgui.EndChild() imgui.SameLine()
			imgui.BeginChild('right', imgui.ImVec2(325, 290), true)
				if scriptsettings.menu == 1 then
					imgui.Text(u8'Ваша фракция:    ')
					imgui.SameLine()
					imgui.PushItemWidth(54.5) 
					if imgui.InputTextWithHint("##userdata.fraction", u8"ГУВД-А", userdata.fraction) then cfg.userdata.fraction = userdata.fraction.v end
					imgui.PopItemWidth()
					imgui.Text(u8'Ваша должность: ')
					imgui.SameLine()
					imgui.PushItemWidth(102.5) 
					if imgui.InputTextWithHint("##userdata.position", u8"Зам. Директора", userdata.position) then cfg.userdata.position = userdata.position.v end
					imgui.PopItemWidth() 
				elseif scriptsettings.menu == 2 then
					if imgui.Checkbox(u8'Авто-антиблат', settings.antiblat) then cfg.settings.antiblat = settings.antiblat.v end
					imgui.TextQuestion(u8'Команды авто-антиблата:\n  /giverank - изменение ранга\n  /invite - приглашение во фракцию\n\nСохраняет все действия связанные с\n  повышением/понижением/принятием во фракцию по пути:\n'..u8'GTA\\moonloader\\LeadHelper\\Авто-антиблат\\Антиблат - '..os.date("%d.%m.%Y"))
					if imgui.Checkbox(u8'Авто-департамент', settings.department) then cfg.settings.department = settings.department.v end
					imgui.TextQuestion(u8'Ваш главный помощник с рацией департамента.\nРаботать с департаментом стало гораздо проще.\nТеперь тебе не нужно постоянно переключаться между языками,\nа отвечать ты можешь нажатием одной кнопки.')
					if imgui.Checkbox(u8'Авто-скрин', settings.autoscreen) then cfg.settings.autoscreen = settings.autoscreen.v end
					imgui.TextQuestion(u8'При повышении/принятии во фракцию автоматически делает скрин с таймом')
					if imgui.Checkbox(u8'RP отыгровки', settings.rp) then cfg.settings.rp = settings.rp.v end
					imgui.TextQuestion(u8'Список доступных команд:\n  /invite [id] [причина]\n  /uninvite [id] [причина]\n  /fwarn [id] [причина]\n  /unfwarn [id]\n  /r [текст] - рация\n  /d [тэг фракции(которую вызываете)]; [текст]')
				elseif scriptsettings.menu == 3 then
					imgui.Text(u8'LeadHelper - первый и единственный скрипт,\n  который предназначен для того, чтобы помогать\n  Лидерам и заместителям лидеров.\n\nЭто не стиллер, не чит, и уж тем более\n  мы не пытаемся украсть ваши данные.\n\nДанный скрипт поможет тебе отстоять срок\n  урезая рутинную работу.')
					imgui.Text('')
					imgui.Text(u8'Разработчики:') imgui.SameLine() imgui.Link('https://vk.com/osprodsamp', 'OS Production') imgui.SameLine() imgui.Text(u8'x') imgui.SameLine() imgui.Link('https://vk.com/r.sozykin', 'Kostya Fedosov')
					imgui.Text(u8'Нашли баг, есть предложения?') imgui.SameLine() imgui.Link('https://vk.me/r.sozykin', u8'Вам сюда!')
				elseif scriptsettings.menu == 4 then
				end
			imgui.EndChild()
		imgui.End()
		imgui.PopStyleColor(3)
	end
	if frames.password.v then
			imgui.ShowCursor = true
			imgui.SetNextWindowPos(imgui.ImVec2(width / 2 , height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(250, 125), imgui.Cond.FirstUseEver)
			imgui.Begin("Log In##passwordwindow", frames.password, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove)
				imgui.Text('')
				imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - 117.5 / 2)
				imgui.PushItemWidth(117.5)
				imgui.InputTextWithHint("##password", u8"Введите пароль...", userdata.inputpassword)
				imgui.PopItemWidth()
				imgui.Text('')
				imgui.SetCursorPosX(57.5)
				if imgui.Button(u8'Отправить данные', imgui.ImVec2(135, 20)) then
					if userdata.inputpassword.v == scriptsettings.password then
						scriptsettings.accept = true
						frames.password.v = false
						frames.mainwindow.v = true
					else
						msg('Пароль введён неверно, отказано в доступе.')
						frames.password.v = false
					end
			  end
			imgui.End()
	end
end

--[[

			  W O R K I N G 

			F U N C T I O N S

]]--

function sampev.onServerMessage(color, text)
	if not sampIsCursorActive() then
		_, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
		lua_thread.create(function()
			if settings.department.v and text:find('%[D%] (.+) (.+)%[(%d+)%]: %[(.+)%](.+)%['..u8:decode(userdata.fraction.v)..'%](.+)') then
				local _, _, _, caller_fraction, _, _, _ = text:match('%[D%] (.+) (.+)%[(%d+)%]: %[(.+)%](.+)%['..u8:decode(userdata.fraction.v)..'%](.+)')
				frames.callstatus.v = true
				while frames.callstatus.v do
					wait(0) 
					if frames.callstatus.v and wasKeyPressed(0x59) then
						sampSendChat('/do В левом ухе находится гарнитура с пометкой "Департамент".')
						wait(1000)
						sampSendChat('/me нажал кнопку наушника и что-то передал')
						wait(100)
						sampSetChatInputText('/d ['..u8:decode(userdata.fraction.v)..'] - ['..caller_fraction..']: ')
						setVirtualKeyDown(117, true)
						setVirtualKeyDown(117, false)
						frames.callstatus.v = false
					elseif frames.callstatus.v and wasKeyPressed(0x4E) then
						msg('Вы проигнорировали сообщение в департамент от '..caller_fraction)
						frames.callstatus.v = false
					end
				end
			end
			if settings.autoscreen.v and text:find('^Вы повысили игрока (.+) до (%d+) ранга') or text:find('^Приветствуем нового члена нашей организации (.+)%, которого пригласил (.+)%['..myID..'%].') then
				wait(500)
				sampSendChat('/time')
				wait(500)
				setVirtualKeyDown(119, true) 
				setVirtualKeyDown (119, false)
			end
		end)
	end
end

function updatepassword(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-password.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            info = decodeJson(f:read('*a'))
            updatelink = info.updatelink
            password = info.password
            f:close()
            os.remove(json)
            if password ~= scriptsettings.password then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                wait(0)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
            end]]--
          end
        else
          update = false
        end
      end
    end
  )
end

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

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    local iWidth = imgui.GetWindowWidth()
    local iTextSize = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( iWidth / 2 - iTextSize.x / 2 )

    render_text(text)
end

function imgui.Link(link,name,myfunc)
	myfunc = type(name) == 'boolean' and name or myfunc or false
	name = type(name) == 'string' and name or type(name) == 'boolean' and link or link
	local size = imgui.CalcTextSize(name)
	local p = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local resultBtn = imgui.InvisibleButton('##'..link..name, size)
	if resultBtn then
		if not myfunc then
		    os.execute('explorer '..link)
		end
	end
	imgui.SetCursorPos(p2)
	if imgui.IsItemHovered() then
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], name)
		imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
	else
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Button], name)
	end
	return resultBtn
end

function imgui.TextQuestion(text)
	imgui.SameLine()
	imgui.TextDisabled('(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end

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
		colors[clr.TitleBg]                = ImVec4(0.00, 0.46, 0.71, 0.90);
		colors[clr.TitleBgActive]          = ImVec4(0.00, 0.46, 0.71, 1.00);
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
		colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
		colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.12, 0.12, 0.12, 1.00);
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.36, 0.36, 0.36, 1.00);
		colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
		colors[clr.CheckMark]              = ImVec4(0.00, 0.48, 0.75, 1.00);
		colors[clr.SliderGrab]             = ImVec4(0.00, 0.48, 0.75, 1.00);
		colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.46, 0.71, 1.00);
		colors[clr.Button]                 = ImVec4(0.00, 0.48, 0.75, 1.00);
		colors[clr.ButtonHovered]          = ImVec4(0.00, 0.71, 0.94, 1.00);
		colors[clr.ButtonActive]           = ImVec4(0.00, 0.46, 0.71, 1.00);
		colors[clr.Header]                 = ImVec4(0.00, 0.48, 0.75, 1.00);
		colors[clr.HeaderHovered]          = ImVec4(0.00, 0.71, 0.94, 1.00);
		colors[clr.HeaderActive]           = ImVec4(0.00, 0.46, 0.71, 1.00);
		colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
		colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
		colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
		colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.30);
		colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.50);
		colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 0.60);
		colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
		colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
		colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
		colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end	