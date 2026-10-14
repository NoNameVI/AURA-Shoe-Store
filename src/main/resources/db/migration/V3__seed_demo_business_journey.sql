/* Local development journey: purchasing, stock ledger, cart, order, payment and after-sales. */

/* Local development journey. Stock enters and leaves through approved document
   lines; posting each document creates immutable inventory transactions. */
SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;

INSERT INTO purchase_order
    (purchase_order_id, po_code, supplier_id, created_by_staff_id, note)
VALUES
    (2001, 'PO-DEMO-001',
     (SELECT supplier_id FROM supplier WHERE supplier_code = 'SUP-DEMO-001'),
     1001, 'Demo purchase order for two shoe variants.');

INSERT INTO purchase_order_item
    (purchase_order_item_id, purchase_order_id, variant_id, ordered_quantity, unit_cost)
VALUES
    (2001, 2001,
     (SELECT variant_id FROM product_variant WHERE sku = 'DEMO-AS01-GRY-40'),
     100, 790000.00),
    (2002, 2001,
     (SELECT variant_id FROM product_variant WHERE sku = 'DEMO-NC02-WHT-40'),
     60, 720000.00);

UPDATE purchase_order
   SET status = 'APPROVED', approved_by_staff_id = 1002,
       approved_at = CURRENT_TIMESTAMP(6)
 WHERE purchase_order_id = 2001;

INSERT INTO inventory_document
    (inventory_document_id, document_code, document_type, purchase_order_id,
     created_by_staff_id, note)
VALUES
    (3001, 'GR-DEMO-001', 'RECEIPT', 2001, 1001,
     'Demo receipt for the approved purchase order.');

INSERT INTO inventory_document_item
    (inventory_document_item_id, inventory_document_id, variant_id,
     product_version_id, sku_snapshot, color_snapshot, size_snapshot,
     purchase_order_item_id, quantity_change, unit_cost)
SELECT 3001, 3001, v.variant_id, pv.product_version_id,
       v.sku, (SELECT c.color_name FROM color c WHERE c.color_id = v.color_id), v.size_code, 2001, 100, 790000.00
  FROM product_variant v
  JOIN product_version pv ON pv.product_id = v.product_id
 WHERE v.sku = 'DEMO-AS01-GRY-40'
 ORDER BY pv.version_number DESC LIMIT 1;

INSERT INTO inventory_document_item
    (inventory_document_item_id, inventory_document_id, variant_id,
     product_version_id, sku_snapshot, color_snapshot, size_snapshot,
     purchase_order_item_id, quantity_change, unit_cost)
SELECT 3002, 3001, v.variant_id, pv.product_version_id,
       v.sku, (SELECT c.color_name FROM color c WHERE c.color_id = v.color_id), v.size_code, 2002, 60, 720000.00
  FROM product_variant v
  JOIN product_version pv ON pv.product_id = v.product_id
 WHERE v.sku = 'DEMO-NC02-WHT-40'
 ORDER BY pv.version_number DESC LIMIT 1;

UPDATE inventory_document
   SET document_status = 'APPROVED', approved_by_staff_id = 1002,
       approved_at = CURRENT_TIMESTAMP(6)
 WHERE inventory_document_id = 3001;

UPDATE inventory_document
   SET document_status = 'POSTED', posted_by_staff_id = 1002,
       posted_at = CURRENT_TIMESTAMP(6)
 WHERE inventory_document_id = 3001;

/* All catalog products have a local image. The two received variants can be
   ordered; the remaining products stay visible as out of stock examples. */
UPDATE product SET publication_status = 'ACTIVE' WHERE slug LIKE 'demo-%';

/* Resolve the variant outside the INSERT: its reservation trigger updates
   product_variant, which MySQL disallows while the same statement reads it. */
SET @demo_core_variant_id =
    (SELECT variant_id FROM product_variant WHERE sku = 'DEMO-NC02-WHT-40');
INSERT INTO cart_item
    (customer_id, variant_id, quantity, reserved_quantity, reservation_expires_at)
VALUES
    (1005, @demo_core_variant_id,
     1, 1, CURRENT_TIMESTAMP(6) + INTERVAL 1 DAY);

INSERT INTO wishlist_item (customer_id, product_id)
VALUES
    (1005, (SELECT product_id FROM product WHERE slug = 'demo-aura-sprint-01'));

INSERT INTO sales_order
    (order_id, order_code, customer_id, shipping_address_id, shipping_method_id,
     voucher_id, shipping_recipient_name, shipping_phone, shipping_address_text,
     shipping_method_name, voucher_code, subtotal_amount, discount_amount,
     shipping_fee, payment_method, customer_note)
