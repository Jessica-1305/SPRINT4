		-- NIVEL 1 --
CREATE DATABASE sprint4db;

CREATE TABLE user (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL
);
   
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv'
INTO TABLE user
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date_raw, country, city, postal_code, address)
SET 
    birth_date = STR_TO_DATE(@birth_date_raw, '%b %d, %Y');
    
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv'
INTO TABLE user
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date_raw, country, city, postal_code, address)
SET 
    birth_date = STR_TO_DATE(@birth_date_raw, '%b %d, %Y');
    
    
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv'
INTO TABLE user
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date_raw, country, city, postal_code, address)
SET 
    birth_date = STR_TO_DATE(@birth_date_raw, '%b %d, %Y');

CREATE TABLE company (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    website VARCHAR(255) NOT NULL
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv'
INTO TABLE company
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, phone, email, country, website);

CREATE TABLE product (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price VARCHAR(20) NOT NULL,
    colour VARCHAR(7) NOT NULL,
    weight DECIMAL(5, 2) NOT NULL,
    warehouse_id VARCHAR(10) NOT NULL
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv'
INTO TABLE product
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, price, colour, weight, warehouse_id);

DESCRIBE PRODUCT;

CREATE TABLE credit_card (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL,
    iban VARCHAR(34) NOT NULL,
    pan VARCHAR(20) NOT NULL,
    pin INT NOT NULL,
    cvv INT NOT NULL,
    track1 VARCHAR(255) NOT NULL,
    track2 VARCHAR(255) NOT NULL,
    expiring_date DATE NOT NULL
);
    
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date) 
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');




CREATE TABLE transaction (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(20) NOT NULL,
    business_id VARCHAR(20) NOT NULL,
    timestamp DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    declined BOOLEAN NOT NULL,
    product_ids VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    lat DECIMAL(20, 10) NOT NULL,
    longitude DECIMAL(20, 10) NOT NULL,
    FOREIGN KEY (card_id) REFERENCES credit_card(id),
    FOREIGN KEY (business_id) REFERENCES company(id),
    FOREIGN KEY (user_id) REFERENCES user(id)
);


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);


-- Ejercicio1
SELECT u.id, u.name, u.surname, u.email
FROM user u
WHERE u.id IN (
    SELECT t.user_id
    FROM transaction t
    GROUP BY t.user_id
    HAVING COUNT(t.id) > 30
);

-- Ejercicio2
SELECT c.iban, AVG(t.amount) AS average_amount
FROM transaction t
INNER JOIN credit_card c ON t.card_id = c.id
INNER JOIN company comp ON t.business_id = comp.id
WHERE comp.name = 'Donec Ltd'
GROUP BY c.iban;


			-- NIVEL 2 --
 -- Ejercicio 1 --
CREATE TABLE credit_card_status (
	id VARCHAR(20) PRIMARY KEY,
    status VARCHAR(30) NOT NULL
);

INSERT INTO credit_card_status (id, status)
WITH ranked_transactions AS (
    SELECT 
        id, 
        card_id, 
        timestamp, 
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS row_num
    FROM transaction
)
SELECT card_id as id,
	CASE
		WHEN sum(declined) = 3 THEN 'Inactive'
		ELSE 'Active'
    END AS status
FROM credit_card cc 
INNER JOIN ranked_transactions
ON cc.id = card_id
WHERE row_num IN (1,2,3)
GROUP BY card_id;


SELECT COUNT(*) FROM credit_card_status
WHERE status = 'Active';


