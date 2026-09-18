-- OISM - Rang buoc Append-only cho So cai Ton kho (inventory_transactions)
-- Ky thuat: INSTEAD OF TRIGGER (SQL Server khong ho tro BEFORE TRIGGER)
-- Xem giai trinh: PHYSICAL_DESIGN.md muc 5

CREATE TRIGGER trg_Prevent_Update_Delete_Inventory
ON inventory_transactions
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- dam bao ROLLBACK huy toan bo batch mot cach nhat quan

    RAISERROR (
      N'Loi bao mat: Khong duoc phep UPDATE hoac DELETE tren so cai kho (inventory_transactions). Moi sai sot phai duoc xu ly bang phieu dieu chinh (ADJUSTMENT).',
      16, 1);
    ROLLBACK TRANSACTION;
END;
