# Trabalho Prático — Administração, Segurança e Governança de Dados

**Disciplina:** Administração de Banco de Dados (DBA) <br>
**SGBD utilizado:** PostgreSQL <br>
**Ferramenta de administração:** pgAdmin <br>
**Instituição:** Aems <br>
**Integrante(s):** Lucas Tadashi Azambuja Miasaki

---

## 1. Apresentação

Este projeto foi desenvolvido com o objetivo de aplicar, de forma prática, conceitos relacionados à administração de banco de dados, segurança da informação, controle de acesso, governança de dados e auditoria.

O cenário proposto considera a implantação de um sistema denominado **Movimentador de Contas e Rastreabilidade**, destinado ao acompanhamento do fluxo de contas hospitalares entre diferentes setores de uma instituição de saúde.

A solução foi implementada utilizando o **PostgreSQL** como Sistema Gerenciador de Banco de Dados (SGBD) e o **pgAdmin** como ferramenta de administração e execução dos scripts SQL.

---

## 2. Objetivos

O projeto tem como objetivo estruturar um banco de dados capaz de registrar e controlar o fluxo de contas hospitalares, mantendo integridade, segurança e rastreabilidade das informações.

Entre os principais objetivos da implementação, destacam-se:

* criar uma base de dados própria para o sistema de movimentação de contas;
* organizar os objetos do banco por meio de schemas distintos;
* implementar tabelas relacionais com chaves primárias e estrangeiras;
* aplicar controle de acesso baseado em papéis (RBAC);
* limitar o acesso a informações sensíveis;
* disponibilizar informações gerenciais por meio de uma view;
* implementar mecanismos de auditoria utilizando triggers;
* registrar alterações realizadas em tabelas consideradas críticas;
* simular tentativas de acesso não autorizado;
* realizar consultas destinadas à análise forense dos eventos registrados.

---

## 3. Estrutura do Banco de Dados

A organização do banco foi dividida em dois schemas.

### 3.1 Schema `workflow`

O schema `workflow` concentra os dados relacionados ao funcionamento do sistema.

As principais tabelas são:

* `setores`: armazena os setores envolvidos no fluxo das contas;
* `usuarios`: armazena os usuários vinculados aos setores;
* `contas_workflow`: registra as contas hospitalares acompanhadas pelo sistema;
* `movimentacoes`: registra as transferências das contas entre os setores;
* `comentarios`: registra observações relacionadas às contas.

### 3.2 Schema `audit`

O schema `audit` foi criado para separar os registros de auditoria dos dados operacionais.

A tabela:

```text
audit.logged_actions
```

armazena informações referentes às operações realizadas nas tabelas monitoradas, incluindo:

* nome do schema;
* nome da tabela;
* usuário responsável pela operação;
* data e hora;
* tipo da operação;
* dados anteriores;
* dados posteriores.

Essa separação contribui para a organização do banco e para a preservação das informações utilizadas na análise de auditoria.

---

## 4. Estrutura dos Arquivos

O projeto está organizado da seguinte forma:

```text
.
├── README.md
└── scripts/
    ├── 01_setup_database.sql
    ├── 02_seed_data.sql
    ├── 03_security_rbac.sql
    ├── 04_audit_setup.sql
    ├── 05_attack_simulation.sql
    └── 06_forensic_queries.sql
```

Cada script possui uma finalidade específica e deve ser executado na ordem indicada.

---

## 5. Descrição dos Scripts

### `01_setup_database.sql`

Responsável pela criação da estrutura principal do banco de dados, incluindo:

* schemas;
* tabelas;
* chaves primárias;
* chaves estrangeiras;
* relacionamentos entre as entidades.

### `02_seed_data.sql`

Responsável pela inserção dos dados iniciais utilizados nos testes.

São cadastrados:

* quatro setores;
* quatro usuários;
* três contas;
* movimentações iniciais;
* comentários relacionados às contas.

### `03_security_rbac.sql`

Responsável pela configuração do controle de acesso baseado em papéis.

São criadas as seguintes roles:

* `role_operacional`;
* `role_gestao`;
* `role_admin_workflow`.

