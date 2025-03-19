local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	local position = creature:getPosition()
	position:sendMagicEffect(CONST_ME_POFF)

	local tile = Tile(position)
	if not tile:isRopeSpot() then
		creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	tile = Tile(position:moveUpstairs())
	if not tile then
		creature:sendCancelMessage(RETURNVALUE_NOTENOUGHROOM)
		return false
	end

	creature:teleportTo(position, false)
	position:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

spell:name("Pedra Magica")
spell:words("celeris petra")
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
spell:castSound(SOUND_EFFECT_TYPE_SPELL_MAGIC_ROPE)
spell:id(76)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(5)
spell:mana(20)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
