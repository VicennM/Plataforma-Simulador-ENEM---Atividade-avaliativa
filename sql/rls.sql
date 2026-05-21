ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE simulation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY profile_self_manage ON profiles
FOR ALL USING (id = current_setting('app.current_profile_id', true)::uuid);

CREATE POLICY profile_admin_escolar_read ON profiles
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM enrollments e
        JOIN schools s ON e.school_id = s.id
        WHERE e.student_id = profiles.id 
        AND s.admin_id = current_setting('app.current_profile_id', true)::uuid
    )
);

CREATE POLICY profile_admin_global_all ON profiles
FOR ALL USING (current_setting('app.current_role', true) = 'admin_global');

CREATE POLICY school_admin_manage ON schools
FOR ALL USING (admin_id = current_setting('app.current_profile_id', true)::uuid);

CREATE POLICY school_student_read ON schools
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM enrollments e 
        WHERE e.school_id = schools.id 
        AND e.student_id = current_setting('app.current_profile_id', true)::uuid
    )
);

CREATE POLICY school_global_all ON schools
FOR ALL USING (current_setting('app.current_role', true) = 'admin_global');

CREATE POLICY enrollment_admin_manage ON enrollments
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM schools s 
        WHERE s.id = enrollments.school_id 
        AND s.admin_id = current_setting('app.current_profile_id', true)::uuid
    )
);

CREATE POLICY enrollment_student_read ON enrollments
FOR SELECT USING (student_id = current_setting('app.current_profile_id', true)::uuid);

CREATE POLICY enrollment_global_all ON enrollments
FOR ALL USING (current_setting('app.current_role', true) = 'admin_global');

CREATE POLICY questions_read_all ON questions
FOR SELECT USING (current_setting('app.current_profile_id', true) IS NOT NULL);

CREATE POLICY questions_global_manage ON questions
FOR ALL USING (current_setting('app.current_role', true) = 'admin_global');

CREATE POLICY session_student_manage ON simulation_sessions
FOR ALL USING (student_id = current_setting('app.current_profile_id', true)::uuid);

CREATE POLICY session_admin_audit ON simulation_sessions
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM enrollments e
        JOIN schools s ON e.school_id = s.id
        WHERE e.student_id = simulation_sessions.student_id
        AND s.admin_id = current_setting('app.current_profile_id', true)::uuid
    )
);

CREATE POLICY answer_student_manage ON answers
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM simulation_sessions ss
        WHERE ss.id = answers.session_id
        AND ss.student_id = current_setting('app.current_profile_id', true)::uuid
    )
);

CREATE POLICY answer_admin_audit ON answers
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM simulation_sessions ss
        JOIN enrollments e ON ss.student_id = e.student_id
        JOIN schools s ON e.school_id = s.id
        WHERE ss.id = answers.session_id
        AND s.admin_id = current_setting('app.current_profile_id', true)::uuid
    )
);

CREATE POLICY session_global_all ON simulation_sessions
FOR ALL USING (current_setting('app.current_role', true) = 'admin_global');

CREATE POLICY answer_global_all ON answers
FOR ALL USING (current_setting('app.current_role', true) = 'admin_global');