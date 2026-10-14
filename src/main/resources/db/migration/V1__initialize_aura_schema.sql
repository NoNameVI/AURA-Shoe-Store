/* Local clean-install schema derived from AURA_database_newversion.sql.
   Create the empty aura_store database before Flyway starts. */

SET NAMES utf8mb4 COLLATE utf8mb4_vi_0900_ai_ci;
SET time_zone = '+00:00';

/* ============================== 1. IAM / RBAC ============================== */

CREATE TABLE role (
    role_code             VARCHAR(50) NOT NULL,
    role_name             VARCHAR(100) COLLATE utf8mb4_vi_0900_ai_ci NOT NULL,
    description           VARCHAR(500) COLLATE utf8mb4_vi_0900_ai_ci NULL,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                          ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_role PRIMARY KEY (role_code),
    CONSTRAINT uq_role_name UNIQUE (role_name),
    CONSTRAINT ck_role_code
        CHECK (role_code IN ('SALES', 'WAREHOUSE', 'SYSTEM_ADMIN'))
) ENGINE=InnoDB;

CREATE TABLE permission (
    permission_key        VARCHAR(120) NOT NULL,
    permission_name       VARCHAR(150) COLLATE utf8mb4_vi_0900_ai_ci NOT NULL,
    module_code           VARCHAR(50) NOT NULL,
    description           VARCHAR(500) COLLATE utf8mb4_vi_0900_ai_ci NULL,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at            DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                          ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_permission PRIMARY KEY (permission_key),
    CONSTRAINT uq_permission_name UNIQUE (permission_name),
    INDEX ix_permission_module_active (module_code, is_active)
) ENGINE=InnoDB;

CREATE TABLE account (
    account_id             INT AUTO_INCREMENT,
    username               VARCHAR(50) NOT NULL,
    email                  VARCHAR(255) NOT NULL,
    phone                  VARCHAR(20) NULL,
    password_hash          VARCHAR(255) NULL,
    is_google_auth         BOOLEAN NOT NULL DEFAULT FALSE,
    oauth_subject          VARCHAR(255) NULL,
    full_name              VARCHAR(150) COLLATE utf8mb4_vi_0900_ai_ci NOT NULL,
    avatar_url             VARCHAR(500) NULL,
    account_status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_login_attempts  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    locked_until           DATETIME(6) NULL,
    deleted_at             DATETIME(6) NULL,
    created_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                           ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_account PRIMARY KEY (account_id),
    CONSTRAINT uq_account_username UNIQUE (username),
    CONSTRAINT uq_account_email UNIQUE (email),
    CONSTRAINT uq_account_oauth UNIQUE (is_google_auth, oauth_subject),
    CONSTRAINT ck_account_auth_consistency CHECK (
        (is_google_auth = FALSE AND password_hash IS NOT NULL)
        OR (is_google_auth = TRUE AND oauth_subject IS NOT NULL)
    ),
    CONSTRAINT ck_account_status
        CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'LOCKED')),
    CONSTRAINT ck_account_phone
        CHECK (phone IS NULL OR phone REGEXP '^(0|\\+84)[35789][0-9]{8}$'),
    CONSTRAINT ck_account_email
        CHECK (email REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$'),
    INDEX ix_account_status_deleted (account_status, deleted_at),
    INDEX ix_account_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE customer (
    customer_id            INT NOT NULL,
    foot_length_mm         SMALLINT UNSIGNED NULL,
    preferred_size         VARCHAR(10) NULL,
    created_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                           ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_customer PRIMARY KEY (customer_id),
    CONSTRAINT fk_customer_account FOREIGN KEY (customer_id)
        REFERENCES account (account_id) ON DELETE CASCADE,
    CONSTRAINT ck_customer_foot_length
        CHECK (foot_length_mm IS NULL OR foot_length_mm BETWEEN 100 AND 400)
) ENGINE=InnoDB;

CREATE TABLE staff (
    staff_id               INT NOT NULL,
    role_code              VARCHAR(50) NOT NULL,
    must_change_password   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at             DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                           ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_staff PRIMARY KEY (staff_id),
    CONSTRAINT fk_staff_account FOREIGN KEY (staff_id)
        REFERENCES account (account_id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_role FOREIGN KEY (role_code)
        REFERENCES role (role_code) ON DELETE RESTRICT,
    CONSTRAINT ck_staff_role
        CHECK (role_code IN ('SALES', 'WAREHOUSE', 'SYSTEM_ADMIN')),
    INDEX ix_staff_role (role_code)
) ENGINE=InnoDB;

CREATE TABLE role_permission (
    role_code             VARCHAR(50) NOT NULL,
    permission_key        VARCHAR(120) NOT NULL,
    CONSTRAINT pk_role_permission PRIMARY KEY (role_code, permission_key),
    CONSTRAINT fk_role_permission_role FOREIGN KEY (role_code)
        REFERENCES role (role_code) ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_key)
        REFERENCES permission (permission_key) ON DELETE CASCADE,
    CONSTRAINT ck_role_permission_role
        CHECK (role_code IN ('SALES', 'WAREHOUSE', 'SYSTEM_ADMIN')),
    INDEX ix_role_permission_key (permission_key)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
    audit_log_id         INT AUTO_INCREMENT,
    actor_type           VARCHAR(20) NOT NULL,
    actor_account_id     INT NULL,
    permission_key       VARCHAR(120) NULL,
    action_name          VARCHAR(120) NOT NULL,
    resource_type        VARCHAR(80) NOT NULL,
    resource_id          VARCHAR(100) NULL,
    action_result        VARCHAR(20) NOT NULL,
    before_data          JSON NULL,
    after_data           JSON NULL,
    request_id           CHAR(36) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_audit_log PRIMARY KEY (audit_log_id),
    CONSTRAINT fk_audit_log_account FOREIGN KEY (actor_account_id)
        REFERENCES account (account_id) ON DELETE RESTRICT,
    CONSTRAINT ck_audit_log_actor CHECK (
        (actor_type IN ('CUSTOMER', 'STAFF') AND actor_account_id IS NOT NULL)
        OR (actor_type = 'SYSTEM' AND actor_account_id IS NULL)
    ),
    CONSTRAINT ck_audit_log_result
        CHECK (action_result IN ('SUCCESS', 'DENIED', 'FAILED')),
    INDEX ix_audit_log_account_time (actor_account_id, created_at),
    INDEX ix_audit_log_resource (resource_type, resource_id, created_at),
    INDEX ix_audit_log_request (request_id)
) ENGINE=InnoDB;

/* ============================== 2. CUSTOMER ================================ */

CREATE TABLE address (
    address_id           INT AUTO_INCREMENT,
    customer_id          INT NOT NULL,
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
    active_default_customer_id INT GENERATED ALWAYS AS (
        IF(is_default = TRUE AND deleted_at IS NULL, customer_id, NULL)
    ) STORED,
    CONSTRAINT pk_address PRIMARY KEY (address_id),
    CONSTRAINT uq_address_one_default UNIQUE (active_default_customer_id),
    CONSTRAINT uq_address_address_customer UNIQUE (address_id, customer_id),
    CONSTRAINT fk_address_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id) ON DELETE RESTRICT,
    CONSTRAINT ck_address_phone
        CHECK (phone REGEXP '^(0|\\+84)[35789][0-9]{8}$'),
    INDEX ix_address_customer_active (customer_id, deleted_at)
) ENGINE=InnoDB;

/* =============================== 3. CATALOG ================================ */

