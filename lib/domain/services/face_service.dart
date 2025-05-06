import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceService {
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  Future<List<Face>> detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    return await faceDetector.processImage(inputImage);
  }

  List<double> extractFaceFeatures(Face face) {
    final landmarks = face.landmarks;
    final contours = face.contours;
    
    List<double> features = [];
    
    // Add landmark coordinates
    for (final landmark in landmarks.values) {
      if (landmark?.position != null) {
        features.add(landmark!.position.x.toDouble());
        features.add(landmark.position.y.toDouble());
      }
    }
    
    // Add contour points
    for (final contour in contours.values) {
      if (contour?.points != null) {
        for (final point in contour!.points) {
          features.add(point.x.toDouble());
          features.add(point.y.toDouble());
        }
      }
    }
    
    return features;
  }

  double calculateFaceSimilarity(List<double> features1, List<double> features2) {
    if (features1.length != features2.length) {
      return 0.0;
    }
    
    double sum = 0.0;
    for (int i = 0; i < features1.length; i++) {
      sum += (features1[i] - features2[i]) * (features1[i] - features2[i]);
    }
    
    return 1.0 / (1.0 + sum);
  }

  void dispose() {
    faceDetector.close();
  }
} 