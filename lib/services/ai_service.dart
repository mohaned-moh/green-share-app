import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class AIService {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY', 
    defaultValue: 'AIzaSyCNCWG3ZC5lEsTBTkjkM7Cw-hwNiaBdMnE',
  );

  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  Future<String?> classifyImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final prompt = TextPart("Classify this image into exactly one of these categories: Clothing, Furniture, Books, Electronics, Toys, or Other. Output only the exact category string and nothing else. No formatting, no extra words.");
      final imagePart = DataPart(imageFile.mimeType ?? 'image/jpeg', bytes);
      
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final String? text = response.text?.trim();
      
      final validCategories = ['Clothing', 'Furniture', 'Books', 'Electronics', 'Toys', 'Other'];
      if (text != null) {
        // Handle case variations just in case Gemini adds periods or slightly differs capitalization
        final cleanText = text.replaceAll('.', '').trim();
        for (final category in validCategories) {
          if (category.toLowerCase() == cleanText.toLowerCase()) {
            return category;
          }
        }
      }
      return 'Other';
    } catch (e) {
      debugPrint('Error classifying image with Gemini: $e');
      throw Exception(e);
    }
  }

  void dispose() {
    // No explicit dispose needed for Gemini SDK
  }
}
