# Testes SQL

Esta pasta reúne o executor do ciclo de teste, as asserções automatizadas e consultas diagnósticas de normalização. Os caminhos neste guia são relativos à raiz do repositório.

- `run_tests.sh` executa, em ordem, o DDL, os dados fictícios e as asserções. Use somente em um **banco de teste vazio**: o DDL não recria tabelas existentes e o script de exemplos não é idempotente.
- `test_integridade.sql` verifica 21 tabelas, 21 PKs, 21 FKs, duas restrições `UNIQUE`, 10 tipos ENUM e rótulos esperados, as quantidades dos exemplos, referências e cálculos selecionados.
- `diagnostico_normalizacao.sql` contém consultas de apoio para investigar 1FN, 2FN e 3FN. Elas não certificam formas normais automaticamente.
- `sql/schema/migracao_enums.sql` converte uma base existente que tenha sido criada com o DDL anterior aos ENUMs. Não execute essa migração numa base nova criada com o DDL atual.

## Executar o ciclo completo em uma base nova

É necessário ter PostgreSQL e o cliente `psql`. Crie um banco de teste vazio, por exemplo `erp_teste`, e, na raiz do repositório, rode:

```bash
DATABASE_URL='postgresql://postgres:SUA_SENHA@localhost:5432/erp_teste' ./sql/tests/run_tests.sh
```

O executor cria as tabelas, insere os exemplos e roda as asserções. Se uma verificação falhar, o `psql` para no primeiro erro. Para repetir o ciclo do zero, use outro banco vazio ou apague e recrie o banco de teste. Não use um banco com dados que queira preservar.

## Converter uma base existente

Se a base já contém as tabelas da versão anterior do DDL, faça primeiro um backup e confira se os valores existentes correspondem aos rótulos do tipo ENUM. Execute `sql/schema/migracao_enums.sql` uma única vez nessa base. A conversão está dentro de uma transação: se algum valor não corresponder exatamente a um rótulo, o PostgreSQL interrompe a migração e a transação deve ser revertida com `ROLLBACK;`. Não rode o seed de exemplo como parte da migração.

A migração usa os rótulos vistos no seed atual. Eles são sensíveis a maiúsculas/minúsculas e acentos. Novos valores de categorias, tamanhos, cores, tipos de movimentação, estados e etapas precisam ser confirmados com as regras do negócio e incluídos no tipo ENUM antes de serem usados.

Para uma base existente, depois de confirmar um novo rótulo, o PostgreSQL permite acrescentá-lo, por exemplo: `ALTER TYPE cor_produto_enum ADD VALUE 'Verde';`. Atualize também o `CREATE TYPE` correspondente em `sql/schema/der.sql`, o script de migração se ele ainda for necessário para outra base antiga, os testes e o Mermaid. Rode os testes numa base isolada depois da mudança.

`fornecedor.razao_social` permanece `TEXT`: nomes legais de empresas são dados livres, não opções fixas de um catálogo. A coluna `compra.status` mantém seu nome. As colunas de contas e produção usam os nomes explícitos `status_conta`, `status_conta_receber` e `status_producao`, alinhados ao DER; cada uma usa seu tipo ENUM específico.

## Executar pelo pgAdmin

Para uma base nova e vazia, abra o Query Tool e execute, nessa ordem, `sql/schema/der.sql`, `sql/examples/dados_exemplo_erp.sql` e `sql/tests/test_integridade.sql`. Em seguida, se desejar, execute `sql/tests/diagnostico_normalizacao.sql`.

Se houver erro, procure a primeira mensagem de falha. Mensagens `current transaction is aborted` que aparecem depois normalmente são consequência do erro original. Execute `ROLLBACK;` antes de tentar novamente. Não reexecute o seed sobre os mesmos registros: ele usa IDs fixos de demonstração.

## Interpretar os diagnósticos

Algumas consultas podem retornar linhas candidatas a análise; outras podem retornar zero linhas. Uma amostra sem duplicidades ou divergências não prova uma regra para todos os dados ou processos. Confirme as dependências funcionais e regras reais com o grupo — por exemplo, o significado de `preco_unitario`, a regra de `COMPRA.valor_total`, se `cnpj` precisa ser único e como são garantidas as participações mínimas entre entidades.

O seed contém somente registros fictícios. As verificações testam o DDL e esses registros; não testam dados reais nem certificam 1FN, 2FN ou 3FN do ERP completo.

## Resultado registrado

Em 02/11/2026, a versão anterior foi executada em PostgreSQL 16.15 num banco isolado. Em 03/11/2026, a versão atual foi testada em PostgreSQL 16.15 por dois caminhos: criação completa em banco novo pelo runner e conversão de uma base com o DDL anterior, seed e asserções atualizadas. Nos dois caminhos, passaram as contagens de tabelas/chaves, os 10 ENUMs e rótulos esperados, as referências, as quantidades de exemplos e os cálculos de compra, venda e estoque. As consultas de diagnóstico também rodaram sem erro nas duas bases; elas são exploratórias e não certificam formas normais.
