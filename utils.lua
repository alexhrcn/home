-- utils.lua: Вспомогательные функции для mini-casino (утилиты).

local utils = {}

-- Функция центрирования текста по горизонтали внутри заданной ширины.
-- width: общая ширина поля (например, окна или контейнера)
-- text: сама строка текста
-- Возвращает смещение X, с которого надо выводить текст, чтобы он был по центру.
function utils.centerTextX(width, text)
  local textLen = #text
  if textLen >= width then
    return 1  -- если текст длиннее или равен ширине, начинаем с самого начала
  end
  local padding = math.floor((width - textLen) / 2)
  return padding + 1
end

-- Функция форматирования числа монет в строку баланса.
-- amount: число (баланс игрока)
-- Возвращает строку вида "Баланс: X монет"
function utils.formatBalance(amount)
  return "Баланс: " .. tostring(amount) .. " монет"
end

return utils
