# Báo cáo Đồ án OISM (LaTeX)

Báo cáo tốt nghiệp cho Hệ thống quản lý bán hàng và tồn kho đa kênh (OISM),
dựng lại từ template báo cáo gốc, phạm vi nội dung: **Thiết kế hệ thống +
Cơ sở dữ liệu** (không bao gồm code Backend/Frontend — xem Chương 1, mục 1.6).
**Cơ sở dữ liệu (Chương 4) là trọng tâm của báo cáo** — bao gồm phân tích
chuẩn hóa (1NF/2NF/3NF), script DDL thật, cơ chế append-only, kiểm soát
concurrency (locking), chỉ mục tối ưu, và các script kiểm thử SQL thật.

File `main.pdf` đính kèm là bản build sẵn (55 trang) để xem nhanh không cần
cài LaTeX.

**Gói thêm cần cài so với bản trước:** `\usepackage{listings}` và
`\usepackage{xcolor}` (để hiển thị code SQL có tô màu cú pháp trong Chương 4)
— cả hai đều là gói TeX Live chuẩn, không cần cài thêm gì ngoài
`texlive-lang-other`/`texlive-lang-european` như hướng dẫn bên dưới.

## Build lại từ source (yêu cầu `xelatex`)

```bash
cd report
xelatex -interaction=nonstopmode -file-line-error main.tex
xelatex -interaction=nonstopmode -file-line-error main.tex   # chạy lần 2 để mục lục/tham chiếu đúng
```

Hoặc dùng `latexmk`:
```bash
latexmk -xelatex report/main.tex
```

**Lưu ý về font tiếng Việt:** file dùng `babel` với `main=vietnamese`. Nếu máy
báo lỗi thiếu `vietnamese.ldf`, cài thêm gói ngôn ngữ:
- Ubuntu/Debian: `sudo apt-get install texlive-lang-other texlive-lang-european`
- Overleaf: đã có sẵn, không cần cài thêm.

File cũng ưu tiên dùng font Times New Roman/Arial nếu máy có cài (Windows,
Overleaf); nếu không có, tự động dùng Liberation Serif/Sans (Linux) — không
cần chỉnh sửa gì thêm.

## Quy ước file

- `main.tex`: entry file (chứa preamble, đã định nghĩa khung `imgnote` để
  đánh dấu vị trí cần chèn hình).
- `chapters/`: mỗi chương một file wrapper (`chapter1.tex`...`chapter5.tex`),
  mỗi chương chia nhỏ thành các file con trong `chapters/chN/`.
- `images/`: nơi đặt các file hình thật khi thay thế placeholder.
- `bib/references.bib`: để trống, bổ sung tài liệu tham khảo nếu cần trích dẫn.

## Danh sách hình cần bổ sung (📌 đã đánh dấu ngay trong từng chương)

| Hình | Tên file đề xuất | Vị trí |
|---|---|---|
| Hình 1 | `Hinh_01_KienTrucTongThe.png` | Chương 3, mục 3.2 |
| Hình 2 | `Hinh_02_UseCaseDiagram.png` | Chương 3, mục 3.3.2 |
| Hình 3 | `Hinh_03_ERD_OISM.png` | Chương 3, mục 3.3.3 |
| Hình 4 | `Hinh_04_ClassDiagram_OISM.png` | Chương 3, mục 3.3.3 |
| Hình 5 | `Hinh_05_Sequence_StockReservation.png` | Chương 3, mục FR-RSE |
| Hình 6 | `Hinh_06_Sequence_FastCheckout.png` | Chương 3, mục FR-POS |
| Hình 7 | `Hinh_07_Sequence_PurchaseReceipt.png` | Chương 3, mục FR-INV |
| Hình 8 | `Hinh_08_Sequence_StockTransfer.png` | Chương 3, mục FR-INV |
| Hình 9 | `Hinh_09_Sequence_Stocktake.png` | Chương 3, mục FR-INV |
| Hình 10 | `Hinh_10_StateDiagram_OrderLifecycle.png` | Chương 3, mục FR-ORD |

Khi có file hình thật, đặt vào `images/` (hoặc `chapters/ch3/`) rồi thay khối
`\fbox{\parbox{...}{...[Chèn hình tại đây]...}}` bằng:
```latex
\includegraphics[width=0.9\textwidth]{images/Hinh_03_ERD_OISM.png}
```
và xoá khối `\begin{imgnote}...\end{imgnote}` tương ứng.

## Việc còn cần điền tay trước khi nộp

- Bảng thành viên nhóm (Chương 1, mục 1.1.2): tên thật, email, MSSV.
- Số liệu kết quả kiểm thử (Chương 4, mục 4.3 và Chương 5, mục 5.2): điền sau
  khi chạy thật script DDL/seed data/integrity check trên máy.
