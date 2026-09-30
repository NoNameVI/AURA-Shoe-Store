/*
 * AURA Store initial schema.
 *
 * Generated from AURA_database_core_mysql8_0.sql.
 * The database itself must already exist; Flyway owns all objects inside it.
 * Do not add DROP DATABASE, CREATE DATABASE, or USE statements here.
 */

SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;
SET time_zone = '+00:00';

/* ============================== 1. IAM / RBAC ============================== */

CREATE TABLE roles (
    role_code             VARCHAR(50) NOT NULL,
    role_name             VARCHAR(100) COLLATE utf8mb4_vi_0900_ai_ci NOT NULL,
    description           VARCHAR(500) COLLATE utf8mb4_vi_0900_ai_ci NULL,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                          ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_roles PRIMARY KEY (role_code),
    CONSTRAINT uq_roles_name UNIQUE (role_name),
    CONSTRAINT ck_roles_code
        CHECK (role_code IN ('SALES', 'WAREHOUSE', 'SYSTEM_ADMIN'))
) ENGINE=InnoDB;

CREATE TABLE permissions (
    permission_key        VARCHAR(120) NOT NULL,
    permission_name       VARCHAR(150) COLLATE utf8mb4_vi_0900_ai_ci NOT NULL,
    module_code           VARCHAR(50) NOT NULL,
    description           VARCHAR(500) COLLATE utf8mb4_vi_0900_ai_ci NULL,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                          ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_permissions PRIMARY KEY (permission_key),
    CONSTRAINT uq_permissions_name UNIQUE (permission_name),
    INDEX ix_permissions_module_active (module_code, is_active)
) ENGINE=InnoDB;

CREATE TABLE accounts (
    account_id             BIGINT UNSIGNED AUTO_INCREMENT,
    username               VARCHAR(50) NOT NULL,
    email                  VARCHAR(255) NOT NULL,
    phone                  VARCHAR(20) NULL,
    password_hash          VARCHAR(255) NULL,
    is_google_auth         BOOLEAN NOT NULL DEFAULT FALSE,
    oauth_subject          VARCHAR(255) NULL,
    full_name              VARCHAR(150) COLLATE utf8mb4_vi_0900_ai_ci NOT NULL,
    avatar_url             VARCHAR(500) NULL,
    account_type           VARCHAR(20) NOT NULL,
    account_status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_login_attempts  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    locked_until           DATETIME(6) NULL,
    deleted_at             DATETIME(6) NULL,
    created_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                           ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_accounts PRIMARY KEY (account_id),
    CONSTRAINT uq_accounts_username UNIQUE (username),
    CONSTRAINT uq_accounts_email UNIQUE (email),
    CONSTRAINT uq_accounts_oauth UNIQUE (is_google_auth, oauth_subject),
    CONSTRAINT uq_accounts_id_type UNIQUE (account_id, account_type),
    CONSTRAINT ck_accounts_type CHECK (account_type IN ('CUSTOMER', 'STAFF')),
    CONSTRAINT ck_accounts_auth_consistency CHECK (
        (is_google_auth = FALSE AND password_hash IS NOT NULL)
        OR (is_google_auth = TRUE AND oauth_subject IS NOT NULL)
    ),
    CONSTRAINT ck_accounts_status
        CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'LOCKED')),
    CONSTRAINT ck_accounts_phone
        CHECK (phone IS NULL OR phone REGEXP '^(0|\\+84)[35789][0-9]{8}$'),
    CONSTRAINT ck_accounts_email
        CHECK (email REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$'),
    INDEX ix_accounts_type_status (account_type, account_status, deleted_at),
    INDEX ix_accounts_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE google_oauth_tokens (
    account_id                    BIGINT UNSIGNED NOT NULL,
    access_token_encrypted        TEXT NOT NULL,
    refresh_token_encrypted       TEXT NULL,
    token_type                    VARCHAR(30) NOT NULL DEFAULT 'Bearer',
    granted_scopes                TEXT NULL,
    access_token_expires_at       DATETIME(6) NOT NULL,
    refresh_token_expires_at      DATETIME(6) NULL,
    last_refreshed_at             DATETIME(6) NULL,
    revoked_at                    DATETIME(6) NULL,
    created_at                    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at                    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                  ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_google_oauth_tokens PRIMARY KEY (account_id),
    CONSTRAINT fk_google_oauth_tokens_account FOREIGN KEY (account_id)
        REFERENCES accounts (account_id) ON DELETE CASCADE,
    CONSTRAINT ck_google_oauth_tokens_type
        CHECK (CHAR_LENGTH(TRIM(token_type)) > 0),
    CONSTRAINT ck_google_oauth_tokens_access_expiry
        CHECK (access_token_expires_at > created_at),
    CONSTRAINT ck_google_oauth_tokens_refresh_expiry
        CHECK (
            refresh_token_expires_at IS NULL
            OR refresh_token_expires_at > created_at
        ),
    INDEX ix_google_oauth_tokens_access_expiry
        (access_token_expires_at, revoked_at)
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id            BIGINT UNSIGNED NOT NULL,
    account_type           VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    foot_length_mm         SMALLINT UNSIGNED NULL,
    preferred_size         VARCHAR(10) NULL,
    created_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                           ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT fk_customers_account_type FOREIGN KEY (customer_id, account_type)
        REFERENCES accounts (account_id, account_type) ON DELETE CASCADE,
    CONSTRAINT ck_customers_account_type CHECK (account_type = 'CUSTOMER'),
    CONSTRAINT ck_customers_foot_length
        CHECK (foot_length_mm IS NULL OR foot_length_mm BETWEEN 100 AND 400)
) ENGINE=InnoDB;

CREATE TABLE staffs (
    staff_id               BIGINT UNSIGNED NOT NULL,
    account_type           VARCHAR(20) NOT NULL DEFAULT 'STAFF',
    role_code              VARCHAR(50) NOT NULL,
    must_change_password   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                           ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_staffs PRIMARY KEY (staff_id),
    CONSTRAINT fk_staffs_account_type FOREIGN KEY (staff_id, account_type)
        REFERENCES accounts (account_id, account_type) ON DELETE CASCADE,
    CONSTRAINT fk_staffs_role FOREIGN KEY (role_code)
        REFERENCES roles (role_code) ON DELETE RESTRICT,
    CONSTRAINT ck_staffs_account_type CHECK (account_type = 'STAFF'),
    CONSTRAINT ck_staffs_role
        CHECK (role_code IN ('SALES', 'WAREHOUSE', 'SYSTEM_ADMIN')),
    INDEX ix_staffs_role (role_code)
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
    role_code             VARCHAR(50) NOT NULL,
    permission_key        VARCHAR(120) NOT NULL,
    CONSTRAINT pk_role_permissions PRIMARY KEY (role_code, permission_key),
    CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_code)
        REFERENCES roles (role_code) ON DELETE CASCADE,
    CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_key)
        REFERENCES permissions (permission_key) ON DELETE CASCADE,
    CONSTRAINT ck_role_permissions_role
        CHECK (role_code IN ('SALES', 'WAREHOUSE', 'SYSTEM_ADMIN')),
    INDEX ix_role_permissions_key (permission_key)
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    audit_log_id         BIGINT UNSIGNED AUTO_INCREMENT,
    actor_type           VARCHAR(20) NOT NULL,
    actor_account_id     BIGINT UNSIGNED NULL,
    permission_key       VARCHAR(120) NULL,
    action_name          VARCHAR(120) NOT NULL,
    resource_type        VARCHAR(80) NOT NULL,
    resource_id          VARCHAR(100) NULL,
    action_result        VARCHAR(20) NOT NULL,
    before_data          JSON NULL,
    after_data           JSON NULL,
    request_id           CHAR(36) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_audit_logs PRIMARY KEY (audit_log_id),
    CONSTRAINT fk_audit_logs_account FOREIGN KEY (actor_account_id)
        REFERENCES accounts (account_id) ON DELETE RESTRICT,
    CONSTRAINT ck_audit_logs_actor CHECK (
        (actor_type IN ('CUSTOMER', 'STAFF') AND actor_account_id IS NOT NULL)
        OR (actor_type = 'SYSTEM' AND actor_account_id IS NULL)
    ),
    CONSTRAINT ck_audit_logs_result
        CHECK (action_result IN ('SUCCESS', 'DENIED', 'FAILED')),
    INDEX ix_audit_logs_account_time (actor_account_id, created_at),
    INDEX ix_audit_logs_resource (resource_type, resource_id, created_at),
    INDEX ix_audit_logs_request (request_id)
) ENGINE=InnoDB;

