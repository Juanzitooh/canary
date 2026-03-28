# Briefing - Kingdom of Pets (Mount/Familiar/Monster)

## 1) Objetivo do projeto
Criar um sistema onde mounts viram criaturas reais e o jogo gira em volta delas:

- apenas criaturas do ecossistema `pet` serao usadas como monstros principais;
- cada pet deve aparecer e funcionar corretamente no Bestiary;
- pets podem usar ataque basico e magias de monster;
- jogador pode ter ate 2 criaturas ativas, com regras claras de mount e familiar.

## 2) Base atual do Canary (confirmado no codigo)

### 2.1 Mount hoje nao e criatura separada
- mount hoje e estado visual/velocidade no player;
- catalogo: `data/XML/mounts.xml` (235 mounts, ids `1..235`);
- toggle:
  - `ProtocolGame::parseToggleMount` -> `Game::playerToggleMount` -> `Player::toggleMount`;
  - arquivos: `src/server/network/protocol/protocolgame.cpp`, `src/game/game.cpp`, `src/creatures/players/player.cpp`.

### 2.2 Pasta de monsters efetiva no projeto
- `dataPackDirectory` padrao: `data-otservbr-global`;
- monsters carregam de: `data-otservbr-global/monster`.
- referencia:
  - `src/config/configmanager.cpp` (`dataPackDirectory`, `coreDirectory`);
  - `src/game/functions/game_reload.cpp` (`loadScripts(datapackFolder + "/monster", ...)`).

### 2.3 Familiar e summon ja existem
- summon por Lua: `Game.createMonster(name, pos, extended, force, master)`;
- familiar atual: `Player:CreateFamiliarSpell` / `Player:createFamiliar` em `data/libs/functions/player.lua`;
- scripts gerais ja usam limite de 2 summons em algumas regras:
  - `data/scripts/spells/support/summon_creature.lua`;
  - `data/scripts/runes/convince_creature.lua`;
  - `data/scripts/runes/animate_dead_rune.lua`.

## 3) Arquitetura alvo (Mount = Pet = Monster)

### 3.1 Regra central
`Mount` deixa de ser apenas cosmetico e passa a selecionar um `PetMonster` correspondente:

- `mountId` identifica qual criatura pet deve ser usada;
- ao montar, a criatura correspondente e invocada (ou reusada) como summon do player;
- ao desmontar, a criatura pode ser removida ou ficar ativa no slot (regra de design).

### 3.2 Slots de criaturas (recomendado)
Padronizar 2 slots fixos:

- `slot 1`: pet do mount (vinculado ao mount atual);
- `slot 2`: familiar pessoal do jogador (ou segundo pet).

Assim voce cumpre:

- maximo de 2 criaturas por jogador;
- no maximo 1 montada ao mesmo tempo;
- mount/familiar/monster ficam interligados no mesmo sistema de slots.

### 3.3 KV/state sugerido por player
- `pet-slot-1-monster`;
- `pet-slot-2-monster`;
- `pet-active-mount-id`;
- `pet-mounted` (`0/1`);
- `pet-mode` (`passive`, `assist`, `aggressive`);
- `pet-follow-distance`.

## 4) Bestiary: como garantir que apareca certo

Esse ponto e critico para o projeto.

### 4.1 Requisitos obrigatorios por pet monster
Cada monster gerado deve ter:

- `raceId` unico e nao-zero;
- bloco `Bestiary` preenchido;
- nome unico de monster.

### 4.2 Por que isso e obrigatorio
- `register_monster_type.lua` aplica `raceId` e campos de `Bestiary`;
- ao setar `raceId`, o engine registra a entrada no bestiary list;
- kills com `raceId == 0` sao ignoradas no bestiary.

Referencias:
- `data/scripts/lib/register_monster_type.lua`;
- `src/lua/functions/creatures/monster/monster_type_functions.cpp` (`luaMonsterTypeRaceid`);
- `src/io/iobestiary.cpp` (`addBestiaryKill`);
- `src/creatures/players/player.cpp` (`STORAGEVALUE_BESTIARYKILLCOUNT + raceid`).

