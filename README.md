# DER — Sistema de Gestão Comercial

Modelo lógico de dados para apoiar a gestão comercial de uma empresa de moda automotiva e streetwear. O projeto reúne o diagrama Entidade-Relacionamento (DER), o DDL PostgreSQL, dados fictícios para teste e consultas de validação.

[Diagrama renderizado](model/der.png) · [Fonte Mermaid](model/der.mmd) · [DDL PostgreSQL](sql/schema/der.sql) · [Guia de testes](sql/tests/README.md)

## Organização do repositório

```text
.
├── README.md
├── model/
│   ├── der.mmd                   # Fonte Mermaid do DER
│   └── der.png                   # Diagrama renderizado
└── sql/
    ├── schema/
    │   ├── der.sql               # Criação das tabelas, ENUMs e restrições
    │   └── migracao_enums.sql    # Conversão da versão anterior do esquema
    ├── examples/
    │   └── dados_exemplo_erp.sql # Registros fictícios para demonstração
    └── tests/
        ├── README.md             # Instruções e resultado de execução
        ├── run_tests.sh          # Carrega os scripts e roda as asserções
        ├── test_integridade.sql  # Verificações automatizadas
        └── diagnostico_normalizacao.sql # Consultas diagnósticas
```

O diretório `model/` contém os artefatos do diagrama. A pasta `sql/schema/` contém a definição do banco; `sql/examples/` guarda os inserts fictícios; e `sql/tests/` reúne os testes, diagnósticos e instruções de execução.

## Tipos ENUM

O DDL usa ENUMs para `produto.categoria`, `produto.tamanho`, `produto.cor`, `movimentacao_estoque.tipo_movimentacao`, `compra.status`, `venda.status_venda`, `conta_pagar.status_conta`, `conta_receber.status_conta_receber`, além de `pedido_producao.etapa_atual` e `pedido_producao.status_producao`. No DDL, os dois últimos tipos se chamam `etapa_producao_enum` e `status_producao_enum`.

Os rótulos refletem somente valores encontrados no seed: categoria (`Camiseta`, `Jaqueta`, `Acessorio`); tamanho (`M`, `G`, `Unico`); cor (`Preta`, `Azul`, `Preto`); movimentação (`ENTRADA`, `SAIDA`); compra (`RECEBIDA`); venda (`FINALIZADA`); conta a pagar (`PENDENTE`); conta a receber (`RECEBIDA`); etapa (`Corte e costura`); produção (`EM_ANDAMENTO`). Alguns ENUMs têm apenas um rótulo porque o seed atual só demonstra um estado; a lista ainda precisa de validação de negócio. Os rótulos são sensíveis a maiúsculas/minúsculas e acentos.

`fornecedor.razao_social` permanece `TEXT`: nomes de empresas são valores livres, não uma lista fechada de opções. O arquivo `sql/schema/migracao_enums.sql` converte uma base criada com a versão anterior do DDL; use-o apenas nessa base antiga. Em um banco novo, execute `sql/schema/der.sql` pelo runner. Não aplique a migração depois de criar o banco com o novo DDL.

## Executar em PostgreSQL

Use um banco de teste vazio. O script de dados não é idempotente e os IDs de exemplo podem conflitar com registros já existentes. Com PostgreSQL e `psql` instalados, execute a partir da raiz do repositório:

```bash
DATABASE_URL='postgresql://postgres:SUA_SENHA@localhost:5432/erp_teste' ./sql/tests/run_tests.sh
```

O executor cria as tabelas, carrega os dados fictícios e executa as verificações de integridade. Para rodar as consultas de normalização depois desse ciclo:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -P pager=off \
  -f sql/tests/diagnostico_normalizacao.sql
```

No pgAdmin, selecione um banco de teste vazio e execute, nesta ordem, `sql/schema/der.sql`, `sql/examples/dados_exemplo_erp.sql` e `sql/tests/test_integridade.sql`. O arquivo `sql/tests/diagnostico_normalizacao.sql` pode ser executado depois. Se um comando falhar dentro de uma transação, consulte primeiro a mensagem de erro original; `current transaction is aborted` costuma ser uma consequência. Use `ROLLBACK;` para encerrar a transação abortada antes de continuar.

## O que a suíte verifica

Os testes automatizados conferem as 21 tabelas, 21 chaves primárias, 21 chaves estrangeiras, duas restrições `UNIQUE`, os 10 tipos ENUM e seus rótulos, as quantidades de registros fictícios e alguns totais e saldos demonstrativos. Em 03/11/2026, a suíte atual passou em PostgreSQL 16.15 tanto numa base nova quanto numa base criada com o DDL anterior e convertida pela migração. O resultado e os limites das consultas estão descritos em [`sql/tests/README.md`](sql/tests/README.md).

Esses testes verificam a estrutura e a consistência dos exemplos usados. Eles não certificam automaticamente 1FN, 2FN ou 3FN para todos os dados e regras do ERP. As consultas diagnósticas ajudam a investigar possíveis dependências; seus resultados precisam ser interpretados junto às regras de negócio.

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

O repositório contém os scripts necessários para reproduzir os testes. Uma captura antiga do pgAdmin não está incluída na árvore atual; use o executor e os resultados documentados na pasta `sql/tests/` para repetir as verificações num banco de teste.
