-- installer.lua: Скрипт установки мини-казино на компьютер OpenComputers.
-- Он загружает все необходимые файлы из репозитория пользователя и сохраняет их на диск.
-- Требуется Интернет-карта в компьютере для загрузки с GitHub.

local component = require("component")
local fs = require("filesystem")
local internet = require("internet")

-- URL-адрес сырого содержимого репозитория (ветка main). 
-- Здесь хранятся файлы нашего проекта.
local GITHUB_REPO = "https://raw.githubusercontent.com/alexhrcn/home/main/"

-- Список файлов для загрузки с указанием путей в локальной файловой системе.
local filesToDownload = {
  "main.lua",
  "core.lua",
  "balance.lua",
  "config.lua",
  "storage.lua",
  "utils.lua",
  "gui/GUI.lua",
  "gui/DoubleBuffering.lua",
  "games/blackjack.lua",
  "games/roulette.lua"
}

-- Функция для скачивания файла по URL и сохранения его по заданному локальному пути.
local function downloadFile(url, path)
  local result, response = pcall(internet.request, url)
  if not result or not response then
    io.stderr:write("Ошибка запроса: " .. url .. "\n")
    return false
  end

  -- Создаем необходимую директорию, если файла вложен в папку
  local directory = fs.path(path)
  if directory and directory ~= "" and not fs.isDirectory(directory) then
    fs.makeDirectory(directory)
  end

  -- Открываем файл для записи
  local file, reason = io.open(path, "w")
  if not file then
    io.stderr:write("Не удалось открыть файл для записи: " .. path .. " : " .. tostring(reason) .. "\n")
    return false
  end

  -- Считываем данные по частям и записываем в файл
  for chunk in response do
    file:write(chunk)
  end

  file:close()
  return true
end

-- Основная установка: цикл по списку файлов, загрузка каждого.
print("Начало установки mini-casino...")
for _, file in ipairs(filesToDownload) do
  local url = GITHUB_REPO .. file
  local ok = downloadFile(url, file)
  if ok then
    print("Загружен файл: " .. file)
  else
    io.stderr:write("Не удалось загрузить файл: " .. file .. "\n")
    print("Установка прервана. Проверьте подключение к Интернету и повторите попытку.")
    return
  end
end

print("Установка завершена. Все файлы загружены.")
print("Для запуска введите команду: main.lua")
print("или просто 'main' (без кавычек) в консоли OpenOS.")
