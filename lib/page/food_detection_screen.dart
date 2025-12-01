import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/services/food_classifier.dart';
import 'package:eatwise2/database/food_database.dart';
import 'package:eatwise2/models/food_model.dart';
import 'package:eatwise2/page/food_detail_screen.dart';

class FoodDetectionScreen extends StatefulWidget {
  const FoodDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FoodDetectionScreen> createState() => _FoodDetectionScreenState();
}

class _FoodDetectionScreenState extends State<FoodDetectionScreen> {
  static const Color brandGreen = Color(0xFF13721C);
  static const Color bgColor = Color.fromARGB(255, 170, 184, 171);
  static const Color cardColor = Color.fromARGB(255, 230, 238, 230);

  final FoodClassifier classifier = FoodClassifier();
  final ImagePicker picker = ImagePicker();
  final FoodDatabase foodDb = FoodDatabase();

  bool isModelLoaded = false;
  bool isLoading = false;
  bool isClassifying = false;

  File? selectedImage;
  Map<String, dynamic>? result;
  FoodModel? detectedFood;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      await classifier.loadModel();
      setState(() {
        isModelLoaded = true;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Model AI siap (${classifier.numClasses} kategori)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'Gagal memuat model: $e';
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          result = null;
          detectedFood = null;
          errorMsg = null;
        });

        await classifyImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> classifyImage() async {
    if (selectedImage == null || !isModelLoaded) return;

    setState(() {
      isClassifying = true;
      errorMsg = null;
    });

    try {
      final res = await classifier.classifyImage(selectedImage!.path);

      setState(() {
        result = res;
        isClassifying = false;
      });

      if (res['success'] == false) {
        setState(() {
          errorMsg = res['error'] ?? 'Error';
        });
      } else {
        // Query database for food details
        final predictedFoodName = res['predicted_class'] as String;
        final food = await foodDb.getFoodByName(predictedFoodName);

        setState(() {
          detectedFood = food;
        });

        if (food == null) {
          print('⚠️ Food not found in database: $predictedFoodName');
        }
      }
    } catch (e) {
      setState(() {
        isClassifying = false;
        errorMsg = 'Error: $e';
      });
    }
  }

  void showSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Gambar',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: brandGreen, size: 30),
                title: Text('Kamera', style: GoogleFonts.inter(fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: brandGreen, size: 30),
                title: Text('Galeri', style: GoogleFonts.inter(fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('AI Deteksi Makanan',
            style: GoogleFonts.padauk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: brandGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(brandGreen)),
                  const SizedBox(height: 20),
                  Text('Memuat model AI...',
                      style: GoogleFonts.inter(fontSize: 16)),
                ],
              ),
            )
          : errorMsg != null && selectedImage == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 80, color: Colors.red),
                        const SizedBox(height: 20),
                        Text(errorMsg!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.red)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: loadModel,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: brandGreen,
                              foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildInfoCard(),
                      const SizedBox(height: 20),
                      if (selectedImage != null) ...[
                        buildImagePreview(),
                        const SizedBox(height: 20),
                      ],
                      if (isClassifying)
                        buildClassifying()
                      else if (result != null && result!['success'] == true)
                        buildResult()
                      else if (selectedImage == null)
                        buildEmpty(),
                    ],
                  ),
                ),
      floatingActionButton: isModelLoaded && !isLoading
          ? FloatingActionButton.extended(
              onPressed: showSourceDialog,
              backgroundColor: brandGreen,
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: Text('Pilih Gambar',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: brandGreen, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ambil foto atau pilih dari galeri untuk mendeteksi makanan Indonesia',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(selectedImage!,
            height: 300, width: double.infinity, fit: BoxFit.cover),
      ),
    );
  }

  Widget buildClassifying() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(brandGreen)),
          const SizedBox(height: 16),
          Text('Menganalisis...',
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget buildResult() {
    final predictedClass = result!['predicted_class'] as String;
    final confidence = result!['confidence'] as double;
    final top3 = result!['top_3'] as List;
    final inferenceTime = result!['inference_time_ms'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: brandGreen, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hasil Deteksi:',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.black54)),
                    Text(predictedClass,
                        style: GoogleFonts.padauk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: brandGreen)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tingkat Keyakinan:',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${(confidence * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: brandGreen)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(confidence > 0.7
                  ? Colors.green
                  : confidence > 0.4
                      ? Colors.orange
                      : Colors.red),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text('Top 3 Prediksi:',
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...top3.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final label = item['label'] as String;
            final conf = item['confidence'] as double;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: idx == 0 ? brandGreen : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text('${idx + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: idx == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal))),
                  Text('${(conf * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: idx == 0 ? brandGreen : Colors.grey[600])),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Waktu: ${inferenceTime}ms',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),

          // Button to view full nutrition details
          if (detectedFood != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(
                        food: detectedFood!,
                        imagePath: selectedImage?.path,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Lihat Detail Nutrisi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.photo_camera,
              size: 100, color: brandGreen.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text('Belum ada gambar',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45)),
          const SizedBox(height: 8),
          Text('Tekan tombol di bawah untuk memilih',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black38)),
        ],
      ),
    );
  }
}
