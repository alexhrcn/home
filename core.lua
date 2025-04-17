-- core.lua: Основная логика интерфейса мини-казино.
-- Управляет созданием окон, переключением между главным меню и играми, обработкой событий ввода.

local event = require("event")
local component = require("component")
local GUI = require("gui.GUI")
local balance = require("balance")
local config = require("config")
local utils = require("utils")

-- Создаем главное приложение (контейнер на весь экран)
local app = GUI.application()

-- Флаги состояния
local currentScreen = "main"      -- текущее "окно": "main", "blackjack", "roulette"
local running = true             -- флаг работы главного цикла

-- Контейнеры/окна интерфейса
local mainMenuContainer          -- контейнер главного меню
local blackjackContainer         -- контейнер игры Blackjack (заглушка)
local rouletteContainer          -- контейнер игры Roulette (заглушка)

-- Функция для построения интерфейса главного меню казино
local function buildMainMenu()
  mainMenuContainer = GUI.container:new(1, 1, app.width, app.height)
  -- Фон (панель) на весь экран
  mainMenuContainer:addChild(GUI.panel(1, 1, app.width, app.height, config.backgroundColor))
  -- Заголовок "Mini-Casino"
  local titleText = "Mini-Casino"
  local titleX = utils.centerTextX(app.width, titleText)
  mainMenuContainer:addChild(GUI.label(titleX, 3, #titleText, 1, config.textColor, titleText))
  -- Отображение текущего баланса
  local balanceText = utils.formatBalance(balance.get())
  local balanceX = utils.centerTextX(app.width, balanceText)
  mainMenuContainer:addChild(GUI.label(balanceX, 5, #balanceText, 1, config.textColor, balanceText))
  -- Кнопка "Blackjack"
  local btnWidth = 20
  local btnHeight = 3
  local btnX = utils.centerTextX(app.width, string.rep(" ", btnWidth))  -- центрируем по ширине экрана
  local blackjackBtn = GUI.button(btnX, 8, btnWidth, btnHeight, 
                                  config.buttonBgColor, config.buttonTextColor, 
                                  config.buttonBgColorPressed, config.buttonTextColorPressed, 
                                  "Blackjack")
  -- Назначаем обработчик клика по кнопке Blackjack
  blackjackBtn.onTouch = function()
    currentScreen = "blackjack"
  end
  mainMenuContainer:addChild(blackjackBtn)
  -- Кнопка "Roulette"
  local rouletteBtn = GUI.button(btnX, 12, btnWidth, btnHeight,
                                 config.buttonBgColor, config.buttonTextColor,
                                 config.buttonBgColorPressed, config.buttonTextColorPressed,
                                 "Roulette")
  rouletteBtn.onTouch = function()
    currentScreen = "roulette"
  end
  mainMenuContainer:addChild(rouletteBtn)
  -- Кнопка "Выход"
  local exitBtn = GUI.button(btnX, 16, btnWidth, btnHeight,
                             config.buttonBgColor, config.buttonTextColor,
                             config.buttonBgColorPressed, config.buttonTextColorPressed,
                             "Выход")
  exitBtn.onTouch = function()
    running = false       -- установим флаг для выхода из цикла
  end
  mainMenuContainer:addChild(exitBtn)
end

-- Функции для построения интерфейсов игр (заглушек)

local function buildBlackjackUI()
  local games = require("games.blackjack")
  blackjackContainer = games.initUI(app.width, app.height, config)  -- создаем окно игры, передавая размеры экрана и конфиг
end

local function buildRouletteUI()
  local games = require("games.roulette")
  rouletteContainer = games.initUI(app.width, app.height, config)
end

-- Функция отрисовки текущего активного экрана (main menu или игра)
local function drawCurrentScreen()
  if currentScreen == "main" then
    mainMenuContainer:draw()
  elseif currentScreen == "blackjack" and blackjackContainer then
    blackjackContainer:draw()
  elseif currentScreen == "roulette" and rouletteContainer then
    rouletteContainer:draw()
  end
  -- После отрисовки всех компонентов выводим на экран содержимое буфера
  local buffer = require("gui.DoubleBuffering")
  buffer.draw()
end

-- Инициализация (вызывается из main.lua)
local function start()
  -- Загрузка баланса из файла или установка начального
  balance.init()
  -- Построение интерфейса
  buildMainMenu()
  buildBlackjackUI()
  buildRouletteUI()
  -- Главный цикл обработки событий
  while running do
    drawCurrentScreen()
    -- Ждем события: касание экрана или прерывание (Ctrl+C)&#8203;:contentReference[oaicite:22]{index=22}
    local eventId, address, x, y, button, player = event.pullMultiple("touch", "interrupted")
    if eventId == "touch" then
      -- В зависимости от активного экрана проверяем, по какому элементу кликнули
      if currentScreen == "main" then
        local clicked = mainMenuContainer:getChildAt(x, y)
        if clicked and clicked.onTouch then
          clicked.onTouch()
        end
      elseif currentScreen == "blackjack" then
        local clicked = blackjackContainer:getChildAt(x, y)
        if clicked and clicked.onTouch then
          clicked.onTouch()
          -- Если из игры нажали "Назад", вернемся в меню
          if currentScreen ~= "blackjack" then
            currentScreen = "main"
          end
        else
          -- Клик вне активных элементов игры - ничего не делаем
        end
      elseif currentScreen == "roulette" then
        local clicked = rouletteContainer:getChildAt(x, y)
        if clicked and clicked.onTouch then
          clicked.onTouch()
          if currentScreen ~= "roulette" then
            currentScreen = "main"
          end
        end
      end
    elseif eventId == "interrupted" then
      -- Прервано (Ctrl+C), выходим
      running = false
    end
  end
  -- Выйдя из цикла, сохраняем баланс и завершаем
  balance.save()
end

return {
  start = start
}
