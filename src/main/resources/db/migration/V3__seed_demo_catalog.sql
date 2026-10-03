/* Deterministic demo catalog. No customer, order, payment, stock movement,
   credential, or image URL is fabricated by this migration.
   Products remain DRAFT with zero stock until images and stock receipts exist. */

SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;

INSERT INTO brands (brand_name, slug, description) VALUES
    ('AURA Demo', 'aura-demo', 'Thương hiệu giả lập cho dữ liệu mẫu.'),
    ('Nova Demo', 'nova-demo', 'Thương hiệu giả lập cho dữ liệu mẫu.'),
    ('Motion Demo', 'motion-demo', 'Thương hiệu giả lập cho dữ liệu mẫu.');

INSERT INTO categories (category_name, slug, description) VALUES
    ('Giày mẫu', 'demo-footwear', 'Danh mục gốc cho sản phẩm mẫu.');

INSERT INTO categories (category_name, slug, description) VALUES
    ('Giày chạy bộ mẫu', 'demo-running', 'Sản phẩm chạy bộ giả lập.'),
    ('Giày tập luyện mẫu', 'demo-training', 'Sản phẩm tập luyện giả lập.'),
    ('Giày thường ngày mẫu', 'demo-lifestyle', 'Sản phẩm thường ngày giả lập.'),
    ('Giày sân tập mẫu', 'demo-court', 'Sản phẩm sân tập giả lập.');

UPDATE categories AS child
JOIN categories AS parent ON parent.slug = 'demo-footwear'
SET child.parent_id = parent.category_id
WHERE child.slug IN ('demo-running', 'demo-training', 'demo-lifestyle', 'demo-court');

INSERT INTO suppliers (supplier_code, supplier_name, address_text) VALUES
    ('SUP-DEMO-001', 'Nhà cung cấp mẫu 01', 'Địa chỉ giả lập, không dùng giao dịch thật'),
    ('SUP-DEMO-002', 'Nhà cung cấp mẫu 02', 'Địa chỉ giả lập, không dùng giao dịch thật');

INSERT INTO products
    (brand_id, category_id, product_name, slug, style_code, description, publication_status)
VALUES
    ((SELECT brand_id FROM brands WHERE slug = 'aura-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-running'),
     'AURA Sprint 01', 'demo-aura-sprint-01', 'DEMO-AS01',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'aura-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-running'),
     'AURA Pace 02', 'demo-aura-pace-02', 'DEMO-AP02',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'nova-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-running'),
     'Nova Trail 01', 'demo-nova-trail-01', 'DEMO-NT01',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'nova-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-training'),
     'Nova Core 02', 'demo-nova-core-02', 'DEMO-NC02',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'motion-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-training'),
     'Motion Flex 01', 'demo-motion-flex-01', 'DEMO-MF01',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'motion-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-lifestyle'),
     'Motion Street 02', 'demo-motion-street-02', 'DEMO-MS02',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'aura-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-court'),
     'AURA Court 03', 'demo-aura-court-03', 'DEMO-AC03',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT'),
    ((SELECT brand_id FROM brands WHERE slug = 'nova-demo'),
     (SELECT category_id FROM categories WHERE slug = 'demo-lifestyle'),
     'Nova Daily 04', 'demo-nova-daily-04', 'DEMO-ND04',
     'Sản phẩm mẫu. Bổ sung ảnh và nhập kho trước khi mở bán.', 'DRAFT');

INSERT INTO product_variants
    (product_id, sku, color_name, size_code, sale_price, cost_price)
VALUES
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-sprint-01'), 'DEMO-AS01-GRY-39', 'Xám', '39', 1290000.00, 790000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-sprint-01'), 'DEMO-AS01-GRY-40', 'Xám', '40', 1290000.00, 790000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-sprint-01'), 'DEMO-AS01-GRY-41', 'Xám', '41', 1290000.00, 790000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-pace-02'), 'DEMO-AP02-BLU-39', 'Xanh dương', '39', 1390000.00, 850000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-pace-02'), 'DEMO-AP02-BLU-40', 'Xanh dương', '40', 1390000.00, 850000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-pace-02'), 'DEMO-AP02-BLU-41', 'Xanh dương', '41', 1390000.00, 850000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-trail-01'), 'DEMO-NT01-BLK-40', 'Đen', '40', 1590000.00, 980000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-trail-01'), 'DEMO-NT01-BLK-41', 'Đen', '41', 1590000.00, 980000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-trail-01'), 'DEMO-NT01-BLK-42', 'Đen', '42', 1590000.00, 980000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-core-02'), 'DEMO-NC02-WHT-39', 'Trắng', '39', 1190000.00, 720000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-core-02'), 'DEMO-NC02-WHT-40', 'Trắng', '40', 1190000.00, 720000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-core-02'), 'DEMO-NC02-WHT-41', 'Trắng', '41', 1190000.00, 720000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-motion-flex-01'), 'DEMO-MF01-RED-39', 'Đỏ', '39', 990000.00, 590000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-motion-flex-01'), 'DEMO-MF01-RED-40', 'Đỏ', '40', 990000.00, 590000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-motion-flex-01'), 'DEMO-MF01-RED-41', 'Đỏ', '41', 990000.00, 590000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-motion-street-02'), 'DEMO-MS02-BGE-40', 'Be', '40', 1090000.00, 660000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-motion-street-02'), 'DEMO-MS02-BGE-41', 'Be', '41', 1090000.00, 660000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-motion-street-02'), 'DEMO-MS02-BGE-42', 'Be', '42', 1090000.00, 660000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-court-03'), 'DEMO-AC03-WHT-40', 'Trắng', '40', 1490000.00, 910000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-court-03'), 'DEMO-AC03-WHT-41', 'Trắng', '41', 1490000.00, 910000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-aura-court-03'), 'DEMO-AC03-WHT-42', 'Trắng', '42', 1490000.00, 910000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-daily-04'), 'DEMO-ND04-GRN-39', 'Xanh lá', '39', 890000.00, 520000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-daily-04'), 'DEMO-ND04-GRN-40', 'Xanh lá', '40', 890000.00, 520000.00),
    ((SELECT product_id FROM products WHERE slug = 'demo-nova-daily-04'), 'DEMO-ND04-GRN-41', 'Xanh lá', '41', 890000.00, 520000.00);
