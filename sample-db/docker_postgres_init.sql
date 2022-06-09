CREATE TABLE sample
(
    id bigint NOT NULL,
    name text COLLATE pg_catalog."default",
    CONSTRAINT sample_pkey PRIMARY KEY (id)
);

INSERT INTO sample(id, name) VALUES
 (1, 'A'),
 (2, 'B'),
 (3, 'C');