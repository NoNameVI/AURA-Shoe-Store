/* DEV/DEMO ONLY. Flyway runs this migration automatically after V4.
   All five demo accounts share the password documented in README.
   Only its BCrypt hash is persisted. Do not deploy this migration to production.
   The procedure is transactional and refuses to run twice. */
SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;
SET @demo_password_hash = '$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly';

DROP PROCEDURE IF EXISTS seed_aura_demo_journey;
DELIMITER $$
CREATE PROCEDURE seed_aura_demo_journey(IN p_password_hash VARCHAR(255))
BEGIN
    DECLARE v_warehouse_creator INT;
    DECLARE v_warehouse_approver INT;
    DECLARE v_sales INT;
    DECLARE v_customer INT;
    DECLARE v_browser INT;
    DECLARE v_address INT;
    DECLARE v_sprint INT;
    DECLARE v_core INT;
    DECLARE v_po INT;
    DECLARE v_po_sprint INT;
    DECLARE v_po_core INT;
    DECLARE v_document INT;
    DECLARE v_order INT;
    DECLARE v_order_item INT;
    DECLARE v_payment INT;
    DECLARE v_shipping INT;
    DECLARE v_voucher INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_password_hash IS NULL OR CHAR_LENGTH(p_password_hash) <> 60
       OR LEFT(p_password_hash, 4) NOT IN ('$2a$', '$2b$', '$2y$') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supply a 60-character BCrypt password hash';
    END IF;
    IF EXISTS (SELECT 1 FROM accounts)
       OR EXISTS (SELECT 1 FROM orders)
       OR EXISTS (SELECT 1 FROM inventory_documents)
       OR EXISTS (SELECT 1 FROM product_images)
       OR EXISTS (SELECT 1 FROM product_variants WHERE stock_quantity <> 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Demo journey requires a fresh V3/V4 development database';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM product_variants WHERE sku = 'DEMO-AS01-GRY-40')
       OR NOT EXISTS (SELECT 1 FROM product_variants WHERE sku = 'DEMO-NC02-WHT-40') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Run Flyway V3 catalog seed first';
    END IF;

    START TRANSACTION;

    INSERT INTO accounts (username, email, phone, password_hash, full_name, account_type)
    VALUES ('demo.warehouse.creator', 'warehouse.creator@example.test', '0900000001', p_password_hash, 'Nhân viên kho lập phiếu', 'STAFF');
    SET v_warehouse_creator = LAST_INSERT_ID();
    INSERT INTO staffs (staff_id, role_code, must_change_password)
    VALUES (v_warehouse_creator, 'WAREHOUSE', FALSE);

    INSERT INTO accounts (username, email, phone, password_hash, full_name, account_type)
    VALUES ('demo.warehouse.approver', 'warehouse.approver@example.test', '0900000002', p_password_hash, 'Nhân viên kho duyệt phiếu', 'STAFF');
    SET v_warehouse_approver = LAST_INSERT_ID();
    INSERT INTO staffs (staff_id, role_code, must_change_password)
    VALUES (v_warehouse_approver, 'WAREHOUSE', FALSE);

    INSERT INTO accounts (username, email, phone, password_hash, full_name, account_type)
    VALUES ('demo.sales', 'sales@example.test', '0900000003', p_password_hash, 'Nhân viên bán hàng', 'STAFF');
    SET v_sales = LAST_INSERT_ID();
    INSERT INTO staffs (staff_id, role_code, must_change_password)
    VALUES (v_sales, 'SALES', FALSE);

    INSERT INTO accounts (username, email, phone, password_hash, full_name, account_type)
    VALUES ('demo.customer', 'customer@example.test', '0900000004', p_password_hash, 'Khách hàng mua thử', 'CUSTOMER');
    SET v_customer = LAST_INSERT_ID();
    INSERT INTO customers (customer_id, preferred_size) VALUES (v_customer, '40');

    INSERT INTO accounts (username, email, phone, password_hash, full_name, account_type)
    VALUES ('demo.browser', 'browser@example.test', '0900000005', p_password_hash, 'Khách hàng xem thử', 'CUSTOMER');
    SET v_browser = LAST_INSERT_ID();
    INSERT INTO customers (customer_id, preferred_size) VALUES (v_browser, '40');

    INSERT INTO addresses
        (customer_id, recipient_name, phone, province_code, province_name,
         ward_code, ward_name, address_line, is_default)
    VALUES (v_customer, 'Khách hàng mua thử', '0900000004', '79', 'TP. Hồ Chí Minh',
            '00001', 'Phường mẫu (demo)', '123 Đường mẫu, địa chỉ giả lập', TRUE);
    SET v_address = LAST_INSERT_ID();

    INSERT INTO shipping_methods
        (method_code, method_name, base_fee, estimated_days_min, estimated_days_max)
    VALUES ('DEMO_STANDARD', 'Giao hàng tiêu chuẩn (demo)', 30000.00, 2, 4);
    SET v_shipping = LAST_INSERT_ID();

    INSERT INTO vouchers
        (voucher_code, voucher_name, discount_percentage, max_discount_amount,
         min_order_amount, usage_limit, used_count, max_uses_per_user, start_at, end_at)
    VALUES ('DEMO10', 'Giảm giá đơn hàng demo', 10.00, 100000.00,
            500000.00, 100, 0, 1, CURRENT_TIMESTAMP - INTERVAL 1 DAY,
            CURRENT_TIMESTAMP + INTERVAL 1 YEAR);
    SET v_voucher = LAST_INSERT_ID();

    INSERT INTO product_images (product_id, image_url, alt_text, display_order, is_primary)
    SELECT product_id, '/images/demo/shoe-placeholder.svg',
           CONCAT('Ảnh minh họa demo: ', product_name), 0, TRUE
      FROM products WHERE slug LIKE 'demo-%';
    UPDATE products SET publication_status = 'ACTIVE' WHERE slug LIKE 'demo-%';

    SELECT variant_id INTO v_sprint FROM product_variants WHERE sku = 'DEMO-AS01-GRY-40';
    SELECT variant_id INTO v_core FROM product_variants WHERE sku = 'DEMO-NC02-WHT-40';

    INSERT INTO purchase_orders (po_code, supplier_id, created_by_staff_id, note)
    VALUES ('PO-DEMO-001', (SELECT supplier_id FROM suppliers WHERE supplier_code = 'SUP-DEMO-001'),
            v_warehouse_creator, 'Đơn mua thử cho quy trình nhập kho.');
    SET v_po = LAST_INSERT_ID();
    INSERT INTO purchase_order_items (purchase_order_id, variant_id, ordered_quantity, unit_cost)
    VALUES (v_po, v_sprint, 100, 790000.00);
    SET v_po_sprint = LAST_INSERT_ID();
    INSERT INTO purchase_order_items (purchase_order_id, variant_id, ordered_quantity, unit_cost)
    VALUES (v_po, v_core, 60, 720000.00);
    SET v_po_core = LAST_INSERT_ID();
    UPDATE purchase_orders SET status = 'APPROVED', approved_by_staff_id = v_warehouse_approver,
           approved_at = CURRENT_TIMESTAMP WHERE purchase_order_id = v_po;

    INSERT INTO inventory_documents
        (document_code, document_type, purchase_order_id, created_by_staff_id, note)
    VALUES ('GR-DEMO-001', 'RECEIPT', v_po, v_warehouse_creator, 'Nhận đủ hai dòng của đơn mua.');
    SET v_document = LAST_INSERT_ID();
    UPDATE inventory_documents SET document_status = 'APPROVED',
           approved_by_staff_id = v_warehouse_approver, approved_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    UPDATE inventory_documents SET document_status = 'POSTED',
           posted_by_staff_id = v_warehouse_approver, posted_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    INSERT INTO inventory_transactions
        (inventory_document_id, variant_id, purchase_order_item_id, actor_staff_id,
         transaction_type, quantity_change, unit_cost, idempotency_key)
    VALUES (v_document, v_sprint, v_po_sprint, v_warehouse_approver,
            'RECEIPT', 100, 790000.00, UUID());
    INSERT INTO inventory_transactions
        (inventory_document_id, variant_id, purchase_order_item_id, actor_staff_id,
         transaction_type, quantity_change, unit_cost, idempotency_key)
    VALUES (v_document, v_core, v_po_core, v_warehouse_approver,
            'RECEIPT', 60, 720000.00, UUID());

    INSERT INTO wishlist_items (customer_id, product_id)
    VALUES (v_browser, (SELECT product_id FROM products WHERE slug = 'demo-aura-sprint-01'));
    INSERT INTO cart_items (customer_id, variant_id, quantity, reserved_quantity, reservation_expires_at)
    VALUES (v_browser, v_core, 1, 1, CURRENT_TIMESTAMP + INTERVAL 1 DAY);

    INSERT INTO orders
        (order_code, customer_id, shipping_address_id, shipping_method_id, voucher_id,
         shipping_recipient_name, shipping_phone, shipping_address_text,
         shipping_method_name, voucher_code, subtotal_amount, discount_amount,
         shipping_fee, payment_method, customer_note)
    VALUES ('ORD-DEMO-001', v_customer, v_address, v_shipping, v_voucher,
            'Khách hàng mua thử', '0900000004', '123 Đường mẫu, Phường mẫu (demo), TP. Hồ Chí Minh',
            'Giao hàng tiêu chuẩn (demo)', 'DEMO10', 2580000.00, 100000.00,
            30000.00, 'COD', 'Đơn hàng giả lập, không giao thật.');
    SET v_order = LAST_INSERT_ID();
    INSERT INTO order_items
        (order_id, product_id, variant_id, product_name_snapshot, sku_snapshot,
         color_snapshot, size_snapshot, unit_price, unit_cost_snapshot, quantity,
         discount_amount, returnable_quantity)
    SELECT v_order, p.product_id, pv.variant_id, p.product_name, pv.sku,
           pv.color_name, pv.size_code, pv.sale_price, pv.cost_price, 2, 100000.00, 2
      FROM product_variants pv JOIN products p ON p.product_id = pv.product_id
     WHERE pv.variant_id = v_sprint;
    SET v_order_item = LAST_INSERT_ID();
    UPDATE vouchers SET used_count = used_count + 1 WHERE voucher_id = v_voucher;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id, reason)
    VALUES (v_order, NULL, 'PENDING', 'CUSTOMER', v_customer, 'Khách tạo đơn demo.');
    UPDATE orders SET order_status = 'CONFIRMED' WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id)
    VALUES (v_order, 'PENDING', 'CONFIRMED', 'STAFF', v_sales);
    UPDATE orders SET order_status = 'PROCESSING' WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id)
    VALUES (v_order, 'CONFIRMED', 'PROCESSING', 'STAFF', v_sales);

    INSERT INTO inventory_documents
        (document_code, document_type, source_order_id, created_by_staff_id, note)
    VALUES ('GI-DEMO-001', 'ISSUE', v_order, v_warehouse_creator, 'Xuất 2 đôi để giao đơn demo.');
    SET v_document = LAST_INSERT_ID();
    UPDATE inventory_documents SET document_status = 'APPROVED',
           approved_by_staff_id = v_warehouse_approver, approved_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    UPDATE inventory_documents SET document_status = 'POSTED',
           posted_by_staff_id = v_warehouse_approver, posted_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    INSERT INTO inventory_transactions
        (inventory_document_id, variant_id, actor_staff_id, transaction_type,
         quantity_change, unit_cost, idempotency_key)
    VALUES (v_document, v_sprint, v_warehouse_approver, 'ISSUE', -2, 790000.00, UUID());

    UPDATE orders SET order_status = 'SHIPPED', tracking_number = 'DEMO-NO-SHIPMENT-001'
     WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id)
    VALUES (v_order, 'PROCESSING', 'SHIPPED', 'STAFF', v_sales);
    UPDATE orders SET order_status = 'DELIVERED' WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id)
    VALUES (v_order, 'SHIPPED', 'DELIVERED', 'STAFF', v_sales);
    INSERT INTO payments
        (order_id, is_refund, payment_method, idempotency_key, amount, payment_status, processed_at)
    VALUES (v_order, FALSE, 'COD', UUID(), 2510000.00, 'SUCCESS', CURRENT_TIMESTAMP);
    SET v_payment = LAST_INSERT_ID();
    UPDATE orders SET payment_status = 'PAID' WHERE order_id = v_order;
    INSERT INTO reviews (customer_id, order_item_id, rating, content)
    VALUES (v_customer, v_order_item, 5, 'Đánh giá minh họa sau khi nhận đơn demo.');

    INSERT INTO after_sales_requests
        (request_code, customer_id, order_id, order_item_id, request_type, reason,
         requested_quantity, requested_refund_amount)
    VALUES ('AS-DEMO-001', v_customer, v_order, v_order_item, 'RETURN',
            'Trả một đôi trong đơn demo.', 1, 1240000.00);
    UPDATE orders SET order_status = 'RETURN_REQUESTED' WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id)
    VALUES (v_order, 'DELIVERED', 'RETURN_REQUESTED', 'CUSTOMER', v_customer);
    UPDATE after_sales_requests
       SET request_status = 'APPROVED', handled_by_staff_id = v_sales,
           resolution_note = 'Chấp nhận nhận lại một đôi còn bán được.'
     WHERE request_code = 'AS-DEMO-001';

    INSERT INTO inventory_documents
        (document_code, document_type, source_order_id, created_by_staff_id, note)
    VALUES ('GR-DEMO-RETURN-001', 'RECEIPT', v_order, v_warehouse_creator,
            'Nhận lại một đôi bán được từ đơn demo.');
    SET v_document = LAST_INSERT_ID();
    UPDATE inventory_documents SET document_status = 'APPROVED',
           approved_by_staff_id = v_warehouse_approver, approved_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    UPDATE inventory_documents SET document_status = 'POSTED',
           posted_by_staff_id = v_warehouse_approver, posted_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    INSERT INTO inventory_transactions
        (inventory_document_id, variant_id, actor_staff_id, transaction_type,
         quantity_change, unit_cost, reason, idempotency_key)
    VALUES (v_document, v_sprint, v_warehouse_approver, 'RECEIPT', 1, 790000.00,
            'Khách trả một đôi còn bán được.', UUID());
    INSERT INTO payments
        (order_id, parent_payment_id, is_refund, payment_method, idempotency_key,
         amount, payment_status, processed_at)
    VALUES (v_order, v_payment, TRUE, 'COD', UUID(), 1240000.00, 'SUCCESS', CURRENT_TIMESTAMP);
    UPDATE orders SET payment_status = 'PARTIALLY_REFUNDED' WHERE order_id = v_order;
    UPDATE order_items SET returnable_quantity = 1 WHERE order_item_id = v_order_item;
    UPDATE after_sales_requests SET request_status = 'COMPLETED'
     WHERE request_code = 'AS-DEMO-001';
    UPDATE orders SET order_status = 'DELIVERED' WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id, reason)
    VALUES (v_order, 'RETURN_REQUESTED', 'DELIVERED', 'STAFF', v_sales,
            'Đã xử lý trả một phần; khách giữ đôi còn lại.');
    UPDATE orders SET order_status = 'COMPLETED' WHERE order_id = v_order;
    INSERT INTO order_status_history
        (order_id, old_status, new_status, actor_type, changed_by_account_id)
    VALUES (v_order, 'DELIVERED', 'COMPLETED', 'STAFF', v_sales);

    INSERT INTO inventory_documents (document_code, document_type, created_by_staff_id, note)
    VALUES ('ADJ-DEMO-001', 'ADJUSTMENT', v_warehouse_creator,
            'Kiểm kê mẫu: Nova Core thiếu một đôi.');
    SET v_document = LAST_INSERT_ID();
    UPDATE inventory_documents SET document_status = 'APPROVED',
           approved_by_staff_id = v_warehouse_approver, approved_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    UPDATE inventory_documents SET document_status = 'POSTED',
           posted_by_staff_id = v_warehouse_approver, posted_at = CURRENT_TIMESTAMP
     WHERE inventory_document_id = v_document;
    INSERT INTO inventory_transactions
        (inventory_document_id, variant_id, actor_staff_id, transaction_type,
         quantity_change, reason, idempotency_key)
    VALUES (v_document, v_core, v_warehouse_approver, 'ADJUSTMENT', -1,
            'Chênh lệch kiểm kê giả lập: thiếu một đôi.', UUID());

    INSERT INTO audit_logs
        (actor_type, actor_account_id, permission_key, action_name, resource_type,
         resource_id, action_result, after_data, request_id)
    VALUES
        ('STAFF', v_warehouse_approver, 'purchase_order.approve', 'DEMO_PO_APPROVE',
         'purchase_orders', CAST(v_po AS CHAR), 'SUCCESS', JSON_OBJECT('status', 'RECEIVED'), UUID()),
        ('STAFF', v_warehouse_approver, 'inventory.receive', 'DEMO_STOCK_RECEIPT',
         'product_variants', CAST(v_sprint AS CHAR), 'SUCCESS', JSON_OBJECT('stock_after', 99), UUID()),
        ('STAFF', v_sales, 'after_sales.status.update', 'DEMO_RETURN_COMPLETE',
         'orders', CAST(v_order AS CHAR), 'SUCCESS', JSON_OBJECT('refund', 1240000), UUID());

    COMMIT;
END$$
DELIMITER ;

CALL seed_aura_demo_journey(@demo_password_hash);
DROP PROCEDURE seed_aura_demo_journey;
