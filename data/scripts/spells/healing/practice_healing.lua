local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Nova Fórmula: Mantendo um mínimo de 5 e um máximo de 50 de cura
function onGetFormulaValues(player, level, magicLevel)
	local baseMin = (level / 5) + (magicLevel * 1.5) + 2
	local baseMax = (level / 5) + (magicLevel * 2.5) + 10

	-- Garante que o mínimo é pelo menos 5 e o máximo não passa de 50
	local min = math.max(5, baseMin)
	local max = math.min(60, baseMax)

	return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Cura Leve")
spell:words("sanvia modicus")
spell:group("healing")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_PRACTISE_HEALING)
spell:id(166)
spell:cooldown(1 * 1000)
spell:groupCooldown(1 * 1000)
spell:level(1)
spell:mana(5)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)

-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de guerreiro da terra",
	"aprendiz de arqueiro da terra",
	"aprendiz de mago da terra"
)


spell:register()
