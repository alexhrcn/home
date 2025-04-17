-- gui/GUI.lua: Минималистичная GUI-библиотека.
-- Предоставляет функции для создания контейнеров, панелей, надписей и кнопок, а также объект Application (корневой контейнер).
-- Кроме того, реализует простую систему обработки кликов по объектам.

local doubleBuffering = require("gui.DoubleBuffering")
local GUI = {}

-- Базовый объект GUI
GUI.object = {}
GUI.object.__index = GUI.object

function GUI.object:new(x, y, width, height)
  local obj = {
    x = x or 1,
    y = y or 1,
    width = width or 1,
    height = height or 1,
    children = {},     -- список дочерних объектов (для контейнеров)
    draw = function(self) end  -- базовый объект сам по себе ничего не рисует
  }
  setmetatable(obj, GUI.object)
  return obj
end

-- Контейнер (может содержать другие объекты, и сам является объектом)
GUI.container = {}
setmetatable(GUI.container, {__index = GUI.object})  -- наследуем от GUI.object

function GUI.container:new(x, y, width, height)
  local container = GUI.object:new(x, y, width, height)
  setmetatable(container, {__index = GUI.container})
  -- Переопределяем метод draw для контейнера: рисует всех детей
  container.draw = function(self)
    -- контейнер сам по себе может иметь фон, но предположим, что фон уже отрисован панелью если нужно
    for _, child in ipairs(self.children) do
      child:draw()
    end
  end
  -- Метод добавления дочернего объекта
  container.addChild = function(self, child)
    table.insert(self.children, child)
    return child
  end
  -- Метод для поиска объекта, на который кликнули (по координатам внутри этого контейнера)
  container.getChildAt = function(self, x, y)
    for _, child in ipairs(self.children) do
      -- Вычисляем глобальные координаты объекта
      local objX = child.x
      local objY = child.y
      local objW = child.width
      local objH = child.height
      if x >= objX and x < objX + objW and y >= objY and y < objY + objH then
        return child
      end
    end
    return nil
  end
  return container
end

-- Application: корневой контейнер на весь экран
function GUI.application()
  local screenW, screenH = component.gpu.getResolution()
  return GUI.container:new(1, 1, screenW, screenH)
end

-- Панель (заливка цветом)
function GUI.panel(x, y, width, height, color)
  local panel = GUI.object:new(x, y, width, height)
  -- Переопределяем draw: рисуем прямоугольник заданным цветом
  panel.draw = function(self)
    doubleBuffering.fill(self.x, self.y, self.width, self.height, 0xFFFFFF, color or 0x0, " ")
  end
  return panel
end

-- Надпись (Label)
function GUI.label(x, y, width, height, textColor, text)
  local label = GUI.object:new(x, y, width, height)
  label.text = text or ""
  label.textColor = textColor or 0xFFFFFF
  label.draw = function(self)
    -- Выводим текст посимвольно в буфер
    local len = #self.text
    local displayText = self.text
    if len > self.width then
      displayText = string.sub(self.text, 1, self.width)  -- обрезаем, если не влезает
      len = self.width
    end
    for i = 1, len do
      local ch = displayText:sub(i, i)
      doubleBuffering.set(self.x + i - 1, self.y, self.textColor, nil, ch)
    end
  end
  return label
end

-- Кнопка (Button)
function GUI.button(x, y, width, height, bgColor, textColor, bgColorPressed, textColorPressed, text)
  local button = GUI.object:new(x, y, width, height)
  button.text = text or ""
  button.bgColor = bgColor or 0xFFFFFF
  button.textColor = textColor or 0x000000
  button.bgColorPressed = bgColorPressed or button.bgColor
  button.textColorPressed = textColorPressed or button.textColor
  button.onTouch = nil  -- обработчик будет назначен извне при создании
  -- Отрисовка кнопки:
  button.draw = function(self)
    -- Рисуем тело кнопки:
    doubleBuffering.fill(self.x, self.y, self.width, self.height, self.textColor, self.bgColor, " ")
    -- Рисуем текст кнопки по центру:
    local textLen = #self.text
    if textLen > 0 then
      local textX = self.x + math.floor((self.width - textLen) / 2)
      local textY = self.y + math.floor((self.height - 1) / 2)
      for i = 1, textLen do
        local ch = self.text:sub(i, i)
        if textX + i - 1 < self.x + self.width then
          doubleBuffering.set(textX + i - 1, textY, self.textColor, self.bgColor, ch)
        end
      end
    end
  end
  return button
end

return GUI
