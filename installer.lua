---------------------------------------------------------------------------
-- installer.lua · mini‑casino for OpenComputers · alexhrcn/home repo    --
---------------------------------------------------------------------------

local fs       = require("filesystem")
local internet = require("internet")

-- Файлы лежат прямо в корне репозитория (папки gui/, games/ — там же)
local BASE = "https://raw.githubusercontent.com/alexhrcn/home/main/"

local FILES = {
  -- корень
  { "main.lua"        },
  { "core.lua"        },
  { "config.lua"      },
  { "balance.lua"     },
  { "storage.lua"     },
  { "utils.lua"       },

  -- GUI
  { "gui/GUI.lua"            },
  { "gui/DoubleBuffering.lua"},

  -- игры‑заглушки
  { "games/blackjack.lua" },
  { "games/roulette.lua"  },
}

---------------------------------------------------------------------------
--  helpers
---------------------------------------------------------------------------

local function ensureDir(dir)
  if dir == "" then return end
  if fs.exists(dir) and not fs.isDirectory(dir) then
    fs.remove(dir)                       -- файл → убираем
  end
  if not fs.exists(dir) then
    fs.makeDirectory(dir)
  end
end

local function grab(url)
  local ok, handle = pcall(internet.request, url)
  if not ok or not handle then return nil, "connect‑error" end
  local data = ""
  repeat
    local chunk = handle:read(math.huge)
    if chunk then data = data .. chunk end
  until not chunk
  return (#data > 0) and data or nil, "empty"
end

---------------------------------------------------------------------------
--  install
---------------------------------------------------------------------------

print("===> mini‑casino installer")

-- базовые каталоги
ensureDir("gui")
ensureDir("games")

for _, f in ipairs(FILES) do
  local path = f[1]
  local url  = BASE .. path

  ensureDir(fs.path(path) or "")

  -- если по пути уже каталог — удаляем рекурсивно
  if fs.exists(path) and fs.isDirectory(path) then
    fs.remove(path, true)
  end

  io.write("• " .. path .. " … ")

  local data, err = grab(url)
  if not data then
    print("FAIL (" .. err .. ")");  return
  end

  local file, reason = io.open(path, "w")
  if not file then
    print("FAIL (fs‑error)");  io.stderr:write(tostring(reason).."\n");  return
  end
  file:write(data); file:close()
  print("OK")
end

print("\n✅  Установка завершена.  Запуск:  lua main.lua")
