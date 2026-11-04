# DER — Sistema de Gestão Comercial

Modelo lógico de dados para apoiar a gestão comercial de uma empresa de moda automotiva e streetwear. O projeto reúne o diagrama Entidade-Relacionamento (DER), o DDL MySQL, dados fictícios para teste e consultas de validação.

[Diagrama renderizado](model/der.png) · [Fonte Mermaid](model/der.mmd) · [DDL MySQL](sql/schema/der.sql) · [Guia de testes](sql/tests/README.md)

## Organização do repositório

```text
.
├── README.md
├── model/
│   ├── der.mmd                   # Fonte Mermaid do DER
│   └── der.png                   # Diagrama renderizado
└── sql/
    ├── schema/
    │   ├── der.sql               # DDL MySQL: tabelas, ENUMs e restrições
    │   └── migracao_enums.sql    # Migração de esquema MySQL anterior
    ├── examples/
    │   └── dados_exemplo_erp.sql # Registros fictícios para demonstração
    └── tests/
        ├── README.md             # Instruções e resultado de execução
        ├── run_tests.sh          # Carrega os scripts e roda as asserções
        ├── test_integridade.sql  # Verificações automatizadas
        └── diagnostico_normalizacao.sql # Consultas diagnósticas
```

O diretório `model/` contém os artefatos do diagrama. A pasta `sql/schema/` contém a definição do banco; `sql/examples/` guarda os inserts fictícios; e `sql/tests/` reúne os testes, diagnósticos e instruções de execução.

## MySQL e tipos ENUM

O esquema usa ENUM inline nas colunas `produto.categoria`, `produto.tamanho`, `produto.cor`, `movimentacao_estoque.tipo_movimentacao`, `compra.status_compra`, `venda.status_venda`, `conta_pagar.status_conta_pagar`, `conta_receber.status_conta_receber`, `pedido_producao.etapa_producao` e `pedido_producao.status_producao`. O MySQL declara os rótulos dentro da própria coluna ENUM; não há `CREATE TYPE` separado.

