\# HƯỚNG DẪN CÀI ĐẶT DATABASE



\## 1. Yêu cầu



\* SQL Server 2019 trở lên.

\* SQL Server Management Studio (SSMS).

\* Có quyền tạo Database và chạy SQL Script.



\## 2. Tạo Database



Mở SQL Server Management Studio và chạy:



```sql

CREATE DATABASE TKCSDL;

GO



USE TKCSDL;

GO

```



\## 3. Chạy Schema



Mở file `database/schema.sql`.



Chọn Database `TKCSDL` và nhấn \*\*Execute\*\* để tạo các bảng.



\## 4. Chạy dữ liệu mẫu



Lần lượt mở và chạy:



1\. `database/data.sql`

2\. `database/seed\_data.sql`



Chọn Database `TKCSDL` trước khi nhấn \*\*Execute\*\*.



\## 5. Kiểm tra dữ liệu



Mở file `database/integrity\_check.sql`.



Chọn Database `TKCSDL` và nhấn \*\*Execute\*\*.



File này kiểm tra:



\* Số lượng dữ liệu trong các bảng.



