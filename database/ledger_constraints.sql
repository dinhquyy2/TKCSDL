-- OISM - Rang buoc Append-only cho So cai Ton kho (inventory_transactions)
-- Ky thuat: INSTEAD OF TRIGGER (SQL Server khong ho tro BEFORE TRIGGER)
-- Dung CREATE OR ALTER de co the chay lai file nhieu lan ma khong loi
-- "trigger already exists" (Msg 2111)

CREATE OR ALTER TRIGGER trg_Prevent_Update_Delete_Inventory
ON inventory_transactions
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    RAISERROR (
      N'Loi bao mat: Khong duoc phep UPDATE hoac DELETE tren so cai kho (inventory_transactions). Moi sai sot phai duoc xu ly bang phieu dieu chinh (ADJUSTMENT).',
      16, 1);
    ROLLBACK TRANSACTION;
END;
