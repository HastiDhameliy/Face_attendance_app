import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_attendance_app/presentation/pages/home/home_viewmodel.dart';
import 'package:face_attendance_app/presentation/routes/app_pages.dart';
import 'package:face_attendance_app/domain/models/user_model.dart';
import 'package:intl/intl.dart';

class HomePage extends GetView<HomeViewModel> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshUser,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.user.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No employee registered yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.REGISTER),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register Employee'),
                ),
              ],
            ),
          );
        }

        final user = controller.user.value!;
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final currentMonth = DateTime.now().month;
        final currentYear = DateTime.now().year;
        final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
        final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
        final lastDayOfMonth = DateTime(currentYear, currentMonth, daysInMonth);

        // Calculate attendance statistics
        int presentDays = 0;
        int absentDays = 0;
        for (var i = 1; i <= daysInMonth; i++) {
          final date = DateTime(currentYear, currentMonth, i);
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          final attendance = user.attendanceRecords[dateKey];
          if (attendance?.isPresent == true) {
            presentDays++;
          } else if (date.isBefore(DateTime.now())) {
            absentDays++;
          }
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // User Profile Card
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.department,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Monthly Statistics
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Present',
                        presentDays.toString(),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Absent',
                        absentDays.toString(),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
              ),

              // Monthly Calendar
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: daysInMonth + firstDayOfMonth.weekday - 1,
                      itemBuilder: (context, index) {
                        if (index < firstDayOfMonth.weekday - 1) {
                          return const SizedBox();
                        }
                        
                        final day = index - firstDayOfMonth.weekday + 2;
                        final date = DateTime(currentYear, currentMonth, day);
                        final dateKey = DateFormat('yyyy-MM-dd').format(date);
                        final attendance = user.attendanceRecords[dateKey];
                        final isToday = dateKey == today;
                        
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.blue.shade100
                                : attendance?.isPresent == true
                                    ? Colors.green.shade100
                                    : date.isBefore(DateTime.now())
                                        ? Colors.red.shade100
                                        : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isToday
                                  ? Colors.blue
                                  : attendance?.isPresent == true
                                      ? Colors.green
                                      : date.isBefore(DateTime.now())
                                          ? Colors.red
                                          : Colors.grey,
                              width: isToday ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday
                                        ? Colors.blue
                                        : attendance?.isPresent == true
                                            ? Colors.green
                                            : date.isBefore(DateTime.now())
                                                ? Colors.red
                                                : Colors.grey,
                                  ),
                                ),
                                if (attendance?.checkInTime != null)
                                  Text(
                                    DateFormat('hh:mm').format(attendance!.checkInTime!),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.user.value == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.ATTENDANCE),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Mark Attendance'),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
} 