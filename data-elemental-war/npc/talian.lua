local npcName = "Talian"
local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = "Talian, O Guardiao da fenda entre os mundos."

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

npcConfig.voices = {
	interval = 60000,
	chance = 50,
	{ text = "Eu sou Talian, o guarda desta fenda, fale comigo dizendo 'oi' e irei te explicar como seguir em frente." },
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


-- Função creatureSayCallback refatorada apenas para a história
local function creatureSayCallback(npc, creature, type, message)
    local player = Player(creature)
    
    -- Verifica se a interação é válida
    if not npcHandler:checkInteraction(npc, creature) then
        return false
    end

    -- Se o jogador mencionar "historia", inicia a leitura do pergaminho
    if MsgContains(message, "historia") then
        local storyParagraphs = {
            "Pergaminho Antigo",
            "Aquele que se aventurar por estas terras, estas palavras sao para voce. O que esta escrito aqui e um relato de um tempo distante, onde o Reino Elemental foi tomado pela escuridao e a guerra parecia nao ter fim. Ha muito tempo, forcas poderosas, conhecidas como os Guardioes, travaram batalhas epicas para restaurar a paz e o equilibrio. Com habilidades alem da compreensao, eles eram a ultima linha de defesa contra as forcas da corrupcao que consumiam o mundo.",
            "Essa guerra, no entanto, nao foi uma simples disputa. A cobica pelo Eter, a essencia que molda toda a existencia, corrompia ate mesmo os coracoes mais puros. Aqueles que buscavam controlar esse poder se viam consumidos por ele, perdendo a humanidade e tornando-se sombras do que eram antes. Um a um, os Guardioes cairam, suas forcas diminuidas, ate restarem apenas alguns poucos. E as trevas, impiedosas, se espalhavam.",
            "Em uma ultima tentativa de salvar seu mundo, os Guardioes realizaram um rito supremo, um ritual proibido que rasgou o veu entre os reinos. Pela primeira vez na historia, um portal foi aberto, permitindo que povos de outros mundos — Humanos, Anoes, Elfos, Sharai e Animus — cruzassem a fronteira e entrassem no Reino Elemental.",
            "Agora, o que restou do Reino esta a beira do colapso. O Eter ainda pulsa por aqui, mas seu poder e imprevisivel e perigoso. A corrupcao que uma vez devastou o reino ainda espreita nas sombras, e o equilibrio entre os mundos permanece fragil. Seu papel, viajante, sera descobrir o que restou do legado dos Guardioes, desvendar os segredos do Eter e decidir se voce ajudara a restaurar o que foi perdido ou se sucumbira a mesma tentacao que consumiu tantos antes de voce."
        }
        
        -- Exibir a historia paragrafo por paragrafo
        for _, paragraph in ipairs(storyParagraphs) do
            npcHandler:say(paragraph, npc, creature, 10)
        end
        return true
    end
    
    return true
end

-- Funcao greetCallback refatorada
local function greetCallback(npc, creature)
    local player = Player(creature)
    local playerId = player:getId()
    
    -- Verifica se o jogador ja iniciou a quest introdutoria
    local questStartStorage = player:getStorageValue(Storage.Quest.Chamado.Start)
    if questStartStorage == -1 then
        player:setStorageValue(Storage.Quest.Chamado.Start, 1)
        npcHandler:setMessage(MESSAGE_GREET, "Seja bem vindo ao Reino Elemental, antes de permitir sua viagem e negociacao com todos os habitantes preciso te ensinar como se conectar com o eter, clicando em Menu lá na parte superior da tela, tem um botão com nome missoes, clique nele e verá o que deve fazer. Ps: Se quiser também posso te contar um pouco sobre a {historia} desse lugar.")
        return true
    end
    
    -- Se a quest ja foi iniciada, verifica se o jogador quer ajuda ou informacoes
    npcHandler:setMessage(MESSAGE_GREET, "Opa como e bom te ver novamente, esta com dificuldade de passar o portal ou deseja saber mais sobre a {historia}?")
    return true
end



npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "thau, meu bom.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)