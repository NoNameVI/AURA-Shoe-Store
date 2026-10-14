/* Local development baseline: roles, permissions, reference catalog, accounts and images. */

/* Core staff roles and permissions from AURA_database_newversion.sql. */

SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;

INSERT INTO role (role_code, role_name, description)
VALUES
    ('SALES', 'Nhân viên bán hàng', 'Quản lý khách hàng, đơn hàng và hậu mãi.'),
    ('WAREHOUSE', 'Nhân viên kho', 'Quản lý sản phẩm, nhập hàng và tồn kho.'),
    ('SYSTEM_ADMIN', 'Quản trị hệ thống', 'Quản lý tài khoản nhân viên và cấu hình phân quyền.');

INSERT INTO permission (permission_key, permission_name, module_code)
VALUES
    ('catalog.read', 'Xem danh mục sản phẩm', 'CATALOG'),
    ('catalog.manage', 'Quản lý danh mục sản phẩm', 'CATALOG'),
    ('supplier.manage', 'Quản lý nhà cung cấp', 'SUPPLIER'),
    ('purchase_order.read', 'Xem đơn đặt hàng nhà cung cấp', 'PURCHASE_ORDER'),
    ('purchase_order.manage', 'Quản lý đơn đặt hàng nhà cung cấp', 'PURCHASE_ORDER'),
    ('purchase_order.approve', 'Phê duyệt đơn đặt hàng nhà cung cấp', 'PURCHASE_ORDER'),
    ('inventory.read', 'Xem tồn kho', 'INVENTORY'),
    ('inventory.adjust', 'Điều chỉnh tồn kho', 'INVENTORY'),
    ('inventory.receive', 'Nhập kho', 'INVENTORY'),
    ('inventory.issue', 'Xuất kho', 'INVENTORY'),
    ('order.read', 'Xem đơn hàng', 'ORDER'),
    ('order.status.update', 'Cập nhật trạng thái đơn hàng', 'ORDER'),
    ('payment.read', 'Xem thanh toán', 'PAYMENT'),
    ('payment.refund', 'Hoàn tiền', 'PAYMENT'),
    ('after_sales.read', 'Xem yêu cầu hậu mãi', 'AFTER_SALES'),
    ('after_sales.decision.update', 'Duyệt yêu cầu hậu mãi', 'AFTER_SALES'),
    ('after_sales.status.update', 'Cập nhật trạng thái hậu mãi', 'AFTER_SALES'),
    ('voucher.manage', 'Quản lý mã giảm giá', 'VOUCHER'),
    ('customer.manage', 'Quản lý khách hàng', 'CUSTOMER'),
    ('staff.manage', 'Quản lý nhân viên', 'STAFF'),
    ('role_permission.manage', 'Quản lý phân quyền', 'AUTHORIZATION'),
    ('audit.read', 'Xem nhật ký hệ thống', 'AUDIT'),
    ('report.revenue.read', 'Xem báo cáo doanh thu', 'REPORT'),
    ('report.order.read', 'Xem báo cáo đơn hàng', 'REPORT'),
    ('report.product.read', 'Xem báo cáo sản phẩm', 'REPORT'),
    ('report.inventory.read', 'Xem báo cáo tồn kho', 'REPORT'),
    ('report.export', 'Xuất báo cáo', 'REPORT');