/* ============================== 2. CUSTOMER ================================ */

CREATE TABLE addresses (
    address_id           BIGINT UNSIGNED AUTO_INCREMENT,
    customer_id          BIGINT UNSIGNED NOT NULL,
    recipient_name       VARCHAR(150) NOT NULL,
    phone                VARCHAR(20) NOT NULL,
    province_code        CHAR(2) NOT NULL,
    province_name        VARCHAR(100) NOT NULL,
    ward_code            CHAR(5) NOT NULL,
    ward_name            VARCHAR(120) NOT NULL,
    address_line         VARCHAR(255) NOT NULL,
    is_default           BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at           DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    active_default_customer_id BIGINT UNSIGNED GENERATED ALWAYS AS (
        IF(is_default = TRUE AND deleted_at IS NULL, customer_id, NULL)
    ) STORED,
    CONSTRAINT pk_addresses PRIMARY KEY (address_id),
    CONSTRAINT uq_addresses_one_default UNIQUE (active_default_customer_id),
    CONSTRAINT uq_addresses_address_customer UNIQUE (address_id, customer_id),
    CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    CONSTRAINT ck_addresses_phone
        CHECK (phone REGEXP '^(0|\\+84)[35789][0-9]{8}$'),
    INDEX ix_addresses_customer_active (customer_id, deleted_at)
) ENGINE=InnoDB;

/* =============================== 3. CATALOG ================================ */

CREATE TABLE brands (
    brand_id             INT UNSIGNED AUTO_INCREMENT,
    brand_name           VARCHAR(150) COLLATE utf8mb4_vi_0900_as_cs NOT NULL,
    slug                 VARCHAR(160) NOT NULL,
    description          VARCHAR(1000) NULL,
    logo_url             VARCHAR(500) NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_brands PRIMARY KEY (brand_id),
    CONSTRAINT uq_brands_name UNIQUE (brand_name),
    CONSTRAINT uq_brands_slug UNIQUE (slug)
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id          INT UNSIGNED AUTO_INCREMENT,
    parent_id            INT UNSIGNED NULL,
    category_name        VARCHAR(150) NOT NULL,
    slug                 VARCHAR(160) NOT NULL,
    description          VARCHAR(1000) NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_slug UNIQUE (slug),
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id)
        REFERENCES categories (category_id) ON DELETE RESTRICT,
    INDEX ix_categories_parent_active (parent_id, is_active)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id           BIGINT UNSIGNED AUTO_INCREMENT,
    brand_id             INT UNSIGNED NOT NULL,
    category_id          INT UNSIGNED NOT NULL,
    product_name         VARCHAR(180) NOT NULL,
    slug                 VARCHAR(200) NOT NULL,
    style_code           VARCHAR(100) NULL,
    description          VARCHAR(3000) NULL,
    publication_status   VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    archived_at          DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT uq_products_slug UNIQUE (slug),
    CONSTRAINT uq_products_style_code UNIQUE (style_code),
    CONSTRAINT fk_products_brand FOREIGN KEY (brand_id)
        REFERENCES brands (brand_id) ON DELETE RESTRICT,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id) ON DELETE RESTRICT,
    CONSTRAINT ck_products_status
        CHECK (publication_status IN ('DRAFT', 'ACTIVE', 'INACTIVE', 'ARCHIVED')),
    INDEX ix_products_catalog (publication_status, category_id, brand_id),
    FULLTEXT INDEX ft_products_search (product_name, description)
) ENGINE=InnoDB;

