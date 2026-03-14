import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/services/food_classifier.dart';
import 'package:eatwise2/services/food_mapping_service.dart';
import 'package:eatwise2/services/color_based_detector.dart';
import 'package:eatwise2/database/food_database.dart';
import 'package:eatwise2/models/food_model.dart';
import 'package:eatwise2/page/food_detail_screen.dart';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';

class FoodDetectionScreen extends StatefulWidget {
  const FoodDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FoodDetectionScreen> createState() => _FoodDetectionScreenState();
}

class _FoodDetectionScreenState extends State<FoodDetectionScreen> {
  final FoodClassifier classifier = FoodClassifier();
  final ImagePicker picker = ImagePicker();
  final FoodDatabase foodDb = FoodDatabase();
  bool isModelLoaded = false;
  bool isLoading = false;
  bool isClassifying = false;

  File? selectedImage;
  Map<String, dynamic>? result;
  Map<String, dynamic>? colorResult;
  FoodModel? detectedFood;
  String? errorMsg;
  List<String> similarFoods = [];
  bool useColorDetection = false;

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
    if (selectedImage == null || !isModelLoaded) {
      print('⚠️ Cannot classify: selectedImage=${selectedImage != null}, isModelLoaded=$isModelLoaded');
      return;
    }

    print('🚀 Starting classification...');
    setState(() {
      isClassifying = true;
      errorMsg = null;
    });

