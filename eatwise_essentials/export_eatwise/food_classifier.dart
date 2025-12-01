import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodClassifier {
  static const String MODEL_PATH = 'assets/models/eatwise_float16.tflite';
  static const String LABELS_PATH = 'assets/models/labels.txt';
  static const int INPUT_SIZE = 224;
  static const int NUM_CLASSES = 13;
  
  Interpreter? _interpreter;
  List<String>? _labels;
  
  static final FoodClassifier _instance = FoodClassifier._internal();
  factory FoodClassifier() => _instance;
  FoodClassifier._internal();
  
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(MODEL_PATH);
      
      final labelsData = await rootBundle.loadString(LABELS_PATH);
      _labels = labelsData.split('\n')
          .where((label) => label.trim().isNotEmpty)
          .map((label) => label.trim())
          .toList();
      
      print('✅ Model loaded: ${_labels!.length} classes');
    } catch (e) {
      print('❌ Error loading model: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      throw Exception('Model not loaded');
    }
    
    try {
      final startTime = DateTime.now();
      
      final imageBytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) throw Exception('Failed to decode image');
      
      final resized = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);
      final input = _imageToFloat32List(resized);
      final output = List.filled(1 * NUM_CLASSES, 0.0).reshape([1, NUM_CLASSES]);
      
      _interpreter!.run(input, output);
      
      final probabilities = output[0] as List<double>;
      final top3 = _getTop3(probabilities);
      
      return {
        'success': true,
        'predicted_class': top3[0]['label'],
        'confidence': top3[0]['confidence'],
        'top_3': top3,
        'inference_time_ms': DateTime.now().difference(startTime).inMilliseconds,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  Float32List _imageToFloat32List(img.Image image) {
    final buffer = Float32List(1 * INPUT_SIZE * INPUT_SIZE * 3);
    int pixelIndex = 0;
    
    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r.toDouble();
        buffer[pixelIndex++] = pixel.g.toDouble();
        buffer[pixelIndex++] = pixel.b.toDouble();
      }
    }
    return buffer;
  }
  
  List<Map<String, dynamic>> _getTop3(List<double> probs) {
    final indexed = List.generate(probs.length, (i) => {'i': i, 'p': probs[i]});
    indexed.sort((a, b) => (b['p'] as double).compareTo(a['p'] as double));
    
    return indexed.take(3).map((item) {
      return {
        'label': _labels![item['i'] as int],
        'confidence': item['p'] as double,
        'index': item['i'] as int,
      };
    }).toList();
  }
  
  bool get isLoaded => _interpreter != null && _labels != null;
  
  void dispose() {
    _interpreter?.close();
  }
}