CREATE TABLE product_variants (
    variant_id           BIGINT UNSIGNED AUTO_INCREMENT,
    product_id           BIGINT UNSIGNED NOT NULL,
    sku                  VARCHAR(100) NOT NULL,
    color_name           VARCHAR(100) NOT NULL,
    size_code            VARCHAR(10) NOT NULL,
    sale_price           DECIMAL(18,2) NOT NULL,
    cost_price           DECIMAL(18,2) NOT NULL DEFAULT 0,
    stock_quantity       BIGINT UNSIGNED NOT NULL DEFAULT 0,
    reserved_quantity    BIGINT UNSIGNED NOT NULL DEFAULT 0,
    available_quantity   BIGINT GENERATED ALWAYS AS (
        CAST(stock_quantity AS SIGNED) - CAST(reserved_quantity AS SIGNED)
    ) STORED,
    low_stock_threshold  BIGINT UNSIGNED NOT NULL DEFAULT 5,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_product_variants PRIMARY KEY (variant_id),
    CONSTRAINT uq_product_variants_sku UNIQUE (sku),
    CONSTRAINT uq_product_variants_dimensions UNIQUE (product_id, color_name, size_code),
    CONSTRAINT uq_product_variants_product_variant UNIQUE (product_id, variant_id),
    CONSTRAINT fk_product_variants_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON DELETE RESTRICT,
    CONSTRAINT ck_product_variants_price CHECK (sale_price >= 0 AND cost_price >= 0),
    CONSTRAINT ck_product_variants_stock CHECK (reserved_quantity <= stock_quantity),
    INDEX ix_product_variants_sellable (product_id, is_active, available_quantity)
) ENGINE=InnoDB;

CREATE TABLE product_images (
    image_id             BIGINT UNSIGNED AUTO_INCREMENT,
    product_id           BIGINT UNSIGNED NOT NULL,
    image_url            VARCHAR(500) NOT NULL,
    alt_text             VARCHAR(255) NOT NULL DEFAULT '',
    display_order        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    is_primary           BOOLEAN NOT NULL DEFAULT FALSE,
    primary_product_id   BIGINT UNSIGNED GENERATED ALWAYS AS (
        IF(is_primary = TRUE, product_id, NULL)
    ) STORED,
    CONSTRAINT pk_product_images PRIMARY KEY (image_id),
    CONSTRAINT uq_product_images_primary UNIQUE (primary_product_id),
    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON DELETE RESTRICT,
    INDEX ix_product_images_gallery (product_id, display_order)
) ENGINE=InnoDB;

/* =========================== 4. PROCUREMENT / STOCK ======================= */

CREATE TABLE suppliers (
    supplier_id          BIGINT UNSIGNED AUTO_INCREMENT,
    supplier_code        VARCHAR(50) NOT NULL,
    supplier_name        VARCHAR(180) NOT NULL,
    contact_name         VARCHAR(150) NULL,
    phone                VARCHAR(20) NULL,
    email                VARCHAR(255) NULL,
    tax_code             VARCHAR(20) NULL,
    address_text         VARCHAR(500) NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_suppliers PRIMARY KEY (supplier_id),
    CONSTRAINT uq_suppliers_code UNIQUE (supplier_code),
    CONSTRAINT uq_suppliers_tax_code UNIQUE (tax_code),
    CONSTRAINT ck_suppliers_tax_code
        CHECK (tax_code IS NULL OR tax_code REGEXP '^[0-9]{10}(-[0-9]{3})?$')
) ENGINE=InnoDB;

