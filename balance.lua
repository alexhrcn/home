-- balance.lua: Управление балансом игрока (чтение, изменение, проверка, сохранение).

local storage = require("storage")
local config = require("config")

local balance = {}
local currentBalance = 0  -- текущее значение баланса в памяти

-- Инициализация баланса при запуске программы.
-- Пытается загрузить из файла; если не удалось, берет начальный баланс из config.
function balance.init()
  local loaded = storage.load(config.dataFile)
  if loaded then
    currentBalance = loaded
  else
    currentBalance = config.initialBalance or 0
  end
end

-- Получить текущий баланс
function balance.get()
  return currentBalance
end

-- Установить новое значение баланса
function balance.set(amount)
  currentBalance = amount
end

-- Изменить баланс на указанную величину (amount может быть положительным или отрицательным)
function balance.change(amount)
  currentBalance = currentBalance + amount
  if currentBalance < 0 then
    currentBalance = 0  -- не допускаем отрицательного баланса
  end
end

-- Сохранить текущий баланс в файл
function balance.save()
  storage.save(config.dataFile, currentBalance)
end

return balance
