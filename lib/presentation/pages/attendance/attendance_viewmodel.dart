import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:face_attendance_app/domain/services/face_service.dart';
import 'package:face_attendance_app/data/repositories/user_repository.dart';
import 'package:face_attendance_app/domain/models/user_model.dart';
import 'package:intl/intl.dart';

class AttendanceViewModel extends GetxController {
  late CameraController cameraController;
  final isInitialized = false.obs;
  final isDetecting = false.obs;
  final faceService = FaceService();
  final userRepository = UserRepository();
  final currentUser = Rxn<UserModel>();
  final attendanceStatus = ''.obs;
  final checkInTime = ''.obs;
  final checkOutTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await cameraController.initialize();
      isInitialized.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize camera: $e');
    }
  }

  Future<void> takePicture() async {
    try {
      isDetecting.value = true;
      final XFile image = await cameraController.takePicture();
      final File imageFile = File(image.path);
      
      // Process the image for face detection
      final faces = await faceService.detectFaces(imageFile);

      if (faces.isEmpty) {
        Get.snackbar('Error', 'No face detected');
        return;
      }

      // Extract face features
      final faceFeatures = faceService.extractFaceFeatures(faces.first);
      
      // Get all users from repository
      final users = await userRepository.getUsers();
      
      // Find the best matching user
      UserModel? bestMatch;
      double bestScore = 0.0;
      
      for (final user in users) {
        final score = faceService.calculateFaceSimilarity(faceFeatures, user.faceFeatures);
        if (score > bestScore) {
          bestScore = score;
          bestMatch = user;
        }
      }

      if (bestMatch != null && bestScore > 0.8) {
        currentUser.value = bestMatch;
        await markAttendance(bestMatch);
      } else {
        Get.snackbar('Error', 'No matching user found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take picture: $e');
    } finally {
      isDetecting.value = false;
    }
  }

  Future<void> markAttendance(UserModel user) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateKey = DateFormat('yyyy-MM-dd').format(today);

    var record = user.attendanceRecords[dateKey] ?? AttendanceRecord(date: today);
    
    if (record.checkInTime == null) {
      // First check-in of the day
      record = AttendanceRecord(
        date: today,
        checkInTime: now,
        isPresent: true,
      );
      checkInTime.value = DateFormat('hh:mm a').format(now);
      attendanceStatus.value = 'Checked In';
    } else if (record.checkOutTime == null) {
      // Check-out
      record = AttendanceRecord(
        date: today,
        checkInTime: record.checkInTime,
        checkOutTime: now,
        isPresent: true,
      );
      checkOutTime.value = DateFormat('hh:mm a').format(now);
      attendanceStatus.value = 'Checked Out';
    } else {
      Get.snackbar('Info', 'Attendance already marked for today');
      return;
    }

    // Update user's attendance record
    final updatedUser = UserModel(
      id: user.id,
      name: user.name,
      department: user.department,
      faceImagePath: user.faceImagePath,
      faceFeatures: user.faceFeatures,
      attendanceRecords: {
        ...user.attendanceRecords,
        dateKey: record,
      },
    );

    await userRepository.saveUser(updatedUser);
    currentUser.value = updatedUser;
  }

  @override
  void onClose() {
    cameraController.dispose();
    faceService.dispose();
    super.onClose();
  }
} 