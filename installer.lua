---------------------------------------------------------------------------
-- installer.lua – мини‑казино: скачивает файлы из github.com/alexhrcn/home
---------------------------------------------------------------------------

local fs       = require("filesystem")
local internet = require("internet")

-- ⚠️ Файлы лежат в КОРНЕ репозитория
local BASE_URL = "https://raw.githubusercontent.com/alexhrcn/home/main/"

local FILES = {
  "main.lua",
  "core.lua",
  "config.lua",
  "balance.lua",
  "storage.lua",
  "utils.lua",
  "/gui/GUI.lua",
  "/gui/DoubleBuffering.lua",
  "/games/blackjack.lua",
  "/games/roulette.lua",
}

-- ────────── утилиты ──────────
local function ensureDir(path)
  if path ~= "" and not fs.isDirectory(path) then
    if fs.exists(path) then fs.remove(path) end
    fs.makeDirectory(path)
  end
end

local function download(url, target)
  local handle, reason = internet.request(url)
  if not handle then
    io.stderr:write("HTTP‑ошибка: " .. tostring(reason) .. "\n"); return false
  end
  local code = ({handle:response()})[1]
  if code ~= 200 then
    io.stderr:write("GitHub ответил "..code.." (нет файла?)\n"); return false
  end
  local file, err = io.open(target, "w")
  if not file then
    io.stderr:write("Не могу создать "..target..": "..tostring(err).."\n"); return false
  end
  for chunk in handle do file:write(chunk) end
  file:close()
  return true
end

-- ────────── установка ──────────
print("===> Установка / обновление mini‑casino")

ensureDir("gui")
ensureDir("games")

for _, p in ipairs(FILES) do
  local url  = BASE_URL .. p
  local dir  = fs.path(p) or ""
  ensureDir(dir)
  io.write("• "..p.." … ")
  if download(url, p) then
    print("OK")
  else
    print("FAIL");  return
  end
end

print("\n✅  Всё скачано.  Запуск:  lua main.lua")