### 4.3 Range de raceId para pets
Reservar faixa dedicada, exemplo:

- `raceId = 30000 + mountId`.

Com 235 mounts atuais:

- faixa final: `30001..30235`.

### 4.4 Exemplo minimo de bloco Bestiary
```lua
monster.raceId = 30001
monster.Bestiary = {
	class = "Pet",
	race = BESTY_RACE_MAGICAL,
	toKill = 250,
	FirstUnlock = 25,
	SecondUnlock = 100,
	CharmsPoints = 5,
	Stars = 2,
	Occurrence = 0,
	Locations = "Kingdom of Pets"
}
```

## 5) Magias nos pets e familiares: e possivel?
Sim. Totalmente possivel.

### 5.1 O que ja existe no engine
Monsters suportam ataques e magias via `monster.attacks`/`monster.defenses`, incluindo:

- melee;
- combat por elemento;
- rune/spell names;
- conditions (paralyze, poison, etc.);
- speed/outfit/invisible;
- summoning e efeitos.

Referencia principal:
- `src/creatures/monsters/monsters.cpp` (`deserializeSpell`).

### 5.2 Prova na base atual
Familiar existente ja usa varias magias:
- `data-otservbr-global/monster/familiars/knight_familiar.lua`.

### 5.3 Conclusao pratica
Voce pode iniciar com ataque basico e evoluir por tiers:

- Tier 0: melee only;
- Tier 1: 1 spell ofensiva + 1 utilitaria;
- Tier 2: kit completo por familia de pet.

## 6) Estrategia para "so existir pet monster"

### 6.1 O que precisa mudar de verdade
Nao basta gerar a pasta `monster/pet`. Tambem precisa:

- ajustar spawns XML do mundo para nomes de pets;
- remover/substituir referencias de monstros antigos nos spawns ativos.

No datapack atual ha spawns em:
- `data-otservbr-global/world/otservbr-monster.xml`;
- outros arquivos `*-monster.xml` em quests/eventos.

### 6.2 Fases seguras
1. Gerar pets e validar carga.
2. Ativar um mapa/area de teste 100% pet.
3. Migrar spawns globais por lote.
4. Desativar monsters legados apenas no fim.

## 7) Gerador Python (saidas esperadas)

### 7.1 Entrada
- `data/XML/mounts.xml`;
- template base de pet;
- configuracao de faixas: vida, exp, dano, tier, bestiary.

### 7.2 Saidas
- `data-otservbr-global/monster/pet/*.lua` (1 por mount);
- `data-otservbr-global/monster/pet/pet_index.lua`:
  - `mountId -> monsterName`;
  - `mountId -> raceId`;
  - `mountId -> lookType`.

### 7.3 Exemplo de arquivo gerado
`data-otservbr-global/monster/pet/pet_widow_queen.lua`

```lua
local mType = Game.createMonsterType("Pet Widow Queen")
local monster = {}

monster.description = "a pet widow queen"
monster.experience = 120
monster.outfit = { lookType = 368 }
monster.health = 900
monster.maxHealth = 900
monster.speed = 230
monster.race = "blood"
monster.corpse = 0
monster.raceId = 30001
monster.manaCost = 0

monster.Bestiary = {
	class = "Pet",
	race = BESTY_RACE_MAGICAL,
	toKill = 250,
	FirstUnlock = 25,
	SecondUnlock = 100,
	CharmsPoints = 5,
	Stars = 2,
	Occurrence = 0,
	Locations = "Kingdom of Pets"
}

monster.changeTarget = { interval = 4000, chance = 0 }
monster.flags = {
	summonable = false,
	convinceable = false,
	hostile = false,
	attackable = true,
	illusionable = false,
	pushable = false,
	canPushItems = false,
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 1
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -25, maxDamage = -50 }
}

monster.defenses = { defense = 10, armor = 8 }
mType:register(monster)
```

## 8) Pontos de atencao imediatos

### 8.1 Inconsistencia atual de mounts
`/addmount <player>, all` ainda vai de `1..231`, mas o XML atual tem `1..235`.
Arquivo: `data/scripts/talkactions/god/add_mount.lua`.

