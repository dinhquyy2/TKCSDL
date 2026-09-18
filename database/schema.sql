/* =====================================================================
   OISM - Omnichannel Inventory and Sales Management System
   database/schema.sql  (SQL Server / T-SQL)

   Phiên bản: 2.0 (đã sửa theo review Logical + Physical correctness)
   Xem giải trình đầy đủ tại: LOGICAL_DESIGN.md và PHYSICAL_DESIGN.md
   ===================================================================== */

-- =====================================================================
-- NHÓM 1: TENANT / AUTH / DANH MỤC
-- =====================================================================

CREATE TABLE tenants (
    tenant_id   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name        NVARCHAR(255) NOT NULL,
    domain      VARCHAR(100)  NULL,
    status      VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE'
                CHECK (status IN ('ACTIVE','SUSPENDED','INACTIVE')),
    created_at  DATETIME      NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_tenants_domain UNIQUE (domain)
);

CREATE TABLE branches (
    branch_id   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    name        NVARCHAR(255) NOT NULL,
    address     NVARCHAR(500),
    phone       VARCHAR(20),
    is_active   BIT NOT NULL DEFAULT 1,
    created_at  DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME NOT NULL DEFAULT GETDATE()
);

-- FIX: username/email phải duy nhất TRONG PHẠM VI TENANT, không phải toàn
-- hệ thống (bản gốc UNIQUE(username) toàn cục vi phạm nguyên tắc cô lập
-- đa khách thuê BR-05 và mâu thuẫn với chính report Chương 4 đã đặc tả).
CREATE TABLE users (
    user_id        UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id      UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    username       VARCHAR(100)  NOT NULL,
    email          VARCHAR(255)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,
    full_name      NVARCHAR(255),
    role           VARCHAR(50) NOT NULL CHECK (role IN ('Owner','Staff','Cashier')),
    is_active      BIT NOT NULL DEFAULT 1,
    created_at     DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_users_tenant_username UNIQUE (tenant_id, username),
    CONSTRAINT uq_users_tenant_email    UNIQUE (tenant_id, email)
);

CREATE TABLE partners (
    partner_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    type        VARCHAR(50) NOT NULL CHECK (type IN ('SUPPLIER','CUSTOMER')),
    name        NVARCHAR(255) NOT NULL,
    phone       VARCHAR(20),
    email       VARCHAR(255),
    address     NVARCHAR(500),
    created_at  DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME NOT NULL DEFAULT GETDATE()
);

-- MỚI: hình thức hóa khái niệm "Omnichannel" thành thực thể tra cứu, thay vì
-- một cột text tự do trên orders (lý do: cần FK toàn vẹn tham chiếu +
-- phục vụ trực tiếp FR-REP-01 "lọc báo cáo theo kênh").
CREATE TABLE sales_channels (
    channel_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    code        VARCHAR(30) NOT NULL,          -- 'POS','ADMIN_MANUAL','SHOPEE','TIKTOK','LAZADA'
    name        NVARCHAR(100) NOT NULL,
    type        VARCHAR(20) NOT NULL CHECK (type IN ('OFFLINE','ONLINE')),
    is_active   BIT NOT NULL DEFAULT 1,
    created_at  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_channels_tenant_code UNIQUE (tenant_id, code)
);

CREATE TABLE product_categories (
    category_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id    UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    parent_id    UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES product_categories(category_id),
    name         NVARCHAR(100) NOT NULL,
    description  NVARCHAR(500),
    created_at   DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at   DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_category_tenant_name UNIQUE (tenant_id, name)
);

CREATE TABLE brands (
    brand_id    UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    name        NVARCHAR(100) NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_brand_tenant_name UNIQUE (tenant_id, name)
);

-- =====================================================================
-- NHÓM 2: SẢN PHẨM / BIẾN THỂ
-- =====================================================================

