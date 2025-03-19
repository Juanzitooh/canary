local scriptConfig = {
	itemId = 19236,
	registerPositions = {
		{ x = 3079, y = 3098, z = 7, message = "Quadro de Taxas do Mercado do Assentamento de Ararua." }
	}
}

local worldBoard = Action()

function worldBoard.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Se o item usado não for o correto, retorna falso
	if item:getId() ~= scriptConfig.itemId then
		return false
	end

	-- Identifica a posição específica e exibe a mensagem correspondente
	for _, positionData in ipairs(scriptConfig.registerPositions) do
		if fromPosition.x == positionData.x and fromPosition.y == positionData.y and fromPosition.z == positionData.z then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, positionData.message)
			return true
		end
	end

	return false
end

-- Define múltiplas posições e registra os itens no mapa
for _, position in ipairs(scriptConfig.registerPositions) do
	worldBoard:position(position, scriptConfig.itemId)
end

worldBoard:register()
