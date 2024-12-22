import 'package:demo_mobile/app/modules/ForgetPassword/Views/resetpassword.dart';
import 'package:demo_mobile/app/modules/ForgetPassword/Views/success.dart';
import 'package:demo_mobile/app/modules/ForgetPassword/Views/verifycode.dart';
import 'package:demo_mobile/app/modules/Halaman_Utama/halamanutama_view.dart';
import 'package:demo_mobile/app/modules/Katalog/Views/Food.dart';
import 'package:demo_mobile/app/modules/Katalog/Views/berhasil.dart';
import 'package:demo_mobile/app/modules/Katalog/Views/checkout.dart';
import 'package:demo_mobile/app/modules/Profile/views/editProfile.dart';
import 'package:demo_mobile/app/modules/Profile/views/profile.dart';
import 'package:demo_mobile/app/modules/Settings/Cat.dart';
import 'package:demo_mobile/app/modules/Settings/alamat.dart';
import 'package:demo_mobile/app/modules/Settings/generalsetting.dart';
import 'package:demo_mobile/app/modules/Settings/setting.dart';
import 'package:demo_mobile/app/modules/connection/view/connection_view.dart';
import 'package:demo_mobile/app/modules/login/views/login_view.dart';
import 'package:demo_mobile/app/modules/notifikasi/notification.dart';
import 'package:demo_mobile/app/modules/webview/article.dart';
import 'package:demo_mobile/app/modules/login/views/splashscreen.dart';
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
    GetPage(
      name: AppRoutes.PROFILES,
      page: () => ProfileView(), // Halaman profile
    ),
    GetPage(
      name: AppRoutes.KATALOG,
      page: () => CatalogPage(), // Halaman profile
    ),
    GetPage(
      name: AppRoutes.EDITPROFILE,
      page: () => Editprofile(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => NotificationPage(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingPage(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.MAPS,
      page: () => SettingAlamatPage(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.Paymentsuccess,
      page: () =>PaymentSuccessPage(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.SplashScreen,
      page: () => SplashScreen(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.VERIFY_CODE,
      page: () => VerifyOTPView(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.CHANGE_PASSWORD,
      page: () => NewPasswordView(), // Halaman edit profile
    ),
    GetPage(
      name: AppRoutes.PASSWORD_CHANGED,
      page: () => PasswordChangedScreen(), // Halaman edit profile
    ),
  ];
}
