-- Consultas diagnósticas para apoiar a revisão de 1FN, 2FN e 3FN.
-- Execute após DER/der.sql e exemplo/dados_exemplo_erp.sql.
-- Resultados vazios ou sem duplicidades NÃO provam normalização: as regras
-- funcionais precisam ser confirmadas com o negócio e os dados podem ser poucos.

-- 1FN — procurar colunas estruturadas como ARRAY/JSON no schema public.
-- Isso não detecta listas armazenadas como texto; verifique valores textuais também.
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (data_type = 'ARRAY' OR udt_name IN ('json', 'jsonb'))
ORDER BY table_name, ordinal_position;

-- Heurística para encontrar campos textuais com possíveis listas delimitadas.
-- Examine os resultados manualmente; separadores podem ser legítimos em texto.
SELECT 'fornecedor' AS tabela, id_fornecedor::text AS id, 'telefone' AS campo, telefone AS valor
FROM fornecedor
WHERE telefone ~ '[,;|]'
UNION ALL
SELECT 'cliente', id_cliente::text, 'telefone', telefone
FROM cliente
WHERE telefone ~ '[,;|]'
ORDER BY tabela, id, campo;

-- 2FN — ITEM_COMPRA tem PK composta (id_compra, id_produto).
-- Estas consultas mostram se, nos registros existentes, cada parte isolada
-- aparece associada a mais de um valor para atributos do item.
-- Se houver mais de um valor distinto, a amostra refuta aquela dependência funcional.
-- Se não houver resultado, isso não prova a dependência: a amostra pode ser pequena.
SELECT 'id_compra / quantidade' AS atributo_testado, id_compra::text AS valor_determinante,
       COUNT(DISTINCT quantidade) AS valores_distintos
FROM item_compra
GROUP BY id_compra
HAVING COUNT(DISTINCT quantidade) > 1
UNION ALL
SELECT 'id_produto / quantidade', id_produto::text,
       COUNT(DISTINCT quantidade)
FROM item_compra
GROUP BY id_produto
HAVING COUNT(DISTINCT quantidade) > 1
ORDER BY atributo_testado, valor_determinante;

-- Verificação semelhante para custo_unitario do item de compra.
SELECT 'id_compra / custo_unitario' AS atributo_testado, id_compra::text AS valor_determinante,
       COUNT(DISTINCT custo_unitario) AS valores_distintos
FROM item_compra
GROUP BY id_compra
HAVING COUNT(DISTINCT custo_unitario) > 1
UNION ALL
SELECT 'id_produto / custo_unitario', id_produto::text,
       COUNT(DISTINCT custo_unitario)
FROM item_compra
GROUP BY id_produto
HAVING COUNT(DISTINCT custo_unitario) > 1
ORDER BY atributo_testado, valor_determinante;

-- 3FN — possível regra funcional: CNPJ identifica um único fornecedor?
-- O modelo atual não declara UNIQUE(cnpj); confirme a regra antes de mudar o DDL.
SELECT cnpj, COUNT(*) AS quantidade_fornecedores
FROM fornecedor
WHERE cnpj IS NOT NULL
GROUP BY cnpj
HAVING COUNT(*) > 1
ORDER BY cnpj;

-- Ponto de validação: valor_total da compra comparado ao cálculo dos itens.
-- Divergência indica inconsistência com esta fórmula; confirme impostos, frete,
-- descontos e se valor_total representa valor calculado ou valor registrado.
SELECT c.id_compra, c.valor_total,
       SUM(i.quantidade * i.custo_unitario) AS total_calculado,
       c.valor_total - SUM(i.quantidade * i.custo_unitario) AS diferenca
FROM compra c
JOIN item_compra i USING (id_compra)
GROUP BY c.id_compra, c.valor_total
HAVING c.valor_total IS DISTINCT FROM SUM(i.quantidade * i.custo_unitario)
ORDER BY c.id_compra;

-- Informações sobre atributos de preço com semântica a esclarecer.
SELECT id_produto, nome, preco_venda, preco_unitario, custo_unitario
FROM produto
ORDER BY id_produto;
