# TalkActions - Mini Manual para LLM (UI Focus)

Objetivo:
- dar instruções exatas para uma LLM gerar comandos de chat com segurança.
- cobrir somente os comandos escolhidos para interface (M1/M2).

Escopo de comandos:
- M1 (`gamemaster`): `/listplayers`, `/active`, `/goto`, `/pos`, `/town`, `/t`, `/kick`, `/info`, `/mc`, `/namelock`, `/getstorage`
- M2 (`god`): `/addmoney`, `/getkv`, `/getallkv`, `/setkv`, `/setstorage`, `/addskill`, `/addmount`, `/addbadge`, `/addtitle`, `/settitle`, `/addtutor`, `/removetutor`, `/raid`, `/listraid`

## Regras gerais de parsing
- Separador principal de parâmetros compostos: vírgula `,`.
- Nomes de player/creature/town são *case-insensitive* na maior parte dos comandos (dependendo do lookup interno).
- Sempre preferir formato explícito com vírgula quando o comando espera múltiplos argumentos.
- Se um comando tiver opção sem parâmetro e com parâmetro, a LLM deve escolher a forma explícita para evitar ambiguidades.

## M1 - Gamemaster

### `/listplayers [all]`
- Sintaxe:
  - `/listplayers`
  - `/listplayers all`
- Parâmetros:
  - `mode` (opcional): enum `all`
- Comportamento:
  - sem `all`: abre modal com players ativos (não ghost, não treino, não idle, fora da sala de treino).
  - com `all`: inclui todos os players (exceto você).

### `/active`
- Sintaxe: `/active`
- Parâmetros: nenhum.
- Comportamento: teleporta para um player ativo aleatório.

### `/goto <creatureName>`
- Sintaxe: `/goto <creatureName>`
- Parâmetros:
  - `creatureName` (obrigatório): string.
- Erros comuns: `Creature not found.`

### `/pos` e `!pos`
- Sintaxe:
  - `/pos`
  - `!pos`
  - `/pos <x, y, z>`
  - `/pos Position(x, y, z)`
  - `/pos {x = x, y = y, z = z}`
- Parâmetros:
  - `position` (opcional): position literal.
- Comportamento:
  - sem parâmetro: mostra posição atual.
  - com parâmetro: teleporta para posição válida.

### `/town <townName|townId>`
- Sintaxe: `/town <townName|townId>`
- Parâmetros:
  - `town` (obrigatório): string (nome) ou número (id).

### `/t [playerName]`
- Sintaxe:
  - `/t`
  - `/t <playerName>`
- Parâmetros:
  - `playerName` (opcional): string.
- Comportamento:
  - sem parâmetro: teleporta você para seu templo.
  - com parâmetro: teleporta o alvo para o templo dele.

### `/kick <playerName>`
- Sintaxe: `/kick <playerName>`
- Parâmetros:
  - `playerName` (obrigatório): string.
- Restrições:
  - não expulsa jogador com `getGroup():getAccess()`.

### `/info <playerName>`
- Sintaxe: `/info <playerName>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
- Saída:
  - popup com IP, posição, skills, level etc.

### `/mc`
- Sintaxe: `/mc`
- Parâmetros: nenhum.
- Saída: lista de possíveis multiclients por IP.

### `/namelock <playerName>, <reason>`
- Sintaxe: `/namelock <playerName>, <reason>`
- Parâmetros:
  - `playerName` (obrigatório): string.
  - `reason` (obrigatório): string não vazia.
- Observação:
  - pode aplicar em player online ou offline (via `Game.getOfflinePlayer`).

### `/getstorage <playerName>, <storageKeyOrName>`
- Sintaxe: `/getstorage <playerName>, <storageKeyOrName>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
  - `storageKeyOrName` (obrigatório): número ou string.

## M2 - God

### `/addmoney <playerName>, <amount>`
- Sintaxe: `/addmoney <playerName>, <amount>`
- Parâmetros:
  - `playerName` (obrigatório): string.
  - `amount` (obrigatório): inteiro positivo.
- Comportamento: credita banco (`Bank.credit`).

### `/getkv <key>[, <playerName>]`
- Sintaxe:
  - `/getkv <key>`
  - `/getkv <key>, <playerName>`
