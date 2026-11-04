-- DDL MySQL 8.0+ para o ERP de gestão comercial.
-- Execute com o banco de destino previamente selecionado.
-- Os valores ENUM refletem os rótulos presentes nos dados fictícios do projeto.

CREATE TABLE fornecedor (
    id_fornecedor INTEGER PRIMARY KEY,
    razao_social VARCHAR(255),
    cnpj CHAR(18),
    telefone VARCHAR(32),
    email VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE produto (
    id_produto INTEGER PRIMARY KEY,
    nome VARCHAR(255),
    categoria ENUM('Camiseta', 'Jaqueta', 'Acessorio'),
    tamanho ENUM('M', 'G', 'Unico'),
    cor ENUM('Preta', 'Azul', 'Preto'),
    preco_venda DECIMAL(12,2),
    ativo BOOLEAN,
    preco_unitario DECIMAL(12,2),
    custo_unitario DECIMAL(12,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cliente (
    id_cliente INTEGER PRIMARY KEY,
    nome VARCHAR(255),
    cpf VARCHAR(20),
    email VARCHAR(255),
    telefone VARCHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE canal_venda (
    id_canal INTEGER PRIMARY KEY,
    nome_canal VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE evento (
    id_evento INTEGER PRIMARY KEY,
    nome_evento VARCHAR(255),
    local_evento VARCHAR(255),
    data_inicio DATE,
    data_fim DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE promocao (
    id_promocao INTEGER PRIMARY KEY,
    nome VARCHAR(255),
    tipo_desconto VARCHAR(50),
    valor_desconto DECIMAL(12,2),
    data_inicio DATE,
    data_fim DATE,
    ativa BOOLEAN
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE perfil_acesso (
    id_perfil INTEGER PRIMARY KEY,
    nome VARCHAR(100),
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE compra (
    id_compra INTEGER PRIMARY KEY,
    id_fornecedor INTEGER NOT NULL,
    data_compra DATE,
    valor_total DECIMAL(12,2),
    status_compra ENUM('RECEBIDA'),
    CONSTRAINT fk_compra_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE item_compra (
    id_compra INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER,
    custo_unitario DECIMAL(12,2),
    CONSTRAINT pk_item_compra PRIMARY KEY (id_compra, id_produto),
    CONSTRAINT fk_item_compra_compra
        FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
    CONSTRAINT fk_item_compra_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estoque (
    id_estoque INTEGER PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    quantidade_atual INTEGER,
    estoque_minimo INTEGER,
    data_atualizacao DATETIME,
    CONSTRAINT uq_estoque_produto UNIQUE (id_produto),
    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE movimentacao_estoque (
    id_movimentacao INTEGER PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    tipo_movimentacao ENUM('ENTRADA', 'SAIDA'),
    quantidade INTEGER,
    data_movimentacao DATETIME,
    motivo VARCHAR(255),
    CONSTRAINT fk_movimentacao_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE venda (
    id_venda INTEGER PRIMARY KEY,
    id_cliente INTEGER,
    id_canal INTEGER NOT NULL,
    id_evento INTEGER,
    data_venda DATETIME,
    valor_total DECIMAL(12,2),
    status_venda ENUM('FINALIZADA'),
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_venda_canal
        FOREIGN KEY (id_canal) REFERENCES canal_venda (id_canal),
    CONSTRAINT fk_venda_evento
        FOREIGN KEY (id_evento) REFERENCES evento (id_evento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE item_venda (
    id_venda INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER,
    desconto DECIMAL(12,2),
    CONSTRAINT pk_item_venda PRIMARY KEY (id_venda, id_produto),
    CONSTRAINT fk_item_venda_venda
        FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
    CONSTRAINT fk_item_venda_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE venda_site (
    id_site INTEGER PRIMARY KEY,
    id_venda INTEGER NOT NULL,
    data_compra DATE,
    data_entrega DATE,
    CONSTRAINT uq_venda_site_venda UNIQUE (id_venda),
    CONSTRAINT fk_venda_site_venda
        FOREIGN KEY (id_venda) REFERENCES venda (id_venda)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE custo_evento (
    id_custo_evento INTEGER PRIMARY KEY,
    id_evento INTEGER NOT NULL,
    descricao VARCHAR(255),
    valor DECIMAL(12,2),
    data_custo DATE,
    CONSTRAINT fk_custo_evento_evento
        FOREIGN KEY (id_evento) REFERENCES evento (id_evento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE item_promocao (
    id_promocao INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    CONSTRAINT pk_item_promocao PRIMARY KEY (id_promocao, id_produto),
    CONSTRAINT fk_item_promocao_promocao
        FOREIGN KEY (id_promocao) REFERENCES promocao (id_promocao),
    CONSTRAINT fk_item_promocao_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE conta_pagar (
    id_conta_pagar INTEGER PRIMARY KEY,
    id_fornecedor INTEGER NOT NULL,
    id_compra INTEGER,
    descricao VARCHAR(255),
    valor DECIMAL(12,2),
    data_emissao DATE,
    data_vencimento DATE,
    data_pagamento DATE,
    status_conta_pagar ENUM('PENDENTE'),
    CONSTRAINT fk_conta_pagar_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
    CONSTRAINT fk_conta_pagar_compra
        FOREIGN KEY (id_compra) REFERENCES compra (id_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE conta_receber (
    id_conta_receber INTEGER PRIMARY KEY,
    id_venda INTEGER NOT NULL,
    descricao VARCHAR(255),
    valor DECIMAL(12,2),
    data_emissao DATE,
    data_vencimento DATE,
    data_recebimento DATE,
    status_conta_receber ENUM('RECEBIDA'),
    CONSTRAINT fk_conta_receber_venda
        FOREIGN KEY (id_venda) REFERENCES venda (id_venda)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pedido_producao (
    id_pedido_producao INTEGER PRIMARY KEY,
    id_fornecedor INTEGER NOT NULL,
    data_pedido DATE,
    data_prevista DATE,
    data_conclusao DATE,
    etapa_producao ENUM('Corte e costura'),
    status_producao ENUM('EM_ANDAMENTO'),
    CONSTRAINT fk_pedido_producao_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE item_pedido_producao (
    id_pedido_producao INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER,
    CONSTRAINT pk_item_pedido_producao PRIMARY KEY (id_pedido_producao, id_produto),
    CONSTRAINT fk_item_pedido_producao_pedido
        FOREIGN KEY (id_pedido_producao)
        REFERENCES pedido_producao (id_pedido_producao),
    CONSTRAINT fk_item_pedido_producao_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY,
    id_perfil INTEGER NOT NULL,
    nome VARCHAR(255),
    email VARCHAR(255),
    senha_hash VARCHAR(255),
    ativo BOOLEAN,
    CONSTRAINT fk_usuario_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil_acesso (id_perfil)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
