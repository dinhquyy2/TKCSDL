### MA TRẬN TRUY VẾT YÊU CẦU (RTM)

## 1. Mục đích

Ma trận truy vết yêu cầu được sử dụng để liên kết các yêu cầu của hệ thống
với nội dung được mô tả trong tài liệu đặc tả yêu cầu.

RTM giúp đảm bảo các yêu cầu chính trong đề bài đều được ghi nhận và có
thể truy vết đến phần tương ứng trong tài liệu.

## 2. Ma trận truy vết yêu cầu chức năng

| Mã yêu cầu | Nhóm yêu cầu | Nội dung yêu cầu | Vị trí trong tài liệu |
|---|---|---|---|
| FR-AUTH | Quản lý người dùng và phân quyền | Đăng ký tenant, xác thực người dùng, phân quyền Owner/Staff/Cashier và quản lý chi nhánh | Mục 4.1 |
| FR-PROD | Quản lý sản phẩm | Quản lý sản phẩm, biến thể, SKU, danh mục, thương hiệu, mã vạch và giá bán | Mục 4.2 |
| FR-INV | Quản lý tồn kho | Ghi nhận biến động tồn kho, nhập hàng, điều chuyển và kiểm kê | Mục 4.3 |
| FR-COST | Tính giá vốn | Tính giá vốn theo Weighted Average Cost và lưu giá vốn khi đơn hàng hoàn thành | Mục 4.4 |
| FR-ORD | Quản lý đơn hàng đa kênh | Tiếp nhận và xử lý đơn hàng từ POS và các kênh bán hàng trực tuyến | Mục 4.5 |
| FR-RSE | Chống bán vượt tồn kho | Kiểm tra Available, giữ hàng, giải phóng hàng giữ và trừ tồn kho | Mục 4.6 |
| FR-POS | Bán hàng tại POS | Bán hàng nhanh, kiểm tra tồn kho, thanh toán tiền mặt/QR và cập nhật tồn kho | Mục 4.7 |
| FR-REP | Báo cáo và cảnh báo | Báo cáo bán hàng, báo cáo tồn kho và cảnh báo tồn kho thấp | Mục 4.8 |

## 3. Ma trận truy vết yêu cầu phi chức năng

| Mã yêu cầu | Nhóm yêu cầu | Nội dung yêu cầu | Vị trí trong tài liệu |
|---|---|---|---|
| NFR-PERF | Hiệu năng và xử lý đồng thời | Hệ thống phải hỗ trợ nhiều người dùng và giao dịch đồng thời, đảm bảo chính xác khi cập nhật tồn kho | Mục 5.1 |
| NFR-SEC | Bảo mật và phân quyền | Xác thực người dùng, phân quyền theo vai trò và bảo vệ dữ liệu giữa các tenant | Mục 5.2 |
| NFR-DATA | Toàn vẹn dữ liệu | Đảm bảo ACID, ghi nhận biến động tồn kho và khả năng truy vết Inventory Ledger | Mục 5.3 |
| NFR-AVAIL | Khả năng sử dụng và sẵn sàng | Giao diện dễ sử dụng, hệ thống hoạt động ổn định và POS hỗ trợ thao tác nhanh | Mục 5.4 |
| NFR-MAINT | Bảo trì và kiểm thử | Thiết kế theo Clean Architecture, có khả năng bảo trì, mở rộng và kiểm thử | Mục 5.5 |

## 4. Truy vết yêu cầu đến quy trình nghiệp vụ

| Mã yêu cầu | Quy trình liên quan | Vị trí |
|---|---|---|
| FR-POS | Quy trình bán hàng tại POS | Mục 7.1 |
| FR-ORD | Quy trình xử lý đơn hàng đa kênh | Mục 7.2 |
| FR-INV | Quy trình nhập hàng | Mục 7.3 |
| FR-INV | Quy trình điều chuyển kho | Mục 7.4 |
| FR-RSE | Quy trình bán hàng và xử lý đơn hàng | Mục 7.1, 7.2 |
| FR-COST | Ghi nhận giá vốn khi hoàn thành đơn hàng | Mục 7.1, 7.2 |

## 5. Kết luận

RTM cho phép kiểm tra mối liên hệ giữa các yêu cầu trong đề bài với
các nội dung tương ứng trong tài liệu đặc tả yêu cầu.

Các nhóm yêu cầu chức năng và phi chức năng chính đều được truy vết
đến các mục tương ứng trong tài liệu.