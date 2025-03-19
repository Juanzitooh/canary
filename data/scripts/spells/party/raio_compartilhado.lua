local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Condição de aumento de velocidade
local speedCondition = Condition(CONDITION_ATTRIBUTES)
speedCondition:setParameter(CONDITION_PARAM_SUBID, 15)
speedCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
speedCondition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
speedCondition:setParameter(CONDITION_PARAM_SPEED, 30) -- Aumento na velocidade de movimento

-- Condição para dano elétrico periódico
local lightningCondition = Condition(CONDITION_ENERGY)
lightningCondition:setParameter(CONDITION_PARAM_SUBID, 16)
lightningCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
lightningCondition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
lightningCondition:setParameter(CONDITION_PARAM_FIELD_DAMAGE, 5) -- Dano de 8 por segundo
lightningCondition:setParameter(CONDITION_PARAM_ENERGY, 1000) -- Intervalo de 1 segundo

local baseMana = 110 -- Custo base de mana

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

	-- Aplica a velocidade e dano elétrico extra a todos os membros da party
	for _, targetPlayer in ipairs(affectedList) do
		targetPlayer:addCondition(speedCondition) -- Aumento de velocidade
		targetPlayer:addCondition(lightningCondition) -- Dano elétrico passivo nos ataques
	end

	return true
end

spell:name("Raio Compartilhado")
spell:words("impulsus ventus communis aletus")
spell:group("support")
spell:vocation("aprendiz de mago do ar")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_TRAIN_PARTY)
spell:id(162)
spell:cooldown(30 * 1000) -- Cooldown de 30 segundos
spell:groupCooldown(30 * 1000)
spell:level(35)
spell:mana(110)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
