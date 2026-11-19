-- ClaimSure: Insurance Policy and Claims Analytics
-- MySQL 8.0 | Relational schema designed around 3NF

CREATE DATABASE IF NOT EXISTS claimsure;
USE claimsure;

DROP VIEW IF EXISTS vw_claim_summary;
DROP TRIGGER IF EXISTS trg_claim_status_audit;
DROP TABLE IF EXISTS claim_status_audit, settlements, claims, premiums, policies, policy_types, agents, customers;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  city VARCHAR(60) NOT NULL,
  date_of_birth DATE
);

CREATE TABLE agents (
  agent_id INT PRIMARY KEY,
  agent_name VARCHAR(100) NOT NULL,
  region VARCHAR(30) NOT NULL
);

CREATE TABLE policy_types (
  policy_type_id INT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255)
);

CREATE TABLE policies (
  policy_id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  agent_id INT NOT NULL,
  policy_type_id INT NOT NULL,
  policy_number VARCHAR(20) NOT NULL UNIQUE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  annual_premium DECIMAL(12,2) NOT NULL CHECK (annual_premium > 0),
  policy_status ENUM('Active','Lapsed','Expired') NOT NULL,
  CONSTRAINT fk_policy_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_policy_agent FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
  CONSTRAINT fk_policy_type FOREIGN KEY (policy_type_id) REFERENCES policy_types(policy_type_id)
);

CREATE TABLE premiums (
  premium_id INT PRIMARY KEY,
  policy_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
  due_date DATE NOT NULL,
  payment_status ENUM('Paid','Pending','Overdue') NOT NULL,
  FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

CREATE TABLE claims (
  claim_id INT PRIMARY KEY,
  policy_id INT NOT NULL,
  claim_number VARCHAR(20) NOT NULL UNIQUE,
  claim_type VARCHAR(50) NOT NULL,
  filed_date DATE NOT NULL,
  claim_amount DECIMAL(12,2) NOT NULL CHECK (claim_amount > 0),
  claim_status ENUM('Submitted','Under Review','Approved','Rejected','Settled') NOT NULL,
  FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

CREATE TABLE settlements (
  settlement_id INT PRIMARY KEY,
  claim_id INT NOT NULL UNIQUE,
  settlement_amount DECIMAL(12,2) NOT NULL CHECK (settlement_amount >= 0),
  settlement_date DATE NOT NULL,
  payment_mode VARCHAR(30) NOT NULL,
  FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

CREATE TABLE claim_status_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  claim_id INT NOT NULL,
  old_status VARCHAR(30),
  new_status VARCHAR(30),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

DELIMITER $$
CREATE TRIGGER trg_claim_status_audit
AFTER UPDATE ON claims
FOR EACH ROW
BEGIN
  IF OLD.claim_status <> NEW.claim_status THEN
    INSERT INTO claim_status_audit(claim_id, old_status, new_status)
    VALUES (NEW.claim_id, OLD.claim_status, NEW.claim_status);
  END IF;
END$$
DELIMITER ;

CREATE VIEW vw_claim_summary AS
SELECT c.claim_id, c.claim_number, c.claim_type, c.filed_date,
       c.claim_amount, c.claim_status, p.policy_number,
       pt.type_name AS policy_type, cu.customer_name, cu.city,
       a.agent_name
FROM claims c
JOIN policies p ON c.policy_id = p.policy_id
JOIN policy_types pt ON p.policy_type_id = pt.policy_type_id
JOIN customers cu ON p.customer_id = cu.customer_id
JOIN agents a ON p.agent_id = a.agent_id;
