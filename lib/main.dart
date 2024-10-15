import 'package:demo_mobile/app/routes/app_pages.dart';
import 'package:demo_mobile/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CatCare App',
      initialRoute: AppRoutes.LOGIN,
      getPages: AppPages.pages,
    );
  }
}
