# Kingdom of Pets - Bootstrap de Instancia Canary

## Objetivo
Subir uma instancia nova e separada do servidor (`Kingdom of Pets`) a partir da base Canary, com banco dedicado.

## 1) Clonar/copiar para novo diretorio
```bash
cd /home/jp/Documentos/github
cp -a canary kingdom-pets
cd kingdom-pets
```

## 2) Branch de trabalho
```bash
git switch -c feat/game-pets
```

## 3) Banco dedicado
1. Execute o bootstrap SQL como root/admin:
```bash
mysql -u root -p < docs/pet/kingdom_pets_db_bootstrap.sql
```
2. Importe o schema no banco novo:
```bash
mysql -u canary -p -h 127.0.0.1 kingdom_pets < schema.sql
```

## 4) Configuracao do servidor
No `config.lua`:
- `serverName = "Kingdom of Pets"`
- `mysqlUser = "canary"`
- `mysqlDatabase = "kingdom_pets"`
- `dataPackDirectory = "data-pet"`

## 5) Subir servidor
```bash
./start.sh
```

## 6) Contas iniciais no schema
- conta GOD: `god` (admin)
- conta de testes: `invocador_samples`
- personagens de testes do invocador: levels `1, 10, 50, 100, 300, 500, 1000`

## 7) Escopo MVP de conteudo
- 10 pets fechados em `data-pet/monster/pet`
- cada um com 3 magias unicas
- backlog restante (`PET-011..PET-235`) fica para pos-MVP
