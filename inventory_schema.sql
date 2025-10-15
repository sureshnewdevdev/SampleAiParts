-- Inventory System Database Creation Script
-- This script creates the schema for an inventory management system
-- including product catalog, warehouses, orders, and stock tracking.

-- Drop existing database if necessary (comment out in production environments)
-- DROP DATABASE IF EXISTS inventory_system;

CREATE DATABASE IF NOT EXISTS inventory_system
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE inventory_system;

-- Table: roles
CREATE TABLE roles (
    role_id       INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(50) NOT NULL UNIQUE,
    description   VARCHAR(255)
) ENGINE=InnoDB;

-- Table: users
CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    role_id       INT NOT NULL,
    username      VARCHAR(100) NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash CHAR(60) NOT NULL,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_roles
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: suppliers
CREATE TABLE suppliers (
    supplier_id   INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    contact_name  VARCHAR(150),
    phone         VARCHAR(50),
    email         VARCHAR(255),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city          VARCHAR(100),
    state         VARCHAR(100),
    postal_code   VARCHAR(20),
    country       VARCHAR(100),
    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: customers
CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    contact_name  VARCHAR(150),
    phone         VARCHAR(50),
    email         VARCHAR(255),
    billing_address_line1 VARCHAR(255),
    billing_address_line2 VARCHAR(255),
    billing_city  VARCHAR(100),
    billing_state VARCHAR(100),
    billing_postal_code VARCHAR(20),
    billing_country VARCHAR(100),
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: warehouses
CREATE TABLE warehouses (
    warehouse_id  INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    code          VARCHAR(20) NOT NULL UNIQUE,
    phone         VARCHAR(50),
    email         VARCHAR(255),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city          VARCHAR(100),
    state         VARCHAR(100),
    postal_code   VARCHAR(20),
    country       VARCHAR(100),
    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: product_categories
CREATE TABLE product_categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    parent_id     INT,
    name          VARCHAR(255) NOT NULL,
    description   VARCHAR(255),
    CONSTRAINT fk_product_categories_parent
        FOREIGN KEY (parent_id) REFERENCES product_categories(category_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_product_categories_parent ON product_categories(parent_id);

-- Table: products
CREATE TABLE products (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    sku           VARCHAR(100) NOT NULL UNIQUE,
    name          VARCHAR(255) NOT NULL,
    description   TEXT,
    unit_price    DECIMAL(12,2) NOT NULL,
    unit_cost     DECIMAL(12,2) NOT NULL,
    reorder_point INT NOT NULL DEFAULT 0,
    reorder_quantity INT NOT NULL DEFAULT 0,
    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: product_category_assignments
CREATE TABLE product_category_assignments (
    product_id    INT NOT NULL,
    category_id   INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_pca_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pca_category
        FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table: product_suppliers
CREATE TABLE product_suppliers (
    product_id    INT NOT NULL,
    supplier_id   INT NOT NULL,
    supplier_sku  VARCHAR(100),
    lead_time_days INT,
    purchase_price DECIMAL(12,2),
    PRIMARY KEY (product_id, supplier_id),
    CONSTRAINT fk_product_suppliers_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_product_suppliers_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: warehouse_stock
CREATE TABLE warehouse_stock (
    warehouse_id  INT NOT NULL,
    product_id    INT NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    quantity_available AS (quantity_on_hand - quantity_reserved) STORED,
    PRIMARY KEY (warehouse_id, product_id),
    CONSTRAINT fk_warehouse_stock_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_warehouse_stock_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table: inventory_transactions
CREATE TABLE inventory_transactions (
    transaction_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id      INT NOT NULL,
    product_id        INT NOT NULL,
    transaction_type  ENUM('RECEIPT', 'SHIPMENT', 'ADJUSTMENT', 'TRANSFER_IN', 'TRANSFER_OUT', 'RETURN') NOT NULL,
    quantity          INT NOT NULL,
    reference_type    VARCHAR(50),
    reference_id      VARCHAR(100),
    transaction_date  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    performed_by      INT,
    notes             TEXT,
    CONSTRAINT fk_inventory_transactions_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transactions_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_transactions_user
        FOREIGN KEY (performed_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_inventory_transactions_product_date
    ON inventory_transactions(product_id, transaction_date);

-- Table: purchase_orders
CREATE TABLE purchase_orders (
    purchase_order_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_id        INT NOT NULL,
    warehouse_id       INT NOT NULL,
    status             ENUM('DRAFT', 'SUBMITTED', 'APPROVED', 'RECEIVED', 'CANCELLED') NOT NULL DEFAULT 'DRAFT',
    expected_date      DATE,
    created_by         INT NOT NULL,
    approved_by        INT,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_purchase_orders_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_orders_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_orders_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_orders_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table: purchase_order_items
CREATE TABLE purchase_order_items (
    purchase_order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id      BIGINT NOT NULL,
    product_id             INT NOT NULL,
    ordered_quantity       INT NOT NULL,
    received_quantity      INT NOT NULL DEFAULT 0,
    unit_cost              DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_purchase_order_items_order
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(purchase_order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_purchase_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: sales_orders
CREATE TABLE sales_orders (
    sales_order_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id      INT NOT NULL,
    warehouse_id     INT NOT NULL,
    status           ENUM('DRAFT', 'CONFIRMED', 'PICKED', 'SHIPPED', 'CANCELLED', 'RETURNED') NOT NULL DEFAULT 'DRAFT',
    order_date       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    required_date    DATE,
    created_by       INT NOT NULL,
    approved_by      INT,
    notes            TEXT,
    CONSTRAINT fk_sales_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_sales_orders_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_sales_orders_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_sales_orders_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table: sales_order_items
CREATE TABLE sales_order_items (
    sales_order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sales_order_id      BIGINT NOT NULL,
    product_id          INT NOT NULL,
    ordered_quantity    INT NOT NULL,
    fulfilled_quantity  INT NOT NULL DEFAULT 0,
    unit_price          DECIMAL(12,2) NOT NULL,
    discount_percent    DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_sales_order_items_order
        FOREIGN KEY (sales_order_id) REFERENCES sales_orders(sales_order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_sales_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: stock_adjustments
CREATE TABLE stock_adjustments (
    adjustment_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id     INT NOT NULL,
    product_id       INT NOT NULL,
    adjustment_type  ENUM('INCREASE', 'DECREASE') NOT NULL,
    quantity         INT NOT NULL,
    reason           VARCHAR(255),
    adjustment_date  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       INT NOT NULL,
    CONSTRAINT fk_stock_adjustments_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_stock_adjustments_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_stock_adjustments_user
        FOREIGN KEY (created_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: transfers
CREATE TABLE transfers (
    transfer_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_warehouse_id INT NOT NULL,
    target_warehouse_id INT NOT NULL,
    status           ENUM('REQUESTED', 'IN_TRANSIT', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'REQUESTED',
    requested_by     INT NOT NULL,
    approved_by      INT,
    requested_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at      DATETIME,
    completed_at     DATETIME,
    notes            TEXT,
    CONSTRAINT fk_transfers_source
        FOREIGN KEY (source_warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transfers_target
        FOREIGN KEY (target_warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transfers_requested_by
        FOREIGN KEY (requested_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transfers_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table: transfer_items
CREATE TABLE transfer_items (
    transfer_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transfer_id      BIGINT NOT NULL,
    product_id       INT NOT NULL,
    requested_quantity INT NOT NULL,
    transferred_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_transfer_items_transfer
        FOREIGN KEY (transfer_id) REFERENCES transfers(transfer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_transfer_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: supplier_invoices
CREATE TABLE supplier_invoices (
    supplier_invoice_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id   BIGINT NOT NULL,
    invoice_number      VARCHAR(100) NOT NULL,
    invoice_date        DATE NOT NULL,
    due_date            DATE,
    total_amount        DECIMAL(14,2) NOT NULL,
    status              ENUM('PENDING', 'PAID', 'PARTIALLY_PAID', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_supplier_invoices_purchase_order
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(purchase_order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE KEY uq_supplier_invoice (purchase_order_id, invoice_number)
) ENGINE=InnoDB;

-- Table: customer_invoices
CREATE TABLE customer_invoices (
    customer_invoice_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sales_order_id      BIGINT NOT NULL,
    invoice_number      VARCHAR(100) NOT NULL,
    invoice_date        DATE NOT NULL,
    due_date            DATE,
    total_amount        DECIMAL(14,2) NOT NULL,
    status              ENUM('PENDING', 'PAID', 'PARTIALLY_PAID', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_customer_invoices_sales_order
        FOREIGN KEY (sales_order_id) REFERENCES sales_orders(sales_order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE KEY uq_customer_invoice (sales_order_id, invoice_number)
) ENGINE=InnoDB;

-- Table: payments_received
CREATE TABLE payments_received (
    payment_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_invoice_id BIGINT NOT NULL,
    payment_date   DATE NOT NULL,
    amount         DECIMAL(14,2) NOT NULL,
    payment_method ENUM('CASH', 'CREDIT_CARD', 'WIRE_TRANSFER', 'CHECK', 'OTHER') NOT NULL,
    reference      VARCHAR(100),
    received_by    INT NOT NULL,
    CONSTRAINT fk_payments_received_invoice
        FOREIGN KEY (customer_invoice_id) REFERENCES customer_invoices(customer_invoice_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_received_user
        FOREIGN KEY (received_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: payments_made
CREATE TABLE payments_made (
    payment_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_invoice_id BIGINT NOT NULL,
    payment_date   DATE NOT NULL,
    amount         DECIMAL(14,2) NOT NULL,
    payment_method ENUM('CASH', 'CREDIT_CARD', 'WIRE_TRANSFER', 'CHECK', 'OTHER') NOT NULL,
    reference      VARCHAR(100),
    paid_by        INT NOT NULL,
    CONSTRAINT fk_payments_made_invoice
        FOREIGN KEY (supplier_invoice_id) REFERENCES supplier_invoices(supplier_invoice_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_made_user
        FOREIGN KEY (paid_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Table: product_attributes
CREATE TABLE product_attributes (
    attribute_id   INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    data_type      ENUM('TEXT', 'NUMBER', 'DATE', 'BOOLEAN') NOT NULL,
    unit           VARCHAR(50)
) ENGINE=InnoDB;

-- Table: product_attribute_values
CREATE TABLE product_attribute_values (
    product_id     INT NOT NULL,
    attribute_id   INT NOT NULL,
    value_text     TEXT,
    value_number   DECIMAL(20,4),
    value_date     DATE,
    value_boolean  TINYINT(1),
    PRIMARY KEY (product_id, attribute_id),
    CONSTRAINT fk_product_attribute_values_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_product_attribute_values_attribute
        FOREIGN KEY (attribute_id) REFERENCES product_attributes(attribute_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table: audit_logs
CREATE TABLE audit_logs (
    audit_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name     VARCHAR(255) NOT NULL,
    record_id      VARCHAR(255) NOT NULL,
    action         ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    changed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by     INT,
    details        JSON,
    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (changed_by) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- Sample indexes to optimize frequent queries
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_suppliers_name ON suppliers(name);
CREATE INDEX idx_customers_name ON customers(name);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX idx_sales_orders_status ON sales_orders(status);

-- End of Inventory System schema
