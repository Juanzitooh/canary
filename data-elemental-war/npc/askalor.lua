local npcName = "Askalor"
local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = "Askalor, O Reitor da Academia dos Elementos."

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 3

npcConfig.outfit = {
	lookTypeEx = 2031,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 60000,
	chance = 50,
	{ text = "Venha, e aprenda sobre transformaçao elemental e as artes de combate!" },
	{ text = "Escolha seu caminho: Guerreiro, Arqueiro ou Mago!" },
	{ text = "O equilibrio dos elementos depende de sua escolha!" },
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

-- Lista de vocações disponíveis
local VOCACOES_APRENDIZ = {
	["guerreiro fogo"] = 9,
	["guerreiro agua"] = 10,
	["guerreiro terra"] = 11,
	["guerreiro ar"] = 12,
	["arqueiro fogo"] = 13,
	["arqueiro agua"] = 14,
	["arqueiro terra"] = 15,
	["arqueiro ar"] = 16,
	["mago fogo"] = 17,
	["mago agua"] = 18,
	["mago terra"] = 19,
	["mago ar"] = 20
}

-- Função para definir a vocação do jogador
local function giveVocation(player, vocationChoice)
	local vocationId = VOCACOES_APRENDIZ[vocationChoice:lower()]

	if not vocationId then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Essa vocação não existe!")
		return false
	end

	-- Verifica se o storage 2000000 já tem um valor (se o jogador já escolheu antes)
	local currentVocationStorage = player:getStorageValue(2000000)
	if currentVocationStorage > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce ja escolheu sua forma elemental antes e nao e possivel mudar por agora!")
		return false
	end

	-- Define a nova vocação
	player:setStorageValue(2000000, vocationId)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sua Transformação elemental é a de " .. vocationChoice .. "! para se transformar utilize alguma arvore magica dessas que tem eter saindo delas.")

	return true
end




-- Função que lida com as mensagens enviadas ao NPC (seguindo Oressa)
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Escolha da vocação principal
	if MsgContains(message, "guerreiro") and npcHandler:getTopic(playerId) == 0 then
		npcHandler:say({
			"O Guerreiro e um lutador feroz, especializado em combates corpo a corpo.",
			"Mas ha algo mais importante... Os elementos regem o mundo.",
			"Qual deles deseja dominar? {fogo}, {agua}, {terra} ou {ar}?"
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 2)

	elseif MsgContains(message, "arqueiro") and npcHandler:getTopic(playerId) == 0 then
		npcHandler:say({
			"O Arqueiro é um mestre da precisao, atacando a distancia com grande eficacia.",
			"Mas ha algo mais importante... Os elementos regem o mundo.",
			"Qual deles deseja dominar? {fogo}, {agua}, {terra} ou {ar}?"
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 3)

	elseif MsgContains(message, "mago") and npcHandler:getTopic(playerId) == 0 then
		npcHandler:say({
			"O Mago domina as artes arcanas, lançando feiticos poderosos sobre seus inimigos.",
			"Mas há algo mais importante... Os elementos regem o mundo.",
			"Qual deles deseja dominar? {fogo}, {agua}, {terra} ou {ar}?"
		}, npc, creature, 10)
		npcHandler:setTopic(playerId, 4)

	-- Escolha do elemento para Guerreiro
	elseif (MsgContains(message, "fogo") or MsgContains(message, "agua") or MsgContains(message, "terra") or MsgContains(message, "ar"))
	and npcHandler:getTopic(playerId) == 2 then

		local elementMap = {
			["fogo"] = "Aprendiz de Guerreiro do Fogo",
			["agua"] = "Aprendiz de Guerreiro da Água",
			["terra"] = "Aprendiz de Guerreiro da Terra",
			["ar"] = "Aprendiz de Guerreiro do Ar"
		}

		local vocationChoice = "guerreiro " .. message -- Exemplo: "guerreiro fogo"
		if giveVocation(player, vocationChoice) then
			npcHandler:say({
				"Agora você é um " .. elementMap[message] .. "!",
				"Treine bem sua arte e use os elementos com sabedoria.",
				"Não esqueça de passar na biblioteca, tem muito conhecimento perdido por lá!"
			}, npc, creature, 10)

		else
			npcHandler:say("Algo deu errado. Tem certeza de que é um Ser Humano?", npc, creature)
		end

	-- Escolha do elemento para Arqueiro
	elseif (MsgContains(message, "fogo") or MsgContains(message, "agua") or MsgContains(message, "terra") or MsgContains(message, "ar"))
	and npcHandler:getTopic(playerId) == 3 then

		local elementMap = {
			["fogo"] = "Aprendiz de Arqueiro do Fogo",
			["agua"] = "Aprendiz de Arqueiro da Água",
			["terra"] = "Aprendiz de Arqueiro da Terra",
			["ar"] = "Aprendiz de Arqueiro do Ar"
		}

		local vocationChoice = "arqueiro " .. message -- Exemplo: "arqueiro fogo"
		if giveVocation(player, vocationChoice) then
			npcHandler:say({
				"Agora você é um " .. elementMap[message] .. "!",
				"A precisão é sua maior arma. Treine bem!",
				"Não esqueça de aprimorar sua mira e estratégia para dominar os elementos."
			}, npc, creature, 10)

		else
			npcHandler:say("Algo deu errado. Tem certeza de que é um Ser Humano?", npc, creature)
		end

	-- Escolha do elemento para Mago
	elseif (MsgContains(message, "fogo") or MsgContains(message, "agua") or MsgContains(message, "terra") or MsgContains(message, "ar"))
	and npcHandler:getTopic(playerId) == 4 then

		local elementMap = {
			["fogo"] = "Aprendiz de Mago do Fogo",
			["agua"] = "Aprendiz de Mago da Água",
			["terra"] = "Aprendiz de Mago da Terra",
			["ar"] = "Aprendiz de Mago do Ar"
		}

		local vocationChoice = "mago " .. message -- Exemplo: "mago fogo"
		if giveVocation(player, vocationChoice) then
			npcHandler:say({
				"Agora você é um " .. elementMap[message] .. "!",
				"A magia é uma força poderosa, use-a com sabedoria.",
				"Não esqueça de estudar na biblioteca para ampliar seu conhecimento arcano!"
			}, npc, creature, 10)

		else
			npcHandler:say("Algo deu errado. Tem certeza de que voce ja não tem uma forma elemental?", npc, creature)
		end

	else
		npcHandler:say("Não entendi o que você quer dizer. Escolha entre guerreiro, arqueiro ou mago.", npc, creature)
	end

	return true
end


-- Callback para cumprimentos do NPC
local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()
	local currentVocationStorage = player:getStorageValue(2000000)

	-- Se o jogador já tem uma vocação armazenada no storage, impede a escolha
	if currentVocationStorage > 0 then
		npcHandler:setMessage(
			MESSAGE_GREET,
			"Voce ja escolheu sua forma elemental antes e nao e possivel mudar por agora!"
		)
		return true
	end

	-- Se o storage estiver vazio (-1), permite escolher uma vocação
	npcHandler:setMessage(
		MESSAGE_GREET,
		"Saudacoes, jovem! Voce deseja aprender a ter uma forma elemental de um dos 4 elementos? \z
		Primeiro precisa escolher uma arte de batalha, qual escolhe entre {guerreiro}, {arqueiro} ou {mago}?"
	)

	return true
end



npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "thau, meu bom.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
