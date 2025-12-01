import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/models/food_model.dart';
import 'package:eatwise2/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodModel food;
  final String? imagePath;

  const FoodDetailScreen({Key? key, required this.food, this.imagePath})
      : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  static const Color brandGreen = Color(0xFF13721C);
  static const Color bgColor = Color.fromARGB(255, 170, 184, 171);
  static const Color cardColor = Color.fromARGB(255, 230, 238, 230);

  bool isAddingToTracking = false;

  Future<void> _addToTracking() async {
    setState(() {
      isAddingToTracking = true;
    });

    try {
      // Get user ID dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 Checking userId from SharedPreferences...');
      print('📦 All keys in SharedPreferences: ${prefs.getKeys()}');
      print('🆔 userId value: $userId');

      if (userId == null) {
        print('❌ userId is NULL!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Error: User tidak terautentikasi. Silakan login ulang.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🎯 Menambahkan ${widget.food.name} ke tracking');
      print('👤 User ID: $userId');

      // Panggil API untuk save ke MySQL
      final result = await HistoryService.addFoodToHistory(
        userId: userId,
        foodName: widget.food.name,
        kalori: widget.food.calories,
        protein: widget.food.protein,
        carbs: widget.food.carbs,
        fat: widget.food.fat,
        fiber: widget.food.fiber,
        servingSize: widget.food.servingSize,
        imagePath: widget.imagePath,
      );

      if (mounted) {
        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${widget.food.name} ditambahkan ke tracking harian!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: brandGreen,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menambahkan ke tracking',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToTracking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isAddingToTracking ? null : _addToTracking,
        backgroundColor: isAddingToTracking ? Colors.grey : brandGreen,
        icon: isAddingToTracking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add_circle, color: Colors.white),
        label: Text(
          isAddingToTracking ? 'Menyimpan...' : 'Tambah ke Tracking',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          widget.food.name,
          style: GoogleFonts.padauk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: brandGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDescriptionCard(),
            const SizedBox(height: 16),
            _buildNutritionCard(),
            const SizedBox(height: 16),
            _buildMacroDistributionCard(),
            const SizedBox(height: 16),
            _buildHealthBenefitsCard(),
            const SizedBox(height: 16),
            _buildIngredientsCard(),
            const SizedBox(height: 16),
            _buildTipsCard(),
            const SizedBox(height: 16),
            _buildAllergensCard(),
            const SizedBox(height: 16),
            _buildRecommendationCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _buildCard(
      title: 'Deskripsi',
      icon: Icons.restaurant_menu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.food.description,
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: brandGreen),
              const SizedBox(width: 8),
              Text(
                'Waktu Persiapan: ${widget.food.preparationTime}',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.scale, size: 18, color: brandGreen),
              const SizedBox(width: 8),
              Text(
                'Porsi: ${widget.food.servingSize}',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return _buildCard(
      title: 'Informasi Nutrisi',
      icon: Icons.local_fire_department,
      child: Column(
        children: [
          _buildNutritionRow(
            'Kalori',
            '${widget.food.calories}',
            'kkal',
            Colors.red,
            Icons.local_fire_department,
          ),
          const Divider(height: 20),
          _buildNutritionRow(
            'Protein',
            widget.food.protein.toStringAsFixed(1),
            'g',
            Colors.blue,
            Icons.fitness_center,
          ),
          const Divider(height: 20),
          _buildNutritionRow(
            'Karbohidrat',
            widget.food.carbs.toStringAsFixed(1),
            'g',
            Colors.orange,
            Icons.bakery_dining,
          ),
          const Divider(height: 20),
          _buildNutritionRow(
            'Lemak',
            widget.food.fat.toStringAsFixed(1),
            'g',
            Colors.amber,
            Icons.opacity,
          ),
          const Divider(height: 20),
          _buildNutritionRow(
            'Serat',
            widget.food.fiber.toStringAsFixed(1),
            'g',
            Colors.green,
            Icons.grass,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistributionCard() {
    return _buildCard(
      title: 'Distribusi Makronutrien',
      icon: Icons.pie_chart,
      child: Column(
        children: [
          _buildMacroBar('Protein', widget.food.proteinPercentage, Colors.blue),
          const SizedBox(height: 12),
          _buildMacroBar(
              'Karbohidrat', widget.food.carbsPercentage, Colors.orange),
          const SizedBox(height: 12),
          _buildMacroBar('Lemak', widget.food.fatPercentage, Colors.amber),
          const SizedBox(height: 16),
          _buildNutritionTags(),
        ],
      ),
    );
  }

  Widget _buildHealthBenefitsCard() {
    return _buildCard(
      title: 'Manfaat Kesehatan',
      icon: Icons.favorite,
      child: Text(
        widget.food.healthBenefits,
        style: GoogleFonts.inter(fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return _buildCard(
      title: 'Bahan-Bahan Utama',
      icon: Icons.shopping_basket,
      child: Text(
        widget.food.ingredients,
        style: GoogleFonts.inter(fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _buildTipsCard() {
    return _buildCard(
      title: 'Tips Makan Sehat',
      icon: Icons.lightbulb,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: brandGreen.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.tips_and_updates, color: brandGreen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.food.tips,
                style: GoogleFonts.inter(fontSize: 13, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergensCard() {
    return _buildCard(
      title: 'Peringatan Alergen',
      icon: Icons.warning_amber,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.food.allergens,
                style: GoogleFonts.inter(
                    fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return _buildCard(
      title: 'Rekomendasi Untuk',
      icon: Icons.people,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.food.recommendedFor,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: brandGreen, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: brandGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildNutritionRow(
      String label, String value, String unit, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: brandGreen,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMacroBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: brandGreen)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionTags() {
    List<Widget> tags = [];

    if (widget.food.isHighProtein) {
      tags.add(_buildTag('Tinggi Protein', Colors.blue));
    }
    if (widget.food.isLowCarb) {
      tags.add(_buildTag('Rendah Karbo', Colors.orange));
    }
    if (widget.food.isLowFat) {
      tags.add(_buildTag('Rendah Lemak', Colors.amber));
    }
    if (widget.food.calories < 400) {
      tags.add(_buildTag('Rendah Kalori', Colors.green));
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags,
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
