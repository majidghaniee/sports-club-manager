# راهنمای بیلد دیتابیس (Drift & build_runner)

این پروژه از پایگاه‌داده **Drift (سابقاً Moor)** استفاده می‌کند.
برای تولید فایل‌های کمکی دیتابیس (`app_database.g.dart` و DAOها) مراحل زیر را دنبال کنید:

1. دریافت پکیج‌ها:
   ```bash
   flutter pub get
   ```

2. اجرای `build_runner` جهت تولید کدهای ORM:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   یا در حالت watch حین توسعه:
   ```bash
   dart run build_runner watch --delete-conflicting-outputs
   ```

3. اجرای برنامه:
   ```bash
   flutter run
   ```
