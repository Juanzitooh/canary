local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

function onGetFormulaValues(player, level, maglevel) -- already compared to the official tibia | compared date: 08/03/21(m/d/y) -- possible max limit of 30?, need test in magic level 71+.
	local min = (level * 0 + maglevel * 0.1614) + 8
	local max = (level * 0 + maglevel * 0.2468) + 15
	return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Limpar Ferimentos")
spell:words("sanvia aqua modicus")
spell:group("healing")
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
spell:castSound(SOUND_EFFECT_TYPE_SPELL_MAGIC_PATCH)
spell:id(174)
spell:cooldown(1 * 1000)
spell:groupCooldown(1 * 1000)
spell:level(1)
spell:mana(6)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:isPremium(false)
spell:register()
