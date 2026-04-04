import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyCNCWG3ZC5lEsTBTkjkM7Cw-hwNiaBdMnE';
  print('Testing Gemini Vision...');
  try {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final prompt = TextPart("What is 1+1?");
    
    final response = await model.generateContent([
      Content.multi([prompt])
    ]);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error caught: ');
    print(e);
  }
}
