USE difeecult;
START TRANSACTION;

INSERT INTO fornecedor (id_fornecedor, razao_social, cnpj, telefone, email) VALUES
(1, 'Distribuidora Streetwear Exemplo Ltda', '00.000.000/0000-00', '(11) 0000-0000', 'fornecedor1@example.invalid'),
(2, 'Acessorios Exemplo Ltda', '11.111.111/1111-11', '(11) 1111-1111', 'fornecedor2@example.invalid');

INSERT INTO produto (id_produto, nome, categoria, tamanho, cor, preco_venda, ativo, preco_unitario, custo_unitario) VALUES
(101, 'Camiseta Street Preta', 'CAMISETA', 'M', 'PRETA', 89.90, TRUE, 89.90, 40.00),
(102, 'Jaqueta Urbana', 'JAQUETA', 'G', 'AZUL', 199.90, TRUE, 199.90, 95.00),
(103, 'Chaveiro da Loja', 'CHAVEIRO', NULL, 'VERDE', 14.90, TRUE, 14.90, 4.00);

INSERT INTO cliente (id_cliente, nome, cpf, email) VALUES
(201, 'Cliente Exemplo A', '000.000.000-00', 'cliente-a@example.invalid'),
(202, 'Cliente Exemplo B', '111.111.111-11', 'cliente-b@example.invalid'),
(299, 'Cliente Temporario para DELETE', '999.999.999-99', 'temporario@example.invalid');

INSERT INTO canal_venda (id_canal, nome_canal) VALUES
(301, 'ONLINE'),
(302, 'PRESENCIAL');

INSERT INTO evento (id_evento, nome_evento, local_evento, data_inicio, data_fim) VALUES
(401, 'Feira Exemplo Streetwear', 'Centro de Eventos Exemplo', '2026-11-08', '2026-11-08');

INSERT INTO promocao (id_promocao, nome, tipo_desconto, valor_desconto, data_inicio, data_fim, ativa) VALUES
(501, 'Promocao de Novembro', 'PERCENTUAL', 10.00, '2026-11-01', '2026-11-30', TRUE);

INSERT INTO perfil_acesso (id_perfil, nome, descricao) VALUES
(601, 'Administrador Exemplo', 'Perfil demonstrativo de acesso a loja.');

-- Compras: 10 camisetas x R$ 40,00 + 5 jaquetas x R$ 95,00 = R$ 875,00.
-- 20 chaveiros x R$ 4,00 = R$ 80,00.
INSERT INTO compra (id_compra, id_fornecedor, data_compra, valor_total, status_compra) VALUES
(701, 1, '2026-11-01', 875.00, 'RECEBIDA'),
(702, 2, '2026-11-02', 80.00, 'RECEBIDA');

INSERT INTO item_compra (id_compra, id_produto, quantidade, custo_unitario) VALUES
(701, 101, 10, 40.00),
(701, 102, 5, 95.00),
(702, 103, 20, 4.00);

-- Vendas: venda 7001 = R$ 379,70; venda 7002 = R$ 119,70.
INSERT INTO venda (id_venda, id_cliente, id_canal, id_evento, data_venda, valor_total, status_venda) VALUES
(7001, 201, 301, NULL, '2026-11-03 14:30:00', 379.70, 'FINALIZADA'),
(7002, 202, 302, 401, '2026-11-08 16:00:00', 119.70, 'FINALIZADA');

INSERT INTO item_venda (id_venda, id_produto, quantidade, desconto) VALUES
(7001, 101, 2, 0.00),
(7001, 102, 1, 0.00),
(7002, 101, 1, 0.00),
(7002, 103, 2, 0.00);

-- O saldo corresponde às entradas compradas menos as saídas vendidas.
-- A jaqueta fica abaixo do estoque minimo para alimentar a consulta gerencial.
INSERT INTO estoque (id_estoque, id_produto, quantidade_atual, estoque_minimo, data_atualizacao) VALUES
(801, 101, 7, 2, '2026-11-08 18:00:00'),
(802, 102, 4, 5, '2026-11-08 18:00:00'),
(803, 103, 18, 5, '2026-11-08 18:00:00');

