DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS posts CASCADE;


CREATE TABLE users(
  id serial PRIMARY KEY,
  name varchar NOT NULL,
  email varchar NOT NULL UNIQUE,
  password varchar NOT NULL,
  img varchar
);

CREATE TABLE posts(
  id serial PRIMARY KEY,
  title varchar NOT NULL,
  post text,
  post_count integer,
  user_id integer REFERENCES users(id)
);

CREATE TABLE comments(
  id serial PRIMARY KEY,
  comment text,
  post_id integer REFERENCES posts(id),
  user_id integer REFERENCES users(id)
);