    try {
      print('📸 Image path: ${selectedImage!.path}');
      
      // Run both AI and Color detection in parallel
      final results = await Future.wait([
        classifier.classifyImage(selectedImage!.path),
        ColorBasedDetector.detectByColor(selectedImage!.path),
      ]);
      
      final aiResult = results[0];
      final colorRes = results[1];
      
      print('📊 AI result: $aiResult');
      print('🎨 Color result: $colorRes');

      setState(() {
        result = aiResult;
        colorResult = colorRes;
        isClassifying = false;
      });

      if (aiResult['success'] == false) {
        print('❌ AI Classification failed: ${aiResult['error']}');
        setState(() {
          errorMsg = aiResult['error'] ?? 'Error';
        });
      } else {
        print('✅ Classification successful!');
        
        // Determine which result to use
        final aiConfidence = aiResult['confidence'] as double;
        final colorConfidence = colorRes['success'] == true 
            ? (colorRes['confidence'] as double) 
            : 0.0;
        
        String predictedFoodName;
        
        // Use color detection if AI confidence is very low
        if (aiConfidence < 0.5 && colorConfidence > aiConfidence) {
          print('🎨 Using color-based detection (AI: ${(aiConfidence * 100).toStringAsFixed(1)}%, Color: ${(colorConfidence * 100).toStringAsFixed(1)}%)');
          predictedFoodName = colorRes['predicted_class'] as String;
          setState(() {
            useColorDetection = true;
          });
        } else {
          print('🤖 Using AI detection (AI: ${(aiConfidence * 100).toStringAsFixed(1)}%, Color: ${(colorConfidence * 100).toStringAsFixed(1)}%)');
          predictedFoodName = aiResult['predicted_class'] as String;
          setState(() {
            useColorDetection = false;
          });
        }
        
        print('🔍 Searching database for: $predictedFoodName');
        
        // Get similar foods
        final similar = FoodMappingService.getSimilarFoods(predictedFoodName);
        print('🔗 Similar foods: $similar');
        
        final food = await foodDb.getFoodByName(predictedFoodName);

        if (food != null) {
          print('✅ Food found in database: ${food.name}');
        } else {
          print('⚠️ Food not found in database: $predictedFoodName');
        }

        setState(() {
          detectedFood = food;
          similarFoods = similar;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Exception in classifyImage: $e');
      print('📍 Stack trace: $stackTrace');
      setState(() {
        isClassifying = false;
        errorMsg = 'Error: $e';
      });
    }
  }

  void showSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 24),
                ),
                title: Text('Camera', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a new photo of your food'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 24),
                ),
                title: Text('Gallery', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: const Text('Choose an existing photo from gallery'),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI Food Detection',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing AI Model...'),
                ],
              ),
            )
          : errorMsg != null && selectedImage == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 80, color: AppColors.error),
                        const SizedBox(height: 20),
                        Text(
                          errorMsg!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: AppColors.error, fontSize: 16),
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          text: 'Retry Loading Model',
                          onPressed: loadModel,
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
                      const SizedBox(height: 24),
                      if (selectedImage != null) ...[
                        buildImagePreview(),
                        const SizedBox(height: 24),
                      ],
                      if (isClassifying)
                        const ModernCard(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Analyzing Image...'),
                              ],
                            ),
                          ),
                        )
                      else if (result != null && result!['success'] == true)
                        buildResult()
                      else if (selectedImage == null)
                        buildEmpty(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      floatingActionButton: isModelLoaded && !isLoading
          ? FloatingActionButton.extended(
              heroTag: 'foodDetectionPickButton',
              onPressed: showSourceDialog,
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: Text(
                'Select Image',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget buildInfoCard() {
    return ModernCard(
      isGlass: true,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Snap a photo or pick from gallery to detect Indonesian food instantly.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImagePreview() {
    return ModernCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(selectedImage!,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildResult() {
    final predictedClass = result!['predicted_class'] as String;
    final confidence = result!['confidence'] as double;
    final top3 = result!['top_3'] as List;
    final inferenceTime = result!['inference_time_ms'] as int;

    // Get color detection info if available
    final hasColorDetection = colorResult != null && colorResult!['success'] == true;
    final colorPrediction = hasColorDetection ? colorResult!['predicted_class'] as String : null;
    final colorConfidence = hasColorDetection ? colorResult!['confidence'] as double : 0.0;

    // Confidence threshold untuk warning
    final bool isLowConfidence = confidence < 0.6;
    final bool isMediumConfidence = confidence >= 0.6 && confidence < 0.8;

    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detection method indicator
          if (useColorDetection) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.palette, color: Colors.purple, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deteksi Berbasis Warna',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.purple, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'AI kurang yakin, menggunakan analisis warna sebagai alternatif',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.purple.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Show both results if color detection is available
          if (hasColorDetection && !useColorDetection) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deteksi Ganda Aktif',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'AI: ${(confidence * 100).toStringAsFixed(0)}% | Warna: $colorPrediction (${(colorConfidence * 100).toStringAsFixed(0)}%)',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.blue.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Warning jika confidence rendah
          if (isLowConfidence && !useColorDetection) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deteksi kurang yakin. Hasil mungkin tidak akurat. Coba foto ulang dengan pencahayaan lebih baik.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (isMediumConfidence) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deteksi cukup yakin. Periksa hasil dan pilih dari Top 3 jika perlu.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detection Result',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    Text(predictedClass,
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence Level',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  Text('${(confidence * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    confidence > 0.8 ? Icons.check_circle : (confidence > 0.6 ? Icons.help_outline : Icons.error_outline),
                    color: confidence > 0.8 ? Colors.green : (confidence > 0.6 ? AppColors.accent : AppColors.error),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 10,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                confidence > 0.8 ? Colors.green : (confidence > 0.6 ? AppColors.accent : AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(
            'Top 3 Predictions',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...top3.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final label = item['label'] as String;
            final conf = item['confidence'] as double;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: idx == 0 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text('${idx + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: idx == 0 ? FontWeight.w600 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text('${(conf * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: idx == 0 ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Analysis took ${inferenceTime}ms',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
          // Similar Foods Section
          if (similarFoods.isNotEmpty && similarFoods.length > 1) ...[
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Text(
              'Makanan Serupa (${similarFoods.length})',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih jika makanan Anda lebih cocok dengan salah satu di bawah:',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: similarFoods.map((foodName) {
                final isSelected = foodName == predictedClass;
                return InkWell(
                  onTap: () async {
                    // Load food from database
                    final food = await foodDb.getFoodByName(foodName);
                    if (food != null) {
                      setState(() {
                        detectedFood = food;
                        result!['predicted_class'] = foodName;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      foodName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (detectedFood != null) ...[
            const SizedBox(height: 24),
            GradientButton(
              text: 'View Nutrition Details',
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
            ),
          ] else if (isLowConfidence) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _showAllFoodsDialog();
              },
              icon: const Icon(Icons.search),
              label: const Text('Cari Manual dari 47 Makanan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return const EmptyState(
      icon: Icons.add_a_photo_outlined,
      title: 'No Image Selected',
      description: 'Tap the button below to start identifying your food.',
    );
  }

  // Dialog untuk memilih dari 47 makanan
  void _showAllFoodsDialog() {
    final allFoods = FoodMappingService.getAllFoods();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pilih Makanan (47 Pilihan)',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: allFoods.length,
                  itemBuilder: (context, index) {
                    final foodName = allFoods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          foodName,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          Navigator.pop(context);
                          // Load food from database
                          final food = await foodDb.getFoodByName(foodName);
                          if (food != null) {
                            setState(() {
                              detectedFood = food;
                              if (result != null) {
                                result!['predicted_class'] = foodName;
                                result!['confidence'] = 1.0; // Manual selection = 100%
                              }
                            });
                            
                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ $foodName dipilih'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('⚠️ Data $foodName tidak ditemukan di database'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}