# Testes do SQL

Esta pasta contém testes reproduzíveis para o DDL e os registros fictícios do projeto.

- `run_tests.sh`: executa, em ordem, o DDL, os dados fictícios e as asserções automatizadas. Use somente em um **banco de teste vazio**, porque o DDL não recria tabelas existentes e o arquivo de exemplos não é idempotente.
- `test_integridade.sql`: verifica a presença das 21 tabelas, 21 PKs, 21 FKs e duas restrições UNIQUE, as quantidades de exemplo, o estado validado das FKs e os cálculos demonstrativos de compras, vendas e estoque.
- `diagnostico_normalizacao.sql`: consultas para apoiar a investigação de 1FN, 2FN e 3FN. Elas não certificam formas normais automaticamente.

## Rodar o ciclo completo

É necessário ter PostgreSQL instalado ou acesso a uma instância PostgreSQL de teste, além do cliente `psql`. Crie um banco vazio, por exemplo `erp_teste`, e rode a partir da raiz do repositório:

```bash
DATABASE_URL='postgresql://postgres:SUA_SENHA@localhost:5432/erp_teste' ./tests/run_tests.sh
```

O script cria as tabelas, insere os exemplos e executa as asserções. Se um teste falhar, o `psql` para no primeiro erro e informa a mensagem. Para repetir do zero, use outro banco vazio ou apague e recrie o banco de teste antes da execução. Não rode este procedimento num banco com dados que queira preservar.

No pgAdmin, crie e selecione um banco de teste vazio. Abra o Query Tool e execute, nessa ordem, o conteúdo de `DER/der.sql`, `exemplo/dados_exemplo_erp.sql` e `tests/test_integridade.sql`. Para as consultas diagnósticas, abra e execute também `tests/diagnostico_normalizacao.sql`. Se houver erro, leia a primeira mensagem de erro; mensagens `current transaction is aborted` que apareçam depois são consequência do primeiro erro. Se necessário, execute `ROLLBACK;` antes de continuar.

Também é possível executar os passos manualmente:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f DER/der.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f exemplo/dados_exemplo_erp.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f tests/test_integridade.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f tests/diagnostico_normalizacao.sql
```

O último arquivo é diagnóstico: algumas consultas podem retornar linhas com problemas candidatos, enquanto outras podem não retornar nada. A ausência de resultados não comprova a regra para todos os dados ou processos.

## O que os testes significam

As asserções automatizadas verificam que os scripts criaram e carregaram corretamente os exemplos esperados e que alguns totais e saldos de demonstração estão coerentes. Elas **não** provam 1FN, 2FN ou 3FN para todo o ERP. Para essa avaliação, é necessário confirmar com o grupo as dependências funcionais e regras reais — por exemplo, o significado de `preco_unitario`, a regra de `COMPRA.valor_total`, se `cnpj` deve ser único e as participações mínimas entre entidades.

Todos os registros do seed são fictícios e servem apenas para testes.

## Resultado da execução desta versão

Validado em PostgreSQL 16.15, em banco de teste isolado, em 2026-11-02: as verificações passaram, incluindo as 21 tabelas, 21 PKs, 21 FKs, duas restrições UNIQUE, contagem dos registros, validação das FKs, totais de compra/venda e saldo de estoque. O arquivo `diagnostico_normalizacao.sql` também foi executado sem erro; suas consultas são exploratórias e não aprovam nem reprovam formalmente uma forma normal.
