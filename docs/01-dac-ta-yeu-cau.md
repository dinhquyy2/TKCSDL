### TÀI LIỆU ĐẶC TẢ YÊU CẦU

## 1. Giới thiệu

# 1.1. Tên hệ thống

Hệ thống quản lý bán hàng và tồn kho đa kênh

# 1.2. Mục đích

Hệ thống được xây dựng nhằm quản lý hoạt động bán hàng và tồn kho
trên nhiều kênh, bao gồm cửa hàng/POS và các kênh thương mại điện tử.

Hệ thống hỗ trợ quản lý sản phẩm, tồn kho, đơn hàng, tính giá vốn
và hạn chế tình trạng bán vượt số lượng tồn kho.

## 2. Phạm vi hệ thống

Hệ thống tập trung vào việc quản lý bán hàng và tồn kho trên nhiều kênh.

# 2.1 Các chức năng trong phạm vi

- Quản lý người dùng và phân quyền.
- Quản lý sản phẩm, biến thể và SKU.
- Quản lý tồn kho.
- Quản lý nhập hàng và điều chuyển kho.
- Quản lý đơn hàng từ nhiều kênh bán hàng.
- Quản lý đặt giữ và trừ tồn kho.
- Tính giá vốn hàng bán.
- Hỗ trợ bán hàng tại cửa hàng thông qua POS.
- Cung cấp báo cáo và cảnh báo tồn kho.

# 2.2 Các kênh bán hàng

Hệ thống hỗ trợ các kênh bán hàng gồm:

- Cửa hàng/POS.
- Shopee.
- TikTok Shop.
- Lazada.
- Website hoặc các kênh thương mại điện tử khác.

## 3. Người sử dụng hệ thống

Hệ thống có các nhóm người sử dụng chính sau:

# 3.1. Owner

- Quản lý thông tin và hoạt động của cửa hàng/doanh nghiệp.
- Quản lý người dùng và phân quyền.
- Quản lý chi nhánh.
- Theo dõi tình hình bán hàng và tồn kho.

# 3.2. Staff

- Thực hiện các nghiệp vụ được phân quyền.
- Quản lý sản phẩm và tồn kho.
- Xử lý các nghiệp vụ nhập hàng, điều chuyển và kiểm kê.

# 3.3. Cashier

- Thực hiện bán hàng tại quầy POS.
- Kiểm tra tồn kho khi bán hàng.
- Thực hiện thanh toán cho đơn hàng.

## 4. Yêu cầu chức năng

# 4.1. Quản lý người dùng và phân quyền

- Hệ thống cho phép đăng ký và quản lý thông tin doanh nghiệp/tenant.
- Hệ thống hỗ trợ đăng nhập và xác thực người dùng.
- Hệ thống phân quyền theo vai trò Owner, Staff và Cashier.
- Owner có quyền quản lý người dùng và chi nhánh.

# 4.2. Quản lý sản phẩm

- Hệ thống cho phép quản lý sản phẩm và biến thể sản phẩm.
- Mỗi sản phẩm/biến thể có mã SKU duy nhất.
- Hệ thống hỗ trợ quản lý danh mục, thương hiệu và mã vạch.
- Hệ thống cho phép quản lý giá bán của sản phẩm.

# 4.3. Quản lý tồn kho

- Hệ thống ghi nhận các biến động tồn kho.
- Hệ thống hỗ trợ nhập hàng.
- Hệ thống hỗ trợ điều chuyển hàng giữa các kho/chi nhánh.
- Hệ thống hỗ trợ kiểm kê tồn kho.
- Hệ thống cho phép theo dõi số lượng tồn kho.

### 4.4. Tính giá vốn

- Hệ thống tính giá vốn hàng tồn kho theo phương pháp Weighted Average Cost.
- Hệ thống lưu lại giá vốn tại thời điểm đơn hàng hoàn thành để phục vụ tính COGS.

### 4.5. Quản lý đơn hàng đa kênh

- Hệ thống tiếp nhận đơn hàng từ POS và các kênh bán hàng trực tuyến.
- Hệ thống hỗ trợ các kênh như Shopee và TikTok Shop.
- Đơn hàng được quản lý theo trạng thái.
- Trạng thái đơn hàng gồm Draft, Reserved, Confirmed, Completed và Cancelled.

### 4.6. Chống bán vượt tồn kho

- Hệ thống kiểm tra số lượng hàng có thể bán trước khi xác nhận đơn hàng.
- Số lượng có thể bán được xác định theo công thức:
  Available = On-hand - Reserved
