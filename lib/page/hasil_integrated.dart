import 'package:eatwise2/page/home_integrated.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/services/product_service_fixed.dart';
import 'package:eatwise2/services/profile_service_fixed.dart';
import 'package:eatwise2/util/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';

// Import LogicAlgorithm Anda
class LogicAlgorithm {
  double _hitungBayes(double kemungkinanAwal, double peluangJikaSakit,
      double peluangJikaSehat) {
    double pembilang = peluangJikaSakit * kemungkinanAwal;
    double penyebut = (peluangJikaSakit * kemungkinanAwal) +
        (peluangJikaSehat * (1 - kemungkinanAwal));
    return pembilang / penyebut;
  }

  double _pHipotesis(double kemungkinanAwal, String umurStr, bool adaRiwayat,
      String penyakit) {
    double faktor = 1.0;
    int umur = int.parse(umurStr);
    if (penyakit == "Diabetes") {
      if (umur > 45)
        faktor *= 1.39;
      else if (umur > 31)
        faktor *= 1.24;
      else
        faktor *= 1.09;
      faktor *= adaRiwayat ? 1.7 : 1.0;
    } else if (penyakit == "Kolestrol") {
      if (umur > 45)
        faktor *= 1.36;
      else if (umur > 31)
        faktor *= 1.27;
      else
        faktor *= 1.15;
      faktor *= adaRiwayat ? 1.4 : 1.0;
    } else if (penyakit == "Hipertensi") {
      if (umur > 45)
        faktor *= 1.39;
      else if (umur > 31)
        faktor *= 1.24;
      else
        faktor *= 1.09;
      faktor *= adaRiwayat ? 1.7 : 1.0;
    }
    return (kemungkinanAwal * faktor).clamp(0, 0.9);
  }

  double diabetes(String umur, bool adaRiwayat) {
    double P_Gula_Terhadap_Diabetes = 0.65;
    double P_Gula_Terhadap_Sehat = 0.4;
    double P_Diabetes = _pHipotesis(0.1, umur, adaRiwayat, "Diabetes");
    return _hitungBayes(
        P_Diabetes, P_Gula_Terhadap_Diabetes, P_Gula_Terhadap_Sehat);
  }

  double kolestrol(String umur, bool adaRiwayat) {
    double P_Lemak_Terhadap_Kolestrol = 0.65;
    double P_Lemak_Terhadap_Sehat = 0.4;
    double P_Kolestrol = _pHipotesis(0.1, umur, adaRiwayat, "Kolestrol");
    return _hitungBayes(
        P_Kolestrol, P_Lemak_Terhadap_Kolestrol, P_Lemak_Terhadap_Sehat);
  }

  double hipertensi(String umur, bool adaRiwayat) {
    double P_Garam_Terhadap_Hipertensi = 0.65;
    double P_Garam_Terhadap_Sehat = 0.4;
    double P_Hipertensi = _pHipotesis(0.1, umur, adaRiwayat, "Hipertensi");
    return _hitungBayes(
        P_Hipertensi, P_Garam_Terhadap_Hipertensi, P_Garam_Terhadap_Sehat);
  }
}

class ReportScreenApi extends StatefulWidget {
  final int productId;

  const ReportScreenApi({Key? key, required this.productId}) : super(key: key);

  @override
  State<ReportScreenApi> createState() => _ReportScreenApiState();
}

