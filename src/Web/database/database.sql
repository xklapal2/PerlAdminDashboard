CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL
);

INSERT INTO users (username, firstName, lastName, password) VALUES ('admin', 'Admin','Inbuilt', '$argon2id$v=19$m=32768,t=3,p=1$ZWZLdWNCeE5SVGJFaUt0UG9pWjBDQT09$mrFypaOLlrCJ5m21BH4Aog');
-- 1|admin|$argon2id$v=19$m=32768,t=3,p=1$ZWZLdWNCeE5SVGJFaUt0UG9pWjBDQT09$mrFypaOLlrCJ5m21BH4Aog|Admin|Inbuilt

CREATE TABLE IF NOT EXISTS helpdeskRequests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    messageId TEXT UNIQUE NOT NULL,
    sender TEXT NOT NULL,
    subject TEXT NOT NULL,
    body TEXT NOT NULL,
    date DATETIME NOT NULL,
    progress INTEGER DEFAULT 0
);


