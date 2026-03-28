# Vocacao Conjurador / Invocador (base Monk)

> Status: documento legado para referencia historica.
> Direcao atual do projeto: manter vocacoes padrao, sem criar/substituir vocacao.
> Fonte oficial de planejamento: `docs/pet/datapack_bootstrap_milestones.md`.

## Objetivo
Definir a vocacao principal do Kingdom of Pets com foco em:
- `mount = familiar montavel`;
- controle ativo de skills do pet;
- balance de PvP com custo continuo de mana.

## Resposta direta
Sim, e totalmente possivel:
1. familiar ativo consumindo mana por tempo;
2. skills do familiar consumindo mana por cast;
3. personagem evoluindo normalmente (`xp`, `hp`, `mana`) como qualquer vocacao.

## Impacto positivo no PvP
O sistema melhora PvP se o pet tiver custo real de recurso:
- evita pet "gratis" pressionando infinito;
- cria tradeoff entre burst proprio e controle do pet;
- abre janela de counterplay (forcar o inimigo a gastar mana);
- reduz snowball: sem mana, o pet perde agressividade/skills.

## Regras recomendadas de mana

### 1) Upkeep (mana por tempo com pet ativo)
- tick: a cada `2s`;
- custo base por pet ativo: `8 mana`;
- custo adicional se montado no pet (`slot 1`): `+4 mana`;
- custo adicional por modo agressivo: `+4 mana`.

Formula sugerida:
`manaTick = 8 + (mounted and 4 or 0) + (mode == "aggressive" and 4 or 0)`

Fallback quando faltar mana:
- opcao A (recomendada): pet entra em `passive` e para skills;
- opcao B: pet e removido apos `N` ticks sem mana.

### 1.1 Regra para 2 criaturas (intencionalmente dificil)
Objetivo: deixar `2 pets ativos` como estado raro e custoso.

Regras sugeridas:
- slot 2 bloqueado ate requisito alto (ex.: level `120` + quest de vinculo);
- ao ativar 2 criaturas, aplicar multiplicador forte de upkeep.

Formula sugerida para upkeep total:
`upkeepTotal = (upkeepSlot1 + upkeepSlot2) * 2.0`

Opcao mais agressiva (recomendada para PvP):
`upkeepTotal = (upkeepSlot1 + upkeepSlot2) * 2.5`

Efeito pratico:
- 2 criaturas drenam mana muito rapido;
- jogador precisa abrir mao de spam de magias proprias;
- uso continuo de 2 summons vira escolha tatica, nao estado padrao.

### 1.2 Escala por nivel da criatura
Sim, o custo deve subir com o nivel/tier da criatura.

Formula sugerida por slot:
`upkeepSlot = baseUpkeep + floor(creatureLevel / 20) + tierBonus`

Exemplo:
- base `8`
- criatura level `80` -> `+4`
- tier bonus `+3`
- upkeep do slot = `15` por tick

Com 2 criaturas:
- `(15 + 15) * 2.0 = 60 mana / tick (2s)` -> muito pesado por design.

### 2) Custo de skill do pet
Toda skill do comando `pet <slot> <skillId> ...` cobra mana do dono.

Tabela inicial sugerida:
- skill 1 (basica): `20 mana`
- skill 2 (controle): `35 mana`
- skill 3 (burst): `55 mana`
- skill 4 (suporte): `45 mana`
- skill 5 (tatico/modo): `10 mana`

Escala por nivel da skill:
`finalCost = baseCost + (skillTier * 5)`

Escala adicional por nivel da criatura:
`finalCost = baseCost + (skillTier * 5) + floor(creatureLevel / 25)`

### 3) Regra anti-spam
- cooldown global do pet: `700ms`;
- cooldown por skill: `2s ~ 8s`;
- opcional PvP: +`20%` no custo de mana contra player.

## Vida combinada com pet montado (max HP)
Sim, tambem e possivel no modelo Lua-first (sem obrigar C++).

Regra sugerida:
- quando `mount = familiar vinculado`, player recebe bonus de `max HP`;
- quando desmontar, bonus e removido;
- se `current HP` ficar acima do novo teto, aplicar clamp para `newMaxHp`.

Formula inicial:
- `bonusMaxHp = floor(petMaxHp * 0.25) + (petTier * 50)`.

Notas de balance:
- esta regra aumenta durabilidade no PvP, entao upkeep de mana precisa permanecer alto;
- para evitar abuso, bonus deve exigir pet ativo e consumo normal de mana.

## Estrategia de implementacao com minimo de source