INSERT INTO role_permission (role_code, permission_key)
VALUES
    ('SALES', 'catalog.read'),
    ('SALES', 'catalog.manage'),
    ('SALES', 'order.read'),
    ('SALES', 'order.status.update'),
    ('SALES', 'payment.read'),
    ('SALES', 'payment.refund'),
    ('SALES', 'after_sales.read'),
    ('SALES', 'after_sales.decision.update'),
    ('SALES', 'after_sales.status.update'),
    ('SALES', 'voucher.manage'),
    ('SALES', 'customer.manage'),
    ('SALES', 'report.order.read'),

    ('WAREHOUSE', 'catalog.read'),
    ('WAREHOUSE', 'supplier.manage'),
    ('WAREHOUSE', 'purchase_order.read'),
    ('WAREHOUSE', 'purchase_order.manage'),
    ('WAREHOUSE', 'purchase_order.approve'),
    ('WAREHOUSE', 'inventory.read'),
    ('WAREHOUSE', 'inventory.adjust'),
    ('WAREHOUSE', 'inventory.receive'),
    ('WAREHOUSE', 'inventory.issue'),
    ('WAREHOUSE', 'order.read'),
    ('WAREHOUSE', 'after_sales.read'),
    ('WAREHOUSE', 'after_sales.status.update'),
    ('WAREHOUSE', 'report.inventory.read'),

    ('SYSTEM_ADMIN', 'catalog.read'),
    ('SYSTEM_ADMIN', 'catalog.manage'),
    ('SYSTEM_ADMIN', 'staff.manage'),
    ('SYSTEM_ADMIN', 'role_permission.manage'),
    ('SYSTEM_ADMIN', 'audit.read');

/* Local-only deterministic demo catalog for the current schema. No customer, order, payment, stock movement,
   credential, or image URL is fabricated by this migration.
   Products remain DRAFT with zero stock until images and stock receipts exist. */

SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;

INSERT INTO brand (brand_name, slug, description) VALUES
    ('AURA Demo', 'aura-demo', 'Thương hiệu giả lập cho dữ liệu mẫu.'),
    ('Nova Demo', 'nova-demo', 'Thương hiệu giả lập cho dữ liệu mẫu.'),
    ('Motion Demo', 'motion-demo', 'Thương hiệu giả lập cho dữ liệu mẫu.');

INSERT INTO category (category_name, slug, description) VALUES
    ('Giày mẫu', 'demo-footwear', 'Danh mục gốc cho sản phẩm mẫu.');

INSERT INTO category (category_name, slug, description) VALUES
    ('Giày chạy bộ mẫu', 'demo-running', 'Sản phẩm chạy bộ giả lập.'),
    ('Giày tập luyện mẫu', 'demo-training', 'Sản phẩm tập luyện giả lập.'),
    ('Giày thường ngày mẫu', 'demo-lifestyle', 'Sản phẩm thường ngày giả lập.'),
    ('Giày sân tập mẫu', 'demo-court', 'Sản phẩm sân tập giả lập.');

UPDATE category AS child
JOIN category AS parent ON parent.slug = 'demo-footwear'
SET child.parent_id = parent.category_id
WHERE child.slug IN ('demo-running', 'demo-training', 'demo-lifestyle', 'demo-court');

INSERT INTO supplier (supplier_code, supplier_name, address_text) VALUES
    ('SUP-DEMO-001', 'Nhà cung cấp mẫu 01', 'Địa chỉ giả lập, không dùng giao dịch thật'),
    ('SUP-DEMO-002', 'Nhà cung cấp mẫu 02', 'Địa chỉ giả lập, không dùng giao dịch thật');

INSERT INTO product
    (brand_id, category_id, product_name, slug, style_code, description, publication_status)
VALUES
    ((SELECT brand_id FROM brand WHERE slug = 'aura-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-running'),
     'AURA Sprint 01', 'demo-aura-sprint-01', 'DEMO-AS01',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'aura-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-running'),
     'AURA Pace 02', 'demo-aura-pace-02', 'DEMO-AP02',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'nova-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-running'),
     'Nova Trail 01', 'demo-nova-trail-01', 'DEMO-NT01',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'nova-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-training'),
     'Nova Core 02', 'demo-nova-core-02', 'DEMO-NC02',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'motion-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-training'),
     'Motion Flex 01', 'demo-motion-flex-01', 'DEMO-MF01',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'motion-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-lifestyle'),
     'Motion Street 02', 'demo-motion-street-02', 'DEMO-MS02',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'aura-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-court'),
     'AURA Court 03', 'demo-aura-court-03', 'DEMO-AC03',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brand WHERE slug = 'nova-demo'),
     (SELECT category_id FROM category WHERE slug = 'demo-lifestyle'),
     'Nova Daily 04', 'demo-nova-daily-04', 'DEMO-ND04',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT');

