/* Convert every numeric identifier and its references to signed INT.
   Keep quantity/ledger BIGINT columns and all existing triggers unchanged.
   MySQL DDL is not atomic: back up a populated database before applying.
   V1 remains immutable for Flyway checksum validation. */

CREATE TEMPORARY TABLE id_int_range_guard (
    must_fit TINYINT NOT NULL,
    CONSTRAINT ck_id_int_range_guard CHECK (must_fit = 1)
) ENGINE=InnoDB;

INSERT INTO id_int_range_guard (must_fit)
SELECT CASE WHEN
    EXISTS (SELECT 1 FROM accounts WHERE account_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM google_oauth_tokens WHERE account_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM customers WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM staffs WHERE staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM audit_logs WHERE audit_log_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM audit_logs WHERE actor_account_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM addresses WHERE address_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM addresses WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM addresses WHERE active_default_customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM brands WHERE brand_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM categories WHERE category_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM categories WHERE parent_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM products WHERE product_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM products WHERE brand_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM products WHERE category_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM product_variants WHERE variant_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM product_variants WHERE product_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM product_images WHERE image_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM product_images WHERE product_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM product_images WHERE primary_product_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM suppliers WHERE supplier_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_orders WHERE purchase_order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_orders WHERE supplier_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_orders WHERE created_by_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_orders WHERE approved_by_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_order_items WHERE purchase_order_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_order_items WHERE purchase_order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM purchase_order_items WHERE variant_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_documents WHERE inventory_document_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_documents WHERE purchase_order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_documents WHERE source_order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_documents WHERE created_by_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_documents WHERE approved_by_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_documents WHERE posted_by_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_transactions WHERE inventory_transaction_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_transactions WHERE inventory_document_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_transactions WHERE variant_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_transactions WHERE purchase_order_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM inventory_transactions WHERE actor_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM cart_items WHERE cart_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM cart_items WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM cart_items WHERE variant_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM wishlist_items WHERE wishlist_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM wishlist_items WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM wishlist_items WHERE product_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM vouchers WHERE voucher_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM shipping_methods WHERE shipping_method_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM orders WHERE order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM orders WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM orders WHERE shipping_address_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM orders WHERE shipping_method_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM orders WHERE voucher_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_items WHERE order_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_items WHERE order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_items WHERE product_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_items WHERE variant_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_status_history WHERE order_status_history_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_status_history WHERE order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM order_status_history WHERE changed_by_account_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM payments WHERE payment_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM payments WHERE order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM payments WHERE parent_payment_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM after_sales_requests WHERE after_sales_request_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM after_sales_requests WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM after_sales_requests WHERE order_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM after_sales_requests WHERE order_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM after_sales_requests WHERE exchange_variant_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM after_sales_requests WHERE handled_by_staff_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM reviews WHERE review_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM reviews WHERE customer_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM reviews WHERE order_item_id > 2147483647)
 OR     EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = DATABASE()
                AND auto_increment > 2147483647)
THEN 0 ELSE 1 END;
DROP TEMPORARY TABLE id_int_range_guard;

DROP VIEW v_inventory_status;
DROP VIEW v_purchase_order_progress;

ALTER TABLE google_oauth_tokens
    DROP FOREIGN KEY fk_google_oauth_tokens_account;
ALTER TABLE customers
    DROP FOREIGN KEY fk_customers_account_type;
ALTER TABLE staffs
    DROP FOREIGN KEY fk_staffs_account_type,
    DROP FOREIGN KEY fk_staffs_role;
ALTER TABLE role_permissions
    DROP FOREIGN KEY fk_role_permissions_role,
    DROP FOREIGN KEY fk_role_permissions_permission;
ALTER TABLE audit_logs
    DROP FOREIGN KEY fk_audit_logs_account;
ALTER TABLE addresses
    DROP FOREIGN KEY fk_addresses_customer;
ALTER TABLE categories
    DROP FOREIGN KEY fk_categories_parent;
ALTER TABLE products
    DROP FOREIGN KEY fk_products_brand,
    DROP FOREIGN KEY fk_products_category;
ALTER TABLE product_variants
    DROP FOREIGN KEY fk_product_variants_product;
ALTER TABLE product_images
    DROP FOREIGN KEY fk_product_images_product;
ALTER TABLE purchase_orders
    DROP FOREIGN KEY fk_purchase_orders_supplier,
    DROP FOREIGN KEY fk_purchase_orders_creator,
    DROP FOREIGN KEY fk_purchase_orders_approver;
ALTER TABLE purchase_order_items
    DROP FOREIGN KEY fk_purchase_order_items_order,
    DROP FOREIGN KEY fk_purchase_order_items_variant;