- Hệ thống hỗ trợ giữ hàng, giải phóng hàng giữ và trừ tồn kho.

### 4.7. Bán hàng tại POS

- Hệ thống hỗ trợ bán hàng nhanh tại quầy.
- Hệ thống kiểm tra tồn kho khi thanh toán.
- Hệ thống hỗ trợ thanh toán bằng tiền mặt và QR.
- Việc thanh toán và cập nhật tồn kho được thực hiện theo giao dịch nguyên tử.

# 4.8. Báo cáo và cảnh báo

- Hệ thống cung cấp báo cáo bán hàng.
- Hệ thống cung cấp báo cáo tồn kho.
- Hệ thống hỗ trợ cảnh báo tồn kho thấp.

## 5. Yêu cầu phi chức năng

# 5.1. Hiệu năng và khả năng xử lý đồng thời

- Hệ thống phải đáp ứng được nhiều người dùng và nhiều giao dịch cùng lúc.
- Hệ thống cần đảm bảo tính chính xác khi nhiều giao dịch cùng cập nhật tồn kho.
- Hệ thống sử dụng cơ chế locking phù hợp để hạn chế xung đột dữ liệu.

# 5.2. Bảo mật và phân quyền

- Người dùng phải được xác thực trước khi sử dụng hệ thống.
- Hệ thống phải áp dụng phân quyền theo vai trò.
- Dữ liệu giữa các tenant phải được cô lập.
- Người dùng chỉ được truy cập dữ liệu theo quyền được cấp.

# 5.3. Tính toàn vẹn dữ liệu

- Các giao dịch quan trọng phải đảm bảo tính ACID.
- Dữ liệu biến động tồn kho phải được ghi nhận đầy đủ.
- Inventory Ledger phải đảm bảo tính nhất quán và có thể truy vết.

# 5.4. Khả năng sử dụng và sẵn sàng

- Giao diện phải dễ sử dụng đối với nhân viên bán hàng và quản lý.
- Hệ thống cần đảm bảo khả năng hoạt động ổn định.
- POS cần hỗ trợ thao tác bán hàng nhanh.

# 5.5. Khả năng bảo trì và kiểm thử

- Hệ thống được thiết kế theo kiến trúc Clean Architecture.
- Các thành phần của hệ thống cần có khả năng bảo trì và mở rộng.
- Hệ thống cần được kiểm thử để đảm bảo chất lượng phần mềm.

## 6. Quy tắc nghiệp vụ

# 6.1. Quy tắc về người dùng và phân quyền

- Người dùng phải đăng nhập và được xác thực trước khi sử dụng hệ thống.
- Quyền truy cập của người dùng được xác định theo vai trò Owner, Staff hoặc Cashier.
- Người dùng chỉ được thực hiện các chức năng phù hợp với quyền được cấp.

# 6.2. Quy tắc về sản phẩm

- Mỗi SKU phải là duy nhất trong phạm vi hệ thống.
- Sản phẩm có thể là sản phẩm đơn giản hoặc sản phẩm có nhiều biến thể.
- Mỗi biến thể sản phẩm được quản lý bằng SKU riêng.

# 6.3. Quy tắc về tồn kho

- Mọi biến động tồn kho phải được ghi nhận vào Inventory Ledger.
- Số lượng tồn kho phải được cập nhật dựa trên các nghiệp vụ nhập, xuất, điều chuyển và kiểm kê.
- Không được để số lượng tồn kho bị âm do giao dịch bán hàng thông thường.

# 6.4. Quy tắc chống bán vượt tồn kho

- Số lượng có thể bán được xác định theo công thức:

  `Available = On-hand - Reserved`

- Khi đơn hàng được giữ hàng, số lượng Reserved được tăng tương ứng.
- Khi đơn hàng bị hủy hoặc giải phóng, số lượng Reserved được giảm.
- Khi đơn hàng hoàn thành, số lượng tồn kho được trừ tương ứng.

# 6.5. Quy tắc tính giá vốn

- Giá vốn được tính theo phương pháp Weighted Average Cost.
- Giá vốn của đơn hàng được lưu tại thời điểm đơn hàng hoàn thành để phục vụ tính COGS.

# 6.6. Quy tắc trạng thái đơn hàng

Đơn hàng được xử lý theo chuỗi trạng thái:

`Draft → Reserved → Confirmed → Completed`

Đơn hàng có thể chuyển sang trạng thái:

`Cancelled`

khi đơn hàng bị hủy theo nghiệp vụ của hệ thống.

## 7. Quy trình nghiệp vụ chính

# 7.1. Quy trình bán hàng tại POS

