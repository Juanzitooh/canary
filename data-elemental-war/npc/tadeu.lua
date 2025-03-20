local internalNpcName = "Tadeu"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 58,
	lookBody = 68,
	lookLegs = 38,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Quest

-- Tabela com os itens iniciais a serem dados quando o jogador interagir com o NPC
local questItems = { -- Tadeu entrega a ferramenta e explica como extrair recursos e que após a primeira extração bem sucedida pode levar alguns recursos ao gerfan.
    -- Coletor (Vocation ID: 22)
    [22] = {
        { itemName = "machete", clientId = 3308, count = 1 },  -- Machete para o Coletor
        { itemName = "worm", clientId = 3492, count = 50 }    -- 50 Worms para o Coletor
    },

    -- Pescador (Vocation ID: 24)
    [24] = {
        { itemName = "fishing rod", clientId = 3483, count = 1 },  -- Vara de Pesca para o Pescador
        { itemName = "worm", clientId = 3492, count = 50 }         -- 50 Worms para o Pescador
    },

    -- Minerador (Vocation ID: 23)
    [23] = {
        { itemName = "pick", clientId = 3456, count = 1 }  -- Pick para o Minerador
    },
}

-- Função para dar os itens de acordo com a vocação
function giveQuestItemsToPlayerByVocation(player)
    -- Obtém a vocação do jogador
    local vocationId = player:getVocation():getId()

    -- Verifica se a vocação existe na tabela de itens
    local targetVocation = questItems[vocationId]
    if not targetVocation then
        return false  -- Se não existir vocação, retorna false
    end

    -- Adiciona a mochila (ID 2854)
    local backpack = player:addItem(2854)
    if not backpack then
        return false  -- Se não conseguir adicionar a mochila, retorna false
    end

    -- Adiciona os itens principais na mochila
    for i = 1, #targetVocation.items do
        backpack:addItem(targetVocation.items[i][1], targetVocation.items[i][2])
    end

    -- Adiciona itens dentro da mochila (container)
    if targetVocation.container then
        for i = 1, #targetVocation.container do
            backpack:addItem(targetVocation.container[i][1], targetVocation.container[i][2])
        end
    end

    return true  -- Sucesso
end


-- negociar


npcConfig.shop = {
	{ itemName = "camouflage backpack", clientId = 2872, buy = 30 },
	{ itemName = "camouflage bag", clientId = 2864, buy = 10 },
	{ itemName = "fishing rod", clientId = 3483, buy = 300 },
	{ itemName = "pick", clientId = 3456, buy = 100 },
	{ itemName = "machete", clientId = 3308, buy = 100 },
	{ itemName = "rope", clientId = 3003, buy = 100 },
	{ itemName = "shovel", clientId = 3457, buy = 100 },
	{ itemName = "torch", clientId = 2920, buy = 5 },
	{ itemName = "treasure map", clientId = 5090, buy = 1000 },
	{ itemName = "very noble-looking watch", clientId = 6092, buy = 500 },
	{ itemName = "worm", clientId = 3492, buy = 2 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
