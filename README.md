# Plataforma-Simulador-ENEM---Atividade-avaliativa

Avaliação prática de Engenharia de Software para a plataforma B2B2C "Simulador ENEM".

## Diagrama Entidade-Relacionamento (DER)

```mermaid
erDiagram
    auth_users ||--|| profiles : "1:1 possui"
    profiles ||--o{ enrollments : "1:N realiza"
    schools ||--o{ enrollments : "1:N contém"
    profiles ||--o{ schools : "1:N gerencia (admin)"
    profiles ||--o{ simulation_sessions : "1:N inicia"
    simulation_sessions ||--o{ answers : "1:N registra"
    questions ||--o{ answers : "1:N recebe (ON DELETE CASCADE)"

    auth_users {
        uuid id PK
        varchar email
        varchar password_hash
    }

    profiles {
        uuid id PK
        uuid auth_user_id FK "UNIQUE"
        varchar full_name
        varchar role "aluno, admin_escolar, admin_global"
    }

    schools {
        uuid id PK
        varchar name
        varchar cnpj "UNIQUE"
        uuid admin_id FK "Must be admin_escolar"
    }

    enrollments {
        uuid id PK
        uuid student_id FK
        uuid school_id FK
        %% UNIQUE(student_id, school_id)
    }

    questions {
        uuid id PK
        int internal_number
        jsonb statement
        jsonb alternatives
    }

    simulation_sessions {
        uuid id PK
        uuid student_id FK
        timestamp started_at
        timestamp finished_at
        varchar status "in_progress, completed"
        int total_questions
        int total_correct
    }

    answers {
        uuid id PK
        uuid session_id FK
        uuid question_id FK
        int chosen_alternative
        boolean is_correct
        timestamp answered_at
        %% UNIQUE(session_id, question_id)
    }
