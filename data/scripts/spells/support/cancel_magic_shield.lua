local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, 0)

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	creature:removeCondition(CONDITION_MANASHIELD)
	return combat:execute(creature, var)
end

spell:group("support")
spell:id(245)
spell:name("Desfazer Escudo Magico")
spell:words("expelis vivare")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CANCEL_MAGIC_SHIELD)
spell:level(14)
spell:mana(50)
spell:isAggressive(false)
spell:isSelfTarget(true)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de mago do fogo",
	"aprendiz de mago da agua",
	"aprendiz de mago da terra",
	"aprendiz de mago do ar"
)
spell:register()
