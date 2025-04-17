-- games/roulette.lua: Заглушка интерфейса игры Roulette.

local GUI = require("gui.GUI")
local utils = require("utils")

local roulette = {}

function roulette.initUI(screenWidth, screenHeight, config)
  local container = GUI.container:new(1, 1, screenWidth, screenHeight)
  container:addChild(GUI.panel(1, 1, screenWidth, screenHeight, config.backgroundColor))
  local title = "Рулетка"
  local titleX = utils.centerTextX(screenWidth, title)
  container:addChild(GUI.label(titleX, 2, #title, 1, config.textColor, title))
  local msg = "(Игра в разработке)"
  local msgX = utils.centerTextX(screenWidth, msg)
  container:addChild(GUI.label(msgX, 4, #msg, 1, config.textColor, msg))
  local btnW, btnH = 12, 3
  local btnX = utils.centerTextX(screenWidth, string.rep(" ", btnW))
  local backBtn = GUI.button(btnX, screenHeight - 5, btnW, btnH,
                             config.buttonBgColor, config.buttonTextColor,
                             config.buttonBgColorPressed, config.buttonTextColorPressed,
                             "Назад")
  backBtn.onTouch = function()
    -- Логика аналогична Blackjack: вернуться в главное меню
    require("core")
    local coreModule = package.loaded["core"]
    if coreModule and coreModule.start then
      coreModule = nil
    end
  end
  container:addChild(backBtn)
  return container
end

return roulette