-- FIX: bổ sung brand_id (bản gốc "brands" là bảng mồ côi - không có bảng
-- nào tham chiếu tới, dữ liệu thương hiệu không thể gắn vào sản phẩm).
CREATE TABLE products (
    product_id   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id    UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    category_id  UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES product_categories(category_id),
    brand_id     UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES brands(brand_id),
    name         NVARCHAR(255) NOT NULL,
    description  NVARCHAR(1000),
    base_price   DECIMAL(15,2) CHECK (base_price IS NULL OR base_price >= 0),
    created_at   DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at   DATETIME NOT NULL DEFAULT GETDATE()
);

-- FIX: (1) thêm tenant_id (bản gốc thiếu); (2) sku_code phải UNIQUE theo
-- TENANT (bản gốc UNIQUE toàn cục, vi phạm BR-03); (3) thêm UNIQUE
-- (product_id, color, size) để chặn tạo trùng 1 biến thể 2 lần.
CREATE TABLE sku_variants (
    sku_id      UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    product_id  UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES products(product_id),
    sku_code    VARCHAR(50) NOT NULL,
    color       NVARCHAR(50) NOT NULL DEFAULT N'',
    size        NVARCHAR(50) NOT NULL DEFAULT N'',
    price       DECIMAL(15,2) NOT NULL CHECK (price >= 0),
    created_at  DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_sku_tenant_code UNIQUE (tenant_id, sku_code),
    CONSTRAINT uq_sku_variant_combo UNIQUE (product_id, color, size)
);

-- FIX: thêm tenant_id (denormalized có chủ đích - xem LOGICAL_DESIGN.md
-- mục "Ngoại lệ chuẩn hóa có kiểm soát"). code vẫn UNIQUE toàn cục vì
-- barcode thật (EAN-13) là chuẩn toàn cầu, không lặp giữa các Tenant.
CREATE TABLE barcodes (
    barcode_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    sku_id      UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    code        VARCHAR(100) NOT NULL,
    type        VARCHAR(20) NOT NULL DEFAULT 'EAN13',
    created_at  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT uq_barcodes_code UNIQUE (code)
);

-- =====================================================================
-- NHÓM 3: TỒN KHO — STOCK_BALANCE (read model) + LEDGER (append-only)
-- =====================================================================

