import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:eatwise2/page/user_profile.dart';
import 'package:eatwise2/page/scan_page.dart';
import 'package:eatwise2/page/food_detection_screen.dart';
import 'package:eatwise2/services/profile_service_local.dart';
import 'package:eatwise2/services/history_service_local.dart';
import 'package:eatwise2/util/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // --- ASET DESAIN --- (Legacy styles kept for other sections)
  static const Color _scanButtonColor = Color.fromARGB(255, 230, 238, 230);
  static const Color _brandColorGreen = Color(0xFF13721C);
  static const double _sidePadding = 20.0;

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  String _userName = "User";
  int _currentCalories = 0;
  int _targetCalories = 2000;
  double _calorieProgress = 0.0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================
  // LOAD DATA FROM LOCAL DATABASE (FAST)
  // ============================================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Ambil user_id dari session
      final prefs = await SharedPreferences.getInstance();
      String? uIdString = prefs.getString(ID_User);
      final userId = int.tryParse(uIdString ?? '');

      if (userId == null) {
        // User belum login, redirect ke login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      setState(() => _userId = userId);

      // Load profile dari local database (FAST - no network)
      final profile = await ProfileServiceLocal.getProfile(userId);

      if (profile != null) {
        // Profile ditemukan
        setState(() {
          _userName =
              profile['nama_lengkap'] ?? prefs.getString(NAMA) ?? 'User';
          _targetCalories = profile['target_kalori_harian'] ?? 2000;
        });
      } else {
        // Profile belum ada, gunakan nama dari session login
        setState(() {
          _userName = prefs.getString(NAMA) ?? 'User';
        });
      }

      // Load kalori hari ini dari local database (FAST - no network)
      final historyResult = await HistoryServiceLocal.getTodayHistory(userId);
      if (historyResult != null) {
        setState(() {
          _currentCalories = historyResult['summary']['total_kalori'] ?? 0;
          _calorieProgress =
              (_currentCalories / _targetCalories).clamp(0.0, 1.0);
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        _sidePadding, 20, _sidePadding, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClickableCalorieCard(
                          context: context,
                          widthFactor: 1.0,
                          height: 180,
                          calorieValue: _currentCalories,
                          targetCalorie: _targetCalories,
                          progress: _calorieProgress,
                          onTap: () {
                            if (_userId == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodHistoryScreen(userId: _userId!),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        const SizedBox(height: 24),
                        // Quick Actions Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildGridItem(
                              icon: Icons.qr_code_scanner,
                              label: 'Scan Barcode',
                              iconColor: Colors.white,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ScanPage()),
                                ).then((_) => _loadData());
                              },
                            ),
                            _buildGridItem(
                              icon: Icons.auto_awesome,
                              label: 'AI Detection',
                              iconColor: Colors.white,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FoodDetectionScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridItem(
                              icon: Icons.person_outline,
                              label: 'Profile',
                              iconColor: Colors.white,
                              onTap: () async {
                                if (_userId == null) return;
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(userId: _userId!),
                                  ),
                                );
                                if (result == true) _loadData();
                              },
                            ),
                            _buildGridItem(
                              icon: Icons.history,
                              label: 'History',
                              iconColor: Colors.white,
                              onTap: () {
                                if (_userId == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodHistoryScreen(userId: _userId!),
                                  ),
                                ).then((_) => _loadData());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildScanButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ModernCard(
        isGlass: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableCalorieCard({
    required BuildContext context,
    required double widthFactor,
    required double height,
    required int calorieValue,
    required int targetCalorie,
    required double progress,
    required VoidCallback onTap,
  }) {
    int remaining = targetCalorie - calorieValue;
    if (remaining < 0) remaining = 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Calories',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$remaining',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'kcal remaining',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$calorieValue / $targetCalorie kcal',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 110,
              height: 110,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        color: AppColors.primary,
                      ),
                      Center(
                        child: Text(
                          '${(value * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            heroTag: 'homeScanButton',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanPage()),
              ).then((_) => _loadData());
            },
            backgroundColor: _scanButtonColor,
            elevation: 8.0,
            shape: const CircleBorder(
              side: BorderSide(color: _brandColorGreen, width: 4),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 27,
              color: _brandColorGreen,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'EATWISE 2026',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ============================================
// FOOD HISTORY SCREEN
// ============================================
class FoodHistoryScreen extends StatefulWidget {
  final int userId;

  const FoodHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _historyItems = [];
  int _totalKalori = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final result = await HistoryServiceLocal.getTodayHistory(widget.userId);
      if (result != null) {
        setState(() {
          _historyItems = result['data'] ?? [];
          _totalKalori = result['summary']['total_kalori'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _historyItems.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'No history yet',
                  description: 'Start tracking your meals to see them here!',
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _historyItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ModernCard(
                            color: AppColors.primary,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.local_fire_department,
                                      color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Calories Today',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_totalKalori kcal',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final item = _historyItems[index - 1];
                      return _buildHistoryItem(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryItem(dynamic item) {
    final String? imagePath = item['image_path'];
    final bool isLocalPath = imagePath != null &&
        (imagePath.startsWith('/') || imagePath.contains('cache'));
    final bool hasValidImage = imagePath != null && imagePath.isNotEmpty;
    String timeStr = 'Today';
    if (item['created_at'] != null) {
      try {
        DateTime dt = DateTime.parse(item['created_at']);
        timeStr = DateFormat('HH:mm').format(dt);
      } catch (_) {}
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ModernCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.primary.withValues(alpha: 0.05),
                child: hasValidImage
                    ? (isLocalPath
                        ? Image.file(File(imagePath), fit: BoxFit.cover)
                        : Image.network(imagePath, fit: BoxFit.cover))
                    : Icon(Icons.fastfood, color: AppColors.primary, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['food_name'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['kalori']} kcal • ${item['serving_size'] ?? '1 serving'}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Item?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to remove this meal from your history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await HistoryServiceLocal.deleteHistoryItem(
        item['id'],
        widget.userId,
      );
      if (success) {
        _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item successfully removed')),
          );
        }
      }
    }
  }
}
