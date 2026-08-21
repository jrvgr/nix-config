-- Menu bar front-end for the Karabiner-driven fn-key switching.
--
-- Karabiner-Elements (see ../karabiner.nix) owns the actual keyboard
-- interception: it has an "Default profile" (automatic, per-app, driven by
-- fn-key-apps.json) and a "Force Function Keys" profile (manual global
-- override). This script never touches the keyboard itself -- it just
-- displays state and drives Karabiner via its CLI, so there is only ever one
-- thing intercepting keystrokes.
--
-- Rule storage: fn-key-apps.json lives in the nix repo itself (not deployed
-- via home-manager), so both nix (at build time) and this script (at
-- runtime) read/write the exact same file, and `git status` in the repo
-- shows changes made from the menu.

local rulesPath = os.getenv("HOME") .. "/.config/nix/home/shared/fn-key-apps.json"
local karabinerCli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
local automaticProfile = "Default profile"
local forcedProfile = "Force Function Keys"

-- The PNG is a 36px bitmap (2x) for an 18pt icon; without an explicit size
-- NSImage treats it as 36x36 points, which shows up oversized and blurry
-- when the menu bar scales it back down.
local brightnessIcon = hs.image.imageFromPath(os.getenv("HOME") .. "/.hammerspoon/icons/brightness.png")
  :setSize({w = 18, h = 18})

local fnMenu = hs.menubar.new()

local function loadRules()
  local f = io.open(rulesPath, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  local ok, decoded = pcall(hs.json.decode, content)
  if ok and decoded then
    return decoded
  end
  return {}
end

local function saveRules(rules)
  local f = io.open(rulesPath, "w")
  if not f then
    hs.notify.new({title = "Fn Keys", informativeText = "Could not write " .. rulesPath}):send()
    return
  end
  f:write(hs.json.encode(rules, true))
  f:close()
end

local function bundleIdIndex(rules)
  local index = {}
  for i, r in ipairs(rules) do
    index[r.bundleId] = i
  end
  return index
end

local function currentProfile()
  local out = hs.execute('"' .. karabinerCli .. '" --show-current-profile-name')
  return (out or ""):gsub("%s+$", "")
end

local function selectProfile(name)
  hs.execute('"' .. karabinerCli .. '" --select-profile "' .. name .. '"')
  updateMenu()
end

function updateMenu()
  local rules = loadRules()
  local index = bundleIdIndex(rules)
  local front = hs.application.frontmostApplication()
  local bundleId = front and front:bundleID() or nil
  local profile = currentProfile()

  local forced = profile == forcedProfile
  local listed = bundleId and index[bundleId] ~= nil

  -- Real function keys active (forced, or this app is on the list): show "fn",
  -- like the physical fn key you'd otherwise have to hold. Otherwise the F-row
  -- is doing its default media/brightness thing, so show a brightness glyph.
  if forced or listed then
    fnMenu:setIcon(nil)
    fnMenu:setTitle("fn")
  else
    fnMenu:setTitle(nil)
    fnMenu:setIcon(brightnessIcon, true)
  end

  local menuItems = {
    {title = "Automatic", checked = not forced, fn = function() selectProfile(automaticProfile) end},
    {title = "Force Function Keys", checked = forced, fn = function() selectProfile(forcedProfile) end},
    {title = "-"},
  }

  if bundleId then
    local appName = front:name() or bundleId
    if listed then
      table.insert(menuItems, {
        title = "Remove " .. appName .. " from list",
        fn = function()
          local newRules = {}
          for _, r in ipairs(rules) do
            if r.bundleId ~= bundleId then
              table.insert(newRules, r)
            end
          end
          saveRules(newRules)
          hs.notify.new({title = "Fn Keys", informativeText = "Removed " .. appName .. " -- run `rebuild` to apply"}):send()
          updateMenu()
        end,
      })
    else
      table.insert(menuItems, {
        title = "Add " .. appName .. " to list",
        fn = function()
          table.insert(rules, {name = appName, bundleId = bundleId})
          saveRules(rules)
          hs.notify.new({title = "Fn Keys", informativeText = "Added " .. appName .. " -- run `rebuild` to apply"}):send()
          updateMenu()
        end,
      })
    end
  end

  table.insert(menuItems, {title = "-"})
  table.insert(menuItems, {
    title = "Edit rules file...",
    fn = function() hs.execute('open -R "' .. rulesPath .. '"') end,
  })
  table.insert(menuItems, {title = "-"})
  table.insert(menuItems, {
    title = "Quit Hammerspoon",
    fn = function() hs.application.get("Hammerspoon"):kill() end,
  })

  fnMenu:setMenu(menuItems)
end

appWatcher = hs.application.watcher.new(function(_, eventType, _)
  if eventType == hs.application.watcher.activated then
    updateMenu()
  end
end)
appWatcher:start()

updateMenu()
