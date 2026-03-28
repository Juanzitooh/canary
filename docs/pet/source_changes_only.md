# Kingdom of Pets - Mudancas na Source (C++ only)

## Objetivo
Listar apenas mudancas que exigem alterar a source C++ do Canary.

## Politica oficial (importante)
- mudanca em source e opcional por padrao;
- source so entra quando for obrigatorio por bloqueio tecnico real;
- se houver workaround Lua viavel com qualidade aceitavel, manter em Lua.

## Resposta curta: tem muitas?
Nao.

Para o MVP do Kingdom of Pets:
- mudancas obrigatorias em source: `0` (zero), se usar `id 9/10` (base Monk) e fluxo em Lua.
- mudancas opcionais/recomendadas: `3` a `5`, para qualidade/performance.

## Status por tipo

## 1) Obrigatorias (MVP)
Nenhuma obrigatoria se voce seguir:
- vocacao Conjurador/Invocador reaproveitando `id 9/10`;
- pet system em `data/libs/systems` + callbacks + kv.

## 2) Opcionais de alto valor

### S1 - Callback nativo de toggle mount
Problema atual:
- sem callback Lua direto para montar/desmontar em tempo real.

Mudanca sugerida:
- adicionar evento tipo `playerOnToggleMount(player, mounted)`.

Impacto:
- remove polling;
- sincroniza melhor estado `MOUNTED_LINKED` do pet.

### S2 - API nativa para custo de mana de pet
Problema atual:
- custo e formulas ficam espalhadas em Lua.

Mudanca sugerida:
- expor helper nativo para calcular/aplicar custo de mana por pet/skill.

Impacto:
- menos duplicacao de formula;
- menos erro de sincronismo entre scripts.

### S3 - Telemetria nativa de pet combat
Problema atual:
- pouca observabilidade para balance PvP.

Mudanca sugerida:
- hooks de metrics para:
  - dano por pet;
  - mana gasta por upkeep;
  - mana gasta por skill;
  - uptime de 2 criaturas.

Impacto:
- balance mais rapido e com dados reais.

### S4 - Extensao de vocacoes (se nao usar base Monk)
Problema atual:
- varios pontos assumem vocacoes atuais (incluindo Monk).

Mudanca sugerida:
- criar nova vocacao CIP/source sem reaproveitar `id 9/10`.

Impacto:
- custo alto;
- mexe em enums, mapeamentos e pontos de gameplay.

Observacao:
- evitar no MVP.

### S5 - Protocolo para UI nativa de pet bar
Problema atual:
- controle via talkaction e funcional, mas sem UX ideal.

Mudanca sugerida:
- opcode/protocolo dedicado para comandos de pet (slot/skill/mode).

Impacto:
- melhor UX;
- aumento de escopo cliente+servidor.

## Caso especifico: vida combinada ao montar (player + criatura)
Sim, e possivel sem alterar C++ no MVP.

Caminho recomendado em Lua:
- ao entrar em estado montado com pet vinculado, aplicar bonus de `max HP` no player;
- ao desmontar/remover vinculo, retirar o bonus e fazer clamp do `current HP` para o novo teto;
- persistir estado no KV para reidratar no login.

Formulas sugeridas:
- `bonusMaxHp = floor(petMaxHp * 0.25) + (petTier * 50)`.
- `playerMaxHpFinal = playerBaseMaxHp + bonusMaxHp`.

Opcional de balance:
- usar `%` em vez de valor fixo (ex.: `+10%` do HP base do player).

Conclusao:
- este requisito nao torna mudanca de source obrigatoria;
- so considerar C++ se precisar de hook nativo dedicado de toggle mount por performance/precisao.

## Ordem recomendada de source changes
1. `S1` callback de mount toggle.
2. `S3` telemetria.
3. `S2` helper de mana pet.
4. `S5` protocolo/UI (quando produto pedir).
5. `S4` nova vocacao source (somente se necessario).

## Criterio para decidir "ficar so em Lua" ou "ir para source"
Ir para source apenas quando houver:
- bloqueio tecnico real em evento/gancho;
- custo alto de polling/script workaround;
- necessidade de performance ou telemetria que Lua nao entrega bem.

## Checklist antes de abrir PR de source
- existe workaround Lua viavel?
- impacto em compatibilidade foi mapeado?
- existe teste/manual de regressao definido?
- docs de contrato Lua/C++ foram atualizadas?

## Referencias do plano
- roadmap essencial: `docs/pet/datapack_bootstrap_milestones.md`
- guia LLM de portabilidade: `docs/pet/kingdom_pets_canary_porting_llm.md`
