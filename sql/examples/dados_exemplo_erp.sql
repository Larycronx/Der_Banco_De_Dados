-- DADOS DE EXEMPLO — ERP de gestão comercial
-- Execute sql/schema/der.sql primeiro, em um banco de teste.
-- Todos os registros abaixo são fictícios. CPF/CNPJ, telefone e hash são placeholders;
-- não são dados válidos.
-- IDs na faixa 9000+; altere-os se já existirem no seu banco.
-- Este arquivo não é idempotente: executá-lo novamente no mesmo banco causará conflito de PK.

BEGIN;

-- 1. Tabelas-base sem dependências
INSERT INTO fornecedor (id_fornecedor, razao_social, cnpj, telefone, email) VALUES
    (9001, 'Fornecedor Exemplo A', '00.000.000/0000-00', '(00) 0000-0000', 'contato-a@example.invalid'),
    (9002, 'Fornecedor Exemplo B', '11.111.111/1111-11', '(00) 1111-1111', 'contato-b@example.invalid');


-- em relação a preco_venda e custo_unitario.
INSERT INTO produto (id_produto, nome, categoria, tamanho, cor, preco_venda, ativo, preco_unitario, custo_unitario) VALUES
    (9011, 'Camiseta Exemplo Street', 'Camiseta', 'M', 'Preta', 89.90, TRUE, NULL, 40.00),
    (9012, 'Jaqueta Exemplo Urbana', 'Jaqueta', 'G', 'Azul', 199.90, TRUE, NULL, 55.00),
    (9013, 'Bone Exemplo', 'Acessorio', 'Unico', 'Preto', 59.90, TRUE, NULL, 32.50);

INSERT INTO cliente (id_cliente, nome, cpf, email, telefone) VALUES
    (9021, 'Cliente Exemplo 1', '000.000.000-00', 'cliente1@example.invalid', '(00) 0000-0001'),
    (9022, 'Cliente Exemplo 2', '111.111.111-11', 'cliente2@example.invalid', '(00) 0000-0002');

INSERT INTO canal_venda (id_canal, nome_canal) VALUES
    (9031, 'ONLINE'),
    (9032, 'PRESENCIAL');

INSERT INTO evento (id_evento, nome_evento, local_evento, data_inicio, data_fim) VALUES
    (9041, 'Feira Exemplo Streetwear', 'Espaco Exemplo', DATE '2026-10-25', DATE '2026-10-25');

INSERT INTO promocao (id_promocao, nome, tipo_desconto, valor_desconto, data_inicio, data_fim, ativa) VALUES
    (9051, 'Promocao Exemplo Novembro', 'PERCENTUAL', 10.00, DATE '2026-11-01', DATE '2026-11-30', TRUE);

INSERT INTO perfil_acesso (id_perfil, nome, descricao) VALUES
    (9061, 'Perfil Administrador Exemplo', 'Perfil ficticio para demonstracao do relacionamento com usuario.');

-- 2. Compras e itens de compra
-- Os totais correspondem a quantidade x custo_unitario dos itens inseridos abaixo.
INSERT INTO compra (id_compra, id_fornecedor, data_compra, valor_total, status) VALUES
    (9071, 9001, DATE '2026-10-10', 675.00, 'RECEBIDA'),
    (9072, 9002, DATE '2026-10-12', 260.00, 'RECEBIDA');

INSERT INTO item_compra (id_compra, id_produto, quantidade, custo_unitario) VALUES
    (9071, 9011, 10, 40.00),
    (9071, 9012, 5, 55.00),
    (9072, 9013, 8, 32.50);

-- Um estoque por produto, respeitando UNIQUE (id_produto).
-- Quantidades refletem compras menos vendas de exemplo registradas neste arquivo.
INSERT INTO estoque (id_estoque, id_produto, quantidade_atual, estoque_minimo, data_atualizacao) VALUES
    (9081, 9011, 8, 2, TIMESTAMP '2026-10-25 18:00:00'),
    (9082, 9012, 4, 1, TIMESTAMP '2026-10-25 18:00:00'),
    (9083, 9013, 7, 2, TIMESTAMP '2026-10-25 18:00:00');

INSERT INTO movimentacao_estoque (id_movimentacao, id_produto, tipo_movimentacao, quantidade, data_movimentacao, motivo) VALUES
    (9091, 9011, 'ENTRADA', 10, TIMESTAMP '2026-10-10 10:00:00', 'Compra de exemplo 9071'),
    (9092, 9012, 'ENTRADA', 5, TIMESTAMP '2026-10-10 10:05:00', 'Compra de exemplo 9071'),
    (9093, 9013, 'ENTRADA', 8, TIMESTAMP '2026-10-12 11:00:00', 'Compra de exemplo 9072'),
    (9094, 9011, 'SAIDA', 2, TIMESTAMP '2026-10-20 14:20:00', 'Venda de exemplo 9101'),
    (9095, 9012, 'SAIDA', 1, TIMESTAMP '2026-10-20 14:20:00', 'Venda de exemplo 9101'),
    (9096, 9013, 'SAIDA', 1, TIMESTAMP '2026-10-25 16:30:00', 'Venda de exemplo 9102');

