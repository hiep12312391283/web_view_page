# Thư viện WebView (Trang Hỗ Trợ)

Đây là một thư viện Flutter Package nội bộ chứa sẵn widget `WebViewPage`. Nó được thiết kế để nhúng một trang web (thường là trang Customer Support, FAQ, CSKH) vào bên trong ứng dụng Flutter một cách tiện lợi, sử dụng bộ nhân `flutter_inappwebview`.

## Thư viện này làm nhiệm vụ gì?

Thay vì phải code lại WebView ở từng dự án ứng dụng khác nhau, thư viện này đóng gói sẵn mọi thứ cần thiết:

**Các tính năng nổi bật:**
- Đã được cấu hình tối ưu sẵn các thông số cho `InAppWebView` (Hardware acceleration, cho phép phát video inline, tự nhận quyền truy cập, v.v).
- **Truyền dữ liệu tự động:** Tự động encode thông tin ngữ cảnh của ứng dụng (`version`, `currentRoute`, `appId`) thành chuỗi JSON và gắn vào tham số URL (`?appData=...`) để bên Web có thể bắt được.
- **Xử lý UX/UI:** Tự động xoá Cache & Cookie mỗi khi mở để cập nhật dữ liệu mới nhất. Hiển thị sẵn màn hình Loading xoay `CircularProgressIndicator` siêu mượt trong thời gian chờ Web render.
- **Giao tiếp với Web (JS Bridge):** Mở sẵn một kênh Javascript tên là `closeWebView`. Khi trang Web gọi lệnh sự kiện này, app Flutter sẽ hứng nó và lập tức gọi lệnh tắt màn hình (`Navigator.pop`).

---

## Cách cài đặt đưa thư viện này vào dự án App khác

Vì đây là một package độc lập, bạn mở file cấu hình `pubspec.yaml` của cái App mà bạn muốn dùng thư viện lên, sau đó khai báo nó ở mục `dependencies`.

### Kéo từ Git
Nếu bạn đã đẩy code thư viện này lên kho chứa trung tâm như Gitlab/Github cho cả team xài chung, hãy chèn link tải như sau:

```yaml
dependencies:
  web_view_feedback_sds:
    git:
      url: https://github.com/hiep12312391283/web_view_feedback_sds.git
      ref: main # (Hoặc branch / tag mà bạn mong muốn)
```

*(Lưu ý: Sau khi khai báo xong, nhớ chạy lệnh `flutter pub get` ở dự án App mới để nó tải thư viện về).*

---

## Cách sử dụng

Khi đã cài ở App mới rồi, bạn chỉ việc import và gọi hàm chuyển trang như bình thường bằng thao tác `Navigator.push`.

```dart
// 1. Nhúng package vào đầu file code
import 'package:web_view_page/web_view_page.dart';
import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Mở trang Hỗ trợ CSKH'),
          onPressed: () {
            
            // 2. Chuyển hướng lên trên cùng của Navigation Stack
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WebViewPage(
                  version: '1.0.0',     // version thực tế của App chính
                  route: '/home',       // màn hình user đang đứng 
                  appId: 'my_app_123',  // Định danh app
                ),
              ),
            );
            
          },
        ),
      ),
    );
  }
}
```

---

## Danh sách App & giá trị `appId` cần truyền

Tham số `appId` xác định **ứng dụng nào** đang mở WebView. Phía Web sẽ dùng giá trị này để gửi phản hồi đến đúng nhóm Telegram tương ứng.

> Truyền sai `appId` → phản hồi sẽ đi vào sai nhóm hoặc sai chủ đề.

| Ứng dụng | `appId` cần truyền |
|---|---|
| **vBHXH** | `'1'` |
| **easyInvoice** | `'2'` |

### Ví dụ truyền đúng `appId`

```dart
// Dùng cho app vBHXH
WebViewPage(
  version: '1.0.0',
  route: '/home',
  appId: '1',   // ← vBHXH
)

// Dùng cho app easyInvoice
WebViewPage(
  version: '2.3.0',
  route: '/dashboard',
  appId: '2',   // ← easyInvoice
)
```

---

### App ví dụ (Tích hợp sẵn)
Trong thư mục chứa source library này có sẵn dự án `/example`. Đây là app nguyên bản bạn có thể nhảy vào (`cd example`) rồi chạy lệnh `flutter run` để tự mình bật lên test thử tính năng thay vì phải cài vào một app khác.
