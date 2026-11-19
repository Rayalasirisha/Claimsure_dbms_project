# ClaimSure: Hybrid Insurance Claims & Loss Analytics System

## Overview
**ClaimSure** is a hybrid relational and document database system designed to help insurers settle genuine claims quickly while controlling financial losses. It combines **MySQL** for normalized transactional records and analytical SQL reporting with **MongoDB** for unstructured claim evidence and investigation notes, connected via **Python DB-API** for segment loss-ratio visualization.

## Project Architecture & Deliverables
1. **Schema Design & Normalisation (`schema.sql`):**
   - Normalized to **Third Normal Form (3NF)** across 8 tables: `customers`, `agents`, `policy_types`, `policies`, `premiums`, `claims`, `settlements`, and `claim_status_audit`.
   - Enforces data integrity with `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `ENUM`, and `CHECK` constraints, plus an automated `AFTER UPDATE` audit trigger (`trg_claim_status_audit`) and reporting view (`vw_claim_summary`).
2. **Sample Dataset (`data.sql`):**
   - Populates **574 records** across 7 core tables (100 customers, 20 agents, 5 policy types, 150 policies, 150 premiums, 150 claims, and 44 settlements).
3. **Analytical SQL Queries (`queries.sql`):**
   - Evaluates claim ratios by policy type, average settlement turnaround time, claim status distributions, agent performance, lapsed policy counts, and monthly claim volume.
4. **Python DB-API & Visualization (`claimsure_analysis.py`):**
   - Connects to MySQL via `mysql-connector-python`, aggregates policy premiums vs. payouts with `pandas`, and generates segment loss-ratio charts with `matplotlib`.
5. **MongoDB Document Store & Aggregation (`claimsure_mongo.js`):**
   - Models nested claim documents (`Police FIR`, `Hospital Bill`, `Surveyor Report`) and investigator risk notes, builds unique/compound indexes, demonstrates full CRUD operations, and runs a `$group` aggregation pipeline by `claim_type`, `region`, and `outcome`.

## Repository Structure
- `schema.sql` — Relational DDL, constraints, trigger, and view definitions
- `data.sql` — Sample DML `INSERT` statements
- `queries.sql` — Analytical SQL queries and trigger verification
- `claimsure_analysis.py` — Python DB-API analysis and charting script
- `claimsure_mongo.js` — MongoDB schema, indexes, CRUD, and aggregation pipeline
- `ClaimSure_Project_Presentation.pptx` — Project presentation deck
- `ClaimSure_Complete_Project_Report.pdf` — Complete project report with outputs and charts
