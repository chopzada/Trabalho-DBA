-- =========================================================
-- 01_setup_database.sql
-- =========================================================

-- Primeiro crie o banco
CREATE DATABASE hospital_movimentador;

-- 1. SCHEMAS

CREATE SCHEMA workflow;
CREATE SCHEMA audit;


-- 2. TABELA DE SETORES

CREATE TABLE workflow.setores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);


-- 3. TABELA DE USUÁRIOS

CREATE TABLE workflow.usuarios (
    id SERIAL PRIMARY KEY,
    login VARCHAR(80) NOT NULL UNIQUE,
    nome_completo VARCHAR(150) NOT NULL,
    setor_id INTEGER NOT NULL,
    credencial_hash TEXT NOT NULL,
    perfil_acesso VARCHAR(30) NOT NULL,

    CONSTRAINT fk_usuario_setor
        FOREIGN KEY (setor_id)
        REFERENCES workflow.setores(id)
);


-- 4. TABELA DE CONTAS

CREATE TABLE workflow.contas_workflow (
    id SERIAL PRIMARY KEY,
    codigo_conta VARCHAR(50) NOT NULL UNIQUE,
    convenio VARCHAR(100) NOT NULL,
    valor_aproximado NUMERIC(12,2) NOT NULL,
    setor_atual_id INTEGER NOT NULL,
    data_entrada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_conta_setor
        FOREIGN KEY (setor_atual_id)
        REFERENCES workflow.setores(id)
);


-- 5. TABELA DE MOVIMENTAÇÕES

CREATE TABLE workflow.movimentacoes (
    id SERIAL PRIMARY KEY,
    conta_id INTEGER NOT NULL,
    setor_origem_id INTEGER NOT NULL,
    setor_destino_id INTEGER NOT NULL,
    usuario_id INTEGER NOT NULL,
    data_movimentacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT,

    CONSTRAINT fk_mov_conta
        FOREIGN KEY (conta_id)
        REFERENCES workflow.contas_workflow(id),

    CONSTRAINT fk_mov_origem
        FOREIGN KEY (setor_origem_id)
        REFERENCES workflow.setores(id),

    CONSTRAINT fk_mov_destino
        FOREIGN KEY (setor_destino_id)
        REFERENCES workflow.setores(id),

    CONSTRAINT fk_mov_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES workflow.usuarios(id)
);


-- 6. TABELA DE COMENTÁRIOS

CREATE TABLE workflow.comentarios (
    id SERIAL PRIMARY KEY,
    conta_id INTEGER NOT NULL,
    usuario_id INTEGER NOT NULL,
    data_comentario TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT NOT NULL,

    CONSTRAINT fk_comentario_conta
        FOREIGN KEY (conta_id)
        REFERENCES workflow.contas_workflow(id),

    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES workflow.usuarios(id)
);
