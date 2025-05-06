import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_attendance_app/data/repositories/user_repository.dart';
import 'package:face_attendance_app/domain/models/user_model.dart';

class HomeViewModel extends GetxController {
  static HomeViewModel get to => Get.find();
  
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> user = Rxn<UserModel>();
  final userRepository = UserRepository();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      isLoading.value = true;
      final users = await userRepository.getUsers();
      if (users.isNotEmpty) {
        user.value = users.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshUser() {
    loadUser();
  }
} 