ALTER TABLE inventory_documents
    DROP FOREIGN KEY fk_inventory_documents_purchase_order,
    DROP FOREIGN KEY fk_inventory_documents_creator,
    DROP FOREIGN KEY fk_inventory_documents_approver,
    DROP FOREIGN KEY fk_inventory_documents_poster,
    DROP FOREIGN KEY fk_inventory_documents_source_order;
ALTER TABLE inventory_transactions
    DROP FOREIGN KEY fk_inventory_transactions_document,
    DROP FOREIGN KEY fk_inventory_transactions_variant,
    DROP FOREIGN KEY fk_inventory_transactions_po_item,
    DROP FOREIGN KEY fk_inventory_transactions_actor;
ALTER TABLE cart_items
    DROP FOREIGN KEY fk_cart_items_customer,
    DROP FOREIGN KEY fk_cart_items_variant;
ALTER TABLE wishlist_items
    DROP FOREIGN KEY fk_wishlist_items_customer,
    DROP FOREIGN KEY fk_wishlist_items_product;
ALTER TABLE orders
    DROP FOREIGN KEY fk_orders_customer,
    DROP FOREIGN KEY fk_orders_address_customer,
    DROP FOREIGN KEY fk_orders_shipping_method,
    DROP FOREIGN KEY fk_orders_voucher;
ALTER TABLE order_items
    DROP FOREIGN KEY fk_order_items_order,
    DROP FOREIGN KEY fk_order_items_product_variant;
ALTER TABLE order_status_history
    DROP FOREIGN KEY fk_order_status_history_order,
    DROP FOREIGN KEY fk_order_status_history_account;
ALTER TABLE payments
    DROP FOREIGN KEY fk_payments_order,
    DROP FOREIGN KEY fk_payments_parent_order;
ALTER TABLE after_sales_requests
    DROP FOREIGN KEY fk_after_sales_order_customer,
    DROP FOREIGN KEY fk_after_sales_item_order,
    DROP FOREIGN KEY fk_after_sales_exchange_variant,
    DROP FOREIGN KEY fk_after_sales_handler;
ALTER TABLE reviews
    DROP FOREIGN KEY fk_reviews_customer,
    DROP FOREIGN KEY fk_reviews_order_item;

ALTER TABLE addresses
    DROP INDEX uq_addresses_one_default,
    DROP COLUMN active_default_customer_id;

ALTER TABLE product_images
    DROP INDEX uq_product_images_primary,
    DROP COLUMN primary_product_id;

ALTER TABLE accounts
    MODIFY COLUMN account_id INT NOT NULL AUTO_INCREMENT;
ALTER TABLE google_oauth_tokens
    MODIFY COLUMN account_id INT NOT NULL;
ALTER TABLE customers
    MODIFY COLUMN customer_id INT NOT NULL;
ALTER TABLE staffs
    MODIFY COLUMN staff_id INT NOT NULL;
ALTER TABLE audit_logs
    MODIFY COLUMN audit_log_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN actor_account_id INT NULL;
ALTER TABLE addresses
    MODIFY COLUMN address_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN customer_id INT NOT NULL;
ALTER TABLE brands
    MODIFY COLUMN brand_id INT NOT NULL AUTO_INCREMENT;
ALTER TABLE categories
    MODIFY COLUMN category_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN parent_id INT NULL;
ALTER TABLE products
    MODIFY COLUMN product_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN brand_id INT NOT NULL,
    MODIFY COLUMN category_id INT NOT NULL;
ALTER TABLE product_variants
    MODIFY COLUMN variant_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN product_id INT NOT NULL;
ALTER TABLE product_images
    MODIFY COLUMN image_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN product_id INT NOT NULL;
ALTER TABLE suppliers
    MODIFY COLUMN supplier_id INT NOT NULL AUTO_INCREMENT;
ALTER TABLE purchase_orders
    MODIFY COLUMN purchase_order_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN supplier_id INT NOT NULL,
    MODIFY COLUMN created_by_staff_id INT NOT NULL,
    MODIFY COLUMN approved_by_staff_id INT NULL;
ALTER TABLE purchase_order_items
    MODIFY COLUMN purchase_order_item_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN purchase_order_id INT NOT NULL,
    MODIFY COLUMN variant_id INT NOT NULL;
ALTER TABLE inventory_documents
    MODIFY COLUMN inventory_document_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN purchase_order_id INT NULL,
    MODIFY COLUMN source_order_id INT NULL,
    MODIFY COLUMN created_by_staff_id INT NOT NULL,
    MODIFY COLUMN approved_by_staff_id INT NULL,
    MODIFY COLUMN posted_by_staff_id INT NULL;
