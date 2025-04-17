-- storage.lua: Модуль для сохранения и загрузки данных (например, баланса игрока) на диск.

local fs = require("filesystem")
local storage = {}

-- Сохранение баланса (или иных данных) в файл.
-- path: путь к файлу
-- data: число или строка для сохранения (в нашем случае баланс - число)
function storage.save(path, data)
  local file, err = io.open(path, "w")
  if not file then
    io.stderr:write("Ошибка сохранения в файл " .. path .. ": " .. tostring(err) .. "\n")
    return false
  end
  file:write(tostring(data))
  file:close()
  return true
end

-- Загрузка баланса (или иных данных) из файла.
-- path: путь к файлу
-- Возвращает считанное значение (число). Если файл не найден или пустой, возвращает nil.
function storage.load(path)
  if not fs.exists(path) then
    return nil
  end
  local file, err = io.open(path, "r")
  if not file then
    io.stderr:write("Ошибка открытия файла " .. path .. ": " .. tostring(err) .. "\n")
    return nil
  end
  local content = file:read("*a")
  file:close()
  if content then
    content = content:gsub("%s+", "")  -- убираем пробелы/переносы на всякий случай
  end
  if content == nil or content == "" then
    return nil
  end
  local number = tonumber(content)
  return number
end

return storage
