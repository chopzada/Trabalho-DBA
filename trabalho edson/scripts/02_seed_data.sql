-- =========================================================
-- 02_seed_data.sql
-- =========================================================

-- 1. SETORES

INSERT INTO workflow.setores (nome) VALUES
('Auditoria'),
('Central de Guias'),
('Faturamento'),
('Recurso de Glosa');


-- 2. USUÁRIOS DA APLICAÇÃO

INSERT INTO workflow.usuarios
(login, nome_completo, setor_id, credencial_hash, perfil_acesso)
VALUES
('usr_auditor_op', 'Auditor Operacional', 1, 'HASH_AUDITOR', 'OPERACIONAL'),
('usr_coordenador_gestao', 'Coordenador de Gestão', 3, 'HASH_GESTAO', 'GESTAO'),
('usr_dba_admin', 'DBA Administrador', 1, 'HASH_DBA', 'ADMIN'),
('usr_analista_faturamento', 'Analista de Faturamento', 3, 'HASH_ANALISTA', 'OPERACIONAL');


-- 3. CONTAS

INSERT INTO workflow.contas_workflow
(codigo_conta, convenio, valor_aproximado, setor_atual_id)
VALUES
('CTA-1001', 'Convênio Ferb', 8500.00, 1),
('CTA-1002', 'Convênio Bob', 4200.00, 3),
('CTA-1003', 'Convênio Phineas', 12000.00, 4);


-- 4. MOVIMENTAÇÕES INICIAIS

INSERT INTO workflow.movimentacoes
(conta_id, setor_origem_id, setor_destino_id, usuario_id, observacoes)
VALUES
(1, 2, 1, 1, 'Conta enviada para Auditoria'),
(2, 2, 3, 4, 'Conta enviada para Faturamento'),
(3, 3, 4, 4, 'Conta enviada para Recurso de Glosa');


-- 5. COMENTÁRIOS

INSERT INTO workflow.comentarios
(conta_id, usuario_id, descricao)
VALUES
(1, 1, 'Aguardando guia'),
(2, 4, 'Documentação conferida'),
(3, 4, 'Erro de MAT/MED');
