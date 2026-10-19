CREATE TABLE public.places (
 id text PRIMARY KEY, city_id text NOT NULL,
 kind text NOT NULL CHECK (kind IN ('hotel','restaurant','adventure','waterpark','mall')),
 name text NOT NULL, area text NOT NULL, description text NOT NULL,
 source_url text NOT NULL CHECK (source_url LIKE 'https://%'), checked_on date NOT NULL
);
ALTER TABLE public.places ENABLE ROW LEVEL SECURITY;
GRANT USAGE ON SCHEMA public TO anonymous;
GRANT SELECT ON public.places TO anonymous;
CREATE POLICY public_catalog_read ON public.places FOR SELECT TO anonymous USING (true);
