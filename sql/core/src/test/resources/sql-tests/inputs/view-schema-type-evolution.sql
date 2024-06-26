-- This test suite checks the WITH SCHEMA TYPE EVOLUTION clause

-- In TYPE EVOLUTION mode Spark will inherit the view column types from the query
DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 INT NOT NULL, c2 INT) USING PARQUET;
INSERT INTO t VALUES (1, 2);
CREATE OR REPLACE VIEW v WITH SCHEMA TYPE EVOLUTION AS SELECT * FROM t;
SELECT * FROM v;
DESCRIBE EXTENDED v;

DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 STRING NOT NULL, c2 DOUBLE) USING PARQUET;
INSERT INTO t VALUES ('1', 2.0);
SELECT * FROM v;
-- The view now describes as v(c1 STRING, c2 DOUBLE)
DESCRIBE EXTENDED v;

-- In TYPE EVOLUTION no new columns are inherited
DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 STRING, c2 DOUBLE, c3 DATE) USING PARQUET;
INSERT INTO t VALUES ('1', 2.0, DATE'2022-01-01');
SELECT * FROM v;
-- The view still describes as v(c1 STRING, c2 DOUBLE)
DESCRIBE EXTENDED v;

-- Still can't drop a column
DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 INT, c2 INT) USING PARQUET;
INSERT INTO t VALUES (1, 2);
CREATE OR REPLACE VIEW v WITH SCHEMA TYPE EVOLUTION AS SELECT * FROM t;
SELECT * FROM v;

-- Describes as v(c1 INT, c2 INT)
DESCRIBE EXTENDED v;

DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 INT) USING PARQUET;

-- The view should be invalid, it lost a column
SELECT * FROM v;
DESCRIBE EXTENDED v;

-- Attempt to rename a column
DROP TABLE IF EXISTS t;
CREATE TABLE t(c3 INT, c2 INT) USING PARQUET;
SELECT * FROM v;
DESCRIBE EXTENDED v;

-- Test preservation of comments
DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 INT COMMENT 'c1', c2 INT COMMENT 'c2') USING PARQUET;

-- Inherit comments from the table, if none are given
CREATE OR REPLACE VIEW v(a1, a2) WITH SCHEMA TYPE EVOLUTION AS SELECT * FROM t;
DESCRIBE EXTENDED v;

DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 BIGINT COMMENT 'c1 6a', c2 STRING COMMENT 'c2 6a') USING PARQUET;
SELECT * FROM v;
DESCRIBE EXTENDED v;

-- TYPE EVOLUTION, column list with comments
CREATE OR REPLACE VIEW v(a1 COMMENT 'a1', a2 COMMENT 'a2') WITH SCHEMA TYPE EVOLUTION AS SELECT * FROM t;
DESCRIBE EXTENDED v;

DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 BIGINT COMMENT 'c1 6b', c2 STRING COMMENT 'c2 6b') USING PARQUET;
SELECT * FROM v;
DESCRIBE EXTENDED v;

-- Test ALTER VIEW ... WITH SCHEMA TYPE EVOLUTION

DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 INT) USING PARQUET;
INSERT INTO t VALUES(1);
CREATE OR REPLACE VIEW v WITH SCHEMA COMPENSATION AS SELECT * FROM t;

DROP TABLE IF EXISTS t;
CREATE TABLE t(c1 STRING) USING PARQUET;
INSERT INTO t VALUES('1');
SELECT * FROM v;
DESCRIBE EXTENDED v;

ALTER VIEW v WITH SCHEMA TYPE EVOLUTION;
SELECT * FROM v;
DESCRIBE EXTENDED v;

-- Cleanup
DROP VIEW IF EXISTS v;
DROP TABLE IF EXISTS t;