CREATE TABLE brand (
    brand_id             INT AUTO_INCREMENT,
    brand_name           VARCHAR(150) COLLATE utf8mb4_vi_0900_as_cs NOT NULL,
    slug                 VARCHAR(160) NOT NULL,
    description          VARCHAR(1000) NULL,
    logo_url             VARCHAR(500) NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_brand PRIMARY KEY (brand_id),
    CONSTRAINT uq_brand_name UNIQUE (brand_name),
    CONSTRAINT uq_brand_slug UNIQUE (slug)
) ENGINE=InnoDB;

CREATE TABLE category (
    category_id          INT AUTO_INCREMENT,
    parent_id            INT NULL,
    category_name        VARCHAR(150) NOT NULL,
    slug                 VARCHAR(160) NOT NULL,
    description          VARCHAR(1000) NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_category PRIMARY KEY (category_id),
    CONSTRAINT uq_category_slug UNIQUE (slug),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_id)
        REFERENCES category (category_id) ON DELETE RESTRICT,
    INDEX ix_category_parent_active (parent_id, is_active)
) ENGINE=InnoDB;

CREATE TABLE product (
    product_id           INT AUTO_INCREMENT,
    brand_id             INT NOT NULL,
    category_id          INT NOT NULL,
    product_name         VARCHAR(180) NOT NULL,
    slug                 VARCHAR(200) NOT NULL,
    style_code           VARCHAR(100) NULL,
    description          VARCHAR(3000) NULL,
    publication_status   VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    archived_at          DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_product PRIMARY KEY (product_id),
    CONSTRAINT uq_product_slug UNIQUE (slug),
    CONSTRAINT uq_product_style_code UNIQUE (style_code),
    CONSTRAINT fk_product_brand FOREIGN KEY (brand_id)
        REFERENCES brand (brand_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES category (category_id) ON DELETE RESTRICT,
    CONSTRAINT ck_product_status
        CHECK (publication_status IN ('DRAFT', 'ACTIVE', 'INACTIVE', 'ARCHIVED')),
    INDEX ix_product_catalog (publication_status, category_id, brand_id),
    FULLTEXT INDEX ft_product_search (product_name, description)
) ENGINE=InnoDB;

/* Immutable snapshots of product metadata. A new row is written on creation
   and whenever the catalog-facing product fields change. */
CREATE TABLE product_version (
    product_version_id   INT AUTO_INCREMENT,
    product_id           INT NOT NULL,
    version_number       INT UNSIGNED NOT NULL,
    brand_id             INT NOT NULL,
    brand_name_snapshot  VARCHAR(150) NOT NULL,
    category_id          INT NOT NULL,
    category_name_snapshot VARCHAR(150) NOT NULL,
    product_name         VARCHAR(180) NOT NULL,
    slug                 VARCHAR(200) NOT NULL,
    style_code           VARCHAR(100) NULL,
    description          VARCHAR(3000) NULL,
    publication_status   VARCHAR(20) NOT NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_product_version PRIMARY KEY (product_version_id),
    CONSTRAINT uq_product_version_number UNIQUE (product_id, version_number),
    CONSTRAINT fk_product_version_product FOREIGN KEY (product_id)
        REFERENCES product (product_id) ON DELETE RESTRICT,
    INDEX ix_product_version_product_time (product_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE color (
    color_id             INT AUTO_INCREMENT,
    color_code           VARCHAR(12) NOT NULL,
    color_name           VARCHAR(50) NOT NULL,
    hex_code             CHAR(7) NULL, /* Vi du: #FF0000 */
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_color PRIMARY KEY (color_id),
    CONSTRAINT uq_color_code UNIQUE (color_code),
    CONSTRAINT uq_color_name UNIQUE (color_name)
) ENGINE=InnoDB;


CREATE TABLE product_variant (
    variant_id           INT AUTO_INCREMENT,
    product_id           INT NOT NULL,
    color_id             INT NOT NULL,
    sku                  VARCHAR(100) NOT NULL,
    size_code            VARCHAR(10) NOT NULL,
    sale_price           DECIMAL(12,2) NOT NULL,
    cost_price           DECIMAL(12,2) NOT NULL DEFAULT 0,
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
    CONSTRAINT pk_product_variant PRIMARY KEY (variant_id),
    CONSTRAINT uq_product_variant_sku UNIQUE (sku),
    CONSTRAINT uq_product_variant_dimensions UNIQUE (product_id, color_id, size_code),
    CONSTRAINT uq_product_variant_product_variant UNIQUE (product_id, variant_id),
    CONSTRAINT fk_product_variant_product FOREIGN KEY (product_id)
        REFERENCES product (product_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_variant_color FOREIGN KEY (color_id)
        REFERENCES color (color_id) ON DELETE RESTRICT,
    CONSTRAINT ck_product_variant_price CHECK (sale_price >= 0 AND cost_price >= 0),
    CONSTRAINT ck_product_variant_stock CHECK (reserved_quantity <= stock_quantity),
    INDEX ix_product_variant_sellable (product_id, is_active, available_quantity)
) ENGINE=InnoDB;

CREATE TABLE product_image (
    image_id             INT AUTO_INCREMENT,
    variant_id           INT NOT NULL,
    image_url            VARCHAR(500) NOT NULL,
    alt_text             VARCHAR(255) NOT NULL DEFAULT '',
    display_order        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    is_primary           BOOLEAN NOT NULL DEFAULT FALSE,
    primary_variant_id   INT GENERATED ALWAYS AS (
        IF(is_primary = TRUE, variant_id, NULL)
    ) STORED,
    CONSTRAINT pk_product_image PRIMARY KEY (image_id),
    CONSTRAINT uq_product_image_primary UNIQUE (primary_variant_id),
    CONSTRAINT fk_product_image_variant FOREIGN KEY (variant_id)
        REFERENCES product_variant (variant_id) ON DELETE RESTRICT,
    INDEX ix_product_image_gallery (variant_id, display_order)
) ENGINE=InnoDB;

/* =========================== 4. PROCUREMENT / STOCK ======================= */

CREATE TABLE supplier (
    supplier_id          INT AUTO_INCREMENT,
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
    CONSTRAINT pk_supplier PRIMARY KEY (supplier_id),
    CONSTRAINT uq_supplier_code UNIQUE (supplier_code),
    CONSTRAINT uq_supplier_tax_code UNIQUE (tax_code),
    CONSTRAINT ck_supplier_tax_code
        CHECK (tax_code IS NULL OR tax_code REGEXP '^[0-9]{10}(-[0-9]{3})?$')
) ENGINE=InnoDB;

CREATE TABLE purchase_order (
    purchase_order_id    INT AUTO_INCREMENT,
    po_code              VARCHAR(50) NOT NULL,
    supplier_id          INT NOT NULL,
    status               VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_by_staff_id  INT NOT NULL,
    approved_by_staff_id INT NULL,
    approved_at          DATETIME(6) NULL,
    note                 VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_purchase_order PRIMARY KEY (purchase_order_id),
    CONSTRAINT uq_purchase_order_code UNIQUE (po_code),
    CONSTRAINT fk_purchase_order_supplier FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_creator FOREIGN KEY (created_by_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_approver FOREIGN KEY (approved_by_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_purchase_order_status
        CHECK (status IN ('PENDING', 'APPROVED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'CANCELLED')),
    CONSTRAINT ck_purchase_order_separation
        CHECK (approved_by_staff_id IS NULL OR approved_by_staff_id <> created_by_staff_id),
    CONSTRAINT ck_purchase_order_approval_state CHECK (
        (status = 'PENDING' AND approved_by_staff_id IS NULL AND approved_at IS NULL)
        OR (status IN ('APPROVED', 'PARTIALLY_RECEIVED', 'RECEIVED')
            AND approved_by_staff_id IS NOT NULL AND approved_at IS NOT NULL)
        OR (status = 'CANCELLED'
            AND ((approved_by_staff_id IS NULL AND approved_at IS NULL)
                 OR (approved_by_staff_id IS NOT NULL AND approved_at IS NOT NULL)))
    ),
    INDEX ix_purchase_order_supplier_time (supplier_id, created_at),
    INDEX ix_purchase_order_status_time (status, created_at)
) ENGINE=InnoDB;

CREATE TABLE purchase_order_item (
    purchase_order_item_id INT AUTO_INCREMENT,
    purchase_order_id    INT NOT NULL,
    variant_id           INT NOT NULL,
    ordered_quantity     INT UNSIGNED NOT NULL,
    received_quantity    INT UNSIGNED NOT NULL DEFAULT 0,
    unit_cost            DECIMAL(12,2) NOT NULL,
    line_total           DECIMAL(12,2) GENERATED ALWAYS AS (ordered_quantity * unit_cost) STORED,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_purchase_order_item PRIMARY KEY (purchase_order_item_id),
    CONSTRAINT uq_purchase_order_item_variant UNIQUE (purchase_order_id, variant_id),
    CONSTRAINT fk_purchase_order_item_order FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_order (purchase_order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_order_item_variant FOREIGN KEY (variant_id)
        REFERENCES product_variant (variant_id) ON DELETE RESTRICT,
    CONSTRAINT ck_purchase_order_item_quantity
        CHECK (ordered_quantity > 0 AND received_quantity <= ordered_quantity),
    CONSTRAINT ck_purchase_order_item_cost CHECK (unit_cost >= 0),
    INDEX ix_purchase_order_item_variant (variant_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_document (
    inventory_document_id INT AUTO_INCREMENT,
    document_code        VARCHAR(50) NOT NULL,
    document_type        VARCHAR(20) NOT NULL,
    document_status      VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    purchase_order_id    INT NULL,
    source_order_id      INT NULL,
    created_by_staff_id  INT NOT NULL,
    approved_by_staff_id INT NULL,
    posted_by_staff_id   INT NULL,
    approved_at          DATETIME(6) NULL,
    posted_at            DATETIME(6) NULL,
    note                 VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_inventory_document PRIMARY KEY (inventory_document_id),
    CONSTRAINT uq_inventory_document_code UNIQUE (document_code),
    CONSTRAINT fk_inventory_document_purchase_order FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_order (purchase_order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_document_creator FOREIGN KEY (created_by_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_document_approver FOREIGN KEY (approved_by_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_document_poster FOREIGN KEY (posted_by_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_inventory_document_type CHECK (
        document_type IN ('RECEIPT', 'ISSUE', 'ADJUSTMENT')
    ),
    CONSTRAINT ck_inventory_document_status CHECK (
        document_status IN ('DRAFT', 'APPROVED', 'POSTED', 'CANCELLED')
    ),
    CONSTRAINT ck_inventory_document_approval CHECK (
        approved_by_staff_id IS NULL OR approved_by_staff_id <> created_by_staff_id
    ),
    CONSTRAINT ck_inventory_document_dates CHECK (
        (document_status = 'DRAFT' AND approved_by_staff_id IS NULL
            AND approved_at IS NULL AND posted_by_staff_id IS NULL AND posted_at IS NULL)
        OR (document_status = 'APPROVED' AND approved_by_staff_id IS NOT NULL
            AND approved_at IS NOT NULL AND posted_by_staff_id IS NULL AND posted_at IS NULL)
        OR (document_status = 'POSTED' AND approved_by_staff_id IS NOT NULL
            AND approved_at IS NOT NULL AND posted_by_staff_id IS NOT NULL AND posted_at IS NOT NULL)
        OR (document_status = 'CANCELLED' AND posted_by_staff_id IS NULL AND posted_at IS NULL)
    ),
    CONSTRAINT ck_inventory_document_business_source CHECK (
        (purchase_order_id IS NULL OR document_type = 'RECEIPT')
        AND (source_order_id IS NULL OR document_type IN ('RECEIPT', 'ISSUE'))
        AND NOT (purchase_order_id IS NOT NULL AND source_order_id IS NOT NULL)
    ),
    INDEX ix_inventory_document_status_time (document_status, created_at),
    INDEX ix_inventory_document_purchase_order (purchase_order_id),
    INDEX ix_inventory_document_source_order (source_order_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_document_item (
    inventory_document_item_id INT AUTO_INCREMENT,
    inventory_document_id INT NOT NULL,
    variant_id           INT NOT NULL,
    product_version_id   INT NOT NULL,
    sku_snapshot         VARCHAR(100) NOT NULL,
    color_snapshot       VARCHAR(100) NOT NULL,
    size_snapshot        VARCHAR(10) NOT NULL,
    purchase_order_item_id INT NULL,
    quantity_change      BIGINT NOT NULL,
    unit_cost            DECIMAL(12,2) NULL,
    reason               VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_inventory_document_item PRIMARY KEY (inventory_document_item_id),
    CONSTRAINT uq_inventory_document_item_document_variant
        UNIQUE (inventory_document_id, variant_id),
    CONSTRAINT uq_inventory_document_item_identity
        UNIQUE (inventory_document_item_id, inventory_document_id, variant_id),
    CONSTRAINT fk_inventory_document_item_document FOREIGN KEY (inventory_document_id)
        REFERENCES inventory_document (inventory_document_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_document_item_variant FOREIGN KEY (variant_id)
        REFERENCES product_variant (variant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_document_item_product_version FOREIGN KEY (product_version_id)
        REFERENCES product_version (product_version_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_document_item_po_item FOREIGN KEY (purchase_order_item_id)
        REFERENCES purchase_order_item (purchase_order_item_id) ON DELETE RESTRICT,
    CONSTRAINT ck_inventory_document_item_quantity CHECK (quantity_change <> 0),
    CONSTRAINT ck_inventory_document_item_cost CHECK (unit_cost IS NULL OR unit_cost >= 0),
    INDEX ix_inventory_document_item_variant (variant_id),
    INDEX ix_inventory_document_item_po_item (purchase_order_item_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_transaction (
    inventory_transaction_id INT AUTO_INCREMENT,
    inventory_document_item_id INT NOT NULL,
    inventory_document_id INT NOT NULL,
    variant_id           INT NOT NULL,
    purchase_order_item_id INT NULL,
    actor_staff_id       INT NOT NULL,
    transaction_type     VARCHAR(20) NOT NULL,
    quantity_change      BIGINT NOT NULL,
    balance_after        BIGINT UNSIGNED NOT NULL DEFAULT 0,
    unit_cost            DECIMAL(12,2) NULL,
    reason               VARCHAR(1000) NULL,
    idempotency_key      CHAR(36) NOT NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_inventory_transaction PRIMARY KEY (inventory_transaction_id),
    CONSTRAINT uq_inventory_transaction_idempotency UNIQUE (idempotency_key),
    CONSTRAINT uq_inventory_transaction_document_item UNIQUE (inventory_document_item_id),
    CONSTRAINT uq_inventory_transaction_document_variant
        UNIQUE (inventory_document_id, variant_id),
    CONSTRAINT fk_inventory_transaction_document_item
        FOREIGN KEY (inventory_document_item_id, inventory_document_id, variant_id)
        REFERENCES inventory_document_item
            (inventory_document_item_id, inventory_document_id, variant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transaction_document FOREIGN KEY (inventory_document_id)
        REFERENCES inventory_document (inventory_document_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transaction_variant FOREIGN KEY (variant_id)
        REFERENCES product_variant (variant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transaction_po_item FOREIGN KEY (purchase_order_item_id)
        REFERENCES purchase_order_item (purchase_order_item_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transaction_actor FOREIGN KEY (actor_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    CONSTRAINT ck_inventory_transaction_type CHECK (
        transaction_type IN ('RECEIPT', 'ISSUE', 'ADJUSTMENT')
    ),
    CONSTRAINT ck_inventory_transaction_quantity CHECK (quantity_change <> 0),
    CONSTRAINT ck_inventory_transaction_cost CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CONSTRAINT ck_inventory_transaction_reason CHECK (
        transaction_type <> 'ADJUSTMENT' OR (reason IS NOT NULL AND TRIM(reason) <> '')
    ),
    INDEX ix_inventory_transaction_variant_time (variant_id, created_at),
    INDEX ix_inventory_transaction_document (inventory_document_id)
) ENGINE=InnoDB;

/* ============================== 5. STOREFRONT ============================== */

CREATE TABLE cart_item (
    cart_item_id         INT AUTO_INCREMENT,
    customer_id          INT NOT NULL,
    variant_id           INT NOT NULL,
    quantity             INT UNSIGNED NOT NULL DEFAULT 1,
    reserved_quantity    INT UNSIGNED NOT NULL DEFAULT 0,
    reservation_expires_at DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_cart_item PRIMARY KEY (cart_item_id),
    CONSTRAINT uq_cart_item_customer_variant UNIQUE (customer_id, variant_id),
    CONSTRAINT fk_cart_item_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cart_item_variant FOREIGN KEY (variant_id)
        REFERENCES product_variant (variant_id) ON DELETE RESTRICT,
    CONSTRAINT ck_cart_item_quantity
        CHECK (quantity > 0 AND reserved_quantity <= quantity),
    CONSTRAINT ck_cart_item_reservation CHECK (
        (reserved_quantity = 0 AND reservation_expires_at IS NULL)
        OR (reserved_quantity > 0 AND reservation_expires_at IS NOT NULL)
    ),
    INDEX ix_cart_item_reservation_expiry (reservation_expires_at),
    INDEX ix_cart_item_variant (variant_id)
) ENGINE=InnoDB;

CREATE TABLE wishlist_item (
    wishlist_item_id     INT AUTO_INCREMENT,
    customer_id          INT NOT NULL,
    product_id           INT NOT NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_wishlist_item PRIMARY KEY (wishlist_item_id),
    CONSTRAINT uq_wishlist_item_customer_product UNIQUE (customer_id, product_id),
    CONSTRAINT fk_wishlist_item_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_item_product FOREIGN KEY (product_id)
        REFERENCES product (product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE voucher (
    voucher_id           INT AUTO_INCREMENT,
    voucher_code         VARCHAR(100) NOT NULL,
    voucher_name         VARCHAR(180) NOT NULL,
    discount_percentage  DECIMAL(5,2) NOT NULL,
    max_discount_amount  DECIMAL(12,2) NULL,
    min_order_amount     DECIMAL(12,2) NOT NULL DEFAULT 0,
    start_at             DATETIME(6) NOT NULL,
    end_at               DATETIME(6) NOT NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_voucher PRIMARY KEY (voucher_id),
    CONSTRAINT uq_voucher_code UNIQUE (voucher_code),
    CONSTRAINT ck_voucher_percentage
        CHECK (discount_percentage > 0 AND discount_percentage <= 100),
    CONSTRAINT ck_voucher_amounts CHECK (
        min_order_amount >= 0 AND (max_discount_amount IS NULL OR max_discount_amount >= 0)
    ),
    CONSTRAINT ck_voucher_period CHECK (end_at > start_at),
    INDEX ix_voucher_available (is_active, start_at, end_at)
) ENGINE=InnoDB;

CREATE TABLE shipping_method (
    shipping_method_id   INT AUTO_INCREMENT,
    method_code          VARCHAR(50) NOT NULL,
    method_name          VARCHAR(120) NOT NULL,
    base_fee             DECIMAL(12,2) NOT NULL DEFAULT 0,
    estimated_days_min   SMALLINT UNSIGNED NULL,
    estimated_days_max   SMALLINT UNSIGNED NULL,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_shipping_method PRIMARY KEY (shipping_method_id),
    CONSTRAINT uq_shipping_method_code UNIQUE (method_code),
    CONSTRAINT ck_shipping_method_fee CHECK (base_fee >= 0),
    CONSTRAINT ck_shipping_method_days CHECK (
        estimated_days_min IS NULL OR estimated_days_max IS NULL
        OR estimated_days_min <= estimated_days_max
    )
) ENGINE=InnoDB;

/* ================================ 6. ORDERS ================================ */

CREATE TABLE sales_order (
    order_id             INT AUTO_INCREMENT,
    order_code           VARCHAR(50) NOT NULL,
    customer_id          INT NOT NULL,
    shipping_address_id  INT NULL,
    shipping_method_id   INT NULL,
    voucher_id           INT NULL,
    shipping_recipient_name VARCHAR(150) NOT NULL,
    shipping_phone       VARCHAR(20) NOT NULL,
    shipping_address_text VARCHAR(500) NOT NULL,
    shipping_method_name VARCHAR(120) NOT NULL,
    tracking_number      VARCHAR(120) NULL,
    voucher_code         VARCHAR(100) NULL,
    currency_code        CHAR(3) NOT NULL DEFAULT 'VND',
    subtotal_amount      DECIMAL(12,2) NOT NULL,
    discount_amount      DECIMAL(12,2) NOT NULL DEFAULT 0,
    shipping_fee         DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_amount         DECIMAL(12,2) GENERATED ALWAYS AS (
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
    CONSTRAINT pk_sales_order PRIMARY KEY (order_id),
    CONSTRAINT uq_sales_order_code UNIQUE (order_code),
    CONSTRAINT uq_sales_order_tracking UNIQUE (tracking_number),
    CONSTRAINT uq_sales_order_voucher_once UNIQUE (voucher_id),
    CONSTRAINT uq_sales_order_order_customer UNIQUE (order_id, customer_id),
    CONSTRAINT fk_sales_order_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sales_order_address_customer FOREIGN KEY (shipping_address_id, customer_id)
        REFERENCES address (address_id, customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sales_order_shipping_method FOREIGN KEY (shipping_method_id)
        REFERENCES shipping_method (shipping_method_id) ON DELETE SET NULL,
    CONSTRAINT fk_sales_order_voucher FOREIGN KEY (voucher_id)
        REFERENCES voucher (voucher_id) ON DELETE RESTRICT,
    CONSTRAINT ck_sales_order_voucher_snapshot CHECK (
        (voucher_id IS NULL AND voucher_code IS NULL)
        OR (voucher_id IS NOT NULL AND voucher_code IS NOT NULL)
    ),
    CONSTRAINT ck_sales_order_phone
        CHECK (shipping_phone REGEXP '^(0|\\+84)[35789][0-9]{8}$'),
    CONSTRAINT ck_sales_order_amounts CHECK (
        subtotal_amount >= 0 AND discount_amount >= 0
        AND shipping_fee >= 0 AND discount_amount <= subtotal_amount
    ),
    CONSTRAINT ck_sales_order_status CHECK (
        order_status IN ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED',
                         'DELIVERY_FAILED', 'CANCELLED', 'RETURN_REQUESTED', 'RETURNED', 'COMPLETED')
    ),
    CONSTRAINT ck_sales_order_payment_method
        CHECK (payment_method IN ('COD', 'VNPAY', 'MOMO', 'BANK_TRANSFER')),
    CONSTRAINT ck_sales_order_payment_status
        CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'PARTIALLY_REFUNDED', 'REFUNDED')),
    CONSTRAINT ck_sales_order_online_paid_before_ship CHECK (
        order_status NOT IN ('SHIPPED', 'DELIVERED', 'COMPLETED')
        OR payment_method = 'COD'
        OR payment_status IN ('PAID', 'PARTIALLY_REFUNDED', 'REFUNDED')
    ),
    INDEX ix_sales_order_customer_time (customer_id, created_at),
    INDEX ix_sales_order_operations (order_status, created_at)
) ENGINE=InnoDB;

ALTER TABLE inventory_document
    ADD CONSTRAINT fk_inventory_document_source_order
    FOREIGN KEY (source_order_id) REFERENCES sales_order (order_id) ON DELETE RESTRICT;

CREATE TABLE order_item (
    order_item_id        INT AUTO_INCREMENT,
    order_id             INT NOT NULL,
    product_id           INT NOT NULL,
    variant_id           INT NOT NULL,
    product_name_snapshot VARCHAR(180) NOT NULL,
    sku_snapshot         VARCHAR(100) NOT NULL,
    color_snapshot       VARCHAR(100) NOT NULL,
    size_snapshot        VARCHAR(20) NOT NULL,
    unit_price           DECIMAL(12,2) NOT NULL,
    unit_cost_snapshot   DECIMAL(12,2) NOT NULL,
    quantity             INT UNSIGNED NOT NULL,
    discount_amount      DECIMAL(12,2) NOT NULL DEFAULT 0,
    line_total           DECIMAL(12,2) GENERATED ALWAYS AS (
        unit_price * quantity - discount_amount
    ) STORED,
    returnable_quantity  INT UNSIGNED NOT NULL,
    CONSTRAINT pk_order_item PRIMARY KEY (order_item_id),

    /* Đã sửa: Ràng buộc đảm bảo một đơn hàng không bị thêm trùng cùng 1 biến thể sản phẩm nhiều lần trên các dòng khác nhau */
    CONSTRAINT uq_order_item_order_variant UNIQUE (order_id, variant_id),
    CONSTRAINT uq_order_item_item_order UNIQUE (order_item_id, order_id),

    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
        REFERENCES sales_order (order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_item_product_variant FOREIGN KEY (product_id, variant_id)
        REFERENCES product_variant (product_id, variant_id) ON DELETE RESTRICT,
    CONSTRAINT ck_order_item_amounts CHECK (
        unit_price >= 0 AND unit_cost_snapshot >= 0
        AND discount_amount >= 0 AND discount_amount <= unit_price * quantity
    ),
    CONSTRAINT ck_order_item_quantity CHECK (
        quantity > 0 AND returnable_quantity <= quantity
    )
) ENGINE=InnoDB;

CREATE TABLE order_status_history (
    order_status_history_id INT AUTO_INCREMENT,
    order_id             INT NOT NULL,
    old_status           VARCHAR(30) NULL,
    new_status           VARCHAR(30) NOT NULL,
    actor_type           VARCHAR(20) NOT NULL,
    changed_by_account_id INT NULL,
    reason               VARCHAR(500) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_order_status_history PRIMARY KEY (order_status_history_id),
    CONSTRAINT fk_order_status_history_order FOREIGN KEY (order_id)
        REFERENCES sales_order (order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_status_history_account FOREIGN KEY (changed_by_account_id)
        REFERENCES account (account_id) ON DELETE RESTRICT,
    CONSTRAINT ck_order_status_history_actor CHECK (
        (actor_type IN ('CUSTOMER', 'STAFF') AND changed_by_account_id IS NOT NULL)
        OR (actor_type = 'SYSTEM' AND changed_by_account_id IS NULL)
    ),
    INDEX ix_order_status_history_order_time (order_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE payment (
    payment_id           INT AUTO_INCREMENT,
    order_id             INT NOT NULL,
    parent_payment_id    INT NULL,
    is_refund            BOOLEAN NOT NULL DEFAULT FALSE,
    payment_method       VARCHAR(30) NOT NULL,
    payment_gateway      VARCHAR(50) NULL,
    gateway_transaction_id VARCHAR(255) NULL,
    idempotency_key      CHAR(36) NOT NULL,
    amount               DECIMAL(12,2) NOT NULL,
    payment_status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    processed_at         DATETIME(6) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_payment PRIMARY KEY (payment_id),
    CONSTRAINT uq_payment_idempotency UNIQUE (idempotency_key),
    CONSTRAINT uq_payment_gateway_transaction UNIQUE (payment_gateway, gateway_transaction_id),
    CONSTRAINT uq_payment_payment_order UNIQUE (payment_id, order_id),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
        REFERENCES sales_order (order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_parent_order FOREIGN KEY (parent_payment_id, order_id)
        REFERENCES payment (payment_id, order_id) ON DELETE RESTRICT,
    CONSTRAINT ck_payment_refund_parent CHECK (
        (is_refund = FALSE AND parent_payment_id IS NULL)
        OR (is_refund = TRUE AND parent_payment_id IS NOT NULL)
    ),
    CONSTRAINT ck_payment_method
        CHECK (payment_method IN ('COD', 'VNPAY', 'MOMO', 'BANK_TRANSFER')),
    CONSTRAINT ck_payment_amount CHECK (amount > 0),
    CONSTRAINT ck_payment_status
        CHECK (payment_status IN ('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    INDEX ix_payment_order_time (order_id, created_at)
) ENGINE=InnoDB;

/* ============================= 7. AFTER-SALES ============================== */

CREATE TABLE after_sales_request (
    after_sales_request_id INT AUTO_INCREMENT,
    request_code         VARCHAR(50) NOT NULL,
    customer_id          INT NOT NULL,
    order_id             INT NOT NULL,
    order_item_id        INT NOT NULL,
    request_type         VARCHAR(20) NOT NULL,
    reason               VARCHAR(2000) NOT NULL,
    requested_quantity   INT UNSIGNED NOT NULL,
    exchange_variant_id  INT NULL,
    requested_refund_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    request_status       VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    handled_by_staff_id  INT NULL,
    resolution_note      VARCHAR(1000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                         ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_after_sales_request PRIMARY KEY (after_sales_request_id),
    CONSTRAINT uq_after_sales_request_code UNIQUE (request_code),
    CONSTRAINT fk_after_sales_order_customer FOREIGN KEY (order_id, customer_id)
        REFERENCES sales_order (order_id, customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_after_sales_item_order FOREIGN KEY (order_item_id, order_id)
        REFERENCES order_item (order_item_id, order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_after_sales_exchange_variant FOREIGN KEY (exchange_variant_id)
        REFERENCES product_variant (variant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_after_sales_handler FOREIGN KEY (handled_by_staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
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

CREATE TABLE review (
    review_id            INT AUTO_INCREMENT,
    customer_id          INT NOT NULL,
    order_item_id        INT NOT NULL,
    rating               TINYINT UNSIGNED NOT NULL,
    content              VARCHAR(3000) NULL,
    created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_review PRIMARY KEY (review_id),
    CONSTRAINT uq_review_order_item UNIQUE (order_item_id),
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_review_order_item FOREIGN KEY (order_item_id)
        REFERENCES order_item (order_item_id) ON DELETE RESTRICT,
    CONSTRAINT ck_review_rating CHECK (rating BETWEEN 1 AND 5),
    INDEX ix_review_created_at (created_at)
) ENGINE=InnoDB;

/* ============================== 8. STOCK VIEWS ============================ */

CREATE OR REPLACE VIEW v_inventory_status AS
SELECT
    pv.variant_id,
    pv.sku,
    p.product_name,
    c.color_name,
    pv.size_code,
    pv.stock_quantity,
    pv.reserved_quantity,
    pv.available_quantity,
    pv.low_stock_threshold,
    (pv.available_quantity <= pv.low_stock_threshold) AS is_low_stock,
    pv.updated_at
FROM product_variant pv
JOIN product p ON p.product_id = pv.product_id
JOIN color c ON c.color_id = pv.color_id;

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
FROM purchase_order po
LEFT JOIN purchase_order_item poi
  ON poi.purchase_order_id = po.purchase_order_id
GROUP BY po.purchase_order_id, po.po_code, po.supplier_id, po.status;

/* ======================== 9. CORE INTEGRITY TRIGGERS ====================== */

DELIMITER $$

CREATE TRIGGER trg_product_after_insert_version
AFTER INSERT ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_version (
        product_id, version_number, brand_id, brand_name_snapshot,
        category_id, category_name_snapshot, product_name, slug,
        style_code, description, publication_status
    )
    SELECT NEW.product_id, 1, NEW.brand_id, b.brand_name,
           NEW.category_id, c.category_name, NEW.product_name, NEW.slug,
           NEW.style_code, NEW.description, NEW.publication_status
      FROM brand b CROSS JOIN category c
     WHERE b.brand_id = NEW.brand_id AND c.category_id = NEW.category_id;
END$$

CREATE TRIGGER trg_product_after_update_version
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    IF NOT (NEW.brand_id <=> OLD.brand_id)
       OR NOT (NEW.category_id <=> OLD.category_id)
       OR NOT (NEW.product_name <=> OLD.product_name)
       OR NOT (NEW.slug <=> OLD.slug)
       OR NOT (NEW.style_code <=> OLD.style_code)
       OR NOT (NEW.description <=> OLD.description)
       OR NOT (NEW.publication_status <=> OLD.publication_status) THEN
        INSERT INTO product_version (
            product_id, version_number, brand_id, brand_name_snapshot,
            category_id, category_name_snapshot, product_name, slug,
            style_code, description, publication_status
        )
        SELECT NEW.product_id,
               (SELECT COALESCE(MAX(pv.version_number), 0) + 1
                  FROM product_version pv WHERE pv.product_id = NEW.product_id),
               NEW.brand_id, b.brand_name, NEW.category_id, c.category_name,
               NEW.product_name, NEW.slug, NEW.style_code,
               NEW.description, NEW.publication_status
          FROM brand b CROSS JOIN category c
         WHERE b.brand_id = NEW.brand_id AND c.category_id = NEW.category_id;
    END IF;
END$$

CREATE TRIGGER trg_product_version_no_update
BEFORE UPDATE ON product_version
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product versions are immutable';
END$$

CREATE TRIGGER trg_product_version_no_delete
BEFORE DELETE ON product_version
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product versions are immutable';
END$$

/* A shared account can have one subtype only. Lock the parent to serialize
   competing customer/staff inserts for the same account. */
CREATE TRIGGER trg_customer_before_insert_exclusive
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    DECLARE v_account_id INT DEFAULT NULL;
    DECLARE v_staff_id INT DEFAULT NULL;
    SELECT account_id INTO v_account_id
      FROM account WHERE account_id = NEW.customer_id FOR UPDATE;
    IF v_account_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer account does not exist';
    END IF;
    SELECT staff_id INTO v_staff_id
      FROM staff WHERE staff_id = NEW.customer_id FOR UPDATE;
    IF v_staff_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account already has a staff profile';
    END IF;
END$$

CREATE TRIGGER trg_customer_before_update_identity
BEFORE UPDATE ON customer
FOR EACH ROW
BEGIN
    IF NEW.customer_id <> OLD.customer_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer account identity cannot be changed';
    END IF;
END$$

CREATE TRIGGER trg_staff_before_insert_exclusive
BEFORE INSERT ON staff
FOR EACH ROW
BEGIN
    DECLARE v_account_id INT DEFAULT NULL;
    DECLARE v_customer_id INT DEFAULT NULL;
    SELECT account_id INTO v_account_id
      FROM account WHERE account_id = NEW.staff_id FOR UPDATE;
    IF v_account_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staff account does not exist';
    END IF;
    SELECT customer_id INTO v_customer_id
      FROM customer WHERE customer_id = NEW.staff_id FOR UPDATE;
    IF v_customer_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account already has a customer profile';
    END IF;
END$$

CREATE TRIGGER trg_staff_before_update_identity
BEFORE UPDATE ON staff
FOR EACH ROW
BEGIN
    IF NEW.staff_id <> OLD.staff_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staff account identity cannot be changed';
    END IF;
END$$

CREATE TRIGGER trg_cart_item_before_insert_reservation
BEFORE INSERT ON cart_item
FOR EACH ROW
BEGIN
    DECLARE v_rows_changed INT DEFAULT 0;
    IF NEW.reserved_quantity > 0 THEN
        UPDATE product_variant
           SET reserved_quantity = reserved_quantity + NEW.reserved_quantity
         WHERE variant_id = NEW.variant_id
           AND available_quantity >= NEW.reserved_quantity;
        SET v_rows_changed = ROW_COUNT();
        IF v_rows_changed <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient available stock for reservation';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_cart_item_before_update_reservation
BEFORE UPDATE ON cart_item
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
        UPDATE product_variant
           SET reserved_quantity = reserved_quantity + v_reservation_delta
         WHERE variant_id = NEW.variant_id
           AND available_quantity >= v_reservation_delta;
        SET v_rows_changed = ROW_COUNT();
        IF v_rows_changed <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient available stock for reservation';
        END IF;
    ELSEIF v_reservation_delta < 0 THEN
        UPDATE product_variant
           SET reserved_quantity = reserved_quantity - ABS(v_reservation_delta)
         WHERE variant_id = NEW.variant_id;
    END IF;
END$$

CREATE TRIGGER trg_cart_item_before_delete_reservation
BEFORE DELETE ON cart_item
FOR EACH ROW
BEGIN
    IF OLD.reserved_quantity > 0 THEN
        UPDATE product_variant
           SET reserved_quantity = reserved_quantity - OLD.reserved_quantity
         WHERE variant_id = OLD.variant_id;
    END IF;
END$$

CREATE TRIGGER trg_inventory_document_item_before_insert
BEFORE INSERT ON inventory_document_item
FOR EACH ROW
BEGIN
    DECLARE v_document_type VARCHAR(20);
    DECLARE v_document_status VARCHAR(20);
    DECLARE v_purchase_order_id INT;
    DECLARE v_po_item_count INT DEFAULT 0;
    DECLARE v_product_version_id INT DEFAULT NULL;
    DECLARE v_sku VARCHAR(100);
    DECLARE v_color VARCHAR(100);
    DECLARE v_size VARCHAR(10);

    SELECT pv.product_version_id, v.sku, c.color_name, v.size_code
      INTO v_product_version_id, v_sku, v_color, v_size
      FROM product_variant v
      JOIN product_version pv ON pv.product_id = v.product_id
      JOIN color c ON c.color_id = v.color_id
     WHERE v.variant_id = NEW.variant_id
     ORDER BY pv.version_number DESC LIMIT 1;
    IF v_product_version_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product version is missing for inventory line';
    END IF;
    SET NEW.product_version_id = v_product_version_id;
    SET NEW.sku_snapshot = v_sku;
    SET NEW.color_snapshot = v_color;
    SET NEW.size_snapshot = v_size;

    SELECT document_type, document_status, purchase_order_id
      INTO v_document_type, v_document_status, v_purchase_order_id
      FROM inventory_document
     WHERE inventory_document_id = NEW.inventory_document_id FOR UPDATE;
    IF v_document_status IS NULL OR v_document_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory lines can only be added to draft documents';
    END IF;
    IF (v_document_type = 'RECEIPT' AND NEW.quantity_change <= 0)
       OR (v_document_type = 'ISSUE' AND NEW.quantity_change >= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line quantity direction is invalid';
    END IF;
    IF v_document_type = 'RECEIPT' AND NEW.unit_cost IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receipt line requires unit cost';
    END IF;
    IF v_document_type = 'ADJUSTMENT'
       AND (NEW.reason IS NULL OR TRIM(NEW.reason) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Adjustment line requires a reason';
    END IF;
    IF v_purchase_order_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_po_item_count
          FROM purchase_order_item
         WHERE purchase_order_item_id = NEW.purchase_order_item_id
           AND purchase_order_id = v_purchase_order_id
           AND variant_id = NEW.variant_id;
        IF v_po_item_count <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line must match its purchase order';
        END IF;
    ELSEIF NEW.purchase_order_item_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Purchase order item requires a purchase-order receipt';
    END IF;
END$$

CREATE TRIGGER trg_inventory_document_item_before_update
BEFORE UPDATE ON inventory_document_item
FOR EACH ROW
BEGIN
    DECLARE v_document_type VARCHAR(20);
    DECLARE v_document_status VARCHAR(20);
    DECLARE v_purchase_order_id INT;
    DECLARE v_po_item_count INT DEFAULT 0;
    DECLARE v_product_version_id INT DEFAULT NULL;
    DECLARE v_sku VARCHAR(100);
    DECLARE v_color VARCHAR(100);
    DECLARE v_size VARCHAR(10);

    IF NEW.inventory_document_id <> OLD.inventory_document_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line cannot move to another document';
    END IF;
    IF NEW.variant_id <> OLD.variant_id THEN
        SELECT pv.product_version_id, v.sku, c.color_name, v.size_code
          INTO v_product_version_id, v_sku, v_color, v_size
          FROM product_variant v
          JOIN product_version pv ON pv.product_id = v.product_id
          JOIN color c ON c.color_id = v.color_id
         WHERE v.variant_id = NEW.variant_id
         ORDER BY pv.version_number DESC LIMIT 1;
        IF v_product_version_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product version is missing for inventory line';
        END IF;
        SET NEW.product_version_id = v_product_version_id;
        SET NEW.sku_snapshot = v_sku;
        SET NEW.color_snapshot = v_color;
        SET NEW.size_snapshot = v_size;
    ELSEIF NEW.product_version_id <> OLD.product_version_id
       OR NEW.sku_snapshot <> OLD.sku_snapshot
       OR NEW.color_snapshot <> OLD.color_snapshot
       OR NEW.size_snapshot <> OLD.size_snapshot THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line product snapshot cannot be edited';
    END IF;
    SELECT document_type, document_status, purchase_order_id
      INTO v_document_type, v_document_status, v_purchase_order_id
      FROM inventory_document
     WHERE inventory_document_id = OLD.inventory_document_id FOR UPDATE;
    IF v_document_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only draft inventory lines can be edited';
    END IF;
    IF (v_document_type = 'RECEIPT' AND NEW.quantity_change <= 0)
       OR (v_document_type = 'ISSUE' AND NEW.quantity_change >= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line quantity direction is invalid';
    END IF;
    IF v_document_type = 'RECEIPT' AND NEW.unit_cost IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receipt line requires unit cost';
    END IF;
    IF v_document_type = 'ADJUSTMENT'
       AND (NEW.reason IS NULL OR TRIM(NEW.reason) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Adjustment line requires a reason';
    END IF;
    IF v_purchase_order_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_po_item_count
          FROM purchase_order_item
         WHERE purchase_order_item_id = NEW.purchase_order_item_id
           AND purchase_order_id = v_purchase_order_id
           AND variant_id = NEW.variant_id;
        IF v_po_item_count <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line must match its purchase order';
        END IF;
    ELSEIF NEW.purchase_order_item_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Purchase order item requires a purchase-order receipt';
    END IF;
END$$

CREATE TRIGGER trg_inventory_document_item_before_delete
BEFORE DELETE ON inventory_document_item
FOR EACH ROW
BEGIN
    DECLARE v_document_status VARCHAR(20);
    SELECT document_status INTO v_document_status
      FROM inventory_document
     WHERE inventory_document_id = OLD.inventory_document_id FOR UPDATE;
    IF v_document_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only draft inventory lines can be deleted';
    END IF;
END$$

CREATE TRIGGER trg_inventory_document_before_update_status
BEFORE UPDATE ON inventory_document
FOR EACH ROW
BEGIN
    DECLARE v_line_count INT DEFAULT 0;
    DECLARE v_invalid_line_count INT DEFAULT 0;
    IF OLD.document_status IN ('POSTED', 'CANCELLED') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Posted or cancelled inventory documents are immutable';
    END IF;
    IF OLD.document_status <> NEW.document_status AND NOT (
        (OLD.document_status = 'DRAFT' AND NEW.document_status IN ('APPROVED', 'CANCELLED'))
        OR (OLD.document_status = 'APPROVED' AND NEW.document_status IN ('DRAFT', 'POSTED', 'CANCELLED'))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid inventory document status transition';
    END IF;
    IF NEW.document_status IN ('APPROVED', 'POSTED') THEN
        SELECT COUNT(*) INTO v_line_count
          FROM inventory_document_item
         WHERE inventory_document_id = NEW.inventory_document_id;
        IF v_line_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory document requires at least one line';
        END IF;
        SELECT COUNT(*) INTO v_invalid_line_count
          FROM inventory_document_item item
          LEFT JOIN purchase_order_item poi
            ON poi.purchase_order_item_id = item.purchase_order_item_id
         WHERE item.inventory_document_id = NEW.inventory_document_id
           AND ((NEW.document_type = 'RECEIPT'
                 AND (item.quantity_change <= 0 OR item.unit_cost IS NULL))
                OR (NEW.document_type = 'ISSUE' AND item.quantity_change >= 0)
                OR (NEW.document_type = 'ADJUSTMENT'
                    AND (item.reason IS NULL OR TRIM(item.reason) = ''))
                OR (NEW.purchase_order_id IS NOT NULL
                    AND (poi.purchase_order_item_id IS NULL
                         OR poi.purchase_order_id <> NEW.purchase_order_id
                         OR poi.variant_id <> item.variant_id))
                OR (NEW.purchase_order_id IS NULL
                    AND item.purchase_order_item_id IS NOT NULL));
        IF v_invalid_line_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory document has invalid lines';
        END IF;
    END IF;
    IF OLD.document_status = 'APPROVED'
       AND NEW.document_status IN ('APPROVED', 'POSTED')
       AND (NOT (NEW.document_type <=> OLD.document_type)
            OR NOT (NEW.purchase_order_id <=> OLD.purchase_order_id)
            OR NOT (NEW.source_order_id <=> OLD.source_order_id)
            OR NOT (NEW.created_by_staff_id <=> OLD.created_by_staff_id)
            OR NOT (NEW.approved_by_staff_id <=> OLD.approved_by_staff_id)
            OR NOT (NEW.approved_at <=> OLD.approved_at)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Approved inventory document content is immutable';
    END IF;
END$$

CREATE TRIGGER trg_inventory_document_after_update_post
AFTER UPDATE ON inventory_document
FOR EACH ROW
BEGIN
    IF OLD.document_status = 'APPROVED' AND NEW.document_status = 'POSTED' THEN
        INSERT INTO inventory_transaction (
            inventory_document_item_id, inventory_document_id, variant_id,
            purchase_order_item_id, actor_staff_id, transaction_type,
            quantity_change, unit_cost, reason, idempotency_key
        )
        SELECT item.inventory_document_item_id, item.inventory_document_id,
               item.variant_id, item.purchase_order_item_id, NEW.posted_by_staff_id,
               NEW.document_type, item.quantity_change, item.unit_cost,
               item.reason, UUID()
          FROM inventory_document_item item
         WHERE item.inventory_document_id = NEW.inventory_document_id
         ORDER BY item.inventory_document_item_id;
    END IF;
END$$

CREATE TRIGGER trg_inventory_transaction_before_insert
BEFORE INSERT ON inventory_transaction
FOR EACH ROW
BEGIN
    DECLARE v_item_quantity BIGINT;
    DECLARE v_item_po_id INT;
    DECLARE v_item_unit_cost DECIMAL(12,2);
    DECLARE v_item_reason VARCHAR(1000);
    DECLARE v_document_type VARCHAR(20);
    DECLARE v_document_status VARCHAR(20);
    DECLARE v_posted_by_staff_id INT;
    DECLARE v_purchase_order_id INT;
    DECLARE v_source_order_id INT;
    DECLARE v_purchase_order_status VARCHAR(20);
    DECLARE v_po_item_count INT DEFAULT 0;
    DECLARE v_order_variant_quantity BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_prior_order_movement BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_rows_changed INT DEFAULT 0;
    DECLARE v_balance BIGINT UNSIGNED;

    SELECT quantity_change, purchase_order_item_id, unit_cost, reason
      INTO v_item_quantity, v_item_po_id, v_item_unit_cost, v_item_reason
      FROM inventory_document_item
     WHERE inventory_document_item_id = NEW.inventory_document_item_id
       AND inventory_document_id = NEW.inventory_document_id
       AND variant_id = NEW.variant_id;
    IF v_item_quantity IS NULL
       OR NEW.quantity_change <> v_item_quantity
       OR NOT (NEW.purchase_order_item_id <=> v_item_po_id)
       OR NOT (NEW.unit_cost <=> v_item_unit_cost)
       OR NOT (NEW.reason <=> v_item_reason) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory transaction must match its approved line';
    END IF;

    SELECT document_type, document_status, posted_by_staff_id,
           purchase_order_id, source_order_id
      INTO v_document_type, v_document_status,
           v_posted_by_staff_id, v_purchase_order_id, v_source_order_id
      FROM inventory_document
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
          FROM purchase_order
         WHERE purchase_order_id = v_purchase_order_id;
        IF v_purchase_order_status NOT IN ('APPROVED', 'PARTIALLY_RECEIVED') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Purchase order is not receivable';
        END IF;
        SELECT COUNT(*) INTO v_po_item_count
          FROM purchase_order_item
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
          FROM order_item
         WHERE order_id = v_source_order_id
           AND variant_id = NEW.variant_id;
        IF v_order_variant_quantity = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory line variant does not belong to its source order';
        END IF;

        SELECT COALESCE(SUM(ABS(it.quantity_change)), 0)
          INTO v_prior_order_movement
          FROM inventory_transaction it
          JOIN inventory_document idoc
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

    UPDATE product_variant
       SET stock_quantity = CAST(stock_quantity AS SIGNED) + NEW.quantity_change
     WHERE variant_id = NEW.variant_id
       AND CAST(stock_quantity AS SIGNED) + NEW.quantity_change >= reserved_quantity;
    SET v_rows_changed = ROW_COUNT();

    IF v_rows_changed <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Variant is missing or available stock is insufficient';
    END IF;

    SELECT stock_quantity INTO v_balance
      FROM product_variant
     WHERE variant_id = NEW.variant_id;
    SET NEW.balance_after = v_balance;
END$$

CREATE TRIGGER trg_inventory_transaction_after_insert_receipt
AFTER INSERT ON inventory_transaction
FOR EACH ROW
BEGIN
    DECLARE v_purchase_order_item_id INT;
    DECLARE v_purchase_order_id INT;
    DECLARE v_rows_changed INT DEFAULT 0;

    IF NEW.transaction_type = 'RECEIPT' THEN
        SET v_purchase_order_item_id = NEW.purchase_order_item_id;
        SELECT purchase_order_id INTO v_purchase_order_id
          FROM inventory_document
         WHERE inventory_document_id = NEW.inventory_document_id;

        IF v_purchase_order_item_id IS NOT NULL THEN
            UPDATE purchase_order_item
               SET received_quantity = received_quantity + NEW.quantity_change
             WHERE purchase_order_item_id = v_purchase_order_item_id
               AND received_quantity + NEW.quantity_change <= ordered_quantity;
            SET v_rows_changed = ROW_COUNT();
            IF v_rows_changed <> 1 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receipt exceeds outstanding purchase order quantity';
            END IF;

            UPDATE purchase_order
               SET status = CASE
                   WHEN NOT EXISTS (
                       SELECT 1
                         FROM purchase_order_item poi
                        WHERE poi.purchase_order_id = v_purchase_order_id
                          AND poi.received_quantity < poi.ordered_quantity
                   ) THEN 'RECEIVED'
                   ELSE 'PARTIALLY_RECEIVED'
               END
             WHERE purchase_order_id = v_purchase_order_id;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_sales_order_before_update_status
BEFORE UPDATE ON sales_order
FOR EACH ROW
BEGIN
    IF NOT (OLD.voucher_id <=> NEW.voucher_id)
       OR NOT (OLD.voucher_code <=> NEW.voucher_code) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order voucher cannot be changed after creation';
    END IF;
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

CREATE TRIGGER trg_sales_order_before_delete_voucher
BEFORE DELETE ON sales_order
FOR EACH ROW
BEGIN
    IF OLD.voucher_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An order that used a voucher cannot be deleted';
    END IF;
END$$

CREATE TRIGGER trg_review_before_insert_owner
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE v_owner_id INT;
    DECLARE v_order_status VARCHAR(30);

    SELECT o.customer_id, o.order_status
      INTO v_owner_id, v_order_status
      FROM order_item oi
      JOIN sales_order o ON o.order_id = oi.order_id
     WHERE oi.order_item_id = NEW.order_item_id;

    IF v_owner_id IS NULL OR v_owner_id <> NEW.customer_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Review must belong to the order owner';
    END IF;
    IF v_order_status NOT IN ('DELIVERED', 'COMPLETED') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only delivered purchases can be reviewed';
    END IF;
END$$

CREATE TRIGGER trg_review_no_update
BEFORE UPDATE ON review
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reviews can only be created or deleted';
END$$

CREATE TRIGGER trg_inventory_transaction_no_update
BEFORE UPDATE ON inventory_transaction
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory ledger is append-only';
END$$

CREATE TRIGGER trg_inventory_transaction_no_delete
BEFORE DELETE ON inventory_transaction
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory ledger is append-only';
END$$

CREATE TRIGGER trg_audit_log_no_update
BEFORE UPDATE ON audit_log
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit log is append-only';
END$$

CREATE TRIGGER trg_audit_log_no_delete
BEFORE DELETE ON audit_log
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit log is append-only';
END$$

DELIMITER ;
