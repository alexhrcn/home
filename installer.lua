--------------------------------------------------------------
-- installer.lua  •  ultra‑simple playlist downloader       --
--------------------------------------------------------------

local fs       = require("filesystem")
local internet = require("internet")

local FILES = {
  -- корень
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/main.lua",            path = "main.lua"         },
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/core.lua",            path = "core.lua"         },
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/config.lua",          path = "config.lua"       },
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/balance.lua",         path = "balance.lua"      },
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/storage.lua",         path = "storage.lua"      },
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/utils.lua",           path = "utils.lua"        },

  -- GUI
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/gui/GUI.lua",          path = "gui/GUI.lua"     },
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/gui/DoubleBuffering.lua", path = "gui/DoubleBuffering.lua" },

  -- игры (заглушки)
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/games/blackjack.lua",  path = "games/blackjack.lua"},
  { url = "https://raw.githubusercontent.com/alexhrcn/home/main/games/roulette.lua",   path = "games/roulette.lua"},
}

----------------------------------------------------------------
local function ensureDir(dir)
  if dir ~= "" and not fs.isDirectory(dir) then
    if fs.exists(dir) then fs.remove(dir) end
    fs.makeDirectory(dir)
  end
end

local function download(url)
  local handle = internet.request(url)
  local data = ""
  for chunk in handle do data = data .. chunk end
  return data
end

print("===> mini‑casino installer")

for _, f in ipairs(FILES) do
  local dir = fs.path(f.path) or ""
  ensureDir(dir)

  io.write("• "..f.path.." … ")
  local ok, content = pcall(download, f.url)
  if not ok or not content or content == "" then
    print("FAIL");  print("  URL: "..f.url)
    return
  end

  local file = io.open(f.path, "w")
  file:write(content)
  file:close()
  print("OK")
end

print("\n✅  Готово!  Запусти:  lua main.lua")
