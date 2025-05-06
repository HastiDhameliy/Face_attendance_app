import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:face_attendance_app/presentation/pages/register/register_viewmodel.dart';

class RegisterPage extends GetView<RegisterViewModel> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => RegisterViewModel());
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Time Registration'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Please complete your first-time registration by providing your details and capturing your face photo.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.idController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Please position your face in the frame below and tap the button to capture your photo.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (!controller.isInitialized.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Stack(
                      children: [
                        CameraPreview(controller.cameraController),
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              onPressed: controller.captureFace,
                              icon: const Icon(Icons.camera),
                              label: const Text('Capture Face'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() => controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: controller.registerUser,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Complete Registration'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 