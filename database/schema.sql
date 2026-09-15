-- =====================================================
-- DATABASE SCHEMA - POSTGRESQL
-- Hệ thống quản lý bán hàng và tồn kho đa kênh
-- Thành viên 2: Database Engineer
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- 1. TENANTS
-- =====================================================

CREATE TABLE tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_tenants_status
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- =====================================================
-- 2. PRODUCT CATEGORIES
-- =====================================================

CREATE TABLE product_categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_categories_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT uq_categories_tenant_name
        UNIQUE (tenant_id, name)
);

-- =====================================================
-- 3. BRANDS
-- =====================================================

CREATE TABLE brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_brands_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT uq_brands_tenant_name
        UNIQUE (tenant_id, name)
);

-- =====================================================
-- 4. BRANCHES
-- =====================================================

CREATE TABLE branches (
    branch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    phone VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_branches_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id)
);

-- =====================================================
-- 5. USERS
-- =====================================================

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT ck_users_role
        CHECK (role IN ('Owner', 'Staff', 'Cashier')),

    CONSTRAINT uq_users_tenant_username
        UNIQUE (tenant_id, username),

    CONSTRAINT uq_users_tenant_email
        UNIQUE (tenant_id, email)
);

-- =====================================================
-- 6. PARTNERS
-- =====================================================

CREATE TABLE partners (
    partner_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    address VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_partners_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT ck_partners_type
        CHECK (type IN ('SUPPLIER', 'CUSTOMER'))
);

-- =====================================================
-- 7. SALES CHANNELS
-- =====================================================

CREATE TABLE sales_channels (
    channel_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_channels_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT ck_channels_type
        CHECK (type IN ('OFFLINE', 'ONLINE')),

    CONSTRAINT uq_channels_tenant_code
        UNIQUE (tenant_id, code)
);

-- =====================================================
-- 8. PRODUCTS
-- =====================================================

CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    category_id UUID,
    brand_id UUID,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    base_price NUMERIC(14,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_products_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES product_categories(category_id),

    CONSTRAINT fk_products_brand
        FOREIGN KEY (brand_id)
        REFERENCES brands(brand_id),

    CONSTRAINT ck_products_base_price
        CHECK (base_price >= 0)
);

-- =====================================================
-- 9. SKU VARIANTS
-- =====================================================

CREATE TABLE sku_variants (
    sku_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    product_id UUID NOT NULL,
    sku_code VARCHAR(100) NOT NULL,
    color VARCHAR(100),
    size VARCHAR(100),
    price NUMERIC(14,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sku_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_sku_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT uq_sku_tenant_code
        UNIQUE (tenant_id, sku_code),

    CONSTRAINT uq_sku_product_variant
        UNIQUE (product_id, color, size),

    CONSTRAINT ck_sku_price
        CHECK (price >= 0)
);

-- =====================================================
-- 10. BARCODES
-- =====================================================

CREATE TABLE barcodes (
    barcode_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    barcode VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_barcodes_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_barcodes_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT uq_barcodes_code
        UNIQUE (barcode)
);

-- =====================================================
-- 11. STOCK BALANCES
-- =====================================================

CREATE TABLE stock_balances (
    tenant_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    on_hand NUMERIC(14,3) NOT NULL DEFAULT 0,
    reserved NUMERIC(14,3) NOT NULL DEFAULT 0,
    avg_cost NUMERIC(14,2) NOT NULL DEFAULT 0,

    available NUMERIC(14,3)
        GENERATED ALWAYS AS (on_hand - reserved) STORED,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_stock_balances
        PRIMARY KEY (branch_id, sku_id),

    CONSTRAINT fk_stock_balances_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_stock_balances_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_stock_balances_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT ck_stock_on_hand
        CHECK (on_hand >= 0),

    CONSTRAINT ck_stock_reserved
        CHECK (reserved >= 0),

    CONSTRAINT ck_stock_reserved_on_hand
        CHECK (reserved <= on_hand),

    CONSTRAINT ck_stock_avg_cost
        CHECK (avg_cost >= 0)
);

-- =====================================================
-- 12. INVENTORY TRANSACTIONS
-- =====================================================

CREATE TABLE inventory_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    transaction_type VARCHAR(10) NOT NULL,
    quantity NUMERIC(14,3) NOT NULL,
    balance_after NUMERIC(14,3) NOT NULL,
    reference_id UUID,
    reference_type VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_transactions_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_inventory_transactions_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_inventory_transactions_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT ck_inventory_transaction_type
        CHECK (transaction_type IN ('IN', 'OUT')),

    CONSTRAINT ck_inventory_transaction_quantity
        CHECK (quantity > 0),

    CONSTRAINT ck_inventory_transaction_balance
        CHECK (balance_after >= 0)
);

-- =====================================================
-- 13. STOCKTAKES
-- =====================================================

