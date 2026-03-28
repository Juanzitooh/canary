# Kingdom of Pets - Guia LLM para portar em outro Canary

## Objetivo
Ensinar uma LLM a aplicar o projeto Kingdom of Pets em outro repositório Canary, com baixa ambiguidade e foco em execucao segura.

## Nota de nomenclatura
Quando o trabalho ocorrer no mesmo repositorio, trate como:
- replicacao entre branches (ex.: `main` -> `feat/game-pets`);
- nao como migracao entre projetos diferentes.

## Resultado esperado
Ao final da migracao, o projeto destino deve ter:
- vocacao `Conjurador/Invocador` operando em `id 9/10`;
- sistema de pet em camada core Lua (`libs/systems`);
- domesticacao por item com chance;
- controle de skills do pet por comando;
- custo de mana por upkeep e por skill;
- backlog de criaturas por mount.

## Premissas
- repositório alvo e um Canary compatível com datapack Lua.
- engine e datapack sobem sem erro antes da migracao.
- LLM possui acesso de escrita no repositório.

## Regra inegociavel de execucao
- tratar mudanca na source C++ como opcional por padrao;
- so abrir mudanca em C++ quando houver bloqueio tecnico real sem alternativa Lua viavel;
- registrar justificativa da obrigatoriedade antes de alterar source.

## Estrategia geral
1. Implementar em datapack/Lua como caminho principal.
2. Nao tocar em C++ sem prova de bloqueio.
3. Implementar em fatias pequenas com validacao frequente.
4. Registrar tudo em docs e milestones.

## Checklist de entrada (antes de alterar)
- confirmar existencia de:
  - `data/XML/vocations.xml`
  - `data/libs/systems/load.lua`
  - `data/libs/functions/player.lua`
  - `data/XML/mounts.xml`
- confirmar que o servidor inicia.
- criar branch dedicada.

Exemplo recomendado:
1. `git switch -c feat/game-pets`
2. separar commit inicial de docs/planejamento
3. evoluir milestones com commits atomicos por tema

## Fase A - Vocacao unica sem quebrar source
Objetivo: renomear Monk/Exalted Monk para Conjurador/Invocador, mantendo ids.

Arquivos-alvo:
- `data/XML/vocations.xml`
- `data/libs/functions/vocation.lua`
- arquivos Lua com dependencia de `VOCATION.BASE_ID.MONK` (revisar e adaptar quando necessario)

Regras:
- manter `id 9/10` e `baseid 9`.
- manter compatibilidade com pontos hardcoded da source.
- aplicar treino universal: `skill multiplier` igual em `id 0..6`.

Validacao:
- login em personagem de vocacao 9/10.
- ganho de skills sem vantagem escondida por tipo de arma.

## Fase B - Catalogo de pets
Objetivo: preparar base para criaturas derivadas de mounts.

Arquivos-alvo:
- `data/XML/mounts.xml`
- `data-otservbr-global/monster/pet/*.lua` (ou datapack equivalente)

Regras:
- `raceId` unico e nao-zero.
- reservar faixa previsivel (ex.: `30000 + mountId`).
- bloco `Bestiary` obrigatorio em cada pet.

Validacao:
- monsters carregam sem erro no startup/reload.
- bestiary registra kills dos pets.

## Fase C - Core Pet System em libs
Objetivo: tratar pet como sistema base, nao script isolado.

Arquivos-alvo:
- `data/libs/systems/pet.lua` (novo)
- `data/libs/functions/player_pet.lua` (novo)
- `data/libs/systems/load.lua` (registrar loader)
- `data/scripts/creaturescripts/pet/*` (novo)

Contrato minimo da lib:
- invocar/remover pet por slot;
- persistir estado em KV;
- validar permissoes de skill;
- suportar estado montado.

Validacao:
- invocacao/desinvocacao por slot funciona.
- estado persiste em relog.

## Fase D - Mana model
Objetivo: balancear pet para PvP/PvE com custo real.

Implementar:
- upkeep por tick (`globalevent`)
- custo por skill no comando `pet`
- fallback sem mana
- restricao severa para 2 criaturas

Regras recomendadas:
- upkeep base por slot + escala por nivel/tier.
- 2 criaturas: multiplicador de custo (`x2.0` ou `x2.5`).

Validacao:
- sem mana -> pet em `passive` ou despawn.
- custo escala conforme nivel da criatura.

## Fase D.1 - Vida combinada montada (opcional de design)
Objetivo: aumentar `max HP` do player enquanto estiver montado no pet vinculado.

Implementar em Lua:
- no estado `mounted + pet linked`, aplicar bonus de `max HP`;
- em `unmount` ou perda do pet ativo, remover bonus e ajustar `current HP` para o teto novo;
- salvar flag no KV para consistencia em login/relog.

Regra de balance sugerida:
- `bonusMaxHp = floor(petMaxHp * 0.25) + (petTier * 50)`.

Validacao:
- montar aumenta HP maximo;
- desmontar normaliza HP maximo sem quebrar estado;
- relog preserva corretamente o estado de bonus.

## Fase E - Domesticacao
Objetivo: converter criatura em familiar com chance.

Arquivos-alvo:
- action de item (novo ou adaptado)
- config central de domesticacao

Fluxo:
1. usa item no alvo valido.
2. valida mana/cooldown/slot.
3. rola chance.
4. sucesso: vincula pet + concede mount.
5. falha: consome tentativa e aplica cooldown.

Validacao:
- sucesso e falha com mensagens corretas.
- persistencia em KV apos relog.

## Fase F - Canais de obtencao
Objetivo: permitir obtenção por gameplay e monetizacao.

Canais:
- item de domesticacao (core)
- store (direto)
- quest (item ou vinculo 100%)

Validacao:
- todos os canais convergem para o mesmo estado final de pet.

## KV schema minimo (obrigatorio)
Prefixo sugerido: `player:<id>:pet:*`

Campos minimos:
- `schema_version`
- `slot1`
- `slot2`
- `mode`
- `mounted`
- `active_mount_id`

Boas praticas:
- versionar schema (`v1`, `v2`...)
- ter migrador simples quando schema mudar
- evitar chaves sem namespace

## Testes de aceite por fase
- A: vocacao 9/10 funcional
- B: pet com bestiary e raceId valido
- C: slots e persistencia
- D: mana upkeep/skill/2 criaturas
- D.1 (opcional): bonus de max HP montado com reversao segura no unmount
- E: domesticacao com chance
- F: store + quest integradas

## Erros comuns
- criar vocacao nova fora de 9/10 cedo demais (rompe compatibilidade)
- esquecer loader de `libs/systems/pet.lua`
- usar `raceId = 0`
- nao persistir estado de slot
- permitir 2 criaturas sem gate/custo severo

## Sequencia sugerida para LLM executar
1. aplicar vocacao (A)
2. preparar catalogo pet (B)
3. subir core pet system (C)
4. ligar mana model (D)
5. ligar vida combinada montada (D.1, opcional)
6. ligar domesticacao (E)
7. ligar canais de obtencao (F)
8. validar e documentar

## Referencias
- roadmap essencial: `docs/pet/datapack_bootstrap_milestones.md`
- vocacao: `docs/pet/vocacao_conjurador_invocador.md`
- domesticacao: `docs/pet/domesticacao_pet_exemplo.md`
- source only: `docs/pet/source_changes_only.md`
