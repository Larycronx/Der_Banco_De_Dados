-- MIGRACAO PARA ENUM — ERP de gestão comercial
-- Use somente em uma base que já tenha sido criada com a versão anterior do DDL.
-- Em uma base nova, execute sql/schema/der.sql; não rode este arquivo depois dele.
-- Os rótulos refletem os valores atualmente presentes nos dados de exemplo do projeto.
-- Se houver valores diferentes na base, a conversão falha e a transação é revertida.
-- razao_social permanece TEXT, pois cada empresa tem um nome livre de catálogo.

BEGIN;

CREATE TYPE categoria_produto_enum AS ENUM ('Camiseta', 'Jaqueta', 'Acessorio');
CREATE TYPE tamanho_produto_enum AS ENUM ('M', 'G', 'Unico');
CREATE TYPE cor_produto_enum AS ENUM ('Preta', 'Azul', 'Preto');
CREATE TYPE tipo_movimentacao_enum AS ENUM ('ENTRADA', 'SAIDA');
CREATE TYPE status_compra_enum AS ENUM ('RECEBIDA');
CREATE TYPE status_venda_enum AS ENUM ('FINALIZADA');
CREATE TYPE status_conta_pagar_enum AS ENUM ('PENDENTE');
CREATE TYPE status_conta_receber_enum AS ENUM ('RECEBIDA');
CREATE TYPE etapa_producao_enum AS ENUM ('Corte e costura');
CREATE TYPE status_producao_enum AS ENUM ('EM_ANDAMENTO');

-- Alinha os nomes das colunas de status ao DER atualizado.
ALTER TABLE conta_pagar RENAME COLUMN status TO status_conta;
ALTER TABLE conta_receber RENAME COLUMN status TO status_conta_receber;
ALTER TABLE pedido_producao RENAME COLUMN status TO status_producao;

ALTER TABLE produto
    ALTER COLUMN categoria TYPE categoria_produto_enum
        USING categoria::text::categoria_produto_enum,
    ALTER COLUMN tamanho TYPE tamanho_produto_enum
        USING tamanho::text::tamanho_produto_enum,
    ALTER COLUMN cor TYPE cor_produto_enum
        USING cor::text::cor_produto_enum;

ALTER TABLE movimentacao_estoque
    ALTER COLUMN tipo_movimentacao TYPE tipo_movimentacao_enum
        USING tipo_movimentacao::text::tipo_movimentacao_enum;

ALTER TABLE compra
    ALTER COLUMN status TYPE status_compra_enum
        USING status::text::status_compra_enum;

ALTER TABLE venda
    ALTER COLUMN status_venda TYPE status_venda_enum
        USING status_venda::text::status_venda_enum;

ALTER TABLE conta_pagar
    ALTER COLUMN status_conta TYPE status_conta_pagar_enum
        USING status_conta::text::status_conta_pagar_enum;

ALTER TABLE conta_receber
    ALTER COLUMN status_conta_receber TYPE status_conta_receber_enum
        USING status_conta_receber::text::status_conta_receber_enum;

ALTER TABLE pedido_producao
    ALTER COLUMN etapa_atual TYPE etapa_producao_enum
        USING etapa_atual::text::etapa_producao_enum,
    ALTER COLUMN status_producao TYPE status_producao_enum
        USING status_producao::text::status_producao_enum;

COMMIT;
