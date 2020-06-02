---
title: "Sử dụng chung ChangeNotifier cho nhiều page trong Flutter"
description: "Sử dụng chung ChangeNotifier cho nhiều page trong Flutter"
date: 2020-04-24T14:11:02+07:00
draft: false
author: tbm98
tags:
 - flutter
---

## Vấn đề ?

Mình có 1 page là profile và login, ở profile mình sử dụng `ChangeNotifierProvider` để cung cấp một lớp `ChangeNotifier` \(tạm gọi là lớp `state`\) có nhiệm vụ lưu giữ thông tin user hiện tại. Trong trường hợp chưa đăng nhập thì sẽ hiển thị nút đăng nhập yêu cầu chuyển sang page login để người dùng đăng nhập. Sau khi đăng nhập xong sẽ pop quay trở lại page profile. Bây giờ ở màn hình login mình muốn sử dụng được lớp `ChangeNotifier` của màn hình profile thì phải làm thế nào ?

## Một vài cách có thể sử dụng

* Khi màn hình login pop sẽ truyền thêm thông tin user trở lại cho màn hình profile, cách này sẽ không hợp lí nếu như dữ liệu update nhiều hơn 1 hoặc ở màn hình login muốn gọi hàm từ lớp `state`.
*  Đặt `ChangeNotifierProvider` ở bên trên `materialApp/cupertinoApp`: cách này được khá nhiều người sử dụng, thường thì những lớp nào họ muốn dùng chung cho toàn bộ ứng dụng sẽ đặt hết vào 1 MultiProvider và đặt nó ở ngoài cùng \(bọc `materialApp / cupertinoApp`\). Nhưng trong trường hợp mình có nhiều page khác nữa mà lại đặt lớp state nằm ở ngoài cùng sẽ dẫn tới tốn bộ nhớ khi không sử dụng tới.
* Còn một vài cách khác nữa ví dụ như truyền callback hay jj đó nhưng mình sẽ bỏ qua và chỉ sử dụng những gì sẵn có của provider thôi.

## Hướng giải quyết của mình.

Cách của mình là sử dụng ChangeNotifierProvider.value để bọc page mà mình muốn push sang.

Sở dĩ phải bọc thêm 1 `ChangeNotifierProvider` là vì `materialApp/cupertinoApp` bản thân nó sử hữu 1 cái `Navigator`, khi mình push sang màn hình mới lập tức màn hình này sẽ là first child \(con đầu tiên\) của `materialApp/cupertinoApp` trong widget tree. Vì nó là con đầu tiên nên 1 là phải đặt `ChangeNotifierProvider` ở bên trên cả `materialApp/cupertinoApp` hoặc là phải bọc nó bởi 1 `ChangeNotifierProvider` mới. Còn 1 cách khác là tạo thêm 1 `Navigator` khác để tự quản lý cái navigation riêng nhưng rắc rối hơn nên bỏ qua :\)\) .

Lớp này sẽ cung cấp một `ChangeNotifierProvider` với một `ChangeNotifier` sẵn có từ trước, và mình sẽ sử dụng lớp state có sẵn bằng câu lệnh này 

```dart
Provider.of<ClassName>(context, listen: false)
```

Khi từ màn hình profile muốn `push` sang màn hình login thì sẽ như thế này

```dart
Navigator.of(context).push(
    MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(value: Provider.of<ClassName>(context, listen: false),
        child: LoginPage())
    )
);
```

## Demo

Đầu tiên tạo Profile page với nội dung như sau

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Profile page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ở đây mình dùng selector để lắng nghe sự thay đổi của biến user
            Selector<ClassName, String>(
              selector: (_, m) => m.user,
              builder: (_, data, __) {
                return Text('current user is $data');
              },
            ),
            
            // ở nút login mình sẽ bọc LoginPage bằng một ChangeNotifierProvider.value
            // với value là ClassName được cung cấp bới ChangeNotifierProvider
            // ở bên trên của Profile page
            RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                          value: Provider.of<ClassName>(context, listen: false),
                          child: LoginPage())));
                },
                child: Text('login')),
          ],
        ),
      ),
    );
  }
}
```

Sau đó ở Login page sẽ code như sau

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login page'),
        ),
        body: Container(
          child: Center(
            child: RaisedButton(
              onPressed: () {
                // ở đây mình vẫn truy cập được tới ClassName bình thường
                // vì mình đã bọc LoginPage bằng một ChangeNotifierProvider.value
                // lúc gọi Navigator.push rồi
                Provider.of<ClassName>(context, listen: false)
                    .loginSuccess('TBM98');
              },
              // ở đây mình dùng selector để lắng nghe sự thay đổi của biến user
              child: Selector<ClassName, String>(
                selector: (_, m) => m.user,
                builder: (_, data, __) {
                  return Text('current user is $data, login demo');
                },
              ),
            ),
          ),
        ));
  }
}
```

## Full source code

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(new MyApp());
}

class ClassName with ChangeNotifier {
  String user = '';

  void loginSuccess(String value) {
    user = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
          create: (_) => ClassName(), child: ProfilePage()),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Profile page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Selector<ClassName, String>(
              selector: (_, m) => m.user,
              builder: (_, data, __) {
                return Text('current user is $data');
              },
            ),
            RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                          value: Provider.of<ClassName>(context, listen: false),
                          child: LoginPage())));
                },
                child: Text('login')),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login page'),
        ),
        body: Container(
          child: Center(
            child: RaisedButton(
              onPressed: () {
                Provider.of<ClassName>(context, listen: false)
                    .loginSuccess('TBM98');
              },
              child: Selector<ClassName, String>(
                selector: (_, m) => m.user,
                builder: (_, data, __) {
                  return Text('current user is $data, login demo');
                },
              ),
            ),
          ),
        ));
  }
}

```

Lần đầu tiên mình viết bài :D Nếu có gì thắc mắc bạn có thể comment mình sẽ trả lời.

