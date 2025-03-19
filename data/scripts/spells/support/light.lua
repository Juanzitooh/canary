local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_LIGHT)
condition:setParameter(CONDITION_PARAM_LIGHT_LEVEL, 6)
condition:setParameter(CONDITION_PARAM_LIGHT_COLOR, 215)
condition:setParameter(CONDITION_PARAM_TICKS, (6 * 60 + 10) * 1000)
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Criar Luz")
spell:words("videre lumen")
spell:group("support")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de guerreiro do fogo",
	"aprendiz de guerreiro da agua",
	"aprendiz de guerreiro da terra",
	"aprendiz de guerreiro do ar",
	"aprendiz de arqueiro do fogo",
	"aprendiz de arqueiro da agua",
	"aprendiz de arqueiro da terra",
	"aprendiz de arqueiro do ar",
	"aprendiz de mago do fogo",
	"aprendiz de mago da agua",
	"aprendiz de mago da terra",
	"aprendiz de mago do ar",
	"ser humano",
	"coletor",
	"minerador",
	"pescador",
	"cozinheiro",
	"ferreiro do fogo",
	"ferreiro da agua",
	"ferreiro da terra",
	"ferreiro do ar",
	"artesao do fogo",
	"artesao da agua",
	"artesao da terra",
	"artesao do ar",
	"joalheiro do fogo",
	"joalheiro da agua",
	"joalheiro da terra",
	"joalheiro do ar",
	"alquimista do fogo",
	"alquimista da agua",
	"alquimista da terra",
	"alquimista do ar"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_LIGHT)
spell:id(10)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(3)
spell:mana(15)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
