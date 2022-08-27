-- CreateTable
CREATE TABLE "locations" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "abbr" TEXT,

    CONSTRAINT "locations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "locations_name_key" ON "locations"("name");

-- CreateIndex
CREATE UNIQUE INDEX "locations_abbr_key" ON "locations"("abbr");

-- Create role
DROP ROLE IF EXISTS prisma;
CREATE ROLE prisma NOLOGIN NOINHERIT;

-- Grants
grant usage on schema public to prisma;
grant all privileges on all tables in schema public to prisma;

-- Enable RLS
alter table "locations" enable row level security;

-- Set policies
CREATE POLICY "Enable insert for prisma users only"
    ON public.locations
    AS PERMISSIVE
    FOR INSERT
    TO prisma
    WITH CHECK (true);

CREATE POLICY "Enable select for prisma users only"
    ON public.locations
    AS PERMISSIVE
    FOR SELECT
    TO prisma
    USING (true);
