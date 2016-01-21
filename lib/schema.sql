DROP TABLE IF EXISTS actors_movies;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS post;


CREATE TABLE users(
  id serial PRIMARY KEY,
  name varchar NOT NULL,
  email varchar NOT NULL,
  password varchar NOT NULL,
  img varchar
);

CREATE TABLE posts(
  id serial PRIMARY KEY,
  title varchar NOT NULL,
  post text,
  user_id integer REFERENCES users(id)
);

CREATE TABLE comments(
  id serial PRIMARY KEY,
  comment text,
  post_id integer REFERENCES posts(id),
  user_id integer REFERENCES users(id)
);