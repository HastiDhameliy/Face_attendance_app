import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:face_attendance_app/domain/services/face_service.dart';
import 'package:face_attendance_app/data/repositories/user_repository.dart';
import 'package:face_attendance_app/domain/models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RegisterViewModel extends GetxController {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final departmentController = TextEditingController();
  final isLoading = false.obs;
  final isInitialized = false.obs;
  final faceService = FaceService();
  final userRepository = UserRepository();
  late CameraController cameraController;
  String? capturedImagePath;

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

  Future<void> captureFace() async {
    try {
      final XFile image = await cameraController.takePicture();
      capturedImagePath = image.path;
      
      // Process the image for face detection
      final faces = await faceService.detectFaces(File(image.path));

      if (faces.isEmpty) {
        Get.snackbar('Error', 'No face detected in the image');
        return;
      }

      if (faces.length > 1) {
        Get.snackbar('Error', 'Multiple faces detected. Please capture an image with only one face.');
        return;
      }

      Get.snackbar('Success', 'Face captured successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
    }
  }

  Future<void> registerUser() async {
    if (nameController.text.isEmpty ||
        idController.text.isEmpty ||
        departmentController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    if (capturedImagePath == null) {
      Get.snackbar('Error', 'Please capture your face photo');
      return;
    }

    try {
      isLoading.value = true;
      
      // Process the captured image for face detection
      final faces = await faceService.detectFaces(File(capturedImagePath!));

      if (faces.isEmpty) {
        Get.snackbar('Error', 'No face detected in the image');
        return;
      }

      if (faces.length > 1) {
        Get.snackbar('Error', 'Multiple faces detected. Please capture an image with only one face.');
        return;
      }

      // Extract face features
      final faceFeatures = faceService.extractFaceFeatures(faces.first);

      // Save the image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${idController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(capturedImagePath!).copy('${appDir.path}/$fileName');

      // Create and save user
      final user = UserModel(
        id: idController.text,
        name: nameController.text,
        department: departmentController.text,
        faceImagePath: savedImage.path,
        faceFeatures: faceFeatures,
      );

      await userRepository.saveUser(user);
      Get.snackbar('Success', 'User registered successfully');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to register user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    idController.dispose();
    departmentController.dispose();
    cameraController.dispose();
    faceService.dispose();
    super.onClose();
  }
} 