-- 1. TENANT (Cửa hàng/Hệ thống gốc)
CREATE TABLE tenants (
    tenant_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name NVARCHAR(255) NOT NULL,
    domain VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 2. BRANCH (Chi nhánh)
CREATE TABLE branches (
    branch_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    name NVARCHAR(255) NOT NULL,
    address NVARCHAR(MAX),
    phone VARCHAR(20),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 3. USER (Người dùng/Nhân viên)
CREATE TABLE users (
    user_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name NVARCHAR(255),
    role VARCHAR(50) NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 4. PARTNER (Khách hàng/Nhà cung cấp)
CREATE TABLE partners (
    partner_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    name NVARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 5. PRODUCT_CATEGORY (Danh mục sản phẩm)
CREATE TABLE product_categories (
    category_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 6. PRODUCT (Sản phẩm chung)
CREATE TABLE products (
    product_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    category_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES product_categories(category_id),
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    base_price DECIMAL(15, 2),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 7. BRAND (Thương hiệu)
CREATE TABLE brands (
    brand_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    name NVARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

-- 8. SKU_VARIANT (Biến thể sản phẩm)
CREATE TABLE sku_variants (
    sku_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    product_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES products(product_id) ON DELETE CASCADE,
    sku_code VARCHAR(50) NOT NULL UNIQUE,
    color NVARCHAR(50),
    size NVARCHAR(50),
    price DECIMAL(15, 2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 9. BARCODE (Mã vạch)
CREATE TABLE barcodes (
    barcode_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    sku_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id) ON DELETE CASCADE,
    barcode VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE()
);

-- 10. STOCK_BALANCE (Tồn kho)
CREATE TABLE stock_balances (
    balance_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    branch_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    sku_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity INT DEFAULT 0,
    last_updated DATETIME DEFAULT GETDATE(),
    CONSTRAINT uq_branch_sku UNIQUE (branch_id, sku_id)
);

-- 11. INVENTORY_TRANSACTION (Giao dịch Sổ cái kho)
CREATE TABLE inventory_transactions (
    transaction_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    branch_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    sku_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    transaction_type VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    reference_id UNIQUEIDENTIFIER,
    created_at DATETIME DEFAULT GETDATE()
);

-- 12. ORDER (Đơn hàng)
CREATE TABLE orders (
    order_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    partner_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES partners(partner_id),
    user_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES users(user_id),
    status VARCHAR(50) DEFAULT 'PENDING',
    total_amount DECIMAL(15, 2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 13. ORDER_ITEM (Chi tiết đơn hàng)
CREATE TABLE order_items (
    order_item_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    order_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES orders(order_id) ON DELETE CASCADE,
    sku_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    subtotal DECIMAL(15, 2) NOT NULL
);

-- 14. PURCHASE_RECEIPT (Phiếu nhập hàng từ NCC)
CREATE TABLE purchase_receipts (
    receipt_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    partner_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES partners(partner_id),
    status VARCHAR(50) DEFAULT 'DRAFT',
    total_amount DECIMAL(15, 2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

-- 15. PURCHASE_RECEIPT_ITEM (Chi tiết phiếu nhập)
CREATE TABLE purchase_receipt_items (
    receipt_item_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    receipt_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES purchase_receipts(receipt_id) ON DELETE CASCADE,
    sku_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity INT NOT NULL,
    cost_price DECIMAL(15, 2) NOT NULL
);

-- 16. STOCK_TRANSFER (Phiếu điều chuyển kho)
CREATE TABLE stock_transfers (
    transfer_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    from_branch_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    to_branch_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT GETDATE()
);

-- 17. STOCK_TRANSFER_ITEM (Chi tiết phiếu điều chuyển)
CREATE TABLE stock_transfer_items (
    transfer_item_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    transfer_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES stock_transfers(transfer_id) ON DELETE CASCADE,
    sku_id UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity INT NOT NULL
);
