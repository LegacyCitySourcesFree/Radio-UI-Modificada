-- mm_radio - integração com ox_inventory (sem RegisterUsableItem)

local function hasExport(res, exportName)
  return GetResourceState(res) == 'started' and exports[res] and exports[res][exportName] ~= nil
end

CreateThread(function()
  if GetResourceState('ox_inventory') ~= 'started' then
    print('[mm_radio] ox_inventory nao iniciado. Iniciando sem integrar o item automaticamente.')
    print('[mm_radio] Dica: no ox_inventory/data/items.lua, no item radio, adicione:')
    print("[mm_radio] client = { event = 'mm_radio:open' }")
    return
  end

  -- Algumas versões do ox_inventory NÃO possuem RegisterUsableItem.
  -- A forma mais compatível é usar registerHook('useItem').
  if hasExport('ox_inventory', 'registerHook') then
    exports.ox_inventory:registerHook('useItem', function(payload)
      -- payload.source: player source
      -- payload.item.name: nome do item
      local item = payload and payload.item
      if not item or item.name ~= (Config and Config.RadioItemName or 'radio') then
        return
      end

      TriggerClientEvent('mm_radio:open', payload.source)

      -- Retorne false para cancelar qualquer efeito padrão do item (se houver)
      return false
    end, {
      itemFilter = { [(Config and Config.RadioItemName or 'radio')] = true }
    })

    print('[mm_radio] Hook useItem registrado (ox_inventory). Item: ' .. (Config and Config.RadioItemName or 'radio'))
    return
  end

  print('[mm_radio] Seu ox_inventory nao tem export registerHook.')
  print('[mm_radio] Use este método (recomendado): no ox_inventory/data/items.lua, no item radio, adicione:')
  print("[mm_radio] client = { event = 'mm_radio:open' }")
end)