## Caminho recomendado (menor custo): reaproveitar Monk
A source Canary tem varios pontos hardcoded para Monk (`id 9/10`).

Para evitar mexer em C++ agora:
- renomear no datapack:
  - `Monk` -> `Conjurador` (id 9)
  - `Exalted Monk` -> `Invocador` (id 10)
- manter ids/baseid atuais para compatibilidade.

Arquivos-chave:
- `data/XML/vocations.xml`
- `data/libs/functions/vocation.lua`
- `data/libs/systems/familiar.lua`
- `data/libs/functions/player.lua`
- `data/scripts/creaturescripts/player/send_first_items.lua`
- `data/modules/scripts/daily_reward/daily_reward.lua`

## Blueprint de vocacao (base Monk)
Use Monk como base e ajuste para caster de pet.

Exemplo de direcao para `id=9` e `id=10`:
- `gainhp`: manter `10` (sobrevivencia media)
- `gainmana`: subir para `15` (economia para upkeep + skills)
- `manamultiplier`: `1.2~1.3`
- `pvp`: iniciar em `1.0/1.0` e balancear depois

## Treino universal sem vantagem (fisico + distancia + defesa)
Objetivo dessa vocacao:
- sem bonus escondido para `fist`, `sword`, `club`, `axe`, `distance` ou `shield`;
- jogador evolui melhor naquilo que treinar mais, sem trilha forcada.

No `vocations.xml`, isso e feito deixando os `skill multiplier` iguais no `id=9/10`.

Sugestao de valor inicial equilibrado:
- `multiplier = 1.2` para `skill id 0..6`.

Leitura pratica:
- todos os caminhos de treino ficam com a mesma dificuldade base;
- diferenca final vem do comportamento do jogador (tempo e foco de treino).

## Modelo XML completo (Monk/Exalted renomeados)
Modelo abaixo usando os IDs atuais da base (`9` e `10`), ja adaptado para:
- `Conjurador` / `Invocador`;
- progressao universal de skills;
- foco de mana para gameplay de pet.

```xml
<vocation id="9" clientid="5" baseid="9" name="Conjurador" description="a conjurador" magicshield="0" gaincap="25" gainhp="10" gainmana="15" gainhpticks="6000" gainhpamount="1" gainmanaticks="6000" gainmanaamount="2" manamultiplier="1.2" attackspeed="2000" basespeed="110" soulmax="100" gainsoulticks="120000" fromvoc="9" avatarlooktype="1831">
	<formula meleeDamage="1.0" distDamage="1.0" defense="1.0" armor="1.0" />
	<mitigation multiplier="1.28" primaryShield="2.08" secondaryShield="1.2" />
	<pvp damageReceivedMultiplier="1.0" damageDealtMultiplier ="1.0"/>
	<skill id="0" multiplier="1.2" />
	<skill id="1" multiplier="1.2" />
	<skill id="2" multiplier="1.2" />
	<skill id="3" multiplier="1.2" />
	<skill id="4" multiplier="1.2" />
	<skill id="5" multiplier="1.2" />
	<skill id="6" multiplier="1.2" />
</vocation>

<vocation id="10" clientid="15" baseid="9" name="Invocador" description="an invocador" magicshield="0" gaincap="25" gainhp="10" gainmana="15" gainhpticks="4000" gainhpamount="1" gainmanaticks="6000" gainmanaamount="2" manamultiplier="1.2" attackspeed="2000" basespeed="110" soulmax="200" gainsoulticks="15000" fromvoc="9" avatarlooktype="1831">
	<formula meleeDamage="1.0" distDamage="1.0" defense="1.0" armor="1.0" />
	<mitigation multiplier="1.28" primaryShield="2.08" secondaryShield="1.2" />
	<pvp damageReceivedMultiplier="1.0" damageDealtMultiplier ="1.0"/>
	<skill id="0" multiplier="1.2" />
	<skill id="1" multiplier="1.2" />
	<skill id="2" multiplier="1.2" />
	<skill id="3" multiplier="1.2" />
	<skill id="4" multiplier="1.2" />
	<skill id="5" multiplier="1.2" />
	<skill id="6" multiplier="1.2" />
	<gem quality="0" name="lesser spiritualist gem" />
	<gem quality="1" name="spiritualist gem" />
	<gem quality="2" name="greater spiritualist gem" />
</vocation>
```

## Modelo tecnico (Lua)

