-- DDL do projeto DER — Sistema de Gestão Comercial
-- Fonte: https://github.com/Larycronx/Der_Banco_De_Dados
-- Dialeto: PostgreSQL
--
-- Mapeamento e limites adotados:
-- 1. Os tipos seguem o DER. Como não foram informados tamanhos para VARCHAR/CHAR
--    nem precisão para DECIMAL, campos textuais usam TEXT e decimais usam NUMERIC.
-- 2. Os atributos não-chave não recebem NOT NULL ou valores padrão sem evidência
--    no modelo. Chaves primárias são NOT NULL por definição.
-- 3. IDs são INTEGER sem geração automática: o DER não especifica sequences,
--    IDENTITY, UUID ou outra estratégia para atribuição de identificadores.
-- 4. FKs obrigatórias ou opcionais seguem as cardinalidades descritas no DER/README.
-- 5. ESTOQUE.id_produto é UNIQUE para refletir PRODUTO 1:1 ESTOQUE no DER.
--    Isso garante no máximo um estoque por produto; a exigência inversa de que
--    todo produto tenha uma linha de estoque exige regra adicional na aplicação.
-- 6. VENDA_SITE.id_venda é UNIQUE conforme observação explícita no README.
-- 7. O vínculo COMPRA -> pelo menos um ITEM_COMPRA e PEDIDO_PRODUCAO -> pelo menos
--    um ITEM_PEDIDO_PRODUCAO não é imposto por uma FK simples; requer validação
--    adicional (por exemplo, na aplicação ou por trigger) se necessário.
-- 8. Não foram adicionados CHECKs para status, faixas ou valores porque tais regras
--    não estão especificadas no repositório. FKs usam o comportamento padrão
--    PostgreSQL (NO ACTION); cascatas não foram presumidas.

BEGIN;

CREATE TABLE fornecedor (
    id_fornecedor INTEGER PRIMARY KEY,
    razao_social  TEXT,
    cnpj          TEXT,
    telefone      TEXT,
    email         TEXT
);

CREATE TABLE produto (
    id_produto     INTEGER PRIMARY KEY,
    nome           TEXT,
    categoria      TEXT,
    tamanho        TEXT,
    cor            TEXT,
    preco_venda    NUMERIC,
    ativo          BOOLEAN,
    preco_unitario NUMERIC,
    custo_unitario NUMERIC
);

CREATE TABLE cliente (
    id_cliente INTEGER PRIMARY KEY,
    nome       TEXT,
    cpf        TEXT,
    email      TEXT,
    telefone   TEXT
);

CREATE TABLE canal_venda (
    id_canal   INTEGER PRIMARY KEY,
    nome_canal TEXT
);

CREATE TABLE evento (
    id_evento   INTEGER PRIMARY KEY,
    nome_evento TEXT,
    local_evento TEXT,
    data_inicio DATE,
    data_fim    DATE
);

CREATE TABLE promocao (
    id_promocao   INTEGER PRIMARY KEY,
    nome          TEXT,
    tipo_desconto TEXT,
    valor_desconto NUMERIC,
    data_inicio   DATE,
    data_fim      DATE,
    ativa         BOOLEAN
);

CREATE TABLE perfil_acesso (
    id_perfil INTEGER PRIMARY KEY,
    nome      TEXT,
    descricao TEXT
);

CREATE TABLE compra (
    id_compra    INTEGER PRIMARY KEY,
    id_fornecedor INTEGER NOT NULL,
    data_compra  DATE,
    valor_total  NUMERIC,
    status       TEXT,
    CONSTRAINT fk_compra_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor)
);

