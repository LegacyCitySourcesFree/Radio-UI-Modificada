local uiOpen = false
local currentChannel = 0
local currentVolume = Config.DefaultVolume

local function hasPmaVoice()
  return GetResourceState('pma-voice') == 'started'
end

local function clamp(num, min, max)
  num = tonumber(num) or min
  if num < min then return min end
  if num > max then return max end
  return num
end

-- Checagem opcional do item (não é necessária se você abre só via uso do item,
-- mas ajuda a evitar abrir por evento indevido).
local function hasRadioItem()
  if not Config.RequireRadioItem then return true end

  if GetResourceState('ox_inventory') ~= 'started' then
    -- Não bloqueia se o inventário não estiver rodando (evita erro em bases diferentes)
    return true
  end

  local itemName = Config.RadioItemName or 'radio'
  local ok, count = pcall(function()
    return exports.ox_inventory:Search('count', itemName)
  end)

  if not ok then return true end
  return (count or 0) > 0
end

local function setRadio(channel)
  if not hasPmaVoice() then
    TriggerEvent('chat:addMessage', { args = { '^1[Rádio]^7 pma-voice não está iniciado.' } })
    return false
  end

  channel = tonumber(channel) or 0

  if channel <= 0 then
    exports['pma-voice']:setRadioChannel(0)
    currentChannel = 0
    return true
  end

  channel = clamp(channel, Config.MinChannel, Config.MaxChannel)
  exports['pma-voice']:setRadioChannel(channel)
  exports['pma-voice']:setRadioVolume(currentVolume)
  currentChannel = channel
  return true
end

local function setVolume(vol)
  vol = tonumber(vol) or Config.DefaultVolume
  if vol < 0.0 then vol = 0.0 end
  if vol > 1.0 then vol = 1.0 end
  currentVolume = vol

  if hasPmaVoice() then
    exports['pma-voice']:setRadioVolume(currentVolume)
  end
end

local function openUI()
  if uiOpen then return end
  uiOpen = true
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = 'open',
    presets = Config.PresetChannels,
    minChannel = Config.MinChannel,
    maxChannel = Config.MaxChannel,
    currentChannel = currentChannel,
    volume = currentVolume,
  })
end

local function closeUI()
  if not uiOpen then return end
  uiOpen = false
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })
end

-- Abre/fecha via item (ox_inventory -> client.event) OU via TriggerClientEvent do server
RegisterNetEvent('mm_radio:open', function()
  if not hasRadioItem() then
    TriggerEvent('chat:addMessage', { args = { '^1[Rádio]^7 Você não possui um rádio.' } })
    return
  end

  if uiOpen then closeUI() else openUI() end
end)

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
  closeUI()
  cb(true)
end)

RegisterNUICallback('connect', function(data, cb)
  local ch = data and data.channel
  if ch == nil then cb(false) return end

  local ok = setRadio(ch)
  SendNUIMessage({ action = 'state', currentChannel = currentChannel, volume = currentVolume })
  cb(ok)
end)

RegisterNUICallback('disconnect', function(_, cb)
  local ok = setRadio(0)
  SendNUIMessage({ action = 'state', currentChannel = currentChannel, volume = currentVolume })
  cb(ok)
end)

RegisterNUICallback('setVolume', function(data, cb)
  local vol = data and data.volume
  setVolume(vol)
  SendNUIMessage({ action = 'state', currentChannel = currentChannel, volume = currentVolume })
  cb(true)
end)

RegisterNUICallback('getState', function(_, cb)
  cb({ currentChannel = currentChannel, volume = currentVolume })
end)

-- Segurança: se o resource reiniciar e a UI ficar presa
AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  if uiOpen then
    SetNuiFocus(false, false)
  end
end)