1. Nhân viên chọn sản phẩm và số lượng cần bán.
2. Hệ thống kiểm tra số lượng tồn kho có thể bán.
3. Hệ thống giữ số lượng hàng cho đơn hàng.
4. Nhân viên thực hiện thanh toán bằng tiền mặt hoặc QR.
5. Hệ thống xác nhận đơn hàng.
6. Hệ thống cập nhật tồn kho và ghi nhận giá vốn.
7. Đơn hàng chuyển sang trạng thái Completed.

# 7.2. Quy trình xử lý đơn hàng đa kênh

1. Hệ thống tiếp nhận đơn hàng từ POS hoặc kênh bán hàng trực tuyến.
2. Hệ thống tạo đơn hàng và xác định trạng thái ban đầu.
3. Hệ thống kiểm tra tồn kho.
4. Hệ thống giữ hàng cho đơn hàng.
5. Đơn hàng được xác nhận và xử lý.
6. Khi hoàn tất, hệ thống trừ tồn kho và ghi nhận giá vốn.

# 7.3. Quy trình nhập hàng

1. Người dùng tạo nghiệp vụ nhập hàng.
2. Hệ thống ghi nhận sản phẩm và số lượng nhập.
3. Hệ thống cập nhật tồn kho.
4. Hệ thống cập nhật thông tin phục vụ tính giá vốn.
5. Biến động được ghi nhận vào Inventory Ledger.

# 7.4. Quy trình điều chuyển kho

1. Người dùng tạo yêu cầu điều chuyển hàng.
2. Chọn kho/chi nhánh nguồn và kho/chi nhánh đích.
3. Chọn sản phẩm và số lượng cần điều chuyển.
4. Hệ thống kiểm tra tồn kho tại kho nguồn.
5. Hệ thống thực hiện điều chuyển.
6. Tồn kho tại kho nguồn giảm và tồn kho tại kho đích tăng.
7. Biến động được ghi nhận vào Inventory Ledger.

## 8. Yêu cầu dữ liệu

# 8.1. Dữ liệu người dùng

Hệ thống cần quản lý các thông tin liên quan đến người dùng và phân quyền, bao gồm:

- Thông tin tài khoản người dùng.
- Vai trò của người dùng.
- Thông tin tenant/doanh nghiệp.
- Thông tin chi nhánh.

# 8.2. Dữ liệu sản phẩm

Hệ thống cần quản lý:

- Sản phẩm.
- Biến thể sản phẩm.
- SKU.
- Mã vạch.
- Danh mục.
- Thương hiệu.
- Giá bán.

# 8.3. Dữ liệu tồn kho

Hệ thống cần quản lý:

- Kho và chi nhánh.
- Số lượng tồn kho.
- Số lượng hàng đang được giữ.
- Các biến động nhập, xuất và điều chuyển.
- Lịch sử biến động trong Inventory Ledger.

# 8.4. Dữ liệu đơn hàng

Hệ thống cần lưu trữ:

- Thông tin đơn hàng.
- Kênh bán hàng.
- Sản phẩm và số lượng trong đơn.
- Trạng thái đơn hàng.
- Thông tin thanh toán.
- Giá vốn tại thời điểm hoàn thành đơn hàng.

### 8.5. Yêu cầu toàn vẹn dữ liệu

- SKU phải duy nhất.
- Dữ liệu giữa các tenant phải được cô lập.
- Các giao dịch cập nhật tồn kho phải đảm bảo tính nhất quán.
- Các biến động tồn kho cần có khả năng truy vết.

## 9. Tiêu chí hoàn thành

Tài liệu đặc tả yêu cầu được xem là hoàn thành khi:

- Xác định rõ mục đích và phạm vi của hệ thống.
- Xác định được các nhóm người sử dụng và vai trò của họ.
- Mô tả đầy đủ các yêu cầu chức năng chính của hệ thống.
- Mô tả các yêu cầu phi chức năng liên quan đến hiệu năng, bảo mật, toàn vẹn dữ liệu và khả năng bảo trì.
- Xác định các quy tắc nghiệp vụ chính.
- Mô tả được các quy trình nghiệp vụ chính.
- Xác định được các nhóm dữ liệu cần quản lý.
- Các yêu cầu trong tài liệu phù hợp với phạm vi và yêu cầu của đề bài.

## 10. Tài liệu tham khảo

1. Tài liệu đặc tả dự án "Omnichannel Inventory and Sales Management System" do giảng viên cung cấp.
2. IBM. Database normalization.
3. PostgreSQL Documentation. Constraints.
4. PostgreSQL Documentation. Data Definition.