-- 3. Vendas, itens e dados do canal online
INSERT INTO venda (id_venda, id_cliente, id_canal, id_evento, data_venda, valor_total, status_venda) VALUES
    (9101, 9021, 9031, NULL, TIMESTAMP '2026-10-20 14:20:00', 379.70, 'FINALIZADA'),
    (9102, 9022, 9032, 9041, TIMESTAMP '2026-10-25 16:30:00', 59.90, 'FINALIZADA');

INSERT INTO item_venda (id_venda, id_produto, quantidade, desconto) VALUES
    (9101, 9011, 2, 0.00),
    (9101, 9012, 1, 0.00),
    (9102, 9013, 1, 0.00);

INSERT INTO venda_site (id_site, id_venda, data_compra, data_entrega) VALUES
    (9111, 9101, DATE '2026-10-20', DATE '2026-10-23');

-- 4. Custos do evento e produtos associados à promoção
INSERT INTO custo_evento (id_custo_evento, id_evento, descricao, valor, data_custo) VALUES
    (9121, 9041, 'Aluguel de espaco — valor de exemplo', 300.00, DATE '2026-10-25'),
    (9122, 9041, 'Material de divulgacao — valor de exemplo', 80.00, DATE '2026-10-25');

INSERT INTO item_promocao (id_promocao, id_produto) VALUES
    (9051, 9011),
    (9051, 9013);

-- 5. Contas a pagar e a receber
INSERT INTO conta_pagar (id_conta_pagar, id_fornecedor, id_compra, descricao, valor, data_emissao, data_vencimento, data_pagamento, status) VALUES
    (9131, 9001, 9071, 'Pagamento referente a compra de exemplo 9071', 675.00, DATE '2026-10-10', DATE '2026-11-09', NULL, 'PENDENTE'),
    (9132, 9002, 9072, 'Pagamento referente a compra de exemplo 9072', 260.00, DATE '2026-10-12', DATE '2026-11-11', NULL, 'PENDENTE');

INSERT INTO conta_receber (id_conta_receber, id_venda, descricao, valor, data_emissao, data_vencimento, data_recebimento, status) VALUES
    (9141, 9101, 'Recebimento referente a venda de exemplo 9101', 379.70, DATE '2026-10-20', DATE '2026-10-20', DATE '2026-10-20', 'RECEBIDA'),
    (9142, 9102, 'Recebimento referente a venda de exemplo 9102', 59.90, DATE '2026-10-25', DATE '2026-10-25', DATE '2026-10-25', 'RECEBIDA');

-- 6. Pedido de produção e itens
-- O pedido está em andamento; por isso não foi lançada entrada de produção no estoque.
INSERT INTO pedido_producao (id_pedido_producao, id_fornecedor, data_pedido, data_prevista, data_conclusao, etapa_atual, status) VALUES
    (9151, 9002, DATE '2026-10-26', DATE '2026-11-15', NULL, 'Corte e costura', 'EM_ANDAMENTO');

INSERT INTO item_pedido_producao (id_pedido_producao, id_produto, quantidade) VALUES
    (9151, 9011, 20),
    (9151, 9013, 10);

-- Hash deliberadamente ficticio: substitua por um hash real e seguro antes de qualquer uso autentico.
INSERT INTO usuario (id_usuario, id_perfil, nome, email, senha_hash, ativo) VALUES
    (9161, 9061, 'Usuario Exemplo', 'usuario@example.invalid', 'HASH_EXEMPLO_NAO_UTILIZAVEL', TRUE);

COMMIT;

-- Consultas opcionais para conferir os exemplos após a execução:
SELECT v.id_venda, v.data_venda, c.nome AS cliente, cv.nome_canal AS canal,
       p.nome AS produto, iv.quantidade, iv.desconto
FROM venda AS v
JOIN cliente AS c ON c.id_cliente = v.id_cliente
JOIN canal_venda AS cv ON cv.id_canal = v.id_canal
JOIN item_venda AS iv ON iv.id_venda = v.id_venda
JOIN produto AS p ON p.id_produto = iv.id_produto
WHERE v.id_venda IN (9101, 9102)
ORDER BY v.id_venda, p.id_produto;
