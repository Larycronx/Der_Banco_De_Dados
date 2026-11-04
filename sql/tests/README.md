# Testes SQL para MySQL

Esta pasta reúne o executor do ciclo de teste, as asserções automatizadas e consultas diagnósticas. Os caminhos são relativos à raiz do repositório.

- `run_tests.sh` executa o DDL MySQL, os dados fictícios e os testes numa única sessão do cliente `mysql`. Use somente em um banco de teste vazio.
- `test_integridade.sql` verifica 21 tabelas, 21 chaves primárias, 21 chaves estrangeiras, duas restrições `UNIQUE`, 10 colunas ENUM e seus rótulos, contagens dos dados fictícios e totais demonstrativos.
- `diagnostico_normalizacao.sql` reúne consultas MySQL de apoio para investigar 1FN, 2FN e 3FN; não certifica formas normais.
- `sql/schema/migracao_enums.sql` atualiza uma versão anterior do esquema que já esteja em MySQL. Ela não serve para executar nem converter uma base PostgreSQL.

## Executar o ciclo numa base nova

É necessário ter MySQL 8.0 ou superior e o cliente `mysql`. Configure as credenciais por `mysql_config_editor` ou em `~/.my.cnf` com permissões restritas. Crie uma base de teste vazia:

```bash
mysql -e "CREATE DATABASE erp_teste CHARACTER SET utf8mb4;"
```

Na raiz do repositório, execute:

```bash
MYSQL_DATABASE=erp_teste ./sql/tests/run_tests.sh
```

O executor ativa `STRICT_ALL_TABLES`, para que a tentativa de gravar um valor não declarado em ENUM gere erro em vez de produzir a string vazia de erro do MySQL. A carga de exemplos usa IDs fixos e não é idempotente. Não rode num banco com dados que queira preservar.

O DDL contém operações `CREATE TABLE`; se a execução parar no meio, o MySQL pode já ter criado parte das tabelas. Para repetir do zero, apague e recrie somente a base de teste descartável. Não aplique essa ação numa base de trabalho.

## Executar pelo MySQL Workbench

Crie e selecione uma base vazia. Execute por inteiro, nesta ordem, `sql/schema/der.sql`, `sql/examples/dados_exemplo_erp.sql` e `sql/tests/test_integridade.sql`. O arquivo de teste cria e chama uma procedure; rode-o como script completo para que o cliente reconheça os comandos `DELIMITER`. Depois, se desejar, execute `sql/tests/diagnostico_normalizacao.sql`.

## Atualizar uma base existente

Faça backup e confirme a origem da base antes de qualquer alteração. `sql/schema/migracao_enums.sql` contém instruções `ALTER TABLE` para uma base MySQL que tenha sido criada com a versão anterior desse esquema. Ela é uma migração de MySQL para MySQL, não um conversor entre mecanismos. Para dados que ainda estejam no PostgreSQL, exporte-os e importe-os separadamente numa base MySQL criada com o DDL atual. Confira tipos, datas, ENUMs e chaves estrangeiras após a importação.

O MySQL declara os valores de ENUM inline na coluna. Os rótulos atualmente presentes nos exemplos foram mantidos; alguns estados têm uma única opção porque só aparecem dessa forma no seed. Confirme todos os estados e etapas válidos com o negócio antes de ampliar ou usar os tipos em dados reais.

## Interpretar os diagnósticos

Resultados vazios ou sem duplicidades não provam uma dependência funcional. Uma amostra pequena pode não revelar variações. Confirme as regras reais com a equipe, como o significado de `preco_unitario`, o cálculo de `COMPRA.valor_total`, a unicidade de `cnpj` e as participações mínimas das entidades.

O seed contém somente registros fictícios. Os testes verificam o DDL e esses exemplos, não dados reais nem a normalização completa do ERP.

## Documentação MySQL

- [Tipo ENUM](https://dev.mysql.com/doc/refman/8.4/en/enum.html)
- [Chaves estrangeiras](https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html)
- [Tipos de dados](https://dev.mysql.com/doc/refman/8.4/en/data-types.html)

## Resultado desta versão

Em 04/11/2026, o ciclo completo passou em MySQL 8.0.46 numa base de teste nova. A migração foi executada com sucesso numa base MySQL legada isolada, preservando os valores e aplicando as 10 colunas ENUM. O arquivo de diagnóstico também foi executado sem erro, e um rótulo ENUM inválido foi rejeitado sob modo estrito. Os resultados abrangem apenas esse esquema e os registros fictícios do projeto.
