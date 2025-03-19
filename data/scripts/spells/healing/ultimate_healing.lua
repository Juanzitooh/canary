local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 6.8) + 42
	local max = (level / 5) + (magicLevel * 12.9) + 90
	return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Cura ancestral")
spell:words("sanvia vivare")
spell:group("healing")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de mago do fogo",
	"aprendiz de mago da agua",
	"aprendiz de mago da terra",
	"aprendiz de mago do ar"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_ULTIMATE_HEALING)
spell:id(3)
spell:cooldown(1 * 1000)
spell:groupCooldown(1 * 1000)
spell:level(50)
spell:mana(160)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
