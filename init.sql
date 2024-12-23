CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE OR REPLACE FUNCTION generate_random_string(len INTEGER) RETURNS TEXT AS $$
DECLARE
    characters TEXT := 'my homework for db';
    random_string TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..len LOOP
        random_string := random_string || substr(characters, floor(random() * length(characters) + 1)::integer, 1);
    END LOOP;
    RETURN random_string;
END;
$$ LANGUAGE plpgsql;