/* Reference colors for the local demo catalog. */
INSERT INTO color (color_code, color_name) VALUES
    ('GRY', 'Xám'), ('BLU', 'Xanh dương'), ('BLK', 'Đen'),
    ('WHT', 'Trắng'), ('RED', 'Đỏ'), ('BGE', 'Be'), ('GRN', 'Xanh lá');

INSERT INTO product_variant
    (product_id, sku, color_id, size_code, sale_price, cost_price)
VALUES
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-sprint-01'), 'DEMO-AS01-GRY-39', (SELECT color_id FROM color WHERE color_code = 'GRY'), '39', 1290000.00, 790000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-sprint-01'), 'DEMO-AS01-GRY-40', (SELECT color_id FROM color WHERE color_code = 'GRY'), '40', 1290000.00, 790000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-sprint-01'), 'DEMO-AS01-GRY-41', (SELECT color_id FROM color WHERE color_code = 'GRY'), '41', 1290000.00, 790000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-pace-02'), 'DEMO-AP02-BLU-39', (SELECT color_id FROM color WHERE color_code = 'BLU'), '39', 1390000.00, 850000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-pace-02'), 'DEMO-AP02-BLU-40', (SELECT color_id FROM color WHERE color_code = 'BLU'), '40', 1390000.00, 850000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-pace-02'), 'DEMO-AP02-BLU-41', (SELECT color_id FROM color WHERE color_code = 'BLU'), '41', 1390000.00, 850000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-trail-01'), 'DEMO-NT01-BLK-40', (SELECT color_id FROM color WHERE color_code = 'BLK'), '40', 1590000.00, 980000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-trail-01'), 'DEMO-NT01-BLK-41', (SELECT color_id FROM color WHERE color_code = 'BLK'), '41', 1590000.00, 980000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-trail-01'), 'DEMO-NT01-BLK-42', (SELECT color_id FROM color WHERE color_code = 'BLK'), '42', 1590000.00, 980000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-core-02'), 'DEMO-NC02-WHT-39', (SELECT color_id FROM color WHERE color_code = 'WHT'), '39', 1190000.00, 720000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-core-02'), 'DEMO-NC02-WHT-40', (SELECT color_id FROM color WHERE color_code = 'WHT'), '40', 1190000.00, 720000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-core-02'), 'DEMO-NC02-WHT-41', (SELECT color_id FROM color WHERE color_code = 'WHT'), '41', 1190000.00, 720000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-motion-flex-01'), 'DEMO-MF01-RED-39', (SELECT color_id FROM color WHERE color_code = 'RED'), '39', 990000.00, 590000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-motion-flex-01'), 'DEMO-MF01-RED-40', (SELECT color_id FROM color WHERE color_code = 'RED'), '40', 990000.00, 590000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-motion-flex-01'), 'DEMO-MF01-RED-41', (SELECT color_id FROM color WHERE color_code = 'RED'), '41', 990000.00, 590000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-motion-street-02'), 'DEMO-MS02-BGE-40', (SELECT color_id FROM color WHERE color_code = 'BGE'), '40', 1090000.00, 660000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-motion-street-02'), 'DEMO-MS02-BGE-41', (SELECT color_id FROM color WHERE color_code = 'BGE'), '41', 1090000.00, 660000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-motion-street-02'), 'DEMO-MS02-BGE-42', (SELECT color_id FROM color WHERE color_code = 'BGE'), '42', 1090000.00, 660000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-court-03'), 'DEMO-AC03-WHT-40', (SELECT color_id FROM color WHERE color_code = 'WHT'), '40', 1490000.00, 910000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-court-03'), 'DEMO-AC03-WHT-41', (SELECT color_id FROM color WHERE color_code = 'WHT'), '41', 1490000.00, 910000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-aura-court-03'), 'DEMO-AC03-WHT-42', (SELECT color_id FROM color WHERE color_code = 'WHT'), '42', 1490000.00, 910000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-daily-04'), 'DEMO-ND04-GRN-39', (SELECT color_id FROM color WHERE color_code = 'GRN'), '39', 890000.00, 520000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-daily-04'), 'DEMO-ND04-GRN-40', (SELECT color_id FROM color WHERE color_code = 'GRN'), '40', 890000.00, 520000.00),
    ((SELECT product_id FROM product WHERE slug = 'demo-nova-daily-04'), 'DEMO-ND04-GRN-41', (SELECT color_id FROM color WHERE color_code = 'GRN'), '41', 890000.00, 520000.00);

