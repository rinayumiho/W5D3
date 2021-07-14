PRAGMA foreign_keys = ON;

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    parent_id INTEGER,
    user_id INTEGER NOT NULL,
    body TEXT NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY(parent_id) REFERENCES replies(id),
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO
    users (fname, lname)
VALUES
    ("James_1", "Miller_1"),
    ("James_2", "Miller_2"),
    ("James_3", "Miller_3"),
    ("James_4", "Miller_4");

INSERT INTO
    questions(title, body, user_id)
VALUES
    ("que_1", "what?", 2),
    ("que_2", "How?", 1),
    ("que_3", "Why?", 3);

INSERT INTO
    question_follows(user_id, question_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 2),
    (3, 1),
    (3, 3),
    (4, 2);

INSERT INTO
    replies(parent_id, user_id, body, question_id)
VALUES
    (null, 2, "WOW!", 1),
    (null, 2, "YES!", 2),
    (2, 4, "NO!", 2),
    (2, 3, "NOOOOOO!", 2),
    (3, 2, "Not NO, it's YES!", 2),
    (4, 1, "Neither NO nor YES!", 2),
    (1, 1, "WOOOOOOW!!!!", 1),
    (null, 3, "TRUE!", 3),
    (7, 3, "Not TRUE! FALSE!", 3);

INSERT INTO
    question_likes(user_id, question_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 3);

