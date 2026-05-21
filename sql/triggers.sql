CREATE OR REPLACE FUNCTION fn_create_default_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (auth_user_id, full_name, role)
    VALUES (NEW.id, 'Aluno ' || split_part(NEW.email, '@', 1), 'aluno');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_auth_insert
AFTER INSERT ON auth_users
FOR EACH ROW EXECUTE FUNCTION fn_create_default_profile();

CREATE OR REPLACE FUNCTION fn_check_school_admin_role()
RETURNS TRIGGER AS $$
DECLARE
    v_role VARCHAR;
BEGIN
    SELECT role INTO v_role FROM profiles WHERE id = NEW.admin_id;
    IF v_role != 'admin_escolar' THEN
        RAISE EXCEPTION 'Erro de Integridade: O usuário atribuído não possui o papel de administrador escolar (admin_escolar).';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_school_insert_update
BEFORE INSERT OR UPDATE ON schools
FOR EACH ROW EXECUTE FUNCTION fn_check_school_admin_role();

CREATE OR REPLACE FUNCTION fn_update_session_counters()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE simulation_sessions
        SET total_questions = total_questions + 1,
            total_correct = total_correct + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END
        WHERE id = NEW.session_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE simulation_sessions
        SET total_questions = total_questions - 1,
            total_correct = total_correct - CASE WHEN OLD.is_correct THEN 1 ELSE 0 END
        WHERE id = OLD.session_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_answer_insert_delete
AFTER INSERT OR DELETE ON answers
FOR EACH ROW EXECUTE FUNCTION fn_update_session_counters();