- Parâmetros:
  - `key` (obrigatório): string.
  - `playerName` (opcional): string (default: executor).

### `/getallkv [playerName]`
- Sintaxe:
  - `/getallkv`
  - `/getallkv <playerName>`
- Parâmetros:
  - `playerName` (opcional): string (default: executor).
- Observação: lista apenas KVs numéricos `>= 0`.

### `/setkv <key>, <value>[, <playerName>]`
- Sintaxe:
  - `/setkv <key>, <value>`
  - `/setkv <key>, <value>, <playerName>`
- Parâmetros:
  - `key` (obrigatório): string.
  - `value` (obrigatório): expressão Lua válida para `load("return " .. value)`.
  - `playerName` (opcional): string (default: executor).
- Observações:
  - para string, enviar com aspas: ex. `\"texto\"`.
  - para boolean: `true` ou `false`.
  - para número: `123`.
  - para tabela simples: `{a=1}`.

### `/setstorage <storageKey>, <value>[, <playerName>]`
- Sintaxe:
  - `/setstorage <storageKey>, <value>`
  - `/setstorage <storageKey>, <value>, <playerName>`
- Parâmetros:
  - `storageKey` (obrigatório): **inteiro** (no código atual, chave textual não é aceita).
  - `value` (obrigatório): string/inteiro (persistido como value do storage).
  - `playerName` (opcional): string (default: executor).
- Observação:
  - alvo precisa estar online quando `playerName` for informado.

### `/addskill <playerName>, <skill|level|magic>[, <amount>]`
- Sintaxe: `/addskill <playerName>, <skillOrType>, <amount?>`
- Parâmetros:
  - `playerName` (obrigatório): string.
  - `skillOrType` (obrigatório):
    - `level` (prefixo `l`)
    - `magic` (prefixo `m`)
    - skills mapeadas: `club`, `sword`, `axe`, `dist`, `shield`, `fish`
    - fallback interno: qualquer outro valor cai em `fist`.
  - `amount` (opcional): inteiro positivo (default: `1`).

### `/addmount <playerName>, <mountId|all>`
- Sintaxe: `/addmount <playerName>, <mountId|all>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
  - `mountIdOrAll` (obrigatório): enum `all` ou inteiro.
- Enum:
  - `all` => adiciona `1..231`.

### `/addbadge <playerName>, <badgeId>`
- Sintaxe: `/addbadge <playerName>, <badgeId>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
  - `badgeId` (obrigatório): inteiro.

### `/addtitle <playerName>, <titleId>`
- Sintaxe: `/addtitle <playerName>, <titleId>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
  - `titleId` (obrigatório): inteiro.

### `/settitle <playerName>, <titleId>`
- Sintaxe: `/settitle <playerName>, <titleId>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
  - `titleId` (obrigatório): inteiro.

### `/addtutor <playerName>`
- Sintaxe: `/addtutor <playerName>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
- Comportamento:
  - promove somente `ACCOUNT_TYPE_NORMAL` para `ACCOUNT_TYPE_TUTOR`.

### `/removetutor <playerName>`
- Sintaxe: `/removetutor <playerName>`
- Parâmetros:
  - `playerName` (obrigatório): string (online).
- Comportamento:
  - rebaixa somente `ACCOUNT_TYPE_TUTOR` para `ACCOUNT_TYPE_NORMAL`.

### `/raid <raidName>`
- Sintaxe: `/raid <raidName>`
- Parâmetros:
  - `raidName` (obrigatório): string.
- Comportamento:
  - tenta iniciar via `Raid.registry[raidName]` ou `Game.startRaid(raidName)`.

### `/listraid`
- Sintaxe: `/listraid`
- Parâmetros: nenhum.
- Saída: lista de raids registradas em runtime.

## Recomendações para prompt de LLM
- Sempre validar pré-condição antes de sugerir comando (ex.: alvo online, quantidade > 0, reason não vazia).
- Preferir comandos determinísticos em vez de aleatórios quando houver alternativa (`/goto` em vez de `/active`).
- Para comandos com lookup por nome, orientar uso de nome completo.
- Para `/setkv`, enviar valores já tipados corretamente (string com aspas, boolean sem aspas, número literal).
