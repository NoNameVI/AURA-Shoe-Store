/* DEV/DEMO ONLY. Flyway runs this migration after V5.
   Creates a SYSTEM_ADMIN test account and grants that role every active
   permission present at migration time. Do not deploy demo credentials to production. */
SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;

START TRANSACTION;

INSERT INTO accounts
    (username, email, phone, password_hash, full_name, account_type)
VALUES
    ('demo.admin', 'system.admin@example.test', '0900000006',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly',
     'Quản trị hệ thống dùng thử', 'STAFF');

SET @demo_system_admin_id = LAST_INSERT_ID();

INSERT INTO staffs (staff_id, role_code, must_change_password)
VALUES (@demo_system_admin_id, 'SYSTEM_ADMIN', FALSE);

INSERT IGNORE INTO role_permissions (role_code, permission_key)
SELECT 'SYSTEM_ADMIN', permission_key
FROM permissions
WHERE is_active = TRUE;

COMMIT;
