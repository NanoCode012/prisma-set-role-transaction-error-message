-- Create role
DROP ROLE IF EXISTS prisma;
CREATE ROLE prisma NOLOGIN NOINHERIT;

-- Grants
grant usage on schema public to prisma;
grant all privileges on all tables in schema public to prisma;

-- Enable RLS
alter table "Location" enable row level security;

-- Set policies
CREATE POLICY "Enable insert for prisma users only"
    ON public."Location"
    AS PERMISSIVE
    FOR INSERT
    TO prisma
    WITH CHECK (true);

CREATE POLICY "Enable select for prisma users only"
    ON public."Location"
    AS PERMISSIVE
    FOR SELECT
    TO prisma
    USING (true);
