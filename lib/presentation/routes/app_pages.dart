import 'package:get/get.dart';
import 'package:face_attendance_app/presentation/pages/home/home_page.dart';
import 'package:face_attendance_app/presentation/pages/attendance/attendance_page.dart';
import 'package:face_attendance_app/presentation/pages/register/register_page.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.ATTENDANCE,
      page: () => const AttendancePage(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
    ),
  ];
} 