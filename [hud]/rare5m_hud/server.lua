ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('svrphealthui:save')
AddEventHandler('svrphealthui:save', function(data)
    MySQL.Async.execute('UPDATE hud SET data = @data', {
		['@data'] = json.encode(data)
	})
end)

ESX.RegisterServerCallback('svrphealthui:getOffsets', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM hud', {}, function(result)
        if result ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)