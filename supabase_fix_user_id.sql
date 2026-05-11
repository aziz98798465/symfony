-- Fix for Symfony/Doctrine error:
-- SQLSTATE[42703]: Undefined column: column t0.id does not exist
--
-- Run this in Supabase SQL Editor.
-- It only targets the application table public."user", not Supabase auth.users.

BEGIN;

-- Diagnostic: check the current columns.
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('user', 'patient_file')
ORDER BY table_name, ordinal_position;

DO $$
BEGIN
    IF to_regclass('public."user"') IS NULL THEN
        RAISE EXCEPTION 'Table public."user" does not exist. Create/import the application schema first.';
    END IF;

    -- Doctrine expects public."user".id.
    -- Some imports create id_user or user_id instead.
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user'
          AND column_name = 'id'
    ) THEN
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'user'
              AND column_name = 'id_user'
        ) THEN
            ALTER TABLE public."user" RENAME COLUMN id_user TO id;
        ELSIF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'user'
              AND column_name = 'user_id'
        ) THEN
            ALTER TABLE public."user" RENAME COLUMN user_id TO id;
        ELSE
            RAISE EXCEPTION 'public."user" has no id, id_user, or user_id column.';
        END IF;
    END IF;

    -- Make sure id auto-increments for future registrations.
    -- If id is already an identity column, PostgreSQL manages it automatically.
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user'
          AND column_name = 'id'
          AND is_identity = 'YES'
    ) THEN
        IF to_regclass('public.user_id_seq') IS NULL THEN
            CREATE SEQUENCE public.user_id_seq OWNED BY public."user".id;
        END IF;

        EXECUTE 'SELECT setval(''public.user_id_seq'', GREATEST(COALESCE((SELECT MAX(id) FROM public."user"), 0), 1), true)';
        ALTER TABLE public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq');
    END IF;

    -- Make sure the primary key exists.
    IF NOT EXISTS (
        SELECT 1
        FROM pg_index i
        JOIN pg_class t ON t.oid = i.indrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = 'public'
          AND t.relname = 'user'
          AND i.indisprimary
    ) THEN
        ALTER TABLE public."user" ADD CONSTRAINT user_pkey PRIMARY KEY (id);
    END IF;

    -- Doctrine also joins patient_file.student_id to public."user".id.
    IF to_regclass('public.patient_file') IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'patient_file'
              AND column_name = 'student_id'
       ) THEN
        ALTER TABLE public.patient_file ADD COLUMN student_id INT;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS uniq_user_email ON public."user" (email);
CREATE UNIQUE INDEX IF NOT EXISTS uniq_patient_file_student_id ON public.patient_file (student_id);

DO $$
BEGIN
    IF to_regclass('public.patient_file') IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'fk_patient_file_student_user'
       ) THEN
        ALTER TABLE public.patient_file
            ADD CONSTRAINT fk_patient_file_student_user
            FOREIGN KEY (student_id)
            REFERENCES public."user" (id)
            NOT VALID;
    END IF;
END $$;

COMMIT;

-- Verify after running:
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('user', 'patient_file')
ORDER BY table_name, ordinal_position;
