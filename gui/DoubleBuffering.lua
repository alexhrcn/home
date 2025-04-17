-- gui/DoubleBuffering.lua: Модуль двойной буферизации экрана.
-- Позволяет рисовать в скрытом буфере и потом одним вызовом выводить все изменения на экран, снижая мерцание.

local component = require("component")
local gpu = component.gpu  -- используем основной GPU компонент

-- Получаем текущую размерность экрана
local screenWidth, screenHeight = gpu.getResolution()

-- Буфер будет представлять собой таблицу, двумерный массив пикселей.
-- Каждый пиксель хранит: символ, цвет текста (foreground), цвет фона (background).
local buffer = {}
for y = 1, screenHeight do
  buffer[y] = {}
  for x = 1, screenWidth do
    -- Инициализируем буфер пробелами на фоне черного цвета (можно и на фоне config.backgroundColor)
    buffer[y][x] = {char = " ", fg = 0xFFFFFF, bg = 0x000000}
  end
end

local doubleBuffering = {}

-- Установка символа и цветов в буфере (но не на экране).
function doubleBuffering.set(x, y, fg, bg, char)
  if x >= 1 and x <= screenWidth and y >= 1 and y <= screenHeight then
    buffer[y][x].char = char or " "
    buffer[y][x].fg = fg or 0xFFFFFF
    buffer[y][x].bg = bg or 0x000000
  end
end

-- Заполнение прямоугольной области буфера заданным символом и цветами.
function doubleBuffering.fill(x, y, w, h, fg, bg, char)
  if not char or char == "" then char = " " end
  for j = y, y + h - 1 do
    if j < 1 or j > screenHeight then break end
    for i = x, x + w - 1 do
      if i < 1 or i > screenWidth then break end
      buffer[j][i].char = char
      buffer[j][i].fg = fg or 0xFFFFFF
      buffer[j][i].bg = bg or 0x000000
    end
  end
end

-- Вывод всего буфера на экран.
function doubleBuffering.draw()
  -- Пройдемся по всем ячейкам и выведем символы с нужными цветами.
  for y = 1, screenHeight do
    for x = 1, screenWidth do
      local cell = buffer[y][x]
      gpu.setForeground(cell.fg)
      gpu.setBackground(cell.bg)
      gpu.set(x, y, cell.char)
    end
  end
end

-- Очистка всего буфера определенным цветом (и опционально символом)
function doubleBuffering.clear(bg)
  local bgColor = bg or 0x000000
  for y = 1, screenHeight do
    for x = 1, screenWidth do
      buffer[y][x].char = " "
      buffer[y][x].fg = 0xFFFFFF
      buffer[y][x].bg = bgColor
    end
  end
end

return doubleBuffering