CREATE TABLE purchase_orders (
    purchase_order_id    BIGINT UNSIGNED AUTO_INCREMENT,
    po_code              VARCHAR(50) NOT NULL,
    supplier_id          BIGINT UNSIGNED NOT NULL,
    status               VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_by_staff_id  BIGINT UNSIGNED NOT NULL,
    approved_by_staff_id BIGINT UNSIGNED NULL,
    approved_at          DATETIME(6) NULL,
    note                 VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_purchase_orders PRIMARY KEY (purchase_order_id),
    CONSTRAINT uq_purchase_orders_code UNIQUE (po_code),
    CONSTRAINT fk_purchase_orders_supplier FOREIGN KEY (supplier_id)
        REFERENCES suppliers (supplier_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_orders_creator FOREIGN KEY (created_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_orders_approver FOREIGN KEY (approved_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_purchase_orders_status
        CHECK (status IN ('PENDING', 'APPROVED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'CANCELLED')),
    CONSTRAINT ck_purchase_orders_separation
        CHECK (approved_by_staff_id IS NULL OR approved_by_staff_id <> created_by_staff_id),
    CONSTRAINT ck_purchase_orders_approval_state CHECK (
        (status = 'PENDING' AND approved_by_staff_id IS NULL AND approved_at IS NULL)
        OR (status IN ('APPROVED', 'PARTIALLY_RECEIVED', 'RECEIVED')
            AND approved_by_staff_id IS NOT NULL AND approved_at IS NOT NULL)
        OR (status = 'CANCELLED'
            AND ((approved_by_staff_id IS NULL AND approved_at IS NULL)
                 OR (approved_by_staff_id IS NOT NULL AND approved_at IS NOT NULL)))
    ),
    INDEX ix_purchase_orders_supplier_time (supplier_id, created_at),
    INDEX ix_purchase_orders_status_time (status, created_at)
) ENGINE=InnoDB;

CREATE TABLE purchase_order_items (
    purchase_order_item_id BIGINT UNSIGNED AUTO_INCREMENT,
    purchase_order_id    BIGINT UNSIGNED NOT NULL,
    variant_id           BIGINT UNSIGNED NOT NULL,
    ordered_quantity     INT UNSIGNED NOT NULL,
    received_quantity    INT UNSIGNED NOT NULL DEFAULT 0,
    unit_cost            DECIMAL(18,2) NOT NULL,
    line_total           DECIMAL(20,2) GENERATED ALWAYS AS (ordered_quantity * unit_cost) STORED,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_purchase_order_items PRIMARY KEY (purchase_order_item_id),
    CONSTRAINT uq_purchase_order_items_variant UNIQUE (purchase_order_id, variant_id),
    CONSTRAINT fk_purchase_order_items_order FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders (purchase_order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_items_variant FOREIGN KEY (variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT,
    CONSTRAINT ck_purchase_order_items_quantity
        CHECK (ordered_quantity > 0 AND received_quantity <= ordered_quantity),
    CONSTRAINT ck_purchase_order_items_cost CHECK (unit_cost >= 0),
    INDEX ix_purchase_order_items_variant (variant_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_documents (
    inventory_document_id BIGINT UNSIGNED AUTO_INCREMENT,
    document_code        VARCHAR(50) NOT NULL,
    document_type        VARCHAR(20) NOT NULL,
    document_status      VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    purchase_order_id    BIGINT UNSIGNED NULL,
    source_order_id      BIGINT UNSIGNED NULL,
    created_by_staff_id  BIGINT UNSIGNED NOT NULL,
    approved_by_staff_id BIGINT UNSIGNED NULL,
    posted_by_staff_id   BIGINT UNSIGNED NULL,
    approved_at          DATETIME(6) NULL,
    posted_at            DATETIME(6) NULL,
    note                 VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_inventory_documents PRIMARY KEY (inventory_document_id),
    CONSTRAINT uq_inventory_documents_code UNIQUE (document_code),
    CONSTRAINT fk_inventory_documents_purchase_order FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders (purchase_order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_documents_creator FOREIGN KEY (created_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_documents_approver FOREIGN KEY (approved_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_documents_poster FOREIGN KEY (posted_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_inventory_documents_type CHECK (
        document_type IN ('RECEIPT', 'ISSUE', 'ADJUSTMENT')
    ),
    CONSTRAINT ck_inventory_documents_status CHECK (
        document_status IN ('DRAFT', 'APPROVED', 'POSTED', 'CANCELLED')
    ),
    CONSTRAINT ck_inventory_documents_approval CHECK (
        approved_by_staff_id IS NULL OR approved_by_staff_id <> created_by_staff_id
    ),
    CONSTRAINT ck_inventory_documents_dates CHECK (
        (document_status = 'DRAFT' AND approved_by_staff_id IS NULL
            AND approved_at IS NULL AND posted_by_staff_id IS NULL AND posted_at IS NULL)
        OR (document_status = 'APPROVED' AND approved_by_staff_id IS NOT NULL
            AND approved_at IS NOT NULL AND posted_by_staff_id IS NULL AND posted_at IS NULL)
        OR (document_status = 'POSTED' AND approved_by_staff_id IS NOT NULL
            AND approved_at IS NOT NULL AND posted_by_staff_id IS NOT NULL AND posted_at IS NOT NULL)
        OR (document_status = 'CANCELLED' AND posted_by_staff_id IS NULL AND posted_at IS NULL)
    ),
    CONSTRAINT ck_inventory_documents_business_source CHECK (
        (purchase_order_id IS NULL OR document_type = 'RECEIPT')
        AND (source_order_id IS NULL OR document_type IN ('RECEIPT', 'ISSUE'))
        AND NOT (purchase_order_id IS NOT NULL AND source_order_id IS NOT NULL)
    ),
    INDEX ix_inventory_documents_status_time (document_status, created_at),
    INDEX ix_inventory_documents_purchase_order (purchase_order_id),
    INDEX ix_inventory_documents_source_order (source_order_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_transactions (
    inventory_transaction_id BIGINT UNSIGNED AUTO_INCREMENT,
    inventory_document_id BIGINT UNSIGNED NOT NULL,
    variant_id           BIGINT UNSIGNED NOT NULL,
    purchase_order_item_id BIGINT UNSIGNED NULL,
    actor_staff_id       BIGINT UNSIGNED NOT NULL,
    transaction_type     VARCHAR(20) NOT NULL,
    quantity_change      BIGINT NOT NULL,
    balance_after        BIGINT UNSIGNED NOT NULL DEFAULT 0,
    unit_cost            DECIMAL(18,2) NULL,
    reason               VARCHAR(1000) NULL,
    idempotency_key      CHAR(36) NOT NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_inventory_transactions PRIMARY KEY (inventory_transaction_id),
    CONSTRAINT uq_inventory_transactions_idempotency UNIQUE (idempotency_key),
    CONSTRAINT uq_inventory_transactions_document_variant
        UNIQUE (inventory_document_id, variant_id),
    CONSTRAINT fk_inventory_transactions_document FOREIGN KEY (inventory_document_id)
        REFERENCES inventory_documents (inventory_document_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transactions_variant FOREIGN KEY (variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transactions_po_item FOREIGN KEY (purchase_order_item_id)
        REFERENCES purchase_order_items (purchase_order_item_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transactions_actor FOREIGN KEY (actor_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_inventory_transactions_type CHECK (
        transaction_type IN ('RECEIPT', 'ISSUE', 'ADJUSTMENT')
    ),
    CONSTRAINT ck_inventory_transactions_quantity CHECK (quantity_change <> 0),
    CONSTRAINT ck_inventory_transactions_cost CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CONSTRAINT ck_inventory_transactions_reason CHECK (
        transaction_type <> 'ADJUSTMENT' OR (reason IS NOT NULL AND TRIM(reason) <> '')
    ),
    INDEX ix_inventory_transactions_variant_time (variant_id, created_at),
    INDEX ix_inventory_transactions_document (inventory_document_id)
) ENGINE=InnoDB;

/* ============================== 5. STOREFRONT ============================== */

CREATE TABLE cart_items (
    cart_item_id         BIGINT UNSIGNED AUTO_INCREMENT,
    customer_id          BIGINT UNSIGNED NOT NULL,
    variant_id           BIGINT UNSIGNED NOT NULL,
    quantity             INT UNSIGNED NOT NULL DEFAULT 1,
    reserved_quantity    INT UNSIGNED NOT NULL DEFAULT 0,
    reservation_expires_at DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_cart_items PRIMARY KEY (cart_item_id),
    CONSTRAINT uq_cart_items_customer_variant UNIQUE (customer_id, variant_id),
    CONSTRAINT fk_cart_items_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cart_items_variant FOREIGN KEY (variant_id)
        REFERENCES product_variants (variant_id) ON DELETE RESTRICT,
    CONSTRAINT ck_cart_items_quantity
        CHECK (quantity > 0 AND reserved_quantity <= quantity),
    CONSTRAINT ck_cart_items_reservation CHECK (
        (reserved_quantity = 0 AND reservation_expires_at IS NULL)
        OR (reserved_quantity > 0 AND reservation_expires_at IS NOT NULL)
    ),
    INDEX ix_cart_items_reservation_expiry (reservation_expires_at),
    INDEX ix_cart_items_variant (variant_id)
) ENGINE=InnoDB;

CREATE TABLE wishlist_items (
    wishlist_item_id     BIGINT UNSIGNED AUTO_INCREMENT,
    customer_id          BIGINT UNSIGNED NOT NULL,
    product_id           BIGINT UNSIGNED NOT NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_wishlist_items PRIMARY KEY (wishlist_item_id),
    CONSTRAINT uq_wishlist_items_customer_product UNIQUE (customer_id, product_id),
    CONSTRAINT fk_wishlist_items_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_items_product FOREIGN KEY (product_id)
        REFERENCES products (product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE vouchers (
    voucher_id           BIGINT UNSIGNED AUTO_INCREMENT,
    voucher_code         VARCHAR(100) NOT NULL,
    voucher_name         VARCHAR(180) NOT NULL,
    discount_percentage  DECIMAL(5,2) NOT NULL,
    max_discount_amount  DECIMAL(18,2) NULL,
    min_order_amount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    usage_limit          INT UNSIGNED NULL,
    used_count           INT UNSIGNED NOT NULL DEFAULT 0,
    max_uses_per_user    INT UNSIGNED NOT NULL DEFAULT 1,
    start_at             DATETIME(6) NOT NULL,
    end_at               DATETIME(6) NOT NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_vouchers PRIMARY KEY (voucher_id),
    CONSTRAINT uq_vouchers_code UNIQUE (voucher_code),
    CONSTRAINT ck_vouchers_percentage
        CHECK (discount_percentage > 0 AND discount_percentage <= 100),
    CONSTRAINT ck_vouchers_amounts CHECK (
        min_order_amount >= 0 AND (max_discount_amount IS NULL OR max_discount_amount >= 0)
    ),
    CONSTRAINT ck_vouchers_usage CHECK (
        (usage_limit IS NULL OR used_count <= usage_limit) AND max_uses_per_user > 0
    ),
    CONSTRAINT ck_vouchers_period CHECK (end_at > start_at),
    INDEX ix_vouchers_available (is_active, start_at, end_at)
) ENGINE=InnoDB;

CREATE TABLE shipping_methods (
    shipping_method_id   INT UNSIGNED AUTO_INCREMENT,
    method_code          VARCHAR(50) NOT NULL,
    method_name          VARCHAR(120) NOT NULL,
    base_fee             DECIMAL(18,2) NOT NULL DEFAULT 0,
    estimated_days_min   SMALLINT UNSIGNED NULL,
    estimated_days_max   SMALLINT UNSIGNED NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_shipping_methods PRIMARY KEY (shipping_method_id),
    CONSTRAINT uq_shipping_methods_code UNIQUE (method_code),
    CONSTRAINT ck_shipping_methods_fee CHECK (base_fee >= 0),
    CONSTRAINT ck_shipping_methods_days CHECK (
        estimated_days_min IS NULL OR estimated_days_max IS NULL
        OR estimated_days_min <= estimated_days_max
    )
) ENGINE=InnoDB;

/* ================================ 6. ORDERS ================================ */

CREATE TABLE orders (
    order_id             BIGINT UNSIGNED AUTO_INCREMENT,
    order_code           VARCHAR(50) NOT NULL,
    customer_id          BIGINT UNSIGNED NOT NULL,
    shipping_address_id  BIGINT UNSIGNED NULL,
    shipping_method_id   INT UNSIGNED NULL,
    voucher_id           BIGINT UNSIGNED NULL,
    shipping_recipient_name VARCHAR(150) NOT NULL,
    shipping_phone       VARCHAR(20) NOT NULL,
    shipping_address_text VARCHAR(500) NOT NULL,
    shipping_method_name VARCHAR(120) NOT NULL,
    tracking_number      VARCHAR(120) NULL,
    voucher_code         VARCHAR(100) NULL,
    currency_code        CHAR(3) NOT NULL DEFAULT 'VND',
    subtotal_amount      DECIMAL(18,2) NOT NULL,
    discount_amount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    shipping_fee         DECIMAL(18,2) NOT NULL DEFAULT 0,
    total_amount         DECIMAL(18,2) GENERATED ALWAYS AS (
        subtotal_amount - discount_amount + shipping_fee
    ) STORED,
    order_status         VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    payment_method       VARCHAR(30) NOT NULL,
    payment_status       VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    customer_note        VARCHAR(1000) NULL,
    internal_note        VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT uq_orders_code UNIQUE (order_code),
    CONSTRAINT uq_orders_tracking UNIQUE (tracking_number),
    CONSTRAINT uq_orders_order_customer UNIQUE (order_id, customer_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_address_customer FOREIGN KEY (shipping_address_id, customer_id)
        REFERENCES addresses (address_id, customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_shipping_method FOREIGN KEY (shipping_method_id)
        REFERENCES shipping_methods (shipping_method_id) ON DELETE SET NULL,
    CONSTRAINT fk_orders_voucher FOREIGN KEY (voucher_id)
        REFERENCES vouchers (voucher_id) ON DELETE SET NULL,
    CONSTRAINT ck_orders_phone
        CHECK (shipping_phone REGEXP '^(0|\\+84)[35789][0-9]{8}$'),
    CONSTRAINT ck_orders_amounts CHECK (
        subtotal_amount >= 0 AND discount_amount >= 0
        AND shipping_fee >= 0 AND discount_amount <= subtotal_amount
    ),
    CONSTRAINT ck_orders_status CHECK (
        order_status IN ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED',
                         'DELIVERY_FAILED', 'CANCELLED', 'RETURN_REQUESTED', 'RETURNED', 'COMPLETED')
    ),
    CONSTRAINT ck_orders_payment_method
        CHECK (payment_method IN ('COD', 'VNPAY', 'MOMO', 'BANK_TRANSFER')),
    CONSTRAINT ck_orders_payment_status
        CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'PARTIALLY_REFUNDED', 'REFUNDED')),
    CONSTRAINT ck_orders_online_paid_before_ship CHECK (
        order_status NOT IN ('SHIPPED', 'DELIVERED', 'COMPLETED')
        OR payment_method = 'COD'
        OR payment_status IN ('PAID', 'PARTIALLY_REFUNDED', 'REFUNDED')
    ),
    INDEX ix_orders_customer_time (customer_id, created_at),
    INDEX ix_orders_operations (order_status, created_at)
) ENGINE=InnoDB;

ALTER TABLE inventory_documents
    ADD CONSTRAINT fk_inventory_documents_source_order
    FOREIGN KEY (source_order_id) REFERENCES orders (order_id) ON DELETE RESTRICT;

CREATE TABLE order_items (
    order_item_id        BIGINT UNSIGNED AUTO_INCREMENT,
    order_id             BIGINT UNSIGNED NOT NULL,
    product_id           BIGINT UNSIGNED NOT NULL,
    variant_id           BIGINT UNSIGNED NOT NULL,
    product_name_snapshot VARCHAR(180) NOT NULL,
    sku_snapshot         VARCHAR(100) NOT NULL,
    color_snapshot       VARCHAR(100) NOT NULL,
    size_snapshot        VARCHAR(20) NOT NULL,
    unit_price           DECIMAL(18,2) NOT NULL,
    unit_cost_snapshot   DECIMAL(18,2) NOT NULL,
    quantity             INT UNSIGNED NOT NULL,
    discount_amount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    line_total           DECIMAL(20,2) GENERATED ALWAYS AS (
        unit_price * quantity - discount_amount
    ) STORED,
    returnable_quantity  INT UNSIGNED NOT NULL,
    CONSTRAINT pk_order_items PRIMARY KEY (order_item_id),
    CONSTRAINT uq_order_items_item_order UNIQUE (order_item_id, order_id),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_product_variant FOREIGN KEY (product_id, variant_id)
        REFERENCES product_variants (product_id, variant_id) ON DELETE RESTRICT,
    CONSTRAINT ck_order_items_amounts CHECK (
        unit_price >= 0 AND unit_cost_snapshot >= 0
        AND discount_amount >= 0 AND discount_amount <= unit_price * quantity
    ),
    CONSTRAINT ck_order_items_quantity CHECK (
        quantity > 0 AND returnable_quantity <= quantity
    )
) ENGINE=InnoDB;

CREATE TABLE order_status_history (
    order_status_history_id BIGINT UNSIGNED AUTO_INCREMENT,
    order_id             BIGINT UNSIGNED NOT NULL,
    old_status           VARCHAR(30) NULL,
    new_status           VARCHAR(30) NOT NULL,
    actor_type           VARCHAR(20) NOT NULL,
    changed_by_account_id BIGINT UNSIGNED NULL,
    reason               VARCHAR(500) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_order_status_history PRIMARY KEY (order_status_history_id),
    CONSTRAINT fk_order_status_history_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_status_history_account FOREIGN KEY (changed_by_account_id)
        REFERENCES accounts (account_id) ON DELETE RESTRICT,
    CONSTRAINT ck_order_status_history_actor CHECK (
        (actor_type IN ('CUSTOMER', 'STAFF') AND changed_by_account_id IS NOT NULL)
        OR (actor_type = 'SYSTEM' AND changed_by_account_id IS NULL)
    ),
    INDEX ix_order_status_history_order_time (order_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id           BIGINT UNSIGNED AUTO_INCREMENT,
    order_id             BIGINT UNSIGNED NOT NULL,
    parent_payment_id    BIGINT UNSIGNED NULL,
    is_refund            BOOLEAN NOT NULL DEFAULT FALSE,
    payment_method       VARCHAR(30) NOT NULL,
    payment_gateway      VARCHAR(50) NULL,
    gateway_transaction_id VARCHAR(255) NULL,
    idempotency_key      CHAR(36) NOT NULL,
    amount               DECIMAL(18,2) NOT NULL,
    payment_status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    processed_at         DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT uq_payments_idempotency UNIQUE (idempotency_key),
    CONSTRAINT uq_payments_gateway_transaction UNIQUE (payment_gateway, gateway_transaction_id),
    CONSTRAINT uq_payments_payment_order UNIQUE (payment_id, order_id),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_parent_order FOREIGN KEY (parent_payment_id, order_id)
        REFERENCES payments (payment_id, order_id) ON DELETE RESTRICT,
    CONSTRAINT ck_payments_refund_parent CHECK (
        (is_refund = FALSE AND parent_payment_id IS NULL)
        OR (is_refund = TRUE AND parent_payment_id IS NOT NULL)
    ),
    CONSTRAINT ck_payments_method
        CHECK (payment_method IN ('COD', 'VNPAY', 'MOMO', 'BANK_TRANSFER')),
    CONSTRAINT ck_payments_amount CHECK (amount > 0),
    CONSTRAINT ck_payments_status
        CHECK (payment_status IN ('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    INDEX ix_payments_order_time (order_id, created_at)
) ENGINE=InnoDB;

/* ============================= 7. AFTER-SALES ============================== */

CREATE TABLE after_sales_requests (
    after_sales_request_id BIGINT UNSIGNED AUTO_INCREMENT,
    request_code         VARCHAR(50) NOT NULL,
    customer_id          BIGINT UNSIGNED NOT NULL,
    order_id             BIGINT UNSIGNED NOT NULL,
    order_item_id        BIGINT UNSIGNED NOT NULL,
    request_type         VARCHAR(20) NOT NULL,
    reason               VARCHAR(2000) NOT NULL,
    requested_quantity   INT UNSIGNED NOT NULL,
    exchange_variant_id  BIGINT UNSIGNED NULL,
    requested_refund_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    request_status       VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    handled_by_staff_id  BIGINT UNSIGNED NULL,
    resolution_note      VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_after_sales_requests PRIMARY KEY (after_sales_request_id),
    CONSTRAINT uq_after_sales_requests_code UNIQUE (request_code),
    CONSTRAINT fk_after_sales_order_customer FOREIGN KEY (order_id, customer_id)
        REFERENCES orders (order_id, customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_after_sales_item_order FOREIGN KEY (order_item_id, order_id)
        REFERENCES order_items (order_item_id, order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_after_sales_exchange_variant FOREIGN KEY (exchange_variant_id)
        REFERENCES product_variants (variant_id) ON DELETE SET NULL,
    CONSTRAINT fk_after_sales_handler FOREIGN KEY (handled_by_staff_id)
        REFERENCES staffs (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_after_sales_type
        CHECK (request_type IN ('RETURN', 'REFUND', 'EXCHANGE')),
    CONSTRAINT ck_after_sales_quantity CHECK (requested_quantity > 0),
    CONSTRAINT ck_after_sales_refund CHECK (requested_refund_amount >= 0),
    CONSTRAINT ck_after_sales_exchange CHECK (
        (request_type = 'EXCHANGE' AND exchange_variant_id IS NOT NULL)
        OR (request_type <> 'EXCHANGE' AND exchange_variant_id IS NULL)
    ),
    CONSTRAINT ck_after_sales_status CHECK (
        request_status IN ('OPEN', 'APPROVED', 'REJECTED', 'PROCESSING', 'COMPLETED', 'CANCELLED')
    ),
    INDEX ix_after_sales_queue (request_status, created_at),
    INDEX ix_after_sales_customer_time (customer_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE reviews (
    review_id            BIGINT UNSIGNED AUTO_INCREMENT,
    customer_id          BIGINT UNSIGNED NOT NULL,
    order_item_id        BIGINT UNSIGNED NOT NULL,
    rating               TINYINT UNSIGNED NOT NULL,
    content              VARCHAR(3000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_reviews PRIMARY KEY (review_id),
    CONSTRAINT uq_reviews_order_item UNIQUE (order_item_id),
    CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_order_item FOREIGN KEY (order_item_id)
        REFERENCES order_items (order_item_id) ON DELETE RESTRICT,
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    INDEX ix_reviews_created_at (created_at)
) ENGINE=InnoDB;

/* ============================== 8. STOCK VIEWS ============================ */

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

/* ======================== 9. CORE INTEGRITY TRIGGERS ====================== */

DELIMITER $$

CREATE TRIGGER trg_cart_items_before_insert_reservation
BEFORE INSERT ON cart_items
FOR EACH ROW
BEGIN
    DECLARE v_rows_changed INT DEFAULT 0;
    IF NEW.reserved_quantity > 0 THEN
        UPDATE product_variants
           SET reserved_quantity = reserved_quantity + NEW.reserved_quantity
         WHERE variant_id = NEW.variant_id
           AND available_quantity >= NEW.reserved_quantity;
        SET v_rows_changed = ROW_COUNT();
        IF v_rows_changed <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient available stock for reservation';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_cart_items_before_update_reservation
BEFORE UPDATE ON cart_items
FOR EACH ROW
BEGIN
    DECLARE v_reservation_delta BIGINT;
    DECLARE v_rows_changed INT DEFAULT 0;
    IF NEW.customer_id <> OLD.customer_id OR NEW.variant_id <> OLD.variant_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cart owner and variant cannot be changed';
    END IF;
    SET v_reservation_delta = CAST(NEW.reserved_quantity AS SIGNED)
                              - CAST(OLD.reserved_quantity AS SIGNED);
    IF v_reservation_delta > 0 THEN
        UPDATE product_variants
           SET reserved_quantity = reserved_quantity + v_reservation_delta
         WHERE variant_id = NEW.variant_id
           AND available_quantity >= v_reservation_delta;
        SET v_rows_changed = ROW_COUNT();
        IF v_rows_changed <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient available stock for reservation';
        END IF;
    ELSEIF v_reservation_delta < 0 THEN
        UPDATE product_variants
           SET reserved_quantity = reserved_quantity - ABS(v_reservation_delta)
         WHERE variant_id = NEW.variant_id;
    END IF;
END$$

CREATE TRIGGER trg_cart_items_before_delete_reservation
BEFORE DELETE ON cart_items
FOR EACH ROW
BEGIN
    IF OLD.reserved_quantity > 0 THEN
        UPDATE product_variants
           SET reserved_quantity = reserved_quantity - OLD.reserved_quantity
         WHERE variant_id = OLD.variant_id;
    END IF;
END$$

CREATE TRIGGER trg_inventory_documents_before_update_status
BEFORE UPDATE ON inventory_documents
FOR EACH ROW
BEGIN
    IF OLD.document_status IN ('POSTED', 'CANCELLED') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Posted or cancelled inventory documents are immutable';
    END IF;
    IF OLD.document_status <> NEW.document_status AND NOT (
        (OLD.document_status = 'DRAFT' AND NEW.document_status IN ('APPROVED', 'CANCELLED'))
        OR (OLD.document_status = 'APPROVED' AND NEW.document_status IN ('DRAFT', 'POSTED', 'CANCELLED'))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid inventory document status transition';
    END IF;
END$$

CREATE TRIGGER trg_inventory_transactions_before_insert
BEFORE INSERT ON inventory_transactions
FOR EACH ROW
BEGIN
    DECLARE v_document_type VARCHAR(20);
    DECLARE v_document_status VARCHAR(20);
    DECLARE v_posted_by_staff_id BIGINT UNSIGNED;
    DECLARE v_purchase_order_id BIGINT UNSIGNED;
    DECLARE v_source_order_id BIGINT UNSIGNED;
    DECLARE v_purchase_order_status VARCHAR(20);
    DECLARE v_po_item_count INT DEFAULT 0;
    DECLARE v_order_variant_quantity BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_prior_order_movement BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_rows_changed INT DEFAULT 0;
    DECLARE v_balance BIGINT UNSIGNED;

    SELECT document_type, document_status, posted_by_staff_id,
           purchase_order_id, source_order_id
      INTO v_document_type, v_document_status,
           v_posted_by_staff_id, v_purchase_order_id, v_source_order_id
      FROM inventory_documents
     WHERE inventory_document_id = NEW.inventory_document_id;

    IF v_document_status <> 'POSTED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only a posted inventory document can create inventory transactions';
    END IF;
    IF NEW.actor_staff_id <> v_posted_by_staff_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory actor must be the document poster';
    END IF;
    IF NEW.transaction_type <> v_document_type THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory transaction type must match its document type';
    END IF;

    IF (v_document_type = 'RECEIPT' AND NEW.quantity_change <= 0)
       OR (v_document_type = 'ISSUE' AND NEW.quantity_change >= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory quantity direction is invalid';
    END IF;

    IF v_purchase_order_id IS NOT NULL THEN
        SELECT status INTO v_purchase_order_status
          FROM purchase_orders
         WHERE purchase_order_id = v_purchase_order_id;
        IF v_purchase_order_status NOT IN ('APPROVED', 'PARTIALLY_RECEIVED') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Purchase order is not receivable';
        END IF;
        SELECT COUNT(*) INTO v_po_item_count
          FROM purchase_order_items
         WHERE purchase_order_item_id = NEW.purchase_order_item_id
           AND purchase_order_id = v_purchase_order_id
           AND variant_id = NEW.variant_id;
        IF v_po_item_count <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receipt line must match the purchase order and variant';
        END IF;
    ELSEIF NEW.purchase_order_item_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Purchase order item requires a purchase-order receipt';
    END IF;

    IF v_source_order_id IS NOT NULL THEN
        SELECT COALESCE(SUM(quantity), 0) INTO v_order_variant_quantity
          FROM order_items
         WHERE order_id = v_source_order_id
           AND variant_id = NEW.variant_id;
        IF v_order_variant_quantity = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line variant does not belong to its source order';
        END IF;

        SELECT COALESCE(SUM(ABS(it.quantity_change)), 0)
          INTO v_prior_order_movement
          FROM inventory_transactions it
          JOIN inventory_documents idoc
            ON idoc.inventory_document_id = it.inventory_document_id
         WHERE idoc.source_order_id = v_source_order_id
           AND it.variant_id = NEW.variant_id
           AND it.transaction_type = NEW.transaction_type;
        IF v_prior_order_movement + ABS(NEW.quantity_change) > v_order_variant_quantity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory movement exceeds the source order quantity';
        END IF;
    END IF;

    IF v_document_type = 'RECEIPT' AND NEW.unit_cost IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receipt line requires unit cost';
    END IF;

    UPDATE product_variants
       SET stock_quantity = CAST(stock_quantity AS SIGNED) + NEW.quantity_change
     WHERE variant_id = NEW.variant_id
       AND CAST(stock_quantity AS SIGNED) + NEW.quantity_change >= reserved_quantity;
    SET v_rows_changed = ROW_COUNT();

    IF v_rows_changed <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Variant is missing or available stock is insufficient';
    END IF;

    SELECT stock_quantity INTO v_balance
      FROM product_variants
     WHERE variant_id = NEW.variant_id;
    SET NEW.balance_after = v_balance;
END$$

CREATE TRIGGER trg_inventory_transactions_after_insert_receipt
AFTER INSERT ON inventory_transactions
FOR EACH ROW
BEGIN
    DECLARE v_purchase_order_item_id BIGINT UNSIGNED;
    DECLARE v_purchase_order_id BIGINT UNSIGNED;
    DECLARE v_rows_changed INT DEFAULT 0;

    IF NEW.transaction_type = 'RECEIPT' THEN
        SET v_purchase_order_item_id = NEW.purchase_order_item_id;
        SELECT purchase_order_id INTO v_purchase_order_id
          FROM inventory_documents
         WHERE inventory_document_id = NEW.inventory_document_id;

        IF v_purchase_order_item_id IS NOT NULL THEN
            UPDATE purchase_order_items
               SET received_quantity = received_quantity + NEW.quantity_change
             WHERE purchase_order_item_id = v_purchase_order_item_id
               AND received_quantity + NEW.quantity_change <= ordered_quantity;
            SET v_rows_changed = ROW_COUNT();
            IF v_rows_changed <> 1 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receipt exceeds outstanding purchase order quantity';
            END IF;

            UPDATE purchase_orders
               SET status = CASE
                   WHEN NOT EXISTS (
                       SELECT 1
                         FROM purchase_order_items poi
                        WHERE poi.purchase_order_id = v_purchase_order_id
                          AND poi.received_quantity < poi.ordered_quantity
                   ) THEN 'RECEIVED'
                   ELSE 'PARTIALLY_RECEIVED'
               END
             WHERE purchase_order_id = v_purchase_order_id;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_orders_before_update_status
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.order_status <> NEW.order_status THEN
        CASE OLD.order_status
            WHEN 'PENDING' THEN
                IF NEW.order_status NOT IN ('CONFIRMED', 'CANCELLED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from PENDING';
                END IF;
            WHEN 'CONFIRMED' THEN
                IF NEW.order_status NOT IN ('PROCESSING', 'CANCELLED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from CONFIRMED';
                END IF;
            WHEN 'PROCESSING' THEN
                IF NEW.order_status NOT IN ('SHIPPED', 'CANCELLED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from PROCESSING';
                END IF;
            WHEN 'SHIPPED' THEN
                IF NEW.order_status NOT IN ('DELIVERED', 'DELIVERY_FAILED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from SHIPPED';
                END IF;
            WHEN 'DELIVERY_FAILED' THEN
                IF NEW.order_status NOT IN ('PROCESSING', 'CANCELLED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from DELIVERY_FAILED';
                END IF;
            WHEN 'DELIVERED' THEN
                IF NEW.order_status NOT IN ('COMPLETED', 'RETURN_REQUESTED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from DELIVERED';
                END IF;
            WHEN 'RETURN_REQUESTED' THEN
                IF NEW.order_status NOT IN ('RETURNED', 'DELIVERED') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from RETURN_REQUESTED';
                END IF;
            WHEN 'RETURNED' THEN
                IF NEW.order_status <> 'COMPLETED' THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transition from RETURNED';
                END IF;
            WHEN 'COMPLETED' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'COMPLETED is terminal';
            WHEN 'CANCELLED' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CANCELLED is terminal';
        END CASE;
    END IF;
END$$

CREATE TRIGGER trg_reviews_before_insert_owner
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    DECLARE v_owner_id BIGINT UNSIGNED;
    DECLARE v_order_status VARCHAR(30);

    SELECT o.customer_id, o.order_status
      INTO v_owner_id, v_order_status
      FROM order_items oi
      JOIN orders o ON o.order_id = oi.order_id
     WHERE oi.order_item_id = NEW.order_item_id;

    IF v_owner_id IS NULL OR v_owner_id <> NEW.customer_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Review must belong to the order owner';
    END IF;
    IF v_order_status NOT IN ('DELIVERED', 'COMPLETED') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only delivered purchases can be reviewed';
    END IF;
END$$

CREATE TRIGGER trg_reviews_no_update
BEFORE UPDATE ON reviews
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reviews can only be created or deleted';
END$$

CREATE TRIGGER trg_inventory_transactions_no_update
BEFORE UPDATE ON inventory_transactions
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory ledger is append-only';
END$$

CREATE TRIGGER trg_inventory_transactions_no_delete
BEFORE DELETE ON inventory_transactions
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory ledger is append-only';
END$$

CREATE TRIGGER trg_audit_logs_no_update
BEFORE UPDATE ON audit_logs
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit log is append-only';
END$$

CREATE TRIGGER trg_audit_logs_no_delete
BEFORE DELETE ON audit_logs
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit log is append-only';
END$$

DELIMITER ;

/* Customer capabilities are enforced by ownership checks in the application.
   System jobs are trusted internal processes and are written to audit_logs as SYSTEM.
   Only staff roles need database-backed permission mappings. */

INSERT INTO roles (role_code, role_name, description)
VALUES
    ('SALES', 'Nhân viên bán hàng', 'Quản lý khách hàng, đơn hàng và hậu mãi.'),
    ('WAREHOUSE', 'Nhân viên kho', 'Quản lý sản phẩm, nhập hàng và tồn kho.'),
    ('SYSTEM_ADMIN', 'Quản trị hệ thống', 'Quản lý tài khoản nhân viên và cấu hình phân quyền.');

INSERT INTO permissions (permission_key, permission_name, module_code)
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

INSERT INTO role_permissions (role_code, permission_key)
VALUES
    ('SALES', 'catalog.read'),
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
    ('WAREHOUSE', 'catalog.manage'),
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

    ('SYSTEM_ADMIN', 'staff.manage'),
    ('SYSTEM_ADMIN', 'role_permission.manage'),
    ('SYSTEM_ADMIN', 'audit.read');