INSERT INTO movimentacao_estoque (id_movimentacao, id_produto, tipo_movimentacao, quantidade, data_movimentacao, motivo) VALUES
(901, 101, 'ENTRADA', 10, '2026-11-01 09:00:00', 'Recebimento da compra 701'),
(902, 102, 'ENTRADA', 5, '2026-11-01 09:10:00', 'Recebimento da compra 701'),
(903, 103, 'ENTRADA', 20, '2026-11-02 09:00:00', 'Recebimento da compra 702'),
(904, 101, 'SAIDA', 2, '2026-11-03 14:30:00', 'Venda 7001'),
(905, 102, 'SAIDA', 1, '2026-11-03 14:30:00', 'Venda 7001'),
(906, 101, 'SAIDA', 1, '2026-11-08 16:00:00', 'Venda 7002'),
(907, 103, 'SAIDA', 2, '2026-11-08 16:00:00', 'Venda 7002');

INSERT INTO venda_site (id_site, id_venda, data_compra, data_entrega) VALUES
(1001, 7001, '2026-11-03', '2026-11-05');

INSERT INTO custo_evento (id_custo_evento, id_evento, descricao, valor, data_custo) VALUES
(1101, 401, 'Aluguel demonstrativo do espaco', 250.00, '2026-11-08'),
(1102, 401, 'Material demonstrativo de divulgacao', 80.00, '2026-11-08');

INSERT INTO item_promocao (id_promocao, id_produto) VALUES
(501, 101),
(501, 103);

INSERT INTO conta_pagar (id_conta_pagar, id_fornecedor, id_compra, descricao, valor, data_emissao, data_vencimento, data_pagamento, status_conta_pagar) VALUES
(1201, 1, 701, 'Pagamento demonstrativo da compra 701', 875.00, '2026-11-01', '2026-11-02', '2026-11-02', 'PAGO'),
(1202, 2, 702, 'Pagamento demonstrativo da compra 702', 80.00, '2026-11-02', '2026-11-15', NULL, 'A_PAGAR');

INSERT INTO conta_receber (id_conta_receber, id_venda, descricao, valor, data_emissao, data_vencimento, data_recebimento, status_conta_receber) VALUES
(1301, 7001, 'Recebimento demonstrativo da venda 7001', 379.70, '2026-11-03', '2026-11-03', '2026-11-03', 'RECEBIDA'),
(1302, 7002, 'Recebimento demonstrativo da venda 7002', 119.70, '2026-11-08', '2026-11-08', NULL, 'A_RECEBER');

INSERT INTO pedido_producao (id_pedido_producao, id_fornecedor, data_pedido, data_prevista, data_conclusao, etapa_producao, status_producao) VALUES
(1401, 1, '2026-11-04', '2026-11-18', NULL, 'CORTE_E_COSTURA', 'EM_ANDAMENTO');

INSERT INTO item_pedido_producao (id_pedido_producao, id_produto, quantidade) VALUES
(1401, 101, 20),
(1401, 102, 10);

-- Senha/hash deliberadamente ficticio; nunca use como credencial real.
INSERT INTO usuario (id_usuario, id_perfil, nome, email, senha_hash, ativo) VALUES
(1501, 601, 'Usuario Administrador Exemplo', 'admin@example.invalid', 'HASH_EXEMPLO_NAO_UTILIZAVEL', TRUE);

-- Adição de telefone para o mesmo usuario
INSERT INTO telefone
    (id_telefone, id_cliente, pais_iso, ddi, ddd, numero_local, tipo, principal) VALUES
    (9001, 201, 'BR', '+55', '11', '999991000', 'CELULAR', TRUE),
    (9002, 201, 'BR', '+55', '11', '33331000',  'FIXO',    FALSE);