As opções vêm dos valores encontrados no seed do repositório: categoria (`Camiseta`, `Jaqueta`, `Acessorio`); tamanho (`M`, `G`, `Unico`); cor (`Preta`, `Azul`, `Preto`); movimentação (`ENTRADA`, `SAIDA`); compra (`RECEBIDA`); venda (`FINALIZADA`); conta a pagar (`PENDENTE`); conta a receber (`RECEBIDA`); etapa (`Corte e costura`); produção (`EM_ANDAMENTO`). Alguns domínios têm apenas um rótulo porque os exemplos só mostram um estado. Valide com a equipe e amplie a lista antes de inserir outros valores. O executor ativa `STRICT_ALL_TABLES` para que valores inválidos em ENUM não sejam convertidos silenciosamente em string vazia. [Manual MySQL: ENUM](https://dev.mysql.com/doc/refman/8.4/en/enum.html)

`fornecedor.razao_social` permanece `VARCHAR(255)`, pois é um nome livre e não um catálogo fechado. Valores monetários foram representados como `DECIMAL(12,2)`. As datas e horas do antigo modelo sem fuso horário usam `DATETIME` no MySQL.

## Executar em MySQL

Use MySQL 8.0 ou superior e um banco de teste vazio. Configure suas credenciais no `mysql_config_editor` ou em `~/.my.cnf` com permissão restrita (`chmod 600 ~/.my.cnf`). Crie o banco:

```bash
mysql -e "CREATE DATABASE erp_teste CHARACTER SET utf8mb4;"
```

Na raiz do repositório, rode o ciclo de criação, seed e testes:

```bash
MYSQL_DATABASE=erp_teste ./sql/tests/run_tests.sh
```

O executor usa `mysql` e importa os scripts na mesma sessão. O script de exemplo não é idempotente e os IDs são fixos; não rode num banco que contenha dados a preservar. Se o DDL falhar no meio, remova e recrie o banco de teste antes de repetir. Para rodar somente as consultas diagnósticas depois:

```bash
mysql erp_teste < sql/tests/diagnostico_normalizacao.sql
```

No MySQL Workbench, crie e selecione um banco vazio, depois abra e execute, nesta ordem, `sql/schema/der.sql`, `sql/examples/dados_exemplo_erp.sql` e `sql/tests/test_integridade.sql`. Em Workbench, execute o arquivo completo para que o comando `DELIMITER` crie a rotina de teste corretamente. O diagnóstico pode ser executado depois.

`sql/schema/migracao_enums.sql` serve somente para atualizar uma base **MySQL** criada com a versão anterior do esquema. Faça backup antes de usar. Ela não converte nem executa no PostgreSQL. Para dados que ainda estejam em PostgreSQL, faça uma exportação/importação separada para uma base MySQL criada com o DDL deste repositório.

## O que a suíte verifica

A rotina de teste confere as 21 tabelas, 21 PKs, 21 FKs, duas restrições `UNIQUE`, os dez campos ENUM e seus rótulos, a contagem de registros fictícios e cálculos de compras, vendas e estoque. As FKs são aplicadas pelas tabelas InnoDB. [Manual MySQL: chaves estrangeiras](https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html)

Os testes verificam o esquema e os dados fictícios. Eles não certificam automaticamente 1FN, 2FN ou 3FN do sistema real. As consultas diagnósticas ajudam a investigar dependências e precisam ser interpretadas à luz das regras de negócio. Em 04/11/2026, o ciclo completo passou em MySQL 8.0.46 numa base nova; a migração de uma base MySQL legada de teste e as consultas diagnósticas também foram executadas sem erro. O modo estrito rejeitou um rótulo ENUM inválido no teste.

## Escopo do modelo

O DER contém 21 entidades:

| Entidade | Finalidade representada |
| --- | --- |
| `FORNECEDOR` | Dados de fornecedores. |
| `COMPRA` | Compras realizadas. |
| `ITEM_COMPRA` | Produtos, quantidades e custos de cada compra. |
| `PRODUTO` | Produtos comercializados ou produzidos. |
| `ESTOQUE` | Saldo atual e estoque mínimo por produto. |
| `MOVIMENTACAO_ESTOQUE` | Entradas, saídas e ajustes de estoque. |
| `PEDIDO_PRODUCAO` | Ordens de produção e seus dados operacionais. |
| `ITEM_PEDIDO_PRODUCAO` | Produtos e quantidades por ordem de produção. |
| `CLIENTE` | Dados dos clientes. |
| `CANAL_VENDA` | Canais utilizados nas vendas. |
| `VENDA` | Registros de vendas. |
| `VENDA_SITE` | Dados de entrega de vendas realizadas pelo site. |
| `ITEM_VENDA` | Produtos, quantidades e descontos por venda. |
| `EVENTO` | Eventos comerciais. |
| `CUSTO_EVENTO` | Custos associados a eventos. |
| `PROMOCAO` | Períodos, tipos e valores de promoções. |
| `ITEM_PROMOCAO` | Produtos abrangidos por promoções. |
| `CONTA_PAGAR` | Obrigações financeiras e parcelas associadas a compras. |
| `CONTA_RECEBER` | Valores a receber e parcelas associadas a vendas. |
| `PERFIL_ACESSO` | Perfis de acesso. |
| `USUARIO` | Usuários e seus perfis de acesso. |

O modelo representa compras e vendas por tabelas de itens, associa produtos a promoções, relaciona custos a eventos e permite parcelas a pagar e a receber. `VENDA_SITE` é modelada como extensão opcional de `VENDA`; essa cardinalidade ainda deve ser confirmada com as regras reais da empresa.

As participações mínimas — por exemplo, uma compra ter ao menos um item — são representadas no diagrama, mas não são todas garantidas pelas FKs do DDL. Valide também o significado de `preco_unitario` e a regra de cálculo ou armazenamento de `COMPRA.valor_total` antes de tratar o modelo como definitivo.

## Evidências

O repositório contém os scripts necessários para reproduzir os testes no MySQL. Rode-os em uma base descartável e preserve suas cópias de segurança antes de aplicar mudanças em outra instância.