ALTER TABLE inventory_transactions
    MODIFY COLUMN inventory_transaction_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN inventory_document_id INT NOT NULL,
    MODIFY COLUMN variant_id INT NOT NULL,
    MODIFY COLUMN purchase_order_item_id INT NULL,
    MODIFY COLUMN actor_staff_id INT NOT NULL;
ALTER TABLE cart_items
    MODIFY COLUMN cart_item_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN customer_id INT NOT NULL,
    MODIFY COLUMN variant_id INT NOT NULL;
ALTER TABLE wishlist_items
    MODIFY COLUMN wishlist_item_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN customer_id INT NOT NULL,
    MODIFY COLUMN product_id INT NOT NULL;
ALTER TABLE vouchers
    MODIFY COLUMN voucher_id INT NOT NULL AUTO_INCREMENT;
ALTER TABLE shipping_methods
    MODIFY COLUMN shipping_method_id INT NOT NULL AUTO_INCREMENT;
ALTER TABLE orders
    MODIFY COLUMN order_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN customer_id INT NOT NULL,
    MODIFY COLUMN shipping_address_id INT NULL,
    MODIFY COLUMN shipping_method_id INT NULL,
    MODIFY COLUMN voucher_id INT NULL;
ALTER TABLE order_items
    MODIFY COLUMN order_item_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN order_id INT NOT NULL,
    MODIFY COLUMN product_id INT NOT NULL,
    MODIFY COLUMN variant_id INT NOT NULL;
ALTER TABLE order_status_history
    MODIFY COLUMN order_status_history_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN order_id INT NOT NULL,
    MODIFY COLUMN changed_by_account_id INT NULL;
ALTER TABLE payments
    MODIFY COLUMN payment_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN order_id INT NOT NULL,
    MODIFY COLUMN parent_payment_id INT NULL;
ALTER TABLE after_sales_requests
    MODIFY COLUMN after_sales_request_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN customer_id INT NOT NULL,
    MODIFY COLUMN order_id INT NOT NULL,
    MODIFY COLUMN order_item_id INT NOT NULL,
    MODIFY COLUMN exchange_variant_id INT NULL,
    MODIFY COLUMN handled_by_staff_id INT NULL;
ALTER TABLE reviews
    MODIFY COLUMN review_id INT NOT NULL AUTO_INCREMENT,
    MODIFY COLUMN customer_id INT NOT NULL,
    MODIFY COLUMN order_item_id INT NOT NULL;

ALTER TABLE addresses
    ADD COLUMN active_default_customer_id INT GENERATED ALWAYS AS (
        IF(is_default = TRUE AND deleted_at IS NULL, customer_id, NULL)
    ) STORED,
    ADD CONSTRAINT uq_addresses_one_default UNIQUE (active_default_customer_id);

ALTER TABLE product_images
    ADD COLUMN primary_product_id INT GENERATED ALWAYS AS (
        IF(is_primary = TRUE, product_id, NULL)
    ) STORED,
    ADD CONSTRAINT uq_product_images_primary UNIQUE (primary_product_id);

ALTER TABLE google_oauth_tokens
    ADD CONSTRAINT fk_google_oauth_tokens_account FOREIGN KEY (account_id)
        REFERENCES accounts (account_id) ON DELETE CASCADE;
ALTER TABLE customers
    ADD CONSTRAINT fk_customers_account_type FOREIGN KEY (customer_id, account_type)
        REFERENCES accounts (account_id, account_type) ON DELETE CASCADE;
ALTER TABLE staffs
    ADD CONSTRAINT fk_staffs_account_type FOREIGN KEY (staff_id, account_type)
        REFERENCES accounts (account_id, account_type) ON DELETE CASCADE,
    ADD CONSTRAINT fk_staffs_role FOREIGN KEY (role_code)
        REFERENCES roles (role_code) ON DELETE RESTRICT;
ALTER TABLE role_permissions
    ADD CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_code)
        REFERENCES roles (role_code) ON DELETE CASCADE,
    ADD CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_key)
        REFERENCES permissions (permission_key) ON DELETE CASCADE;
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_logs_account FOREIGN KEY (actor_account_id)
        REFERENCES accounts (account_id) ON DELETE RESTRICT;
ALTER TABLE addresses
    ADD CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT;
ALTER TABLE categories
    ADD CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id)
        REFERENCES categories (category_id) ON DELETE RESTRICT;
ALTER TABLE products
    ADD CONSTRAINT fk_products_brand FOREIGN KEY (brand_id)
        REFERENCES brands (brand_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id) ON DELETE RESTRICT;