-- FIX QUAN TRỌNG NHẤT: bổ sung reserved, avg_cost (bản gốc chỉ có
-- "quantity" -> không thể tính available = on_hand - reserved, không có
-- chỗ lưu giá vốn bình quân -> phá vỡ FR-RSE và FR-COST, 2 yêu cầu "Rất
-- cao" của toàn đề tài). Đổi PK sang khóa tự nhiên (branch_id, sku_id)
-- thay vì surrogate + UNIQUE riêng, để làm mục tiêu khóa hàng trực tiếp
-- (WITH (UPDLOCK, ROWLOCK)) không cần qua cột phụ.
CREATE TABLE stock_balances (
    tenant_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id   UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    sku_id      UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    on_hand     NUMERIC(14,3) NOT NULL DEFAULT 0,
    reserved    NUMERIC(14,3) NOT NULL DEFAULT 0,
    avg_cost    NUMERIC(14,4) NOT NULL DEFAULT 0 CHECK (avg_cost >= 0),
    available   AS (on_hand - reserved) PERSISTED,   -- computed, phục vụ index cảnh báo tồn thấp
    updated_at  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_stock_balances PRIMARY KEY (branch_id, sku_id),
    CONSTRAINT chk_stock_available_non_negative CHECK (on_hand - reserved >= 0),
    CONSTRAINT chk_stock_reserved_non_negative CHECK (reserved >= 0),
    CONSTRAINT chk_stock_on_hand_non_negative CHECK (on_hand >= 0)
);

-- FIX: bổ sung tenant_id (bản gốc thiếu - đây là bảng Ledger, quan trọng
-- nhất để cô lập đa Tenant) và balance_after (phục vụ đối chiếu/audit
-- từng dòng mà không cần SUM() lại toàn bộ lịch sử).
CREATE TABLE inventory_transactions (
    transaction_id    UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id         UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id         UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    sku_id            UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    transaction_type  VARCHAR(3) NOT NULL CHECK (transaction_type IN ('IN','OUT')),
    quantity          NUMERIC(14,3) NOT NULL CHECK (quantity > 0),
    balance_after     NUMERIC(14,3) NOT NULL,
    reference_id      UNIQUEIDENTIFIER NULL,   -- trỏ tới OrderId/ReceiptId/TransferId/StocktakeId
    reference_type    VARCHAR(30) NULL CHECK (reference_type IS NULL OR reference_type IN
                        ('ORDER','PURCHASE_RECEIPT','STOCK_TRANSFER','STOCKTAKE_ADJUSTMENT')),
    created_at        DATETIME NOT NULL DEFAULT GETDATE()
    -- KHÔNG có updated_at / deleted_at: bảng append-only, xem ledger_constraints.sql
);

-- =====================================================================
-- NHÓM 4: KIỂM KHO (FR-INV-04) — bổ sung mới, bản gốc bị bỏ sót hoàn toàn
-- =====================================================================

CREATE TABLE stocktakes (
    stocktake_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id     UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id     UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    status        VARCHAR(20) NOT NULL DEFAULT 'InProgress'
                  CHECK (status IN ('InProgress','Completed')),
    created_at    DATETIME NOT NULL DEFAULT GETDATE(),
    completed_at  DATETIME NULL
);

-- Chan 2 phien kiem kho InProgress dong thoi tren cung 1 chi nhanh
-- (Filtered Unique Index - chi ap dung rang buoc cho dong co status='InProgress')
CREATE UNIQUE NONCLUSTERED INDEX uq_stocktake_one_active_per_branch
    ON stocktakes (branch_id)
    WHERE status = 'InProgress';

CREATE TABLE stocktake_items (
    stocktake_item_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id          UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    stocktake_id       UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES stocktakes(stocktake_id),
    sku_id             UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    counted_qty        NUMERIC(14,3) NOT NULL CHECK (counted_qty >= 0),
    system_qty         NUMERIC(14,3) NOT NULL,
    variance_qty       AS (counted_qty - system_qty) PERSISTED,  -- computed, không lưu trùng
    CONSTRAINT uq_stocktake_sku UNIQUE (stocktake_id, sku_id)
);

-- =====================================================================
-- NHÓM 5: ĐƠN HÀNG
-- =====================================================================

-- FIX: (1) thêm channel_id (bản gốc KHÔNG có cột nào lưu kênh bán - phá vỡ
-- FR-ORD-01/FR-REP-01); (2) status có CHECK đúng 5 trạng thái state machine
-- SRS (bản gốc free-text, default 'PENDING' không khớp enum nào cả);
-- (3) total_amount giữ lại làm cột cache (denormalized có chủ đích, xem
-- LOGICAL_DESIGN.md) để tránh JOIN + SUM() mỗi lần liệt kê đơn hàng.
CREATE TABLE orders (
    order_id      UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id     UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id     UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    channel_id    UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sales_channels(channel_id),
    partner_id    UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES partners(partner_id),
    user_id       UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES users(user_id),
    status        VARCHAR(20) NOT NULL DEFAULT 'Draft'
                  CHECK (status IN ('Draft','Reserved','Confirmed','Completed','Cancelled')),
    total_amount  DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    created_at    DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at    DATETIME NOT NULL DEFAULT GETDATE()
);

-- FIX: (1) thêm cost_price (bản gốc thiếu -> không snapshot được giá vốn,
-- vi phạm BR-04, không tính được lợi nhuận gộp); (2) thêm tenant_id;
-- (3) thêm UNIQUE(order_id, sku_id) (bản gốc thiếu -> 1 SKU có thể lặp
-- nhiều dòng trong cùng 1 đơn); (4) BỎ cột "subtotal" lưu cứng, thay bằng
-- computed column - vì subtotal = quantity * unit_price là dữ liệu dư
-- thừa 100% suy ra được, lưu riêng tạo nguy cơ sai lệch (update anomaly).
CREATE TABLE order_items (
    order_item_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id      UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    order_id       UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES orders(order_id),
    sku_id         UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity       NUMERIC(14,3) NOT NULL CHECK (quantity > 0),
    unit_price     DECIMAL(15,2) NOT NULL CHECK (unit_price >= 0),
    cost_price     DECIMAL(15,4) NOT NULL CHECK (cost_price >= 0),  -- snapshot bất biến, BR-04
    subtotal       AS (quantity * unit_price) PERSISTED,
    CONSTRAINT uq_order_items_order_sku UNIQUE (order_id, sku_id)
);

-- =====================================================================
-- NHÓM 6: NHẬP HÀNG
-- =====================================================================

CREATE TABLE purchase_receipts (
    receipt_id    UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id     UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    branch_id     UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    partner_id    UNIQUEIDENTIFIER NULL FOREIGN KEY REFERENCES partners(partner_id),
    status        VARCHAR(20) NOT NULL DEFAULT 'Draft'
                  CHECK (status IN ('Draft','Confirmed')),
    total_amount  DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    created_at    DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE purchase_receipt_items (
    receipt_item_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id        UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    receipt_id       UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES purchase_receipts(receipt_id),
    sku_id           UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity         NUMERIC(14,3) NOT NULL CHECK (quantity > 0),
    cost_price       DECIMAL(15,4) NOT NULL CHECK (cost_price >= 0),
    CONSTRAINT uq_receipt_items_receipt_sku UNIQUE (receipt_id, sku_id)
);

-- =====================================================================
-- NHÓM 7: CHUYỂN KHO
-- =====================================================================

CREATE TABLE stock_transfers (
    transfer_id     UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id       UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    from_branch_id  UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    to_branch_id    UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES branches(branch_id),
    status          VARCHAR(20) NOT NULL DEFAULT 'InTransit'
                    CHECK (status IN ('InTransit','Completed')),
    created_at      DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT chk_transfer_different_branch CHECK (from_branch_id <> to_branch_id)
);

CREATE TABLE stock_transfer_items (
    transfer_item_id  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tenant_id         UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES tenants(tenant_id),
    transfer_id       UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES stock_transfers(transfer_id),
    sku_id            UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES sku_variants(sku_id),
    quantity          NUMERIC(14,3) NOT NULL CHECK (quantity > 0),
    CONSTRAINT uq_transfer_items_transfer_sku UNIQUE (transfer_id, sku_id)
);

-- =====================================================================
-- INDEX THEO WORKLOAD (xem luận giải chi tiết trong PHYSICAL_DESIGN.md)
-- =====================================================================

-- Ledger: truy vấn báo cáo/lịch sử luôn lọc theo Tenant trước, sau đó
-- theo thời gian hoặc theo SKU -> 2 index composite bắt buộc (NFR-TENANT-02)
CREATE NONCLUSTERED INDEX idx_ledger_tenant_created ON inventory_transactions (tenant_id, created_at);
CREATE NONCLUSTERED INDEX idx_ledger_tenant_sku     ON inventory_transactions (tenant_id, sku_id);

-- Orders: liệt kê/lọc theo Tenant+thời gian (reporting), theo Tenant+trạng
-- thái (job tự hủy đơn Reserved quá hạn - FR-SIM-03), theo Tenant+kênh (FR-REP-01)
CREATE NONCLUSTERED INDEX idx_orders_tenant_created ON orders (tenant_id, created_at);
CREATE NONCLUSTERED INDEX idx_orders_tenant_status  ON orders (tenant_id, status) INCLUDE (created_at);
CREATE NONCLUSTERED INDEX idx_orders_tenant_channel ON orders (tenant_id, channel_id);

-- Stock balances: cảnh báo tồn thấp (FR-REP-03) lọc theo Tenant + available
CREATE NONCLUSTERED INDEX idx_stock_tenant_available ON stock_balances (tenant_id, available);

-- Order items / Purchase receipt items: join ngược theo SKU cho báo cáo bán chạy
CREATE NONCLUSTERED INDEX idx_order_items_tenant_sku ON order_items (tenant_id, sku_id);

-- Users: tra cứu đăng nhập theo Tenant + email
CREATE NONCLUSTERED INDEX idx_users_tenant_email ON users (tenant_id, email);