CREATE TABLE stocktakes (
    stocktake_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    note VARCHAR(500),
    created_by UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,

    CONSTRAINT fk_stocktakes_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_stocktakes_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_stocktakes_user
        FOREIGN KEY (created_by)
        REFERENCES users(user_id),

    CONSTRAINT ck_stocktakes_status
        CHECK (status IN ('DRAFT', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
);

-- =====================================================
-- 14. STOCKTAKE ITEMS
-- =====================================================

CREATE TABLE stocktake_items (
    stocktake_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    stocktake_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    system_qty NUMERIC(14,3) NOT NULL DEFAULT 0,
    counted_qty NUMERIC(14,3) NOT NULL DEFAULT 0,

    variance_qty NUMERIC(14,3)
        GENERATED ALWAYS AS (counted_qty - system_qty) STORED,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_stocktake_items_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_stocktake_items_stocktake
        FOREIGN KEY (stocktake_id)
        REFERENCES stocktakes(stocktake_id),

    CONSTRAINT fk_stocktake_items_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT ck_stocktake_system_qty
        CHECK (system_qty >= 0),

    CONSTRAINT ck_stocktake_counted_qty
        CHECK (counted_qty >= 0),

    CONSTRAINT uq_stocktake_item
        UNIQUE (stocktake_id, sku_id)
);

-- =====================================================
-- 15. ORDERS
-- =====================================================

CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    channel_id UUID NOT NULL,
    partner_id UUID,
    created_by UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'Draft',
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_orders_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_orders_channel
        FOREIGN KEY (channel_id)
        REFERENCES sales_channels(channel_id),

    CONSTRAINT fk_orders_partner
        FOREIGN KEY (partner_id)
        REFERENCES partners(partner_id),

    CONSTRAINT fk_orders_user
        FOREIGN KEY (created_by)
        REFERENCES users(user_id),

    CONSTRAINT ck_orders_status
        CHECK (
            status IN (
                'Draft',
                'Reserved',
                'Confirmed',
                'Completed',
                'Cancelled'
            )
        ),

    CONSTRAINT ck_orders_total_amount
        CHECK (total_amount >= 0)
);

-- =====================================================
-- 16. ORDER ITEMS
-- =====================================================

CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    order_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    quantity NUMERIC(14,3) NOT NULL,
    unit_price NUMERIC(14,2) NOT NULL,
    cost_price NUMERIC(14,2) NOT NULL DEFAULT 0,

    subtotal NUMERIC(29,5)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_items_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT ck_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT ck_order_items_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT ck_order_items_cost_price
        CHECK (cost_price >= 0),

    CONSTRAINT uq_order_items_order_sku
        UNIQUE (order_id, sku_id)
);

-- =====================================================
-- 17. PURCHASE RECEIPTS
-- =====================================================

CREATE TABLE purchase_receipts (
    receipt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    supplier_id UUID NOT NULL,
    created_by UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_receipts_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_receipts_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_receipts_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES partners(partner_id),

    CONSTRAINT fk_receipts_user
        FOREIGN KEY (created_by)
        REFERENCES users(user_id),

    CONSTRAINT ck_receipts_status
        CHECK (status IN ('DRAFT', 'CONFIRMED', 'CANCELLED')),

    CONSTRAINT ck_receipts_total_amount
        CHECK (total_amount >= 0)
);

-- =====================================================
-- 18. PURCHASE RECEIPT ITEMS
-- =====================================================

CREATE TABLE purchase_receipt_items (
    receipt_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    receipt_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    quantity NUMERIC(14,3) NOT NULL,
    unit_cost NUMERIC(14,2) NOT NULL,

    subtotal NUMERIC(29,5)
        GENERATED ALWAYS AS (quantity * unit_cost) STORED,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_receipt_items_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_receipt_items_receipt
        FOREIGN KEY (receipt_id)
        REFERENCES purchase_receipts(receipt_id),

    CONSTRAINT fk_receipt_items_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT ck_receipt_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT ck_receipt_items_unit_cost
        CHECK (unit_cost >= 0),

    CONSTRAINT uq_receipt_items_receipt_sku
        UNIQUE (receipt_id, sku_id)
);

-- =====================================================
-- 19. STOCK TRANSFERS
-- =====================================================

CREATE TABLE stock_transfers (
    transfer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    from_branch_id UUID NOT NULL,
    to_branch_id UUID NOT NULL,
    created_by UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    note VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transfers_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_transfers_from_branch
        FOREIGN KEY (from_branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_transfers_to_branch
        FOREIGN KEY (to_branch_id)
        REFERENCES branches(branch_id),

    CONSTRAINT fk_transfers_user
        FOREIGN KEY (created_by)
        REFERENCES users(user_id),

    CONSTRAINT ck_transfers_status
        CHECK (status IN ('DRAFT', 'CONFIRMED', 'COMPLETED', 'CANCELLED')),

    CONSTRAINT ck_transfers_different_branch
        CHECK (from_branch_id <> to_branch_id)
);

-- =====================================================
-- 20. STOCK TRANSFER ITEMS
-- =====================================================

CREATE TABLE stock_transfer_items (
    transfer_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    transfer_id UUID NOT NULL,
    sku_id UUID NOT NULL,
    quantity NUMERIC(14,3) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transfer_items_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_transfer_items_transfer
        FOREIGN KEY (transfer_id)
        REFERENCES stock_transfers(transfer_id),

    CONSTRAINT fk_transfer_items_sku
        FOREIGN KEY (sku_id)
        REFERENCES sku_variants(sku_id),

    CONSTRAINT ck_transfer_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT uq_transfer_items_transfer_sku
        UNIQUE (transfer_id, sku_id)
);