ALTER TABLE product_variants
    ADD CONSTRAINT fk_product_variants_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON DELETE RESTRICT;
ALTER TABLE product_images
    ADD CONSTRAINT fk_product_images_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON DELETE RESTRICT;
ALTER TABLE purchase_orders
    ADD CONSTRAINT fk_purchase_orders_supplier FOREIGN KEY (supplier_id)
        REFERENCES suppliers (supplier_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_purchase_orders_creator FOREIGN KEY (created_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_purchase_orders_approver FOREIGN KEY (approved_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT;
ALTER TABLE purchase_order_items
    ADD CONSTRAINT fk_purchase_order_items_order FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders (purchase_order_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_purchase_order_items_variant FOREIGN KEY (variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT;
ALTER TABLE inventory_documents
    ADD CONSTRAINT fk_inventory_documents_purchase_order FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders (purchase_order_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_documents_creator FOREIGN KEY (created_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_documents_approver FOREIGN KEY (approved_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_documents_poster FOREIGN KEY (posted_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_documents_source_order FOREIGN KEY (source_order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT;
ALTER TABLE inventory_transactions
    ADD CONSTRAINT fk_inventory_transactions_document FOREIGN KEY (inventory_document_id)
        REFERENCES inventory_documents (inventory_document_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_transactions_variant FOREIGN KEY (variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_transactions_po_item FOREIGN KEY (purchase_order_item_id)
        REFERENCES purchase_order_items (purchase_order_item_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_transactions_actor FOREIGN KEY (actor_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT;
ALTER TABLE cart_items
    ADD CONSTRAINT fk_cart_items_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_cart_items_variant FOREIGN KEY (variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT;
ALTER TABLE wishlist_items
    ADD CONSTRAINT fk_wishlist_items_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_wishlist_items_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON DELETE CASCADE;
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_orders_address_customer FOREIGN KEY (shipping_address_id, customer_id)
        REFERENCES addresses (address_id, customer_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_orders_shipping_method FOREIGN KEY (shipping_method_id)
        REFERENCES shipping_methods (shipping_method_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_orders_voucher FOREIGN KEY (voucher_id)
        REFERENCES vouchers (voucher_id) ON DELETE SET NULL;
ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_order_items_product_variant FOREIGN KEY (product_id, variant_id)
        REFERENCES product_variants (product_id, variant_id) ON DELETE RESTRICT;
ALTER TABLE order_status_history
    ADD CONSTRAINT fk_order_status_history_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_order_status_history_account FOREIGN KEY (changed_by_account_id)
        REFERENCES accounts (account_id) ON DELETE RESTRICT;
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_payments_parent_order FOREIGN KEY (parent_payment_id, order_id)
        REFERENCES payments (payment_id, order_id) ON DELETE RESTRICT;
ALTER TABLE after_sales_requests
    ADD CONSTRAINT fk_after_sales_order_customer FOREIGN KEY (order_id, customer_id)
        REFERENCES orders (order_id, customer_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_after_sales_item_order FOREIGN KEY (order_item_id, order_id)
        REFERENCES order_items (order_item_id, order_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_after_sales_exchange_variant FOREIGN KEY (exchange_variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_after_sales_handler FOREIGN KEY (handled_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT;
ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_reviews_order_item FOREIGN KEY (order_item_id)
        REFERENCES order_items (order_item_id) ON DELETE RESTRICT;

CREATE VIEW v_inventory_status AS
SELECT
    pv.variant_id,
    pv.sku,
    p.product_name,
    pv.color_name,
    pv.size_code,
    pv.stock_quantity,
    pv.reserved_quantity,
    pv.available_quantity,
    pv.low_stock_threshold,
    (pv.available_quantity <= pv.low_stock_threshold) AS is_low_stock,
    pv.updated_at
FROM product_variants pv
JOIN products p ON p.product_id = pv.product_id;

CREATE VIEW v_purchase_order_progress AS
SELECT
    po.purchase_order_id,
    po.po_code,
    po.supplier_id,
    po.status,
    COUNT(poi.purchase_order_item_id) AS line_count,
    COALESCE(SUM(poi.ordered_quantity), 0) AS total_ordered_quantity,
    COALESCE(SUM(poi.received_quantity), 0) AS total_received_quantity,
    COALESCE(SUM(poi.line_total), 0) AS total_ordered_amount
FROM purchase_orders po
LEFT JOIN purchase_order_items poi
  ON poi.purchase_order_id = po.purchase_order_id
GROUP BY po.purchase_order_id, po.po_code, po.supplier_id, po.status;

