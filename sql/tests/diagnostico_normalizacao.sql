-- Consultas diagnósticas MySQL para apoiar a revisão de 1FN, 2FN e 3FN.
-- Execute após sql/schema/der.sql e sql/examples/dados_exemplo_erp.sql.
-- Resultados vazios ou sem duplicidades NÃO provam normalização: as regras
-- funcionais precisam ser confirmadas com o negócio e os dados podem ser poucos.

-- 1FN — localizar colunas JSON no banco selecionado.
-- O MySQL não possui tipo de coluna ARRAY; a consulta não detecta listas armazenadas como texto.
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND data_type = 'json'
ORDER BY table_name, ordinal_position;

-- Heurística para encontrar campos textuais com possíveis listas delimitadas.
-- Examine os resultados manualmente; separadores podem ser legítimos em texto.
SELECT 'fornecedor' AS tabela, CAST(id_fornecedor AS CHAR) AS id, 'telefone' AS campo, telefone AS valor
FROM fornecedor
WHERE telefone REGEXP '[,;|]'
UNION ALL
SELECT 'cliente', CAST(id_cliente AS CHAR), 'telefone', telefone
FROM cliente
WHERE telefone REGEXP '[,;|]'
ORDER BY tabela, id, campo;

-- 2FN — ITEM_COMPRA tem PK composta (id_compra, id_produto).
-- Estas consultas mostram se, nos registros existentes, cada parte isolada
-- aparece associada a mais de um valor para atributos do item.
-- Se houver mais de um valor distinto, a amostra refuta aquela dependência funcional.
-- Se não houver resultado, isso não prova a dependência: a amostra pode ser pequena.
SELECT 'id_compra / quantidade' AS atributo_testado,
       CAST(id_compra AS CHAR) AS valor_determinante,
       COUNT(DISTINCT quantidade) AS valores_distintos
FROM item_compra
GROUP BY id_compra
HAVING COUNT(DISTINCT quantidade) > 1
UNION ALL
SELECT 'id_produto / quantidade', CAST(id_produto AS CHAR), COUNT(DISTINCT quantidade)
FROM item_compra
GROUP BY id_produto
HAVING COUNT(DISTINCT quantidade) > 1
ORDER BY atributo_testado, valor_determinante;

-- Verificação semelhante para custo_unitario do item de compra.
SELECT 'id_compra / custo_unitario' AS atributo_testado,
       CAST(id_compra AS CHAR) AS valor_determinante,
       COUNT(DISTINCT custo_unitario) AS valores_distintos
FROM item_compra
GROUP BY id_compra
HAVING COUNT(DISTINCT custo_unitario) > 1
UNION ALL
SELECT 'id_produto / custo_unitario', CAST(id_produto AS CHAR), COUNT(DISTINCT custo_unitario)
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
FROM compra AS c
JOIN item_compra AS i ON i.id_compra = c.id_compra
GROUP BY c.id_compra, c.valor_total
HAVING NOT (c.valor_total <=> SUM(i.quantidade * i.custo_unitario))
ORDER BY c.id_compra;

-- Informações sobre atributos de preço com semântica a esclarecer.
SELECT id_produto, nome, preco_venda, preco_unitario, custo_unitario
FROM produto
ORDER BY id_produto;
