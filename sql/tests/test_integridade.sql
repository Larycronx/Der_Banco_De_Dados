-- Testes MySQL 8 para o DDL e os registros fictícios do projeto.
-- Pré-requisito: executar sql/schema/der.sql e sql/examples/dados_exemplo_erp.sql
-- em um banco de teste vazio, com modo SQL estrito habilitado.
-- Este arquivo valida estrutura e exemplos; não certifica 1FN/2FN/3FN.

DROP PROCEDURE IF EXISTS test_integridade;
DELIMITER //
CREATE PROCEDURE test_integridade()
BEGIN
    DECLARE actual_count BIGINT DEFAULT 0;
    DECLARE issue_count BIGINT DEFAULT 0;

    SELECT COUNT(*) INTO actual_count
      FROM information_schema.tables
     WHERE table_schema = DATABASE()
       AND table_type = 'BASE TABLE'
       AND table_name IN (
            'fornecedor', 'produto', 'cliente', 'canal_venda', 'evento', 'promocao',
            'perfil_acesso', 'compra', 'item_compra', 'estoque', 'movimentacao_estoque',
            'venda', 'item_venda', 'venda_site', 'custo_evento', 'item_promocao',
            'conta_pagar', 'conta_receber', 'pedido_producao',
            'item_pedido_producao', 'usuario'
       );
    IF actual_count <> 21 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esperadas 21 tabelas do modelo no banco atual.';
    END IF;

    SELECT COUNT(*) INTO actual_count
      FROM information_schema.table_constraints
     WHERE constraint_schema = DATABASE()
       AND constraint_type = 'PRIMARY KEY'
       AND table_name IN (
            'fornecedor', 'produto', 'cliente', 'canal_venda', 'evento', 'promocao',
            'perfil_acesso', 'compra', 'item_compra', 'estoque', 'movimentacao_estoque',
            'venda', 'item_venda', 'venda_site', 'custo_evento', 'item_promocao',
            'conta_pagar', 'conta_receber', 'pedido_producao',
            'item_pedido_producao', 'usuario'
       );
    IF actual_count <> 21 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esperadas 21 chaves primarias.';
    END IF;

    SELECT COUNT(*) INTO actual_count
      FROM information_schema.table_constraints
     WHERE constraint_schema = DATABASE()
       AND constraint_type = 'FOREIGN KEY';
    IF actual_count <> 21 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esperadas 21 chaves estrangeiras.';
    END IF;

    SELECT COUNT(*) INTO actual_count
      FROM information_schema.table_constraints
     WHERE constraint_schema = DATABASE()
       AND constraint_type = 'UNIQUE';
    IF actual_count <> 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esperadas duas restricoes UNIQUE.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
         WHERE constraint_schema = DATABASE()
           AND table_name = 'estoque'
           AND constraint_name = 'uq_estoque_produto'
           AND constraint_type = 'UNIQUE'
    ) OR NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
         WHERE constraint_schema = DATABASE()
           AND table_name = 'venda_site'
           AND constraint_name = 'uq_venda_site_venda'
           AND constraint_type = 'UNIQUE'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uma restricao UNIQUE esperada esta ausente.';
    END IF;

    SELECT COUNT(*) INTO issue_count
      FROM (
        SELECT 'fornecedor' AS table_name, COUNT(*) AS actual_rows, 2 AS expected_rows FROM fornecedor
        UNION ALL SELECT 'produto', COUNT(*), 3 FROM produto
        UNION ALL SELECT 'cliente', COUNT(*), 2 FROM cliente
        UNION ALL SELECT 'canal_venda', COUNT(*), 2 FROM canal_venda
        UNION ALL SELECT 'evento', COUNT(*), 1 FROM evento
        UNION ALL SELECT 'promocao', COUNT(*), 1 FROM promocao
        UNION ALL SELECT 'perfil_acesso', COUNT(*), 1 FROM perfil_acesso
        UNION ALL SELECT 'compra', COUNT(*), 2 FROM compra
        UNION ALL SELECT 'item_compra', COUNT(*), 3 FROM item_compra
        UNION ALL SELECT 'estoque', COUNT(*), 3 FROM estoque
        UNION ALL SELECT 'movimentacao_estoque', COUNT(*), 6 FROM movimentacao_estoque
        UNION ALL SELECT 'venda', COUNT(*), 2 FROM venda
        UNION ALL SELECT 'item_venda', COUNT(*), 3 FROM item_venda
        UNION ALL SELECT 'venda_site', COUNT(*), 1 FROM venda_site
        UNION ALL SELECT 'custo_evento', COUNT(*), 2 FROM custo_evento
        UNION ALL SELECT 'item_promocao', COUNT(*), 2 FROM item_promocao
        UNION ALL SELECT 'conta_pagar', COUNT(*), 2 FROM conta_pagar
        UNION ALL SELECT 'conta_receber', COUNT(*), 2 FROM conta_receber
        UNION ALL SELECT 'pedido_producao', COUNT(*), 1 FROM pedido_producao
        UNION ALL SELECT 'item_pedido_producao', COUNT(*), 2 FROM item_pedido_producao
        UNION ALL SELECT 'usuario', COUNT(*), 1 FROM usuario
      ) AS table_counts
     WHERE actual_rows <> expected_rows;
    IF issue_count <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'As quantidades de registros de exemplo nao correspondem ao esperado.';
    END IF;

    SELECT COUNT(*) INTO issue_count
      FROM (
        SELECT 'produto' AS table_name, 'categoria' AS column_name, 'enum(''Camiseta'',''Jaqueta'',''Acessorio'')' AS expected_type
        UNION ALL SELECT 'produto', 'tamanho', 'enum(''M'',''G'',''Unico'')'
        UNION ALL SELECT 'produto', 'cor', 'enum(''Preta'',''Azul'',''Preto'')'
        UNION ALL SELECT 'movimentacao_estoque', 'tipo_movimentacao', 'enum(''ENTRADA'',''SAIDA'')'
        UNION ALL SELECT 'compra', 'status_compra', 'enum(''RECEBIDA'')'
        UNION ALL SELECT 'venda', 'status_venda', 'enum(''FINALIZADA'')'
        UNION ALL SELECT 'conta_pagar', 'status_conta_pagar', 'enum(''PENDENTE'')'
        UNION ALL SELECT 'conta_receber', 'status_conta_receber', 'enum(''RECEBIDA'')'
        UNION ALL SELECT 'pedido_producao', 'etapa_producao', 'enum(''Corte e costura'')'
        UNION ALL SELECT 'pedido_producao', 'status_producao', 'enum(''EM_ANDAMENTO'')'
      ) AS expected_enums
      LEFT JOIN information_schema.columns AS actual_columns
        ON actual_columns.table_schema = DATABASE()
       AND actual_columns.table_name = expected_enums.table_name
       AND actual_columns.column_name = expected_enums.column_name
     WHERE actual_columns.column_name IS NULL
        OR actual_columns.data_type <> 'enum'
        OR CAST(actual_columns.column_type AS BINARY) <> CAST(expected_enums.expected_type AS BINARY);
    IF issue_count <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alguma coluna ENUM ou lista de rotulos difere do modelo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
         WHERE table_schema = DATABASE()
           AND table_name = 'fornecedor'
           AND column_name = 'razao_social'
           AND data_type = 'varchar'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fornecedor.razao_social deve continuar VARCHAR livre.';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM compra AS c
          JOIN item_compra AS i ON i.id_compra = c.id_compra
         WHERE c.id_compra IN (9071, 9072)
         GROUP BY c.id_compra, c.valor_total
        HAVING c.valor_total <> SUM(i.quantidade * i.custo_unitario)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total da compra de exemplo diverge da soma dos itens.';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM venda AS v
          JOIN item_venda AS iv ON iv.id_venda = v.id_venda
          JOIN produto AS p ON p.id_produto = iv.id_produto
         WHERE v.id_venda IN (9101, 9102)
         GROUP BY v.id_venda, v.valor_total
        HAVING v.valor_total <> SUM(iv.quantidade * p.preco_venda)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total da venda de exemplo diverge dos itens; teste assume desconto zero.';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM estoque AS e
          JOIN (
                SELECT id_produto,
                       SUM(CASE
                               WHEN tipo_movimentacao = 'ENTRADA' THEN quantidade
                               WHEN tipo_movimentacao = 'SAIDA' THEN -quantidade
                               ELSE 0
                           END) AS calculated_balance
                  FROM movimentacao_estoque
                 WHERE id_produto IN (9011, 9012, 9013)
                 GROUP BY id_produto
          ) AS m ON m.id_produto = e.id_produto
         WHERE e.id_produto IN (9011, 9012, 9013)
           AND e.quantidade_atual <> m.calculated_balance
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo de estoque diverge das movimentacoes de exemplo.';
    END IF;
END//
DELIMITER ;

CALL test_integridade();
DROP PROCEDURE test_integridade;
SELECT 'Todos os testes de integridade passaram.' AS resultado;
