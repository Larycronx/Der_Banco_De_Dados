-- Migração de uma versão ANTERIOR do esquema já em MySQL.
-- Não execute este arquivo em uma base PostgreSQL: PostgreSQL e MySQL são incompatíveis.
-- Faça backup antes. As instruções ALTER TABLE podem confirmar alterações individualmente.
-- Se já existe uma base MySQL vazia, prefira criar o esquema com der.sql.
-- Os rótulos ENUM são os valores presentes no seed atual do projeto.

SET @sql_mode_anterior = @@SESSION.sql_mode;
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES', 'NO_ENGINE_SUBSTITUTION');

ALTER TABLE produto
    MODIFY COLUMN categoria ENUM('Camiseta', 'Jaqueta', 'Acessorio') NULL,
    MODIFY COLUMN tamanho ENUM('M', 'G', 'Unico') NULL,
    MODIFY COLUMN cor ENUM('Preta', 'Azul', 'Preto') NULL;

ALTER TABLE movimentacao_estoque
    MODIFY COLUMN tipo_movimentacao ENUM('ENTRADA', 'SAIDA') NULL;

ALTER TABLE compra
    CHANGE COLUMN status status_compra ENUM('RECEBIDA') NULL;

ALTER TABLE venda
    MODIFY COLUMN status_venda ENUM('FINALIZADA') NULL;

ALTER TABLE conta_pagar
    CHANGE COLUMN status_conta status_conta_pagar ENUM('PENDENTE') NULL;

ALTER TABLE conta_receber
    MODIFY COLUMN status_conta_receber ENUM('RECEBIDA') NULL;

ALTER TABLE pedido_producao
    CHANGE COLUMN etapa_atual etapa_producao ENUM('Corte e costura') NULL,
    MODIFY COLUMN status_producao ENUM('EM_ANDAMENTO') NULL;

SET SESSION sql_mode = @sql_mode_anterior;
