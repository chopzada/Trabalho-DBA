-- =========================================================
-- 03_security_rbac.sql
-- =========================================================

-- 1. RETIRA PERMISSÃO PADRÃO DO PUBLIC

REVOKE ALL ON SCHEMA workflow FROM PUBLIC;
REVOKE ALL ON SCHEMA audit FROM PUBLIC;


-- 2. CRIA AS ROLES

CREATE ROLE role_operacional NOLOGIN;
CREATE ROLE role_gestao NOLOGIN;
CREATE ROLE role_admin_workflow NOLOGIN;


-- 3. CRIA OS USUÁRIOS DO POSTGRESQL

-- Define o formato de senha usado pelo PostgreSQL.
SET password_encryption = 'scram-sha-256';

CREATE USER usr_auditor_op
WITH PASSWORD '123456';

CREATE USER usr_coordenador_gestao
WITH PASSWORD '123456';

CREATE USER usr_dba_admin
WITH PASSWORD '123456';


-- 4. ASSOCIA OS USUÁRIOS ÀS ROLES

GRANT role_operacional TO usr_auditor_op;
GRANT role_gestao TO usr_coordenador_gestao;
GRANT role_admin_workflow TO usr_dba_admin;


-- 5. PERMITE USO DO SCHEMA WORKFLOW

GRANT USAGE ON SCHEMA workflow TO role_operacional;
GRANT USAGE ON SCHEMA workflow TO role_gestao;
GRANT USAGE ON SCHEMA workflow TO role_admin_workflow;


-- =========================================================
-- PERMISSÕES DO OPERADOR
-- =========================================================

GRANT SELECT ON workflow.setores
TO role_operacional;

GRANT SELECT ON workflow.contas_workflow
TO role_operacional;

GRANT SELECT ON workflow.movimentacoes
TO role_operacional;

GRANT SELECT ON workflow.comentarios
TO role_operacional;


-- O operador pode inserir movimentações e comentários.

GRANT INSERT ON workflow.movimentacoes
TO role_operacional;

GRANT INSERT ON workflow.comentarios
TO role_operacional;


-- Permite alterar somente o setor atual da conta.

GRANT UPDATE (setor_atual_id)
ON workflow.contas_workflow
TO role_operacional;


-- Permissão das sequências SERIAL necessárias para INSERT.

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA workflow
TO role_operacional;


-- =========================================================
-- PROTEÇÃO DA TABELA USUARIOS
-- =========================================================

-- O operador NÃO recebe SELECT na tabela inteira.
-- Ele recebe somente acesso às colunas permitidas.

GRANT SELECT
(id, login, nome_completo, setor_id, perfil_acesso)
ON workflow.usuarios
TO role_operacional;


-- A coluna credencial_hash não foi liberada.


-- =========================================================
-- VIEW PARA A GESTÃO
-- =========================================================

CREATE VIEW workflow.v_relatorio_setores AS
SELECT
    s.id AS setor_id,
    s.nome AS setor,
    COUNT(c.id) AS total_contas,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - c.data_entrada)) / 3600
        )::NUMERIC,
        2
    ) AS tempo_medio_horas
FROM workflow.setores s
LEFT JOIN workflow.contas_workflow c
    ON c.setor_atual_id = s.id
GROUP BY s.id, s.nome;


-- Gestão pode consultar somente a view.

GRANT SELECT
ON workflow.v_relatorio_setores
TO role_gestao;


-- =========================================================
-- PERMISSÕES DO ADMINISTRADOR DO WORKFLOW
-- =========================================================

GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA workflow
TO role_admin_workflow;

GRANT ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA workflow
TO role_admin_workflow;