Também são criados usuários específicos para os testes de acesso e são atribuídas permissões de acordo com cada perfil.

### `04_audit_setup.sql`

Responsável pela implementação da auditoria.

O script cria:

* a tabela `audit.logged_actions`;
* a função de auditoria;
* os triggers responsáveis pelo registro automático das alterações.

As tabelas monitoradas são:

* `workflow.movimentacoes`;
* `workflow.contas_workflow`.

### `05_attack_simulation.sql`

Responsável pela simulação dos testes de segurança.

O script contém operações permitidas e operações que devem ser bloqueadas pelo PostgreSQL.

### `06_forensic_queries.sql`

Responsável pelas consultas utilizadas na análise dos registros gerados durante os testes.

Essas consultas permitem identificar, entre outros pontos:

* o usuário responsável por determinada operação;
* a data e a hora da alteração;
* os dados anteriores e posteriores;
* o histórico de movimentações;
* a situação atual das contas.

---

## 6. Controle de Acesso e Segurança

O controle de acesso foi implementado por meio de **roles**, utilizando o princípio do menor privilégio.

### 6.1 Perfil Operacional

A role `role_operacional` possui acesso às informações necessárias para a execução das atividades operacionais.

Entre as permissões concedidas estão:

* consulta de setores;
* consulta de contas;
* consulta de movimentações;
* consulta de comentários;
* inclusão de movimentações;
* inclusão de comentários;
* alteração do setor atual de uma conta.

Esse perfil não possui permissão para excluir ou alterar registros históricos da tabela de movimentações.

### 6.2 Perfil de Gestão

A role `role_gestao` possui acesso à view:

```text
workflow.v_relatorio_setores
```

A finalidade da view é disponibilizar informações consolidadas para acompanhamento gerencial, evitando a exposição direta de informações desnecessárias.

### 6.3 Perfil Administrativo

A role `role_admin_workflow` possui privilégios administrativos sobre os objetos existentes no schema `workflow`.

O acesso à tabela de auditoria é limitado à consulta, preservando os registros utilizados na análise das alterações.

---

## 7. Proteção de Dados

Como medida de minimização de acesso, o usuário operacional não recebe permissão de consulta sobre toda a tabela `workflow.usuarios`.

O acesso é concedido somente às colunas necessárias para a operação:

```text
id
login
nome_completo
setor_id
perfil_acesso
```

A coluna:

```text
credencial_hash
```

permanece restrita.

Dessa forma, uma tentativa de consulta direta dessa coluna pelo usuário operacional deverá ser rejeitada pelo PostgreSQL.

---

## 8. Auditoria

A auditoria foi implementada utilizando triggers.

Sempre que ocorrer uma operação de:

* `INSERT`;
* `UPDATE`;
* `DELETE`;

nas tabelas monitoradas, a função de auditoria registra a ocorrência na tabela:

```text
audit.logged_actions
```

Os dados anteriores e posteriores às alterações são armazenados no formato `JSONB`.

Esse mecanismo permite identificar o estado do registro antes e depois de uma alteração, além do usuário responsável e do momento em que a operação ocorreu.

---

## 9. Procedimento de Execução

### 9.1 Criação do Banco

No pgAdmin, inicialmente deve-se abrir o **Query Tool** conectado ao banco padrão `postgres` e executar:

```sql
CREATE DATABASE hospital_movimentador;
```

Após a criação, deve-se conectar ao banco:

```text
hospital_movimentador
```

### 9.2 Execução dos Scripts de Configuração

Os scripts devem ser executados na seguinte ordem:

1. `01_setup_database.sql`
2. `02_seed_data.sql`
3. `03_security_rbac.sql`
4. `04_audit_setup.sql`

Ao final dessa etapa, o banco estará estruturado e preparado para a realização dos testes.

---

## 10. Usuários Utilizados nos Testes

Foram definidos os seguintes usuários PostgreSQL:

| Usuário                  | Perfil        |
| ------------------------ | ------------- |
| `usr_auditor_op`         | Operacional   |
| `usr_coordenador_gestao` | Gestão        |
| `usr_dba_admin`          | Administrador |

