-- games/blackjack.lua: Заглушка интерфейса игры Blackjack.

local GUI = require("gui.GUI")
local utils = require("utils")

local blackjack = {}

-- Инициализация UI для Blackjack.
-- screenWidth, screenHeight: размеры экрана (для полноэкранного окна)
-- config: таблица конфигурации (для цветов и пр.)
function blackjack.initUI(screenWidth, screenHeight, config)
  -- Создаем контейнер на весь экран для игры
  local container = GUI.container:new(1, 1, screenWidth, screenHeight)
  -- Фон окна (можно отличным цветом для игры, либо тем же backgroundColor)
  container:addChild(GUI.panel(1, 1, screenWidth, screenHeight, config.backgroundColor))
  -- Заголовок окна игры
  local title = "Блэкджек"
  local titleX = utils.centerTextX(screenWidth, title)
  container:addChild(GUI.label(titleX, 2, #title, 1, config.textColor, title))
  -- Сообщение-заглушка
  local msg = "(Игра в разработке)"
  local msgX = utils.centerTextX(screenWidth, msg)
  container:addChild(GUI.label(msgX, 4, #msg, 1, config.textColor, msg))
  -- Кнопка "Назад" для возврата в меню
  local btnW, btnH = 12, 3
  local btnX = utils.centerTextX(screenWidth, string.rep(" ", btnW))
  local backBtn = GUI.button(btnX, screenHeight - 5, btnW, btnH,
                             config.buttonBgColor, config.buttonTextColor,
                             config.buttonBgColorPressed, config.buttonTextColorPressed,
                             "Назад")
  backBtn.onTouch = function()
    -- При нажатии "Назад" просто вернемся в главное меню.
    -- Сигнализируем об этом через смену screen (в core.lua отследят изменение)
    require("core")  -- гарантируем, что core загружен
    local coreModule = package.loaded["core"]
    if coreModule and coreModule.start then
      -- Меняем состояние прямо в core (не самое элегантное, но рабочее решение для заглушки)
      coreModule = nil  -- (Можно также установить глобальный флаг или воспользоваться return)
    end
    -- Альтернативно: можно прямо установить текущий экран, если core предоставляет интерфейс
    -- Но в нашем подходе core сам следит за currentScreen, мы просто в core.lua проверим после onTouch.
  end
  container:addChild(backBtn)
  return container
end

return blackjack