CREATE TABLE item_compra (
    id_compra     INTEGER NOT NULL,
    id_produto    INTEGER NOT NULL,
    quantidade    INTEGER,
    custo_unitario NUMERIC,
    CONSTRAINT pk_item_compra PRIMARY KEY (id_compra, id_produto),
    CONSTRAINT fk_item_compra_compra
        FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
    CONSTRAINT fk_item_compra_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE estoque (
    id_estoque       INTEGER PRIMARY KEY,
    id_produto       INTEGER NOT NULL,
    quantidade_atual INTEGER,
    estoque_minimo   INTEGER,
    data_atualizacao TIMESTAMP,
    CONSTRAINT uq_estoque_produto UNIQUE (id_produto),
    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE movimentacao_estoque (
    id_movimentacao  INTEGER PRIMARY KEY,
    id_produto       INTEGER NOT NULL,
    tipo_movimentacao TEXT,
    quantidade       INTEGER,
    data_movimentacao TIMESTAMP,
    motivo           TEXT,
    CONSTRAINT fk_movimentacao_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE venda (
    id_venda    INTEGER PRIMARY KEY,
    id_cliente  INTEGER,
    id_canal    INTEGER NOT NULL,
    id_evento   INTEGER,
    data_venda  TIMESTAMP,
    valor_total NUMERIC,
    status_venda TEXT,
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_venda_canal
        FOREIGN KEY (id_canal) REFERENCES canal_venda (id_canal),
    CONSTRAINT fk_venda_evento
        FOREIGN KEY (id_evento) REFERENCES evento (id_evento)
);

CREATE TABLE item_venda (
    id_venda  INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER,
    desconto   NUMERIC,
    CONSTRAINT pk_item_venda PRIMARY KEY (id_venda, id_produto),
    CONSTRAINT fk_item_venda_venda
        FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
    CONSTRAINT fk_item_venda_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE venda_site (
    id_site     INTEGER PRIMARY KEY,
    id_venda    INTEGER NOT NULL,
    data_compra DATE,
    data_entrega DATE,
    CONSTRAINT uq_venda_site_venda UNIQUE (id_venda),
    CONSTRAINT fk_venda_site_venda
        FOREIGN KEY (id_venda) REFERENCES venda (id_venda)
);

CREATE TABLE custo_evento (
    id_custo_evento INTEGER PRIMARY KEY,
    id_evento       INTEGER NOT NULL,
    descricao       TEXT,
    valor           NUMERIC,
    data_custo      DATE,
    CONSTRAINT fk_custo_evento_evento
        FOREIGN KEY (id_evento) REFERENCES evento (id_evento)
);

CREATE TABLE item_promocao (
    id_promocao INTEGER NOT NULL,
    id_produto  INTEGER NOT NULL,
    CONSTRAINT pk_item_promocao PRIMARY KEY (id_promocao, id_produto),
    CONSTRAINT fk_item_promocao_promocao
        FOREIGN KEY (id_promocao) REFERENCES promocao (id_promocao),
    CONSTRAINT fk_item_promocao_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE conta_pagar (
    id_conta_pagar INTEGER PRIMARY KEY,
    id_fornecedor  INTEGER NOT NULL,
    id_compra      INTEGER,
    descricao      TEXT,
    valor          NUMERIC,
    data_emissao   DATE,
    data_vencimento DATE,
    data_pagamento DATE,
    status         TEXT,
    CONSTRAINT fk_conta_pagar_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
    CONSTRAINT fk_conta_pagar_compra
        FOREIGN KEY (id_compra) REFERENCES compra (id_compra)
);

CREATE TABLE conta_receber (
    id_conta_receber INTEGER PRIMARY KEY,
    id_venda         INTEGER NOT NULL,
    descricao        TEXT,
    valor            NUMERIC,
    data_emissao     DATE,
    data_vencimento  DATE,
    data_recebimento DATE,
    status           TEXT,
    CONSTRAINT fk_conta_receber_venda
        FOREIGN KEY (id_venda) REFERENCES venda (id_venda)
);

CREATE TABLE pedido_producao (
    id_pedido_producao INTEGER PRIMARY KEY,
    id_fornecedor      INTEGER NOT NULL,
    data_pedido        DATE,
    data_prevista      DATE,
    data_conclusao     DATE,
    etapa_atual        TEXT,
    status             TEXT,
    CONSTRAINT fk_pedido_producao_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor)
);

CREATE TABLE item_pedido_producao (
    id_pedido_producao INTEGER NOT NULL,
    id_produto         INTEGER NOT NULL,
    quantidade         INTEGER,
    CONSTRAINT pk_item_pedido_producao
        PRIMARY KEY (id_pedido_producao, id_produto),
    CONSTRAINT fk_item_pedido_producao_pedido
        FOREIGN KEY (id_pedido_producao)
        REFERENCES pedido_producao (id_pedido_producao),
    CONSTRAINT fk_item_pedido_producao_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY,
    id_perfil  INTEGER NOT NULL,
    nome       TEXT,
    email      TEXT,
    senha_hash TEXT,
    ativo      BOOLEAN,
    CONSTRAINT fk_usuario_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil_acesso (id_perfil)
);

COMMIT;
