import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class AIService {
  final ImageLabeler? _imageLabeler;

  AIService()
      : _imageLabeler = kIsWeb 
          ? null 
          : ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));

  Future<String?> classifyImage(XFile imageFile) async {
    if (kIsWeb || _imageLabeler == null) {
      return null;
    }

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final List<ImageLabel> labels = await _imageLabeler!.processImage(inputImage);

      String? bestCategory;
      double highestConfidence = 0.0;

      for (ImageLabel label in labels) {
        if (label.confidence > highestConfidence) {
          highestConfidence = label.confidence;
          bestCategory = _mapLabelToCategory(label.label);
        }
      }
      return bestCategory ?? 'Other';
    } catch (e) {
      debugPrint('Error classifying image: $e');
      return null;
    }
  }

  String _mapLabelToCategory(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('clothing') || lowerLabel.contains('shirt') || lowerLabel.contains('pants') || lowerLabel.contains('dress')) {
      return 'Clothing';
    } else if (lowerLabel.contains('furniture') || lowerLabel.contains('chair') || lowerLabel.contains('table') || lowerLabel.contains('sofa') || lowerLabel.contains('desk')) {
      return 'Furniture';
    } else if (lowerLabel.contains('book')) {
      return 'Books';
    } else if (lowerLabel.contains('electronics') || lowerLabel.contains('phone') || lowerLabel.contains('computer') || lowerLabel.contains('tv')) {
      return 'Electronics';
    } else if (lowerLabel.contains('toy') || lowerLabel.contains('game')) {
      return 'Toys';
    } else {
      return 'Other'; // Default category
    }
  }

  void dispose() {
    _imageLabeler?.close();
  }
}
