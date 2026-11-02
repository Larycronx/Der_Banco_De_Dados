# Testes SQL

Esta pasta reúne o executor do ciclo de teste, as asserções automatizadas e consultas diagnósticas de normalização. Os caminhos neste guia são relativos à raiz do repositório.

- `run_tests.sh` executa, em ordem, o DDL, os dados fictícios e as asserções. Use somente em um **banco de teste vazio**: o DDL não recria tabelas existentes e o script de exemplos não é idempotente.
- `test_integridade.sql` verifica 21 tabelas, 21 PKs, 21 FKs, duas restrições `UNIQUE`, as quantidades de exemplos, a validação das FKs e alguns totais e saldos demonstrativos.
- `diagnostico_normalizacao.sql` contém consultas de apoio para investigar 1FN, 2FN e 3FN. Elas não certificam formas normais automaticamente.

## Executar o ciclo completo

É necessário ter PostgreSQL instalado ou acesso a uma instância de teste, além do cliente `psql`. Crie um banco vazio, por exemplo `erp_teste`, e, na raiz do repositório, rode:

```bash
DATABASE_URL='postgresql://postgres:SUA_SENHA@localhost:5432/erp_teste' ./sql/tests/run_tests.sh
```

O executor cria as tabelas, insere os exemplos e roda as asserções. Se uma verificação falhar, o `psql` para no primeiro erro. Para repetir o ciclo do zero, use outro banco vazio ou apague e recrie o banco de teste. Não use um banco com dados que queira preservar.

As consultas de normalização são executadas separadamente, após o ciclo completo:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -P pager=off \
  -f sql/tests/diagnostico_normalizacao.sql
```

## Executar pelo pgAdmin

Crie e selecione um banco de teste vazio. Abra o Query Tool e execute, nessa ordem, os arquivos `sql/schema/der.sql`, `sql/examples/dados_exemplo_erp.sql` e `sql/tests/test_integridade.sql`. Em seguida, se desejar, execute `sql/tests/diagnostico_normalizacao.sql`.

Se houver erro, procure a primeira mensagem de falha. Mensagens `current transaction is aborted` que aparecem depois normalmente são consequência do erro original. Execute `ROLLBACK;` antes de tentar novamente. Não reexecute o seed sobre os mesmos registros: ele usa IDs fixos de demonstração.

## Interpretar os diagnósticos

Algumas consultas podem retornar linhas candidatas a análise; outras podem retornar zero linhas. Uma amostra sem duplicidades ou divergências não prova uma regra para todos os dados ou processos. Confirme as dependências funcionais e regras reais com o grupo — por exemplo, o significado de `preco_unitario`, a regra de `COMPRA.valor_total`, se `cnpj` precisa ser único e como são garantidas as participações mínimas entre entidades.

O seed contém somente registros fictícios. As verificações testam o DDL e esses registros; não testam dados reais nem certificam 1FN, 2FN ou 3FN do ERP completo.

## Resultado registrado

Em 02/11/2026, o ciclo foi executado em PostgreSQL 16.15 num banco isolado. Passaram as verificações das 21 tabelas, das 21 PKs, das 21 FKs, das duas restrições `UNIQUE`, das contagens esperadas e da consistência demonstrativa dos totais de compras e vendas e dos saldos de estoque. O arquivo de diagnóstico também foi executado sem erro; seus resultados são exploratórios e dependem da interpretação das regras de negócio.
