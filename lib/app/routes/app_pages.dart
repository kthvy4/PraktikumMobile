import 'package:demo_mobile/app/modules/Halaman_Utama/Halaman_Utama.dart';
import 'package:demo_mobile/app/modules/login/views/login_view.dart'; // Import halaman profile
import 'package:demo_mobile/app/modules/webview/article.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(), // Home Page yang sudah kamu buat
    ),
    GetPage(
      name: AppRoutes.ARTICLES,
      page: () => ArticlePage(), // Halaman Artikel
    ),
  ];
}
