local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STONES)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Condição de resistência e aumento de shielding
local defenseCondition = Condition(CONDITION_ATTRIBUTES)
defenseCondition:setParameter(CONDITION_PARAM_SUBID, 14)
defenseCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
defenseCondition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
defenseCondition:setParameter(CONDITION_PARAM_SKILL_SHIELD, 15) -- Aumento de 15% em Shielding
defenseCondition:setParameter(CONDITION_PARAM_DAMAGEMITIGATION, 5) -- Redução de 5% no dano físico recebido

-- Função para remover debuffs periodicamente (exceto paralisia)
local function removeDebuffs(target)
    if target and target:isPlayer() then
        target:removeCondition(CONDITION_POISON)
        target:removeCondition(CONDITION_BLEEDING)
        target:removeCondition(CONDITION_CURSED)
        target:removeCondition(CONDITION_FIRE)
        target:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end
end

local baseMana = 140 -- Custo base de mana

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	local position = creature:getPosition()
	local party = creature:getParty()

	if not party then
		creature:sendCancelMessage("Você precisa estar em uma party para usar essa magia.")
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local membersList = party:getMembers()
	membersList[#membersList + 1] = party:getLeader()
	if not membersList or type(membersList) ~= "table" or #membersList <= 1 then
		creature:sendCancelMessage("Nenhum membro da party está próximo.")
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local affectedList = {}
	for _, targetPlayer in ipairs(membersList) do
		if targetPlayer:getPosition():getDistance(position) <= 36 then
			affectedList[#affectedList + 1] = targetPlayer
		end
	end

	if #affectedList <= 1 then
		creature:sendCancelMessage("Nenhum membro da party está próximo.")
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local mana = math.ceil((0.9 ^ (#affectedList - 1) * baseMana) * #affectedList)
	if creature:getMana() < mana then
		creature:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if not combat:execute(creature, var) then
		creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	creature:addMana(-(mana - baseMana), false)
	creature:addManaSpent((mana - baseMana))

	-- Aplica as condições de defesa e resistência a todos os membros da party
	for _, targetPlayer in ipairs(affectedList) do
		targetPlayer:addCondition(defenseCondition)

		-- Agendando a remoção de debuffs a cada 2 segundos por 10 segundos
		for i = 0, 10 * 1000, 2000 do
			addEvent(removeDebuffs, i, targetPlayer)
		end
	end

	return true
end

spell:name("Pele de Pedra")
spell:words("munio petra extensus communis")
spell:group("support")
spell:vocation("aprendiz de mago da terra")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_PROTECT_PARTY)
spell:id(161)
spell:cooldown(60 * 1000) -- Cooldown de 1 minuto
spell:groupCooldown(60 * 1000)
spell:level(35)
spell:mana(140)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
