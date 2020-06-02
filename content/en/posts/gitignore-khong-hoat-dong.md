---
title: "Hình như Git ignore không hoạt động ?"
description: "Mình đã gặp trường hợp là rõ ràng đã thêm một vài file vào .gitignore rồi nhưng thi thoảng vẫn thấy sự thay đổi của nó hiện lên git status. Vậy nguyên nhân là gì? Có phải git bị lỗi không?"
date: 2020-04-25T23:41:24+07:00
draft: false

author: tbm98
tags:
- git
---

## Vấn đề
Mình đã gặp trường hợp là rõ ràng đã thêm một vài file vào .gitignore rồi nhưng thi thoảng vẫn thấy sự thay đổi của nó hiện lên git status. Vậy nguyên nhân là gì? Có phải git bị lỗi không?

Ví dụ trong project hiện tại mình đang code, bây giờ mình không muốn up file `main.dart` lên mỗi khi thay đổi nó nữa. Như ở đây là file `main.dart` đang có sự thay đổi và nó được liệt kê ở mục `Unstaged Changes`.
![hihi](/images/gitignore-khong-hoat-dong/a.png)
![hihi](/images/gitignore-khong-hoat-dong/b.png)
Bây giờ mình sẽ ignore file này giống như hình bên dưới, tool nó sẽ tự động thêm đúng đường dẫn tới file đó vào trong file `.gitignore` giúp mình :D.
![hihi](/images/gitignore-khong-hoat-dong/c.png)
Như cái hình bên dưới là nó đã thêm ok rồi đó.
![hihi](/images/gitignore-khong-hoat-dong/d.png)
Nhưng mà để ý cái phần `Unstaged Changes` kìa, file main.dart vẫn còn đó lẽ ra nó phải biến mất khỏi phần đó chứ nhỉ.

## Nguyên nhân

Lý do trong trường hợp này đó là cái file `main.dart` của mình đã từng được commit từ trước đó rồi, và git nó đã lưu trong cache rồi và đó là những file cần lắng nghe sự thay đổi, nó sẽ không quan tâm là ở trong `.gitignore` có liệt kê file đó ra hay là không.

Ok biết nguyên nhân rồi thì giờ làm gì để khắc phục ?
## Giải pháp
Đây là câu lệnh sẽ giúp mình xoá đi cache của file mà mình muốn (nó là lệnh của git nên hệ điều hành nào cũng như vậy nha, có thể trên Windows thì các trỏ đường dẫn của nó khác chút thôi).
- Đối với file
```
git rm --cached <path to file>
```
Ví dụ xoá file main.dart
```
git rm --cached lib/main.dart
```
- Đối với thư mục
```
git rm --cached -r <path to folder>
```
Ví dụ xoá thư mục lib
```
git rm --cached -r lib
```
Sau khi xoá cache xong thì nó sẽ hiện như thế này.
![hihi](/images/gitignore-khong-hoat-dong/e.png)
Trong `Staged Changes` nó sẽ hiện thế này.
![hihi](/images/gitignore-khong-hoat-dong/f.png)
Lệnh này chỉ xoá cache của git thôi chứ file của mình thì vẫn còn nguyên :D không ảnh hưởng gì cả, hình dưới là sau khi mình remove cache file vẫn còn nguyên.
![hihi](/images/gitignore-khong-hoat-dong/g.png)
![hihi](/images/gitignore-khong-hoat-dong/h.png)
Xong rồi, bây giờ nếu muốn thêm file trở lại để push lên git thì chỉ cần xoá phần liệt kê file đó trong `.gitignore` là được, nó sẽ hiện như hình dưới.
![hihi](/images/gitignore-khong-hoat-dong/i.png)
Vậy là ok rồi, stage mấy cái đó vào push lên là được.
Bạn có thể để lại ý kiến bằng cách comment nha :v

