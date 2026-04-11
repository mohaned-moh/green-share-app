import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyBeDfZW8sGqxBOu_QRU3mh837pyzwX5iCs';
  print('Testing Gemini 1.5 Flash...');
  try {
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    final prompt = TextPart("What is 1+1?");
    
    final response = await model.generateContent([
      Content.multi([prompt])
    ]);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error caught: ');
    print(e.toString());
  }
}