/* Local development data only. Never ship these credentials to production.
   All accounts use the BCrypt hash of the documented local demo password. */
SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;

INSERT INTO account
    (account_id, username, email, phone, password_hash, full_name)
VALUES
    (1001, 'demo.warehouse.creator', 'warehouse.creator@example.test', '0900000001',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly', 'Nhân viên kho lập phiếu'),
    (1002, 'demo.warehouse.approver', 'warehouse.approver@example.test', '0900000002',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly', 'Nhân viên kho duyệt phiếu'),
    (1003, 'demo.sales', 'sales@example.test', '0900000003',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly', 'Nhân viên bán hàng'),
    (1004, 'demo.customer', 'customer@example.test', '0900000004',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly', 'Khách hàng mua thử'),
    (1005, 'demo.browser', 'browser@example.test', '0900000005',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly', 'Khách hàng xem thử'),
    (1006, 'demo.admin', 'system.admin@example.test', '0900000006',
     '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly', 'Quản trị hệ thống dùng thử');

INSERT INTO staff (staff_id, role_code, must_change_password) VALUES
    (1001, 'WAREHOUSE', FALSE),
    (1002, 'WAREHOUSE', FALSE),
    (1003, 'SALES', FALSE),
    (1006, 'SYSTEM_ADMIN', FALSE);

INSERT INTO customer (customer_id, preferred_size) VALUES
    (1004, '40'),
    (1005, '41');

INSERT INTO address
    (customer_id, recipient_name, phone, province_code, province_name,
     ward_code, ward_name, address_line, is_default)
VALUES
    (1004, 'Khách hàng mua thử', '0900000004', '79', 'TP. Hồ Chí Minh',
     '00001', 'Phường mẫu (demo)', '123 Đường mẫu, địa chỉ giả lập', TRUE);

INSERT INTO shipping_method
    (method_code, method_name, base_fee, estimated_days_min, estimated_days_max)
VALUES
    ('DEMO_STANDARD', 'Giao hàng tiêu chuẩn (demo)', 30000.00, 2, 4),
    ('DEMO_EXPRESS', 'Giao hàng nhanh (demo)', 60000.00, 1, 2);

INSERT INTO voucher
    (voucher_code, voucher_name, discount_percentage, max_discount_amount,
     min_order_amount, start_at, end_at)
VALUES
    ('DEMO10', 'Giảm giá đơn hàng demo', 10.00, 100000.00,
     500000.00, CURRENT_TIMESTAMP - INTERVAL 1 DAY,
     CURRENT_TIMESTAMP + INTERVAL 1 YEAR);

INSERT INTO product_image (variant_id, image_url, alt_text, display_order, is_primary)
SELECT v.variant_id, CONCAT('/images/demo/', SUBSTRING(p.slug, 6), '.png'),
       CONCAT('Ảnh sản phẩm demo: ', p.product_name), 0, TRUE
  FROM product_variant v
  JOIN product p ON p.product_id = v.product_id
 WHERE p.slug LIKE 'demo-%';

/* Hai mau giay co them goc chup phu. Cac size cung mau dung chung anh cua mau giay,
   con moi mau giay khac nhau co file anh dai dien rieng. */
INSERT INTO product_image (variant_id, image_url, alt_text, display_order, is_primary)
SELECT v.variant_id, CONCAT('/images/demo/', SUBSTRING(p.slug, 6), '-detail.png'),
       CONCAT('Góc khác của ', p.product_name), 1, FALSE
  FROM product_variant v
  JOIN product p ON p.product_id = v.product_id
 WHERE p.slug IN ('demo-aura-sprint-01', 'demo-nova-trail-01');

INSERT INTO audit_log (actor_type, action_name, resource_type, action_result)
VALUES ('SYSTEM', 'SEED_DEMO_DATA', 'DATABASE', 'SUCCESS');