class _ReportScreenApiState extends State<ReportScreenApi> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _product;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _analysis;
  Map<String, double>? _risikoPersentase; // Tambahkan ini
  int? _userId;

  final LogicAlgorithm _bayesAlgorithm = LogicAlgorithm(); // Instance Bayes

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? uIdString =
          prefs.getString(ID_User); // Pakai constant dari session.dart
      _userId = int.tryParse(uIdString ?? '');

      _product = await ProductService.getProductById(widget.productId);

      if (_userId != null) {
        _profile = await ProfileService.getProfile(_userId!);
      }

      if (_product != null && _profile != null) {
        _analysis = _performClientSideAnalysis(_product!, _profile!);
        _risikoPersentase =
            _calculateBayesRisk(_product!, _profile!); // Hitung risiko Bayes
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk menghitung risiko menggunakan Bayes
  Map<String, double> _calculateBayesRisk(
    Map<String, dynamic> product,
    Map<String, dynamic> profile,
  ) {
    Map<String, double> risiko = {};

    // Ambil data profil
    String umur = (profile['umur'] ?? 25).toString();
    bool riwayatDiabetes = profile['riwayat_diabetes'] == 1;
    bool riwayatKolesterol = profile['riwayat_kolesterol'] == 1;
    bool riwayatHipertensi = profile['riwayat_hipertensi'] == 1;

    // Hitung risiko hanya jika produk memiliki tingkat tinggi
    if (product['tingkat_gula'] == 'tinggi') {
      risiko['Diabetes'] = _bayesAlgorithm.diabetes(umur, riwayatDiabetes);
    }

    if (product['tingkat_lemak'] == 'tinggi') {
      risiko['Kolesterol'] = _bayesAlgorithm.kolestrol(umur, riwayatKolesterol);
    }

    if (product['tingkat_garam'] == 'tinggi') {
      risiko['Hipertensi'] =
          _bayesAlgorithm.hipertensi(umur, riwayatHipertensi);
    }

    return risiko;
  }

  Map<String, dynamic> _performClientSideAnalysis(
    Map<String, dynamic> product,
    Map<String, dynamic> profile,
  ) {
    bool statusAman = true;
    List<String> peringatanAlergi = [];
    List<String> peringatanPenyakit = [];
    List<String> komposisiProduk = [];

    // Parsing komposisi
    if (product['komposisi_array'] != null) {
      komposisiProduk = List<String>.from(product['komposisi_array']);
    }

    // // --- 1. LOGIKA DETEKSI BAHAN DIHINDARI ---
    String userPantanganInput = profile['bahan_dihindari'] ?? "";
    print('User Pantangan Input: $userPantanganInput');

    List<String> bahanTerlarangDitemukan =
        IngredientChecker.check(komposisiProduk, userPantanganInput);

    if (bahanTerlarangDitemukan.isNotEmpty) {
      statusAman = false;
      // PERUBAHAN DISINI: Format teks agar lebih jelas
      // Contoh Output: "⚠️ MENGANDUNG PANTANGAN: Gula"
      peringatanAlergi
          .add('MENGANDUNG PANTANGAN:\n${bahanTerlarangDitemukan.join(", ")}');
    }

    // --- 2. LOGIKA ALERGI DARI DATABASE (Tetap Sama) ---
    if (profile['alergi_gluten'] == 1 && product['mengandung_gluten'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG GLUTEN');
    }
    if (profile['alergi_kacang'] == 1 && product['mengandung_kacang'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG KACANG');
    }
    if (profile['alergi_telur'] == 1 && product['mengandung_telur'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG TELUR');
    }
    if (profile['alergi_susu'] == 1 && product['mengandung_susu'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG SUSU');
    }

    return {
      'status_aman': statusAman,
      'peringatan_alergi':
          peringatanAlergi, // List ini yang akan ditampilkan di UI
      'peringatan_penyakit': peringatanPenyakit,
      'bahan_terlarang_ditemukan':
          bahanTerlarangDitemukan, // Ini untuk highlight di list komposisi bawah
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingIndicator(message: 'Fetching Product Data...'),
      );
    }
    if (_product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Product Not Found',
          description: 'We couldn\'t find details for this product.',
        ),
      );
    }

    List<String> composition = [];
    if (_product!['komposisi_array'] != null) {
      composition = List<String>.from(_product!['komposisi_array']);
    } else if (_product!['komposisi_bahan'] != null) {
      try {
        composition = List<String>.from((jsonDecode(_product!['komposisi_bahan']) as List));
      } catch (e) {
        composition = [_product!['komposisi_bahan']];
      }
    }

    final bool isGood = _analysis?['status_aman'] ?? true;
    final Color statusColor = isGood ? AppColors.primary : AppColors.accent;
    final IconData statusIcon = isGood ? Icons.verified_user_rounded : Icons.warning_rounded;
    final String statusText = isGood ? 'SAFE TO CONSUME' : 'POTENTIAL RISK';

    final int currentCalories = _profile?['kalori_terkonsumsi_hari_ini'] ?? 0;
    final int targetCalories = _profile?['target_kalori_harian'] ?? 2000;
    final int productCalories = _product!['kalori'] ?? 0;
    final int futureCalories = currentCalories + productCalories;
    double calorieProgress = (futureCalories / targetCalories).clamp(0.0, 1.0);
    String caloriePercentage = (calorieProgress * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_product!['image_url'] != null && _product!['image_url'].toString().isNotEmpty)
                        Image.network(_product!['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight))
                      else
                        Container(color: AppColors.primaryLight, child: Icon(Icons.fastfood, size: 80, color: AppColors.primary.withValues(alpha: 0.3))),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(statusText, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text((_product!['nama_produk'] ?? 'Unknown').toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)])),
                            if (_product!['merek'] != null) Text(_product!['merek'], style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_risikoPersentase != null && _risikoPersentase!.isNotEmpty) ...[
                      const SectionHeader(title: 'Bayes Risk Analysis'),
                      _buildRisikoSection(_risikoPersentase!),
                      const SizedBox(height: 24),
                    ],
                    if (_analysis != null && _analysis!['bahan_terlarang_ditemukan'].isNotEmpty) ...[
                      const SectionHeader(title: 'Safety Alerts'),
                      _buildAlertCard(_analysis!['peringatan_alergi']),
                      const SizedBox(height: 24),
                    ],
                    const SectionHeader(title: 'Ingredients'),
                    _buildCompositionCard(composition),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Nutritional Info'),
                    _buildNutritionInfoCard(),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Impact on Daily Goal'),
                    _buildDailyImpactCard(futureCalories, targetCalories, calorieProgress, caloriePercentage, statusColor),
                    const SizedBox(height: 120),
                  ]),
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
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: GradientButton(
                  text: 'Log Consumption',
                  onPressed: _handleAddConsumption,
                  isLoading: _isSaving,
                  icon: Icons.add_circle_outline_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget baru untuk menampilkan risiko Bayes
  Widget _buildRisikoSection(Map<String, double> risiko) {
    return ModernCard(
      color: Colors.purple.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: risiko.entries.map((entry) {
          final persentase = entry.value;
          Color itemColor = persentase < 0.3 ? AppColors.primary : (persentase < 0.6 ? AppColors.accent : AppColors.error);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('${(persentase * 100).toStringAsFixed(1)}%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: itemColor)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: persentase, minHeight: 8, color: itemColor, backgroundColor: itemColor.withValues(alpha: 0.1)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAlertCard(List<dynamic> warnings) {
    return ModernCard(
      color: AppColors.error.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: warnings.map((w) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(w.toString(), style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 14))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCompositionCard(List<String> composition) {
    return ModernCard(
      child: Column(
        children: composition.map((item) {
          List<String> detectedDangers = List<String>.from(_analysis!['bahan_terlarang_ditemukan'] ?? []);
          bool isDangerous = detectedDangers.any((danger) => item.toLowerCase().contains(danger.toLowerCase()));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(isDangerous ? Icons.cancel_rounded : Icons.check_circle_rounded, color: isDangerous ? AppColors.error : AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: GoogleFonts.inter(fontSize: 15, fontWeight: isDangerous ? FontWeight.w700 : FontWeight.w400, color: isDangerous ? AppColors.error : AppColors.textPrimary))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionInfoCard() {
    return ModernCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutriItem('Cal', _product!['kalori'].toString(), Colors.orange),
          _buildNutriItem('Protein', _product!['protein'].toString(), Colors.blue),
          _buildNutriItem('Carbs', _product!['karbohidrat'].toString(), Colors.green),
          _buildNutriItem('Fat', _product!['lemak_total'].toString(), Colors.amber),
        ],
      ),
    );
  }

  Widget _buildNutriItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(width: 20, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildDailyImpactCard(int future, int target, double progress, String percent, Color color) {
    return ModernCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$future / $target kcal', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('$percent%', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 10, color: color, backgroundColor: color.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  // Ubah parameternya

  Future<void> _handleAddConsumption() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    print('🔹 Starting add consumption...');
    print('   User ID: $_userId');
    print('   Product ID: ${widget.productId}');

    setState(() => _isSaving = true);

    try {
      final result = await ProductService.analyzeAndSaveConsumption(
        userId: _userId!,
        productId: widget.productId,
        jumlahPorsi: 1.0,
      );

      print('🔹 Result received: $result');

      if (result != null) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('✅ Berhasil!',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: Colors.green)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Konsumsi berhasil ditambahkan!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text('Kalori: +${result['kalori_dikonsumsi']} kal',
                    style: GoogleFonts.inter(fontSize: 14)),
                Text('Total Hari Ini: ${result['total_kalori_hari_ini']} kal',
                    style: GoogleFonts.inter(fontSize: 14)),
                Text('Progress: ${result['persentase_kalori']}%',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.blue)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeContent()),
                    (route) => false,
                  );
                },
                child: Text('Lihat Riwayat',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Response null - API mungkin gagal');
      }
    } catch (e, stackTrace) {
      print('❌ Error in _handleAddConsumption: $e');
      print('   Stack trace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan konsumsi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class IngredientChecker {
  // Input:
  // productIngredients = ["Susu Segar", "Vitamin D"]
  // userAvoidInput = "susu, gula"
  static List<String> check(
      List<String> productIngredients, String userAvoidInput) {
    // 1. Validasi awal
    if (userAvoidInput.isEmpty) return [];

    // 2. Pecah String input user menjadi List kata kunci
    // "susu, gula" -> ["susu", "gula"]
    List<String> userKeywords = userAvoidInput
        .split(',')
        .map((e) => e.trim().toLowerCase()) // Hapus spasi & kecilkan huruf
        .where((e) => e.isNotEmpty) // Hapus input kosong (misal "susu,,gula")
        .toList();

    List<String> detectedIngredients = [];

    // 3. Loop setiap bahan di produk
    for (var ingredient in productIngredients) {
      String item = ingredient.toLowerCase();

      // 4. Cek apakah bahan ini mengandung SALAH SATU dari keyword user
      for (var keyword in userKeywords) {
        if (item.contains(keyword)) {
          detectedIngredients.add(ingredient); // Simpan nama asli bahannya
          break; // Lanjut ke bahan berikutnya agar tidak duplikat
        }
      }
    }

    return detectedIngredients;
  }
}
