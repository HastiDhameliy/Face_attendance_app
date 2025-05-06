import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:face_attendance_app/presentation/pages/attendance/attendance_viewmodel.dart';

class AttendancePage extends GetView<AttendanceViewModel> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AttendanceViewModel());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Attendance'),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.currentUser.value != null) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Text(
                      'Welcome, ${controller.currentUser.value!.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Department: ${controller.currentUser.value!.department}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.attendanceStatus.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (controller.checkInTime.isNotEmpty)
                      Text(
                        'Check-in: ${controller.checkInTime.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (controller.checkOutTime.isNotEmpty)
                      Text(
                        'Check-out: ${controller.checkOutTime.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Please position your face in the frame and tap the button to mark your attendance.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  if (!controller.isInitialized.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return CameraPreview(controller.cameraController);
                }),
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Obx(() {
                    if (controller.isDetecting.value) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Detecting face...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: controller.takePicture,
                      icon: const Icon(Icons.camera),
                      label: const Text('Mark Attendance'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 