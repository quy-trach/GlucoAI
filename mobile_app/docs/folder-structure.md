Cấu trúc thư mục (chi tiết) — Mobile App (GlucoAI)

Mục đích tài liệu: mô tả cấu trúc `lib/` hiện tại, vai trò từng thư mục, gợi ý mở rộng theo phong cách feature-first, và hướng dẫn tạo file Word (.docx) từ tài liệu này.

1. Tổng quan (top-level)
- lib/
  - main.dart
  - navigation/
  - features/
  - core/ (khuyến nghị)
  - shared/ (khuyến nghị)
  - services/ (khuyến nghị)
  - l10n/ (nếu localization)

2. Giải thích từng thư mục
- `lib/main.dart`
  - Entry point của app. Khởi tạo `MaterialApp`, theme, navigator, providers/blocs global.

- `lib/navigation/`
  - Nơi đặt router và widget điều hướng chung (ví dụ `BottomNav`, `AppRouter`).
  - Hiện có: `bottom_nav.dart` (đã cập nhật để dùng `features/...`).

- `lib/features/` (feature-first)
  - Mục đích: gom toàn bộ code liên quan từng tính năng vào một chỗ để dễ mở rộng, test và phân chia công việc.
  - Mẫu cấu trúc cho mỗi feature (ví dụ `home`, `account`, `splash`):
    - features/<feature>/
      - presentation/
        - pages/            -> màn hình (screen/page) (ví dụ: `home_page.dart`)
        - widgets/          -> các UI component chỉ dùng trong feature này (ví dụ: `home_header.dart`)
        - presentation.dart -> (tuỳ chọn) re-export
      - application/        -> providers / bloc / controllers (state management)
      - domain/             -> entities/models, usecases, business rules
      - data/               -> repositories, datasources (API, local DB)
  - Lợi ích: mỗi feature đóng gói mọi thứ cần thiết, dễ tách module, dễ migrate hoặc viết test độc lập.

- `lib/core/` (khuyến nghị)
  - Đặt constants, theme, kiểu lỗi/chung, helper chung, enums.
  - Ví dụ: `core/theme.dart`, `core/constants.dart`, `core/utils.dart`.

- `lib/shared/` (khuyến nghị)
  - Các widget tái sử dụng giữa nhiều feature (Buttons, FormField, Cards), extensions, mixins.
  - Giúp tránh duplicate và duy trì style thống nhất.

- `lib/services/` (khuyến nghị)
  - Các service dùng chung: `api_client.dart`, `local_storage.dart`, `auth_service.dart`.

- `lib/l10n/` (nếu có)
  - File localization (.arb) và cấu hình intl.

3. Lý do chọn feature-first (tóm tắt)
- Phù hợp app trung/ lớn và nhóm nhiều dev.
- Tốt cho test, maintain, refactor, và tách deployment/module.
- Cho phép gói từng feature khi cần (module, package).

4. Ví dụ cây thư mục (mẫu hoàn chỉnh)

lib/
├─ main.dart
├─ navigation/
│  └─ bottom_nav.dart
├─ core/
│  ├─ theme.dart
│  └─ constants.dart
├─ shared/
│  └─ widgets/
│     ├─ primary_button.dart
│     └─ card_item.dart
├─ services/
│  └─ api_client.dart
├─ features/
│  ├─ splash/
│  │  └─ presentation/
│  │     └─ pages/splash_page.dart
│  ├─ home/
│  │  ├─ presentation/
│  │  │  ├─ pages/home_page.dart
│  │  │  └─ widgets/home_header.dart
│  │  ├─ application/
│  │  │  └─ home_controller.dart
│  │  ├─ domain/
│  │  │  └─ models/
│  │  └─ data/
│  │     └─ home_repository.dart
│  └─ account/
│     └─ presentation/pages/account_page.dart
└─ l10n/

5. Gợi ý thực tế khi implement
- Giữ tên file và class nhất quán: file `home_page.dart` -> class `HomePage`.
- Nếu component dùng chung nhiều feature -> chuyển vào `shared/widgets`.
- Dùng `presentation.dart` để re-export nếu bạn muốn import ngắn.
- Tách logic khỏi UI: controllers/bloc trong `application/`, api/db trong `data/`.

6. Hướng dẫn tạo Word (.docx) từ file này
- Cách nhanh (nếu có `pandoc` cài sẵn):

  Mở terminal ở thư mục `mobile_app` và chạy:

  ```bash
  pandoc docs/folder-structure.md -o docs/folder-structure.docx
  ```

- Nếu không có `pandoc`: mở file `docs/folder-structure.md` bằng Microsoft Word (Word có thể mở markdown hoặc bạn có thể copy-paste nội dung vào Word) rồi Save As -> Word Document (.docx).

7. Muốn mình làm tiếp gì?
- Mình có thể:
  - tạo `lib/core/theme.dart` và `lib/shared/widgets/primary_button.dart` mẫu; hoặc
  - thử convert sang `.docx` ở đây (chỉ nếu bạn cho phép mình chạy `pandoc` và pandoc có sẵn trên máy), hoặc
  - xuất file .docx dưới dạng bản text (không khuyến nghị).

---

Tôi đã tạo file này tại: `docs/folder-structure.md`
