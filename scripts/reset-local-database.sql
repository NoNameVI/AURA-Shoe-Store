-- Development database reset. This deletes every table and row in aura_store.
-- Run this file with an administrator MySQL account, then start the application
-- so Flyway applies V1-V3 and loads the local demo data.
DROP DATABASE IF EXISTS aura_store;
CREATE DATABASE aura_store
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_vi_0900_ai_ci;
