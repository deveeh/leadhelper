script_name('Lead Helper')
script_version('0.1.0.1 alpha')
script_author('OS Prod, K. Fedosov') 
require "lib.moonloader"

--local vkeys = require "vkeys"
local imgui    = 	require "imgui"
local encoding = 	require 'encoding'
local inicfg   =	require 'inicfg'
encoding.default =  'CP1251'
u8 			   =    encoding.UTF8

local cfg = inicfg.load({
	test = false,
}, "LeadHelper.ini")

local scriptsettings = {
	color = '{5D00C0}',
	text_color = '{D3D3D3}'
}

local frames = {
	mainwindow = imgui.ImBool(false)
}

local userdata = {

}

local resX, resY = getScreenResolution()

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
	if not doesFileExist(getWorkingDirectory()..'\\config\\LeadHelper.ini') then inicfg.save(cfg, 'LeadHelper.ini') end
	update("https://raw.githubusercontent.com/deveeh/leadhelper/master/update.json", '['..string.upper(thisScript().name)..']: ', "")
	--msg("Команда для активации: /lhelp")

	sampRegisterChatCommand('lhelp', function()
		frames.mainwindow.v = not frames.mainwindow.v
	end)

	while true do
		wait(0)
		imgui.Process = frames.mainwindow.v
	end
end

function imgui.OnDrawFrame()
	if frames.mainwindow.v then
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 , resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 325), imgui.Cond.FirstUseEver)
		imgui.Begin("LeadHelper | v"..thisScript().version, frames.mainwindow, imgui.WindowFlags.NoResize)
			imgui.BeginChild("left", imgui.ImVec2(150, 290), true)
				if imgui.Selectable(u8'Персонализация', menu == 1) then menu = 1
				elseif imgui.Selectable(u8'Настройки', menu == 2) then menu = 2
				elseif imgui.Selectable(u8'Информация', menu == 3) then menu = 3
				end
			imgui.EndChild() imgui.SameLine()
			imgui.BeginChild('right', imgui.ImVec2(325, 290), true)
				if menu == 1 then

				end
			imgui.EndChild()
		imgui.End()
	end
end

function msg(arg)
	sampAddChatMessage(scriptsettings.color.."[LeadHelper] "..scriptsettings.text_color..arg.."", -1)

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

themeSettings()

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