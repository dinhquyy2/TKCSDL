CREATE TRIGGER trg_Prevent_Update_Delete_Inventory
ON inventory_transactions
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    RAISERROR ('Lỗi bảo mật: Không được phép UPDATE hoặc DELETE trên sổ cái kho (inventory_transactions). Mọi sai sót phải được xử lý bằng phiếu điều chỉnh (ADJUSTMENT).', 16, 1);
    ROLLBACK TRANSACTION;
END;