Para fins exclusivamente acadêmicos, os usuários foram configurados com a seguinte senha:

```text
123456
```

Em um ambiente real, devem ser adotadas políticas de senha mais rígidas, além de mecanismos apropriados de autenticação e gerenciamento de credenciais.

---

## 11. Simulação de Violações de Segurança

Os testes de segurança são realizados utilizando o arquivo:

```text
05_attack_simulation.sql
```

Para os testes do perfil operacional, deve-se realizar a conexão no PostgreSQL utilizando o usuário:

```text
usr_auditor_op
```

Recomenda-se executar cada teste individualmente.

### 11.1 Tentativa de Alteração do Histórico

É realizada uma tentativa de `UPDATE` na tabela:

```text
workflow.movimentacoes
```

**Resultado esperado:** operação rejeitada por falta de permissão.

### 11.2 Tentativa de Exclusão do Histórico

É realizada uma tentativa de `DELETE` na tabela:

```text
workflow.movimentacoes
```

**Resultado esperado:** operação rejeitada por falta de permissão.

### 11.3 Tentativa de Acesso à Credencial

O usuário operacional tenta consultar:

```text
credencial_hash
```

na tabela `workflow.usuarios`.

**Resultado esperado:** operação rejeitada por falta de permissão.

### 11.4 Operação Autorizada

O usuário operacional registra uma nova movimentação e adiciona um comentário à conta.

**Resultado esperado:** operação realizada com sucesso.

As alterações realizadas nas tabelas monitoradas devem ser registradas automaticamente na tabela de auditoria.

---

## 12. Análise Forense

Após a execução dos testes, deve-se retornar à conexão administrativa e executar:

```text
06_forensic_queries.sql
```

As consultas desse arquivo permitem analisar:

* registros armazenados na auditoria;
* operações realizadas pelo usuário operacional;
* alterações registradas na tabela de movimentações;
* situação atual das contas;
* histórico completo das movimentações;
* usuários e roles existentes no banco.

A principal consulta da auditoria é:

```sql
SELECT *
FROM audit.logged_actions
ORDER BY data_hora;
```

---

## 13. Evidências dos Testes

Entre as principais evidências recomendadas estão:

* tentativa de `UPDATE` rejeitada;
* tentativa de `DELETE` rejeitada;
* tentativa de acesso à coluna `credencial_hash` rejeitada;
* execução de uma movimentação válida;
* consulta da tabela `audit.logged_actions`;
* consulta da view gerencial.

Quando uma operação é bloqueada por falta de privilégio, ela não modifica os dados. Consequentemente, o trigger de auditoria não é executado para essa tentativa.

Por esse motivo, as mensagens de erro apresentadas pelo PostgreSQL constituem parte das evidências dos testes de segurança.

Um exemplo de mensagem esperada é:

```text
permission denied
```

---

## 14. Resultados Esperados

Ao final da execução do projeto, espera-se demonstrar que:

* o banco possui estrutura relacional adequada;
* os dados estão organizados em schemas distintos;
* os usuários possuem permissões compatíveis com suas funções;
* dados considerados restritos não podem ser acessados pelo perfil operacional;
* o histórico de movimentações não pode ser alterado ou excluído por usuários sem autorização;
* operações válidas podem ser rastreadas;
* a auditoria registra usuário, data, operação e dados alterados;
* as consultas forenses permitem reconstruir as principais ações realizadas no sistema.

---

## 15. Considerações Finais

A implementação desenvolvida demonstra a aplicação prática de conceitos fundamentais da Administração de Banco de Dados.

A utilização de relacionamentos, roles, privilégios, views, triggers e registros de auditoria permite estruturar um ambiente com maior controle sobre o acesso e sobre as alterações realizadas nos dados.

Além da organização das informações operacionais, a separação entre os schemas `workflow` e `audit` contribui para a segregação entre os dados da aplicação e os registros utilizados para rastreabilidade.

Os testes realizados permitem verificar tanto operações autorizadas quanto tentativas de acesso indevido, possibilitando a produção de evidências para análise e auditoria do ambiente PostgreSQL.