### 8.2 Regra atual de familiar limita 1 summon
`Player:CreateFamiliarSpell` bloqueia quando `#self:getSummons() >= 1`.
Arquivo: `data/libs/functions/player.lua`.

Para modelo de 2 slots, essa regra precisa ser ajustada para o novo orquestrador de pets.

## 9) Milestones do Kingdom of Pets

### M1 - Catalogo Pet + Bestiary
- gerar monsters `pet/*` a partir de `mounts.xml`;
- definir range fixo de `raceId`;
- validar que todos aparecem no bestiary.

### M2 - Orquestrador de Slots (2 criaturas)
- implementar controle de `slot1/slot2`;
- ligar mount ao `slot1`;
- permitir familiar/pet secundario no `slot2`.

### M3 - Spells e comportamento
- adicionar skills por tier;
- balancear IA de follow/assist/aggressive;
- validar pvp/pve e cooldowns.

### M4 - Migracao de mundo
- migrar spawns legados para pets;
- garantir que o jogo rode com ecossistema pet-first.

## 10) Entregavel deste briefing
Este arquivo define a base tecnica para implementar o sistema `Kingdom of Pets` sem ambiguidade sobre:

- como montar o catalogo de criaturas;
- como fazer aparecer no bestiary;
- como aplicar magias nos pets;
- como conectar mount, familiar e monster em ate 2 slots por jogador.

## 11) Escopo funcional confirmado (nova direcao)

Modelo conceitual final do Kingdom of Pets:

- criaturas do jogo = monsters gerados do catalogo pet;
- familiares = essas mesmas criaturas, mas domesticadas e vinculadas ao player;
- montarias = outfit visual dessas criaturas, integrado ao slot do familiar/pet.

Tudo operando nas vocacoes padrao do jogo:

- sem criar vocacao nova;
- sem alterar IDs de vocacao;
- liberacao do sistema por quest/storage/config, nao por vocacao.

## 12) Escala de dano por nivel e skills do player

### 12.1 Regra geral
O dano do pet/familiar deve escalar pelo dono (`master`) e nao ficar fixo.

Formula base sugerida:

`petPower = 1.0 + (level * 0.015) + (magicLevel * 0.025) + (skillRef * 0.020)`

`damageMin = baseMin * petPower`
`damageMax = baseMax * petPower`

### 12.2 Skill referencia por tipo de criatura
- `arcane`: usa `magicLevel`;
- `brute`: usa melhor entre `sword/club/axe`;
- `ranged`: usa `distance`;
- `guardian`: usa `shield` (defensivo) + `magicLevel` (suporte);
- `hybrid`: combinacao parcial de `magicLevel + distance`.

### 12.3 Como aplicar tecnicamente no Canary
- pegar `master` com `pet:getMaster()`;
- ler status do player com `getLevel()`, `getMagicLevel()`, `getSkillLevel(...)`;
- calcular dano em Lua;
- executar combate com esse dano no alvo.

Observacao:
- formulas de `Combat:setFormula` padrao escalam por `Player` caster;
- para pet controlado, prefira calcular dano custom em Lua com base no `master`.

## 13) Controle ativo da criatura pelo jogador

### 13.1 Objetivo
Player controla a criatura no chat como "magias da criatura", com IDs numericos e parametros.

### 13.2 Formato recomendado de comando
Comando canonico:

`pet <slot> <skillId> [target] [param1] [param2]`

Shorthand aceito:

`pet <skillId> [target]`

Exemplos:
- `pet 1 2 playername` -> slot 1 usa skill 2 no playername.
- `pet 2 3` -> slot 2 usa skill 3 no alvo atual.
- `pet 1 4 self` -> slot 1 usa skill 4 no proprio dono.
- `pet 2 playername` -> atalho: skill padrao 2 no target nomeado.

### 13.3 Tabela de skills por numero (base inicial)
- `1`: ataque basico ativo (single target).
- `2`: skill principal da criatura (elemental/special).
- `3`: skill de area.
- `4`: skill utilitaria (buff/debuff/heal).
- `5`: comando tatico (trocar modo: passive/assist/aggressive).

