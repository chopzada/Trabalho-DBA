-- =========================================================
-- 04_audit_setup.sql
-- Auditoria básica com Trigger
-- =========================================================


-- 1. TABELA DE AUDITORIA

CREATE TABLE audit.logged_actions (
    id SERIAL PRIMARY KEY,
    schema_name VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    operacao CHAR(1) NOT NULL,
    dados_antigos JSONB,
    dados_novos JSONB
);


-- 2. FUNÇÃO DE AUDITORIA

CREATE OR REPLACE FUNCTION audit.func_auditoria()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN

        INSERT INTO audit.logged_actions
        (
            schema_name,
            table_name,
            usuario,
            operacao,
            dados_antigos,
            dados_novos
        )
        VALUES
        (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            SESSION_USER,
            'I',
            NULL,
            TO_JSONB(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        INSERT INTO audit.logged_actions
        (
            schema_name,
            table_name,
            usuario,
            operacao,
            dados_antigos,
            dados_novos
        )
        VALUES
        (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            SESSION_USER,
            'U',
            TO_JSONB(OLD),
            TO_JSONB(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN

        INSERT INTO audit.logged_actions
        (
            schema_name,
            table_name,
            usuario,
            operacao,
            dados_antigos,
            dados_novos
        )
        VALUES
        (
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            SESSION_USER,
            'D',
            TO_JSONB(OLD),
            NULL
        );

        RETURN OLD;

    END IF;

END;
$$;


-- 3. TRIGGER DA TABELA MOVIMENTACOES

CREATE TRIGGER trg_auditoria_movimentacoes
AFTER INSERT OR UPDATE OR DELETE
ON workflow.movimentacoes
FOR EACH ROW
EXECUTE FUNCTION audit.func_auditoria();


-- 4. TRIGGER DA TABELA CONTAS_WORKFLOW

CREATE TRIGGER trg_auditoria_contas
AFTER INSERT OR UPDATE OR DELETE
ON workflow.contas_workflow
FOR EACH ROW
EXECUTE FUNCTION audit.func_auditoria();


-- 5. PROTEGE A TABELA DE AUDITORIA

REVOKE ALL ON SCHEMA audit FROM PUBLIC;
REVOKE ALL ON audit.logged_actions FROM PUBLIC;

REVOKE ALL ON audit.logged_actions FROM role_operacional;
REVOKE ALL ON audit.logged_actions FROM role_gestao;


-- O administrador pode apenas consultar a auditoria.

GRANT USAGE ON SCHEMA audit
TO role_admin_workflow;

GRANT SELECT ON audit.logged_actions
TO role_admin_workflow;
