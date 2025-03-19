local callback = EventCallback("PlayerOnLookInTradeBaseEvent")

function callback.playerOnLookInTrade(player, partner, item, distance)
	player:sendTextMessage(MESSAGE_LOOK, "Olhando " .. item:getDescription(distance))
end

callback:register()
