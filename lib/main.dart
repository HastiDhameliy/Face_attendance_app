import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_attendance_app/core/theme/app_theme.dart';
import 'package:face_attendance_app/presentation/routes/app_pages.dart';
import 'package:face_attendance_app/presentation/pages/home/home_viewmodel.dart';
import 'package:face_attendance_app/presentation/pages/register/register_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GetX controllers
    Get.put(HomeViewModel());
    Get.put(RegisterViewModel());
    
    return GetMaterialApp(
      title: 'Face Attendance',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