VALUES
    (4001, 'SO-DEMO-001', 1004,
     (SELECT address_id FROM address WHERE customer_id = 1004 AND is_default = TRUE),
     (SELECT shipping_method_id FROM shipping_method WHERE method_code = 'DEMO_STANDARD'),
     (SELECT voucher_id FROM voucher WHERE voucher_code = 'DEMO10'),
     'Khách hàng mua thử', '0900000004', '123 Đường mẫu, TP. Hồ Chí Minh',
     'Giao hàng tiêu chuẩn (demo)', 'DEMO10', 1290000.00, 100000.00,
     30000.00, 'COD', 'Đơn hàng mẫu cho kiểm thử local.');

INSERT INTO order_item
    (order_item_id, order_id, product_id, variant_id,
     product_name_snapshot, sku_snapshot, color_snapshot, size_snapshot,
     unit_price, unit_cost_snapshot, quantity, returnable_quantity)
SELECT 4001, 4001, p.product_id, v.variant_id, p.product_name,
       v.sku, (SELECT c.color_name FROM color c WHERE c.color_id = v.color_id), v.size_code, v.sale_price, v.cost_price, 1, 1
  FROM product_variant v JOIN product p ON p.product_id = v.product_id
 WHERE v.sku = 'DEMO-AS01-GRY-40';

INSERT INTO payment
    (order_id, payment_method, idempotency_key, amount,
     payment_status, processed_at)
VALUES
    (4001, 'COD', '00000000-0000-4000-8000-000000000001',
     1220000.00, 'SUCCESS', CURRENT_TIMESTAMP(6));

UPDATE sales_order SET payment_status = 'PAID' WHERE order_id = 4001;
UPDATE sales_order SET order_status = 'CONFIRMED' WHERE order_id = 4001;
UPDATE sales_order SET order_status = 'PROCESSING' WHERE order_id = 4001;
UPDATE sales_order SET order_status = 'SHIPPED', tracking_number = 'DEMO-TRACK-001'
 WHERE order_id = 4001;
UPDATE sales_order SET order_status = 'DELIVERED' WHERE order_id = 4001;

INSERT INTO order_status_history
    (order_id, old_status, new_status, actor_type, changed_by_account_id, reason)
VALUES
    (4001, NULL, 'PENDING', 'CUSTOMER', 1004, 'Demo checkout'),
    (4001, 'PENDING', 'CONFIRMED', 'STAFF', 1003, 'Demo confirmation'),
    (4001, 'CONFIRMED', 'PROCESSING', 'STAFF', 1003, 'Demo fulfillment'),
    (4001, 'PROCESSING', 'SHIPPED', 'STAFF', 1003, 'Demo dispatch'),
    (4001, 'SHIPPED', 'DELIVERED', 'STAFF', 1003, 'Demo delivery');

INSERT INTO inventory_document
    (inventory_document_id, document_code, document_type, source_order_id,
     created_by_staff_id, note)
VALUES
    (3002, 'GI-DEMO-001', 'ISSUE', 4001, 1001,
     'Demo stock issue for the delivered sales order.');

INSERT INTO inventory_document_item
    (inventory_document_item_id, inventory_document_id, variant_id,
     product_version_id, sku_snapshot, color_snapshot, size_snapshot,
     quantity_change, unit_cost, reason)
SELECT 3003, 3002, v.variant_id, pv.product_version_id,
       v.sku, (SELECT c.color_name FROM color c WHERE c.color_id = v.color_id), v.size_code, -1, v.cost_price,
       'Demo fulfillment of sales order SO-DEMO-001'
  FROM product_variant v
  JOIN product_version pv ON pv.product_id = v.product_id
 WHERE v.sku = 'DEMO-AS01-GRY-40'
 ORDER BY pv.version_number DESC LIMIT 1;

UPDATE inventory_document
   SET document_status = 'APPROVED', approved_by_staff_id = 1002,
       approved_at = CURRENT_TIMESTAMP(6)
 WHERE inventory_document_id = 3002;

UPDATE inventory_document
   SET document_status = 'POSTED', posted_by_staff_id = 1002,
       posted_at = CURRENT_TIMESTAMP(6)
 WHERE inventory_document_id = 3002;

INSERT INTO review (customer_id, order_item_id, rating, content)
VALUES (1004, 4001, 5, 'Sản phẩm demo dùng để thử giao diện đánh giá.');

INSERT INTO after_sales_request
    (request_code, customer_id, order_id, order_item_id,
     request_type, reason, requested_quantity, requested_refund_amount)
VALUES
    ('AS-DEMO-001', 1004, 4001, 4001,
     'RETURN', 'Yêu cầu trả hàng mẫu cho kiểm thử.', 1, 1220000.00);

UPDATE sales_order SET order_status = 'RETURN_REQUESTED' WHERE order_id = 4001;
INSERT INTO order_status_history
    (order_id, old_status, new_status, actor_type, changed_by_account_id, reason)
VALUES
    (4001, 'DELIVERED', 'RETURN_REQUESTED', 'CUSTOMER', 1004,
     'Demo after-sales request');
