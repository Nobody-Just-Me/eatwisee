import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';
import 'package:eatwise2/services/profile_service_fixed.dart';
import 'package:eatwise2/services/notification_service.dart';
import 'package:eatwise2/util/util.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;

  // --- STATE DATA FISIK ---
  DateTime? _tanggalLahir; // Ganti dari String _usia
  int _usia = 0; // Computed dari tanggal lahir
  String _berat = "65.5";
  String _tinggi = "175";
  String _username = "User";

  // --- State Checkbox Riwayat Kesehatan (Tambah Hipertensi) ---
  bool _diabetesChecked = false;
  bool _kolesterolChecked = false;
  bool _hipertensiChecked = false; // BARU

  // --- STATE BARU: Bahan yang Dihindari (Gunakan TextField) ---
  final TextEditingController _bahanDihindariController =
      TextEditingController();
  List<String> _bahanDihindariList = []; // List bahan yang sudah dinormalisasi

  // --- STATE NOTIFIKASI MAKAN ---
  bool _notifSarapan = true;
  TimeOfDay _waktuSarapan = const TimeOfDay(hour: 7, minute: 0);
  bool _notifSiang = true;
  TimeOfDay _waktuSiang = const TimeOfDay(hour: 12, minute: 30);
  bool _notifMalam = true;
  TimeOfDay _waktuMalam = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _requestNotificationPermissions();
  }

  // Request notification permissions di Android 13+
  Future<void> _requestNotificationPermissions() async {
    try {
      final enabled = await NotificationService.areNotificationsEnabled();
      if (!enabled) {
        print('⚠️ Notifications are disabled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '⚠️ Mohon aktifkan izin notifikasi di Settings untuk menerima pengingat makan'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        print('✅ Notifications are enabled');
      }
    } catch (e) {
      print('Error checking notification permission: $e');
    }
  }

  @override
  void dispose() {
    _bahanDihindariController.dispose();
    super.dispose();
  }

  // Safe setState wrappers
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profile = await ProfileService.getProfile(widget.userId);

      if (!mounted) return; // Check again after async operation

      if (profile != null) {
        setState(() {
          // Load tanggal lahir dan hitung umur
          _tanggalLahir =
              ProfileService.parseBirthDate(profile['tanggal_lahir']);
          if (_tanggalLahir != null) {
            _usia = ProfileService.calculateAge(_tanggalLahir!);
          }

          _berat = profile['berat_badan']?.toString() ?? "65.5";
          _tinggi = profile['tinggi_badan']?.toString() ?? "175";
          _diabetesChecked = profile['riwayat_diabetes'] == 1;
          _kolesterolChecked = profile['riwayat_kolesterol'] == 1;
          _hipertensiChecked = profile['riwayat_hipertensi'] == 1; // BARU
          _username = profile['nama_lengkap']?.toString() ?? "User";

          // Load bahan yang dihindari
          if (profile['bahan_dihindari'] != null &&
              profile['bahan_dihindari'].isNotEmpty) {
            _bahanDihindariList =
                _normalizeBahanList(profile['bahan_dihindari']);
            _bahanDihindariController.text = _bahanDihindariList.join(', ');
          }

          // Load waktu notifikasi jika ada
          if (profile['waktu_sarapan'] != null) {
            _waktuSarapan = _parseTimeString(profile['waktu_sarapan']);
          }
          if (profile['waktu_siang'] != null) {
            _waktuSiang = _parseTimeString(profile['waktu_siang']);
          }
          if (profile['waktu_malam'] != null) {
            _waktuMalam = _parseTimeString(profile['waktu_malam']);
          }

          _notifSarapan = profile['notif_sarapan_aktif'] == 1;
          _notifSiang = profile['notif_siang_aktif'] == 1;
          _notifMalam = profile['notif_malam_aktif'] == 1;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper untuk parse string waktu "HH:mm:ss" ke TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      print("⚠️ DEBUG: Gagal parse waktu '$timeString', gunakan default");
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  // Normalisasi list bahan (lowercase, trim, remove duplicates)
  List<String> _normalizeBahanList(String input) {
    if (input.trim().isEmpty) return [];

    return input
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet() // Remove duplicates
        .toList();
  }

  // Fungsi untuk cek apakah bahan ada dalam list (case insensitive)
  bool _isBahanDihindari(String bahan, List<String> bahanList) {
    String normalizedBahan = bahan.trim().toLowerCase();
    return bahanList.any((item) =>
        item.contains(normalizedBahan) || normalizedBahan.contains(item));
  }

  Future<void> _handleSave() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Normalisasi input bahan yang dihindari
      _bahanDihindariList = _normalizeBahanList(_bahanDihindariController.text);

      final profileData = {
        'nama_lengkap': _username,
        'tanggal_lahir': _tanggalLahir
            ?.toIso8601String()
            .split('T')[0], // Format: YYYY-MM-DD
        'berat_badan': double.tryParse(_berat),
        'tinggi_badan': double.tryParse(_tinggi),
        'riwayat_diabetes': _diabetesChecked ? 1 : 0,
        'riwayat_kolesterol': _kolesterolChecked ? 1 : 0,
        'riwayat_hipertensi': _hipertensiChecked ? 1 : 0, // BARU
        'bahan_dihindari': _bahanDihindariList.join(','), // Simpan sebagai CSV
        'waktu_sarapan': ProfileService.timeOfDayToString(
            _waktuSarapan.hour, _waktuSarapan.minute),
        'waktu_siang': ProfileService.timeOfDayToString(
            _waktuSiang.hour, _waktuSiang.minute),
        'waktu_malam': ProfileService.timeOfDayToString(
            _waktuMalam.hour, _waktuMalam.minute),
        'notif_sarapan_aktif': _notifSarapan ? 1 : 0,
        'notif_siang_aktif': _notifSiang ? 1 : 0,
        'notif_malam_aktif': _notifMalam ? 1 : 0,
      };

      final success =
          await ProfileService.saveProfile(widget.userId, profileData);

      if (!mounted) return;

      if (success) {
        // Setup notifikasi untuk jadwal makan
        await _setupMealNotifications();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil disimpan!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan profile')),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Setup notifikasi untuk jadwal makan
  Future<void> _setupMealNotifications() async {
    try {
      print('🔔 Setting up meal notifications...');

      // Cancel semua notifikasi lama terlebih dahulu
      await NotificationService.cancelNotification(1); // Sarapan
      await NotificationService.cancelNotification(2); // Makan Siang
      await NotificationService.cancelNotification(3); // Makan Malam

      int scheduledCount = 0;

      // Setup notifikasi baru jika aktif
      if (_notifSarapan) {
        await NotificationService.scheduleMealNotification(
          id: 1,
          title: '🍳 Waktu Sarapan',
          body: 'Jangan lupa sarapan sehat untuk memulai hari!',
          hour: _waktuSarapan.hour,
          minute: _waktuSarapan.minute,
        );
        scheduledCount++;
        print('   ✓ Sarapan: ${_waktuSarapan.hour}:${_waktuSarapan.minute}');
      }

      if (_notifSiang) {
        await NotificationService.scheduleMealNotification(
          id: 2,
          title: '🍱 Waktu Makan Siang',
          body: 'Saatnya makan siang untuk energi sore hari!',
          hour: _waktuSiang.hour,
          minute: _waktuSiang.minute,
        );
        scheduledCount++;
        print('   ✓ Siang: ${_waktuSiang.hour}:${_waktuSiang.minute}');
      }

      if (_notifMalam) {
        await NotificationService.scheduleMealNotification(
          id: 3,
          title: '🍽️ Waktu Makan Malam',
          body: 'Waktunya makan malam. Jangan skip ya!',
          hour: _waktuMalam.hour,
          minute: _waktuMalam.minute,
        );
        scheduledCount++;
        print('   ✓ Malam: ${_waktuMalam.hour}:${_waktuMalam.minute}');
      }

      print(
          '✅ Meal notifications setup complete: $scheduledCount notifications scheduled');

      // Print pending notifications untuk verify
      await NotificationService.printPendingNotifications();

      if (mounted && scheduledCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $scheduledCount pengingat makan telah diatur!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('⚠️ Error setting up notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Gagal mengatur notifikasi: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'User Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingIndicator(message: 'Loading profile...')
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Data Fisik'),
                    ModernCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDateRow(
                            label: "Tanggal Lahir",
                            date: _tanggalLahir,
                            onEdit: () => _showDatePicker(),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.cake_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Usia: $_usia tahun',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildEditableRow(
                            label: "Berat Badan",
                            value: _berat,
                            unit: "kg",
                            onEdit: () => _showEditDialog("Berat Badan", _berat, (val) => _safeSetState(() => _berat = val)),
                          ),
                          const SizedBox(height: 12),
                          _buildEditableRow(
                            label: "Tinggi Badan",
                            value: _tinggi,
                            unit: "cm",
                            onEdit: () => _showEditDialog("Tinggi Badan", _tinggi, (val) => _safeSetState(() => _tinggi = val)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Riwayat Kesehatan'),
                    ModernCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildToggleRow(
                            icon: Icons.monitor_heart_rounded,
                            label: 'Riwayat Diabetes',
                            value: _diabetesChecked,
                            onChanged: (val) => _safeSetState(() => _diabetesChecked = val),
                          ),
                          _buildToggleRow(
                            icon: Icons.opacity_rounded,
                            label: 'Riwayat Kolesterol',
                            value: _kolesterolChecked,
                            onChanged: (val) => _safeSetState(() => _kolesterolChecked = val),
                          ),
                          _buildToggleRow(
                            icon: Icons.speed_rounded,
                            label: 'Riwayat Hipertensi',
                            value: _hipertensiChecked,
                            onChanged: (val) => _safeSetState(() => _hipertensiChecked = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Bahan yang Dihindari'),
                    ModernCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pisahkan dengan koma (,) untuk beberapa bahan',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _bahanDihindariController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Contoh: gluten, kacang, telur, susu',
                              hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Jadwal Makan'),
                    ModernCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildNotificationRow(
                            icon: Icons.breakfast_dining_rounded,
                            label: "Sarapan",
                            isActive: _notifSarapan,
                            time: _waktuSarapan,
                            onSwitchChanged: (val) => _safeSetState(() => _notifSarapan = val),
                            onTimeTap: () => _selectTime(_waktuSarapan, (picked) => _safeSetState(() => _waktuSarapan = picked)),
                          ),
                          _buildNotificationRow(
                            icon: Icons.lunch_dining_rounded,
                            label: "Makan Siang",
                            isActive: _notifSiang,
                            time: _waktuSiang,
                            onSwitchChanged: (val) => _safeSetState(() => _notifSiang = val),
                            onTimeTap: () => _selectTime(_waktuSiang, (picked) => _safeSetState(() => _waktuSiang = picked)),
                          ),
                          _buildNotificationRow(
                            icon: Icons.dinner_dining_rounded,
                            label: "Makan Malam",
                            isActive: _notifMalam,
                            time: _waktuMalam,
                            onSwitchChanged: (val) => _safeSetState(() => _notifMalam = val),
                            onTimeTap: () => _selectTime(_waktuMalam, (picked) => _safeSetState(() => _waktuMalam = picked)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    GradientButton(
                      text: 'Simpan Profile',
                      onPressed: _isLoading ? null : _handleSave,
                      isLoading: _isLoading,
                      icon: Icons.save_rounded,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      label: Text('Logout', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: AppColors.error, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Hi, $_username',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Stay healthy and keep tracking!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow({required String label, required DateTime? date, required VoidCallback onEdit}) {
    String displayText = date != null ? DateFormat('dd MMMM yyyy', 'id_ID').format(date) : 'Belum diisi';
    return _buildRowItem(icon: Icons.calendar_today_rounded, label: label, value: displayText, onEdit: onEdit);
  }

  Widget _buildEditableRow({required String label, required String value, required String unit, required VoidCallback onEdit}) {
    return _buildRowItem(icon: Icons.edit_note_rounded, label: label, value: '$value $unit', onEdit: onEdit);
  }

  Widget _buildRowItem({required IconData icon, required String label, required String value, required VoidCallback onEdit}) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Text(value, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({required IconData icon, required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      secondary: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 20)),
      title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildNotificationRow({required IconData icon, required String label, required bool isActive, required TimeOfDay time, required ValueChanged<bool> onSwitchChanged, required VoidCallback onTimeTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
          InkWell(
            onTap: isActive ? onTimeTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Text(time.format(context), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isActive ? AppColors.primary : AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: isActive, onChanged: onSwitchChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _tanggalLahir ?? DateTime(2000, 1, 1), firstDate: DateTime(1940), lastDate: DateTime.now(), locale: const Locale('id', 'ID'));
    if (picked != null && mounted) { setState(() { _tanggalLahir = picked; _usia = ProfileService.calculateAge(picked); }); }
  }

  Future<void> _selectTime(TimeOfDay initial, Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) onSelected(picked);
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text("Edit $title", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)), content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(hintText: 'Enter $title')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")), ElevatedButton(onPressed: () { if (controller.text.isNotEmpty) onSave(controller.text); Navigator.pop(context); }, child: const Text("Simpan"))]));
  }

  void _showLogoutDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)), content: const Text('Apakah Anda yakin ingin keluar?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), ElevatedButton(onPressed: () { Navigator.pop(context); logOut(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Logout'))]));
  }
}
