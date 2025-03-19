local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_WIND)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_ATTRIBUTES)
condition:setParameter(CONDITION_PARAM_SUBID, 10)
condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
condition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
condition:setParameter(CONDITION_PARAM_SKILL_MELEE, 10) -- +10 nas skills de ataque corpo a corpo
condition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 10) -- +10 nas skills de ataque à distância
condition:setParameter(CONDITION_PARAM_SPEED, 40) -- Aumento na velocidade

local baseMana = 75 -- Custo base de mana

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

	-- Aplica os buffs a todos os membros da party
	for _, targetPlayer in ipairs(affectedList) do
		targetPlayer:addCondition(condition)
	end

	return true
end

spell:name("Treino de Agilidade")
spell:words("munio celeris alatus communis")
spell:group("support")
spell:vocation("aprendiz de arqueiro do ar")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_TRAIN_PARTY)
spell:id(158)
spell:cooldown(30 * 1000) -- Cooldown de 30 segundos
spell:groupCooldown(30 * 1000)
spell:level(35)
spell:mana(75)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
