-- config.lua: Конфигурационный файл проекта mini-casino.
-- Здесь определены настраиваемые параметры: начальный баланс игрока, цвета интерфейса, пути файлов и др.

local config = {}

-- Начальный баланс игрока (количество "монет" в казино) при первом запуске
config.initialBalance = 1000

-- Путь к файлу для хранения данных (баланса и др.)
config.dataFile = "casino_data.txt"

-- Цветовая схема интерфейса (в формате 0xRRGGBB):
config.backgroundColor = 0x2D2D2D    -- фоновый цвет основного окна (темно-серый)&#8203;:contentReference[oaicite:15]{index=15}
config.textColor = 0xFFFFFF         -- основной цвет текста (белый)
config.buttonBgColor = 0xFFFFFF     -- цвет фона кнопки в обычном состоянии (белый)
config.buttonTextColor = 0x555555   -- цвет текста кнопки в обычном состоянии (темно-серый)
config.buttonBgColorPressed = 0x880000   -- цвет фона кнопки при нажатии (темно-красный)
config.buttonTextColorPressed = 0xFFFFFF -- цвет текста кнопки при нажатии (белый)
config.panelColor = 0x336633        -- пример цвета для панелей/рамок (зеленоватый оттенок, можно не использовать)

return config
