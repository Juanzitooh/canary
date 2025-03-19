local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_LIGHT)
condition:setParameter(CONDITION_PARAM_LIGHT_LEVEL, 8)
condition:setParameter(CONDITION_PARAM_LIGHT_COLOR, 215)
condition:setParameter(CONDITION_PARAM_TICKS, (11 * 60 + 35) * 1000)
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Iluminar a Volta")
spell:words("videre magnus lumen")
spell:group("support")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de arqueiro do fogo",
	"aprendiz de arqueiro da agua",
	"aprendiz de arqueiro da terra",
	"aprendiz de arqueiro do ar",
	"aprendiz de guerreiro da agua",
	"aprendiz de guerreiro da terra",
	"aprendiz de guerreiro do ar",
	"aprendiz de guerreiro do fogo",
	"aprendiz de mago do fogo",
	"aprendiz de mago da agua",
	"aprendiz de mago da terra",
	"aprendiz de mago do ar"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_GREAT_LIGHT)
spell:id(11)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(13)
spell:mana(60)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
