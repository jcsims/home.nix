local log = hs.logger.new('jcsims', 'debug')

local config_path = os.getenv("HOME") .. "/.hammerspoon/"
local config_path_length = config_path:len()

function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        log.i("Got a change to file" .. file)
        if (file:sub(-4) == ".lua" and file:sub(config_path_length + 1, config_path_length + 2) ~= ".#") then
            log.i("Triggering reload due to change in" .. file)
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

local myWatcher = hs.pathwatcher.new(config_path, reloadConfig):start()

-- Launch a bookmarks browser powered by Emacs!
-- I'm doing this here instead of Alfred because it's dramatically faster!
hs.hotkey.bind({ "cmd", "alt" }, "P", function()
      hs.execute(os.getenv("HOME") .. "/bin/bookmarks")
end)

-- Start the screensaver, Hammerspoon edition
hs.hotkey.bind({ "cmd", "alt" }, "L", function()
      hs.caffeinate.startScreensaver()
end)

hs.alert.show("Config loaded")
