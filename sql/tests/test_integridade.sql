-- Testes automatizados para o DDL e os registros fictícios do projeto.
-- Pré-requisito: executar sql/schema/der.sql e sql/examples/dados_exemplo_erp.sql
-- em um banco de teste vazio.
-- Execute com psql -v ON_ERROR_STOP=1 -f sql/tests/test_integridade.sql.
-- Este arquivo valida a estrutura e a consistência dos exemplos; não certifica 1FN/2FN/3FN.

DO $$
DECLARE
    item RECORD;
    actual_count BIGINT;
    missing_tables TEXT;
    expected_tables TEXT[] := ARRAY[
        'fornecedor', 'produto', 'cliente', 'canal_venda', 'evento', 'promocao',
        'perfil_acesso', 'compra', 'item_compra', 'estoque', 'movimentacao_estoque',
        'venda', 'item_venda', 'venda_site', 'custo_evento', 'item_promocao',
        'conta_pagar', 'conta_receber', 'pedido_producao',
        'item_pedido_producao', 'usuario'
    ];
BEGIN
    SELECT string_agg(t.table_name, ', ' ORDER BY t.table_name)
      INTO missing_tables
      FROM unnest(expected_tables) AS t(table_name)
      LEFT JOIN information_schema.tables AS i
        ON i.table_schema = 'public'
       AND i.table_name = t.table_name
       AND i.table_type = 'BASE TABLE'
     WHERE i.table_name IS NULL;

    IF missing_tables IS NOT NULL THEN
        RAISE EXCEPTION 'Tabelas esperadas ausentes no schema public: %', missing_tables;
    END IF;

    RAISE NOTICE 'PASSOU: as 21 tabelas esperadas existem no schema public.';

    SELECT count(*) INTO actual_count
      FROM pg_constraint c
      JOIN pg_class r ON r.oid = c.conrelid
      JOIN pg_namespace n ON n.oid = r.relnamespace
     WHERE n.nspname = 'public'
       AND c.contype = 'p';
    IF actual_count <> 21 THEN
        RAISE EXCEPTION 'Esperadas 21 PKs no schema public; encontradas %', actual_count;
    END IF;

    SELECT count(*) INTO actual_count
      FROM pg_constraint c
      JOIN pg_class r ON r.oid = c.conrelid
      JOIN pg_namespace n ON n.oid = r.relnamespace
     WHERE n.nspname = 'public'
       AND c.contype = 'f';
    IF actual_count <> 21 THEN
        RAISE EXCEPTION 'Esperadas 21 FKs no schema public; encontradas %', actual_count;
    END IF;

    SELECT count(*) INTO actual_count
      FROM pg_constraint c
      JOIN pg_class r ON r.oid = c.conrelid
      JOIN pg_namespace n ON n.oid = r.relnamespace
     WHERE n.nspname = 'public'
       AND c.contype = 'u';
    IF actual_count <> 2 THEN
        RAISE EXCEPTION 'Esperadas 2 restrições UNIQUE no schema public; encontradas %', actual_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'uq_estoque_produto'
           AND contype = 'u'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'uq_venda_site_venda'
           AND contype = 'u'
    ) THEN
        RAISE EXCEPTION 'Uma ou mais restrições UNIQUE esperadas estão ausentes.';
    END IF;

    RAISE NOTICE 'PASSOU: 21 PKs, 21 FKs e 2 restrições UNIQUE do modelo estão declaradas.';

    FOR item IN
        SELECT * FROM (VALUES
            ('fornecedor', 2),
            ('produto', 3),
            ('cliente', 2),
            ('canal_venda', 2),
            ('evento', 1),
            ('promocao', 1),
            ('perfil_acesso', 1),
            ('compra', 2),
            ('item_compra', 3),
            ('estoque', 3),
            ('movimentacao_estoque', 6),
            ('venda', 2),
            ('item_venda', 3),
            ('venda_site', 1),
            ('custo_evento', 2),
            ('item_promocao', 2),
            ('conta_pagar', 2),
            ('conta_receber', 2),
            ('pedido_producao', 1),
            ('item_pedido_producao', 2),
            ('usuario', 1)
        ) AS expected(table_name, expected_count)
    LOOP
        EXECUTE format('SELECT count(*) FROM public.%I', item.table_name)
           INTO actual_count;
        IF actual_count <> item.expected_count THEN
            RAISE EXCEPTION 'Quantidade inesperada em %: esperado %, encontrado %',
                item.table_name, item.expected_count, actual_count;
        END IF;
    END LOOP;

    RAISE NOTICE 'PASSOU: quantidades esperadas de registros de exemplo nas 21 tabelas.';

    IF EXISTS (
        SELECT 1
          FROM pg_constraint c
          JOIN pg_class r ON r.oid = c.conrelid
          JOIN pg_namespace n ON n.oid = r.relnamespace
         WHERE n.nspname = 'public'
           AND c.contype = 'f'
           AND NOT c.convalidated
    ) THEN
        RAISE EXCEPTION 'Há chaves estrangeiras não validadas no schema public.';
    END IF;

    RAISE NOTICE 'PASSOU: todas as FKs declaradas no schema public estão validadas pelo PostgreSQL.';

    IF EXISTS (
        SELECT 1
          FROM compra c
          JOIN item_compra i USING (id_compra)
         WHERE c.id_compra IN (9071, 9072)
         GROUP BY c.id_compra, c.valor_total
        HAVING c.valor_total IS DISTINCT FROM SUM(i.quantidade * i.custo_unitario)
    ) THEN
        RAISE EXCEPTION 'Total da compra de exemplo diverge da soma dos itens.';
    END IF;

    RAISE NOTICE 'PASSOU: totais das compras de exemplo correspondem às quantidades × custos dos itens.';

    IF EXISTS (
        SELECT 1
          FROM venda v
          JOIN item_venda iv USING (id_venda)
          JOIN produto p USING (id_produto)
         WHERE v.id_venda IN (9101, 9102)
         GROUP BY v.id_venda, v.valor_total
        HAVING v.valor_total IS DISTINCT FROM SUM(iv.quantidade * p.preco_venda)
    ) THEN
        RAISE EXCEPTION 'Total da venda de exemplo diverge dos itens (o teste assume desconto zero nos exemplos).';
    END IF;

    RAISE NOTICE 'PASSOU: totais das vendas de exemplo correspondem aos itens com desconto zero.';

    IF EXISTS (
        SELECT 1
          FROM estoque e
          JOIN (
                SELECT id_produto,
                       SUM(CASE
                               WHEN upper(tipo_movimentacao) = 'ENTRADA' THEN quantidade
                               WHEN upper(tipo_movimentacao) = 'SAIDA' THEN -quantidade
                               ELSE 0
                           END) AS saldo_calculado
                  FROM movimentacao_estoque
                 WHERE id_produto IN (9011, 9012, 9013)
                 GROUP BY id_produto
          ) m USING (id_produto)
         WHERE e.id_produto IN (9011, 9012, 9013)
           AND e.quantidade_atual IS DISTINCT FROM m.saldo_calculado
    ) THEN
        RAISE EXCEPTION 'Saldo de estoque de exemplo diverge das movimentações de entrada e saída.';
    END IF;

    RAISE NOTICE 'PASSOU: saldos de estoque dos exemplos correspondem às movimentações.';
END;
$$;

SELECT 'Todos os testes de integridade passaram.' AS resultado;
