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

  /// Load model dan labels dari assets
  Future<void> loadModel() async {
    try {
      // Load interpreter
      _interpreter = await Interpreter.fromAsset(MODEL_PATH);

      // Load labels
      final labelsData = await rootBundle.loadString(LABELS_PATH);
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .map((label) => label.trim())
          .toList();

      print('✅ Model loaded successfully: ${_labels!.length} classes');
    } catch (e) {
      print('❌ Error loading model: $e');
      rethrow;
    }
  }

  /// Klasifikasi gambar dari path file
  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      throw Exception(
          'Model belum dimuat. Panggil loadModel() terlebih dahulu.');
    }

    try {
      final startTime = DateTime.now();

      // Baca dan decode gambar
      final imageBytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Gagal membaca gambar');
      }

      // Resize gambar ke ukuran input model
      final resized = img.copyResize(
        image,
        width: INPUT_SIZE,
        height: INPUT_SIZE,
        interpolation: img.Interpolation.linear,
      );

      // Konversi gambar ke input tensor
      final input = _imageToFloat32List(resized);
      final inputReshaped = input.reshape([1, INPUT_SIZE, INPUT_SIZE, 3]);

      // Siapkan output tensor
      final output =
          List.filled(1 * NUM_CLASSES, 0.0).reshape([1, NUM_CLASSES]);

      // Jalankan inferensi
      _interpreter!.run(inputReshaped, output);

      // Ambil probabilitas hasil prediksi
      final probabilities = output[0] as List<double>;

      // Dapatkan top 3 prediksi
      final top3 = _getTop3(probabilities);

      // Hitung waktu inferensi
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      return {
        'success': true,
        'predicted_class': top3[0]['label'],
        'confidence': top3[0]['confidence'],
        'top_3': top3,
        'inference_time_ms': inferenceTime,
      };
    } catch (e) {
      print('❌ Error during classification: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Konversi gambar ke Float32List untuk input model
  Float32List _imageToFloat32List(img.Image image) {
    final buffer = Float32List(1 * INPUT_SIZE * INPUT_SIZE * 3);
    int pixelIndex = 0;

    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        final pixel = image.getPixel(x, y);
        // Normalisasi pixel ke range [0, 255] untuk float16 model
        buffer[pixelIndex++] = pixel.r.toDouble();
        buffer[pixelIndex++] = pixel.g.toDouble();
        buffer[pixelIndex++] = pixel.b.toDouble();
      }
    }

    return buffer;
  }

  /// Dapatkan top 3 prediksi dengan confidence tertinggi
  List<Map<String, dynamic>> _getTop3(List<double> probabilities) {
    final indexed = List.generate(probabilities.length,
        (i) => {'index': i, 'probability': probabilities[i]});

    // Sort berdasarkan probability (descending)
    indexed.sort((a, b) =>
        (b['probability'] as double).compareTo(a['probability'] as double));

    // Ambil top 3
    return indexed.take(3).map((item) {
      final index = item['index'] as int;
      final probability = item['probability'] as double;

      return {
        'label': _labels![index],
        'confidence': probability,
        'confidence_percent': (probability * 100).toStringAsFixed(1),
        'index': index,
      };
    }).toList();
  }

  /// Cek apakah model sudah dimuat
  bool get isLoaded => _interpreter != null && _labels != null;

  /// Dapatkan jumlah kelas
  int get numClasses => _labels?.length ?? 0;

  /// Dapatkan daftar semua label
  List<String> get labels => _labels ?? [];

  /// Tutup interpreter dan bersihkan resource
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    print('🧹 Model resources cleaned up');
  }
}
