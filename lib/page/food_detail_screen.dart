import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/models/food_model.dart';
import 'package:eatwise2/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodModel food;
  final String? imagePath;

  const FoodDetailScreen({Key? key, required this.food, this.imagePath})
      : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {

  bool isAddingToTracking = false;

  Future<void> _addToTracking() async {
    setState(() {
      isAddingToTracking = true;
    });

    try {
      // Get user ID dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Coba ambil dengan berbagai key yang mungkin dipakai
      int? userId = prefs.getInt('userId'); // Key lama

      // Jika null, coba key 'user_id' (STRING yang di-parse ke INT)
      if (userId == null) {
        final userIdString = prefs.getString('user_id');
        if (userIdString != null) {
          userId = int.tryParse(userIdString);
        }
      }

      // Jika masih null, coba key ID_User dari session.dart
      if (userId == null) {
        final userIdString = prefs.getString('ID_User');
        if (userIdString != null) {
          userId = int.tryParse(userIdString);
        }
      }

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
              backgroundColor: AppColors.primary,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.food.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.imagePath != null)
                        Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                      else
                        Container(color: AppColors.primary),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: AppColors.primary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDescriptionCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Nutrition Info'),
                      _buildNutritionGrid(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Macro Distribution'),
                      _buildMacroDistributionCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Health Benefits'),
                      _buildHealthBenefitsCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Key Ingredients'),
                      _buildIngredientsCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Expert Tips'),
                      _buildTipsCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Allergen Warning'),
                      _buildAllergensCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Recommended For'),
                      _buildRecommendationCard(),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: GradientButton(
                  text: 'Add to Daily Tracking',
                  onPressed: _addToTracking,
                  isLoading: isAddingToTracking,
                  icon: Icons.add_task_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.food.description,
            style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoItem(Icons.access_time_rounded, 'Prep Time', widget.food.preparationTime),
              const SizedBox(width: 24),
              _buildInfoItem(Icons.restaurant_rounded, 'Portion', widget.food.servingSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionGrid() {
    final breakdown = widget.food.nutritionBreakdown;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildNutriTile('Calories', widget.food.calories.toString(), 'kcal', Icons.local_fire_department_rounded, Colors.orange, breakdown?['calories'])),
            const SizedBox(width: 12),
            Expanded(child: _buildNutriTile('Protein', widget.food.protein.toStringAsFixed(1), 'g', Icons.fitness_center_rounded, Colors.blue, breakdown?['protein'])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildNutriTile('Carbs', widget.food.carbs.toStringAsFixed(1), 'g', Icons.bakery_dining_rounded, Colors.green, breakdown?['carbs'])),
            const SizedBox(width: 12),
            Expanded(child: _buildNutriTile('Fats', widget.food.fat.toStringAsFixed(1), 'g', Icons.opacity_rounded, Colors.amber, breakdown?['fat'])),
          ],
        ),
      ],
    );
  }

  Widget _buildNutriTile(String label, String value, String unit, IconData icon, Color color, Map<String, dynamic>? breakdown) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 2),
              Text(unit, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          if (breakdown != null && (breakdown['sources'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            ... (breakdown['sources'] as List).take(2).map((s) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• ${s['name']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
            )),
          ]
        ],
      ),
    );
  }

  Widget _buildMacroDistributionCard() {
    return ModernCard(
      child: Column(
        children: [
          _buildMacroBar('Protein', widget.food.proteinPercentage, Colors.blue),
          const SizedBox(height: 16),
          _buildMacroBar('Carbs', widget.food.carbsPercentage, Colors.green),
          const SizedBox(height: 16),
          _buildMacroBar('Fat', widget.food.fatPercentage, Colors.amber),
          const SizedBox(height: 24),
          _buildNutritionTags(),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${percentage.toStringAsFixed(1)}%', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionTags() {
    List<Widget> tags = [];
    if (widget.food.isHighProtein) tags.add(_buildTag('High Protein', Colors.blue));
    if (widget.food.isLowCarb) tags.add(_buildTag('Low Carb', Colors.green));
    if (widget.food.isLowFat) tags.add(_buildTag('Low Fat', Colors.amber));
    if (widget.food.calories < 400) tags.add(_buildTag('Low Calorie', AppColors.primary));
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: tags);
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildHealthBenefitsCard() {
    return ModernCard(
      child: Text(widget.food.healthBenefits, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textPrimary)),
    );
  }

  Widget _buildIngredientsCard() {
    return ModernCard(
      child: Text(widget.food.ingredients, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textPrimary)),
    );
  }

  Widget _buildTipsCard() {
    return ModernCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.food.tips, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildAllergensCard() {
    return ModernCard(
      color: AppColors.error.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.food.allergens, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return ModernCard(
      color: Colors.blue.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.people_outline_rounded, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.food.recommendedFor, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
