local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Criação da condição de regeneração de vida massiva
local healCondition = Condition(CONDITION_REGENERATION)
healCondition:setParameter(CONDITION_PARAM_SUBID, 13)
healCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
healCondition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
healCondition:setParameter(CONDITION_PARAM_HEALTHGAIN, 50) -- Cura de 150 HP por segundo
healCondition:setParameter(CONDITION_PARAM_HEALTHTICKS, 1000) -- Intervalo de 1 segundo para curar

local baseMana = 180 -- Custo base de mana

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

	-- Aplica a regeneração de vida massiva a todos os membros da party
	for _, targetPlayer in ipairs(affectedList) do
		targetPlayer:addCondition(healCondition)
	end

	return true
end

spell:name("Bencao da Vida")
spell:words("sanvia vivare alatus communis")
spell:group("support")
spell:vocation("aprendiz de mago da agua")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_TRAIN_PARTY)
spell:id(160)
spell:cooldown(60 * 1000) -- Cooldown de 1 minuto
spell:groupCooldown(60 * 1000)
spell:level(35)
spell:mana(180)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
