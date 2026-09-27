-- =========================================================
-- 06_forensic_queries.sql
-- Consultas de auditoria e investigação
-- =========================================================
--
-- Execute novamente como postgres ou usr_dba_admin.
-- =========================================================


-- 1. MOSTRA TODA A AUDITORIA

SELECT *
FROM audit.logged_actions
ORDER BY data_hora;


-- 2. MOSTRA O QUE O USUÁRIO OPERACIONAL FEZ

SELECT *
FROM audit.logged_actions
WHERE usuario = 'usr_auditor_op'
ORDER BY data_hora;


-- 3. MOSTRA AS ALTERAÇÕES DA TABELA MOVIMENTACOES

SELECT *
FROM audit.logged_actions
WHERE table_name = 'movimentacoes'
ORDER BY data_hora;


-- 4. PROCURA UPDATE OU DELETE NO HISTÓRICO

SELECT *
FROM audit.logged_actions
WHERE table_name = 'movimentacoes'
AND operacao IN ('U', 'D');


-- Se nenhum registro feito pelo operador aparecer,
-- significa que ele não conseguiu alterar/apagar o histórico.


-- 5. MOSTRA O HISTÓRICO DE MOVIMENTAÇÕES COM NOMES

SELECT
    m.id,
    c.codigo_conta,
    origem.nome AS setor_origem,
    destino.nome AS setor_destino,
    u.nome_completo AS usuario,
    m.data_movimentacao,
    m.observacoes
FROM workflow.movimentacoes m

INNER JOIN workflow.contas_workflow c
    ON c.id = m.conta_id

INNER JOIN workflow.setores origem
    ON origem.id = m.setor_origem_id

INNER JOIN workflow.setores destino
    ON destino.id = m.setor_destino_id

INNER JOIN workflow.usuarios u
    ON u.id = m.usuario_id

ORDER BY m.id;


-- 6. MOSTRA A SITUAÇÃO ATUAL DAS CONTAS

SELECT
    c.id,
    c.codigo_conta,
    c.convenio,
    c.valor_aproximado,
    s.nome AS setor_atual,
    c.data_entrada
FROM workflow.contas_workflow c

INNER JOIN workflow.setores s
    ON s.id = c.setor_atual_id

ORDER BY c.id;


-- 7. RELATÓRIO PARA A GESTÃO

SELECT *
FROM workflow.v_relatorio_setores
ORDER BY setor;


-- 8. VERIFICA AS ROLES CRIADAS

SELECT rolname
FROM pg_roles
WHERE rolname IN
(
    'role_operacional',
    'role_gestao',
    'role_admin_workflow',
    'usr_auditor_op',
    'usr_coordenador_gestao',
    'usr_dba_admin'
)
ORDER BY rolname;


-- =========================================================
-- OBSERVAÇÃO PARA O RELATÓRIO
-- =========================================================
--
-- As tentativas que deram "permission denied" devem ser
-- comprovadas com prints do pgAdmin.
--
-- Elas não aparecem na tabela audit.logged_actions porque
-- o PostgreSQL bloqueou o comando antes da alteração ocorrer.
-- =========================================================
