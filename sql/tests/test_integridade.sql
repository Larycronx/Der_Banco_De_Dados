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
                               WHEN tipo_movimentacao = 'ENTRADA' THEN quantidade
                               WHEN tipo_movimentacao = 'SAIDA' THEN -quantidade
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

DO $$
DECLARE
    item RECORD;
    actual_labels TEXT[];
BEGIN
    FOR item IN
        SELECT * FROM (VALUES
            ('produto', 'categoria', 'categoria_produto_enum', ARRAY['Camiseta', 'Jaqueta', 'Acessorio']::TEXT[]),
            ('produto', 'tamanho', 'tamanho_produto_enum', ARRAY['M', 'G', 'Unico']::TEXT[]),
            ('produto', 'cor', 'cor_produto_enum', ARRAY['Preta', 'Azul', 'Preto']::TEXT[]),
            ('movimentacao_estoque', 'tipo_movimentacao', 'tipo_movimentacao_enum', ARRAY['ENTRADA', 'SAIDA']::TEXT[]),
            ('compra', 'status', 'status_compra_enum', ARRAY['RECEBIDA']::TEXT[]),
            ('venda', 'status_venda', 'status_venda_enum', ARRAY['FINALIZADA']::TEXT[]),
            ('conta_pagar', 'status_conta', 'status_conta_pagar_enum', ARRAY['PENDENTE']::TEXT[]),
            ('conta_receber', 'status_conta_receber', 'status_conta_receber_enum', ARRAY['RECEBIDA']::TEXT[]),
            ('pedido_producao', 'etapa_atual', 'etapa_producao_enum', ARRAY['Corte e costura']::TEXT[]),
            ('pedido_producao', 'status_producao', 'status_producao_enum', ARRAY['EM_ANDAMENTO']::TEXT[])
        ) AS expected(table_name, column_name, type_name, enum_labels)
    LOOP
        IF NOT EXISTS (
            SELECT 1
              FROM information_schema.columns
             WHERE table_schema = 'public'
               AND table_name = item.table_name
               AND column_name = item.column_name
               AND data_type = 'USER-DEFINED'
               AND udt_name = item.type_name
        ) THEN
            RAISE EXCEPTION 'A coluna %.% não usa o ENUM %',
                item.table_name, item.column_name, item.type_name;
        END IF;

        SELECT array_agg(e.enumlabel ORDER BY e.enumsortorder)
          INTO actual_labels
          FROM pg_type t
          JOIN pg_enum e ON e.enumtypid = t.oid
          JOIN pg_namespace n ON n.oid = t.typnamespace
         WHERE n.nspname = 'public'
           AND t.typname = item.type_name;

        IF actual_labels IS DISTINCT FROM item.enum_labels THEN
            RAISE EXCEPTION 'Rótulos inesperados no ENUM %: esperado %, encontrado %',
                item.type_name, item.enum_labels, actual_labels;
        END IF;
    END LOOP;

    IF NOT EXISTS (
        SELECT 1
          FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name = 'fornecedor'
           AND column_name = 'razao_social'
           AND data_type = 'text'
    ) THEN
        RAISE EXCEPTION 'fornecedor.razao_social deve permanecer TEXT, não ENUM.';
    END IF;

    RAISE NOTICE 'PASSOU: os 10 tipos ENUM, suas colunas e seus rótulos correspondem ao modelo; razao_social permanece TEXT.';
END;
$$;

SELECT 'Todos os testes de integridade passaram.' AS resultado;