## 14) Montado com criatura vinculada ao player

### 14.1 Regra de gameplay
Ao montar, a criatura continua existindo e vinculada ao jogador, sem quebrar o limite de slots.

### 14.2 Estados sugeridos
- `UNMOUNTED_ACTIVE`: pet fisico ativo no mapa.
- `MOUNTED_LINKED`: pet vinculado ao dono em modo montado.

### 14.3 Comportamento no modo `MOUNTED_LINKED`
- pet permanece associado ao `slot 1`;
- pode continuar recebendo comandos de skill;
- movimentacao visual e do player seguem juntas;
- manter sincronismo de estado com `pet-mounted` e `pet-active-mount-id`.

### 14.4 Nota tecnica importante sobre "mesmo SQM"
Manter pet e player sempre no mesmo SQM e possivel, mas sensivel para colisao/pathing.
Implementacao mais segura:

- vinculo logico no mesmo estado (`MOUNTED_LINKED`);
- spawn fisico opcional (ou oculto) durante montaria;
- comandos continuam funcionando pelo slot, mesmo montado.

## 15) Ajustes de milestones para essa versao

Este briefing passa a seguir o roadmap oficial em:
`docs/pet/datapack_bootstrap_milestones.md`.

Mapeamento recomendado dentro deste documento:

- `M2` oficial: orquestrador isolado de slots (`slot1/slot2/control_slot`);
- `M3` oficial: integracao mount -> pet no `slot1` (`MOUNTED_LINKED`);
- `M4` oficial: integracao familiar no `slot2` + comando unificado;
- `M5` oficial: skills, upkeep e anti-spam.

## 16) Lua-first vs Source minima (resposta objetiva)

### 16.1 E possivel fazer "tudo isso" so em Lua?
Resposta curta: **quase tudo, sim**.

Com a API atual, ja e possivel em Lua:

- gerar/catalogar pets (com Python + arquivos Lua de monster);
- invocar/remover pets e familiares (`Game.createMonster(..., master)`);
- controlar slots (`slot1/slot2`) com `player:kv()` e storages;
- criar comandos `pet <slot> <skillId> [target...]` via TalkAction;
- executar skills da criatura com `Combat()` ou `doTargetCombatHealth`;
- escalar dano com nivel/skills do dono (`getLevel`, `getMagicLevel`, `getSkillLevel`);
- manter bestiary completo via `raceId` + bloco `Bestiary`.

### 16.2 Onde o Lua tem limites praticos
Dois pontos principais:

1. **Hook direto de mount toggle**
- hoje nao existe callback Lua especifico para `playerToggleMount`;
- sem source, o workaround e detectar estado por polling/eventos de movimento e outfit.

2. **Ergonomia de combate do pet**
- `Combat:setFormula` padrao usa caster `Player`;
- como pet e `Monster`, escala por master exige formula custom Lua (manual), nao apenas callback pronto.

### 16.3 Source minima recomendada (opcional, cirurgica)
Se quiser reduzir complexidade em Lua, duas adicoes pequenas no C++ resolvem quase tudo:

1. `EventCallback_t::playerOnToggleMount(player, mounted)` real
- evita polling para detectar mount/desmount;
- sincroniza `MOUNTED_LINKED` com precisao.

2. Helper de formula para summon
- ex.: `Combat`/helper que aceite `master` como referencia de stats;
- simplifica escala de dano de pet sem formulas manuais repetidas.

## 17) Estrategia pratica para usar o minimo de source

### 17.1 Fase 1 (100% Lua)
- implementar sistema completo em Lua primeiro;
- validar gameplay (slots, comandos, skills, bestiary, montado vinculado).

### 17.2 Fase 2 (source so se doer)
Somente apos validar:
- adicionar callback de toggle mount;
- adicionar helper de escala por master (se necessario para performance/manutencao).

### 17.3 Regra de decisao
Se o comportamento estiver estavel e performatico em Lua:
- **nao mexe na source**.

Se aparecer custo alto de manutencao/edge cases:
- aplica somente as duas adicoes cirurgicas acima.
