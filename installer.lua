---------------------------------------------------------------------------
--  installer.lua – загрузчик/обновитель mini‑casino                     --
--  ▸ качает файлы из GitHub‑репозитория alexhrcn/home (ветка main)      --
--  ▸ гарантирует, что каталоги gui/ и games/ существуют как директории --
--  ▸ перезаписывает уже существующие файлы, не трогая чужие каталоги    --
---------------------------------------------------------------------------

local fs        = require("filesystem")
local internet  = require("internet")

-- Измените BASE_URL, если репозиторий или ветка будут другими
local BASE_URL  = "https://raw.githubusercontent.com/alexhrcn/home/main/mineos_casino/"

-- Файлы, которые нужно скачать (относительно BASE_URL и текущего каталога ОС)
local FILES = {
  "main.lua",
  "core.lua",
  "config.lua",
  "balance.lua",
  "storage.lua",
  "utils.lua",

  -- GUI‑библиотека
  "gui/GUI.lua",
  "gui/DoubleBuffering.lua",

  -- Заглушки игр
  "games/blackjack.lua",
  "games/roulette.lua",
}

-- ─────────────────────────────────────────────────────────────────────────
--  Вспомогательные функции
-- ─────────────────────────────────────────────────────────────────────────

-- Создаёт каталог dir. Если с таким именем уже есть файл – удаляет его.
local function ensureDirectory(dir)
  if fs.exists(dir) then
    if not fs.isDirectory(dir) then
      fs.remove(dir)               -- был файл – удаляем
    else
      return                       -- уже корректная папка
    end
  end
  fs.makeDirectory(dir)
end

-- Скачивает один файл по HTTP‑URL и сохраняет на диск
local function download(url, path)
  local handle, reason = internet.request(url)
  if not handle then
    io.stderr:write("Не удалось открыть URL: " .. url .. " (" .. tostring(reason) .. ")\n")
    return false
  end

  local file, err = io.open(path, "w")
  if not file then
    io.stderr:write("Не удалось открыть файл для записи: " .. path .. " : " .. tostring(err) .. "\n")
    return false
  end

  for chunk in handle do
    file:write(chunk)
  end
  file:close()
  return true
end

-- ─────────────────────────────────────────────────────────────────────────
--  Основной процесс установки
-- ─────────────────────────────────────────────────────────────────────────

print("===> Установка / обновление mini‑casino")

-- Гарантируем корректные каталоги
ensureDirectory("gui")
ensureDirectory("games")

-- Проходим по списку файлов
for _, relativePath in ipairs(FILES) do
  local url  = BASE_URL .. relativePath
  local path = relativePath           -- сохраняем в ту же структуру

  -- если файл вложен в подпапки глубже, создаём каталог
  local dir = fs.path(path)
  if dir and dir ~= "" then
    ensureDirectory(dir)
  end

  io.write("• " .. relativePath .. " … ")
  if download(url, path) then
    print("OK")
  else
    print("FAIL")
    io.stderr:write("Установка прервана. Проверьте подключение к Интернету и повторите попытку.\n")
    return
  end
end

print("\n✅  Все файлы загружены/обновлены.")
print("Запустите программу командой:  main.lua")
