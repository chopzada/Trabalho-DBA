-- =========================================================
-- 05_attack_simulation.sql
-- Testes de segurança
-- =========================================================
--
-- IMPORTANTE:
-- Conecte no PostgreSQL como:
--
--     usr_auditor_op
--
-- Execute CADA TESTE SEPARADAMENTE.
-- Os testes 1, 2 e 3 devem dar erro de permissão.
-- =========================================================


-- =========================================================
-- TESTE 1
-- TENTATIVA DE ALTERAR O HISTÓRICO
-- RESULTADO ESPERADO: ERRO / PERMISSION DENIED
-- =========================================================

UPDATE workflow.movimentacoes
SET observacoes = 'ALTERAÇÃO INDEVIDA'
WHERE id = 1;


-- =========================================================
-- TESTE 2
-- TENTATIVA DE APAGAR O HISTÓRICO
-- RESULTADO ESPERADO: ERRO / PERMISSION DENIED
-- =========================================================

DELETE FROM workflow.movimentacoes
WHERE id = 1;


-- =========================================================
-- TESTE 3
-- TENTATIVA DE ACESSAR CREDENCIAL
-- RESULTADO ESPERADO: ERRO / PERMISSION DENIED
-- =========================================================

SELECT credencial_hash
FROM workflow.usuarios;


-- =========================================================
-- TESTE 4
-- MOVIMENTAÇÃO PERMITIDA
-- Auditoria -> Central de Guias
--
-- RESULTADO ESPERADO: SUCESSO
-- =========================================================

INSERT INTO workflow.movimentacoes
(
    conta_id,
    setor_origem_id,
    setor_destino_id,
    usuario_id,
    observacoes
)
VALUES
(
    1,
    1,
    2,
    1,
    'Conta transferida da Auditoria para Central de Guias'
);


-- Atualiza o setor atual da conta.

UPDATE workflow.contas_workflow
SET setor_atual_id = 2
WHERE id = 1;


-- =========================================================
-- TESTE 5
-- COMENTÁRIO PERMITIDO
-- RESULTADO ESPERADO: SUCESSO
-- =========================================================

INSERT INTO workflow.comentarios
(
    conta_id,
    usuario_id,
    descricao
)
VALUES
(
    1,
    1,
    'Conta encaminhada para Central de Guias'
);


-- =========================================================
-- CONSULTA PERMITIDA
-- =========================================================

SELECT *
FROM workflow.movimentacoes
ORDER BY id;