### 1) Loop de upkeep de mana
- criar `GlobalEvent` (ex.: `data-otservbr-global/scripts/globalevents/pet/pet_mana_upkeep.lua`)
- a cada 2s:
  - ler estados do pet (`kv`/storage);
  - calcular `manaTick`;
  - debitar mana do player;
  - aplicar fallback se mana insuficiente.

Pseudo:
```lua
if player:getMana() >= manaTick then
  player:addMana(-manaTick)
else
  setPetMode(player, "passive")
  blockPetSkills(player, 3) -- segundos
end
```

### 2) Custo por cast no comando `pet`
No handler do comando:
1. resolver slot/skill/target;
2. calcular custo;
3. validar mana;
4. debitar mana;
5. executar skill do pet.

Pseudo:
```lua
local cost = getPetSkillManaCost(skillId, tier, isPvP)
if player:getMana() < cost then
  return player:sendCancelMessage("Mana insuficiente para skill do familiar.")
end
player:addMana(-cost)
castPetSkill(player, slot, skillId, target)
```

## Milestones sugeridos

### M1 - Vocacao base Conjurador/Invocador
- renomear Monk/Exalted Monk para Conjurador/Invocador;
- ajustar ganhos de mana/hp iniciais;
- manter compatibilidade de ids (9/10).

### M2 - Upkeep de mana do familiar
- implementar `pet_mana_upkeep`;
- fallback sem mana (`passive` + bloqueio curto);
- telemetria basica (log por minuto).

### M3 - Mana por skill e anti-spam
- custo por `skillId`;
- cooldown global + por skill;
- ajuste PvP (`+20%` custo vs player) se necessario.

### M4 - Balance PvP
- ajustar custos por tier;
- ajustar dano/eficiencia do pet em combate entre players;
- fechar tabela final de custos e cooldowns.

## Risco tecnico importante
Criar vocacao nova com IDs fora de `9/10` hoje tende a exigir alteracoes em C++ (varios pontos usam Monk explicitamente).

Por isso, para avancar rapido no datapack:
- use o caminho de substituicao sem mexer em source primeiro.

## Passo a passo (pet como sistema core Lua)
Objetivo: implementar o pet system no mesmo padrao de `data/libs/systems/familiar.lua`.

1. Criar a lib principal:
- `data/libs/systems/pet.lua`
- responsabilidades:
  - estado de slots (`slot1/slot2`);
  - regras de invocar/dispell/domesticar;
  - upkeep de mana;
  - validacoes de 2 criaturas.

2. Criar helpers de Player:
- `data/libs/functions/player_pet.lua`
- metodos sugeridos:
  - `Player:getPetState()`
  - `Player:setPetState(state)`
  - `Player:summonPet(slot, petName)`
  - `Player:despawnPet(slot)`
  - `Player:canUsePetSkill(slot, skillId)`

3. Carregar no bootstrap de libs:
- adicionar `dofile(CORE_DIRECTORY .. "/libs/systems/pet.lua")` em:
  - `data/libs/systems/load.lua`
- adicionar `dofile(CORE_DIRECTORY .. "/libs/functions/player_pet.lua")` no loader de funcoes de player.

4. Integrar callbacks de vida do personagem:
- login: reidratar estado dos pets via KV.
- logout/death: limpar ou persistir estado conforme regra.
- arquivos alvo:
  - `data/scripts/creaturescripts/familiar/on_login.lua` (padrao de referencia)
  - novo namespace de `creaturescripts/pet/*`.

5. Criar loop de upkeep:
- `data-otservbr-global/scripts/globalevents/pet/pet_mana_upkeep.lua`
- tick sugerido: `2s`
- aplicar formulas:
  - custo por slot;
  - multiplicador de 2 criaturas (`x2.0` ou `x2.5`);
  - escala por nivel/tier da criatura.

6. Criar comando de controle:
- talk action `pet <slot> <skillId> [target...]`
- validar:
  - mana;
  - cooldown;
  - slot ativo;
  - permissao de uso no modo atual.

7. Integrar domesticacao:
- action de item unico (`Sigilo de Vinculo`) chamando a lib de pet.
- em sucesso:
  - vincular criatura no `slot1`;
  - conceder mount correspondente;
  - persistir em KV.

8. Definir KV schema (obrigatorio):
- prefixo sugerido: `player:<id>:pet:*`
- chaves minimas:
  - `slot1`, `slot2`, `mode`, `mounted`, `schema_version`.

9. Testes minimos por milestone:
- M1: invocar/dispell 1 pet + persistencia.
- M2: upkeep de mana funcionando.
- M3: skill cost + cooldown + fallback sem mana.
- M4: 2 criaturas com gate dificil e consumo pesado.
