# Plataforma Simulador ENEM - Atividade avaliativa

Avaliação prática de Engenharia de Software para a plataforma B2B2C "Simulador ENEM".

## Integrantes

Adrian Riegel;
Eduardo Selzer;
Vicenzo Luiggi Mori.

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
        varchar email "UNIQUE NOT NULL"
        varchar password_hash "NOT NULL"
        timestamp created_at
    }

    profiles {
        uuid id PK
        uuid auth_user_id FK "UNIQUE NOT NULL"
        varchar full_name "NOT NULL"
        varchar role "NOT NULL DEFAULT 'aluno'"
    }

    schools {
        uuid id PK
        varchar name "NOT NULL"
        varchar cnpj "UNIQUE NOT NULL"
        uuid admin_id FK "NOT NULL - Must be admin_escolar"
    }

    enrollments {
        uuid id PK
        uuid student_id FK "NOT NULL (UK com school_id)"
        uuid school_id FK "NOT NULL"
    }

    questions {
        uuid id PK
        serial internal_number "UNIQUE NOT NULL"
        jsonb statement "NOT NULL"
        jsonb alternatives "NOT NULL"
    }

    simulation_sessions {
        uuid id PK
        uuid student_id FK "NOT NULL"
        timestamp started_at "NOT NULL DEFAULT now()"
        timestamp finished_at
        varchar status "NOT NULL DEFAULT 'in_progress'"
        int total_questions "NOT NULL DEFAULT 0"
        int total_correct "NOT NULL DEFAULT 0"
    }

    answers {
        uuid id PK
        uuid session_id FK "NOT NULL (UK com question_id)"
        uuid question_id FK "NOT NULL"
        int chosen_alternative "NOT NULL"
        boolean is_correct "NOT NULL"
        timestamp answered_at "NOT NULL DEFAULT now()"
    }
