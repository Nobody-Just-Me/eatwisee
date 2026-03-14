import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// Import halaman hasil dan service
import 'package:eatwise2/page/hasil_integrated.dart';
import 'package:eatwise2/services/product_service_fixed.dart';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedCode;
  bool _isTorchOn = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Scan Product',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              setState(() => _isTorchOn = !_isTorchOn);
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isProcessing) {
                for (final barcode in capture.barcodes) {
                  if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
                    _handleBarcodeDetected(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: ScannerOverlay(animationValue: _animation.value),
                child: Container(),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 24,
            right: 24,
            child: ModernCard(
              isGlass: true,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Align barcode within the frame to scan',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                GradientButton(
                  text: 'Upload from Gallery',
                  onPressed: _pickImageFromGallery,
                  height: 56,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _showManualInputDialog,
                  icon: const Icon(Icons.keyboard_outlined, color: Colors.white),
                  label: Text(
                    'Enter Barcode Manually',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing) const LoadingIndicator(),
        ],
      ),
    );
  }

  // ============================================
  // HANDLE BARCODE DETECTED
  // ============================================
  void _handleBarcodeDetected(String barcode) async {
    setState(() {
      _isProcessing = true;
      _lastScannedCode = barcode;
    });

    // Stop scanner sementara
    await cameraController.stop();

    // Fetch product dari API
    await _fetchProductAndNavigate(barcode);

    setState(() {
      _isProcessing = false;
    });
  }

  // ============================================
  // FETCH PRODUCT & NAVIGATE
  // ============================================
  Future<void> _fetchProductAndNavigate(String barcode) async {
    try {
      // Fetch product dari API
      final product = await ProductService.getProductByBarcode(barcode);

      // Sementara pakai delay untuk simulasi
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Navigate ke halaman hasil
      print("Navigating to ReportScreenApi with product: $product");
      int idProduct = product != null ? product['id'] as int : 0;
      if (product != null) {
        print("Product found: $product");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreenApi(productId: idProduct),
          ),
        );
      } else {
        _showProductNotFoundDialog(barcode);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Gagal memuat data produk: $e');
    }
  }

  // ============================================
  // PICK IMAGE FROM GALLERY - UNTUK SCAN BARCODE
  // ============================================
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Ambil gambar dari galeri
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // High quality untuk scan barcode
      );

      if (image == null) return; // User cancelled

      if (!mounted) return;

      // Coba scan barcode dari gambar
      setState(() => _isProcessing = true);

      // Stop camera sementara
      await cameraController.stop();

      // Scan barcode dari gambar menggunakan mobile_scanner
      final barcodeCapture = await cameraController.analyzeImage(image.path);

      if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
        final barcode = barcodeCapture.barcodes.first;
        if (barcode.rawValue != null) {
          await _fetchProductAndNavigate(barcode.rawValue!);
        } else {
          _showNoBarcodeFoundDialog();
        }
      } else {
        _showNoBarcodeFoundDialog();
      }

      setState(() => _isProcessing = false);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      _showErrorDialog('Gagal memproses gambar: $e');
      cameraController.start();
    }
  }

  // ============================================
  // SHOW NO BARCODE FOUND DIALOG
  // ============================================
  void _showNoBarcodeFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('No Barcode Found', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: const Text('We couldn\'t detect a barcode in that image. Please try again with a clearer photo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MANUAL INPUT DIALOG
  // ============================================
  void _showManualInputDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Manual Input', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernInput(
              label: 'Barcode Number',
              hint: 'e.g. 8992761111111',
              controller: controller,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _handleBarcodeDetected(controller.text);
              }
            },
            child: const Text('Find Product'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SHOW ERROR DIALOG
  // ============================================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.error)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SHOW PRODUCT NOT FOUND DIALOG
  // ============================================
  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Product Not Found', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Barcode "$barcode" was not found in our database.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Manual entry page
            },
            child: const Text('Add Manually'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CUSTOM PAINTER: SCANNER OVERLAY
// ============================================
class ScannerOverlay extends CustomPainter {
  final double animationValue;
  ScannerOverlay({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(24)))
        ..fillType = PathFillType.evenOdd,
      backgroundPaint,
    );

    // Frame corners
    final Paint framePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double cornerLength = 40;
    final double radius = 24; // Matching the cutout radius

    // Top-left corner
    canvas.drawPath(Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + radius)
      ..arcToPoint(Offset(left + radius, top), radius: Radius.circular(radius))
      ..lineTo(left + cornerLength, top), framePaint);

    // Top-right corner
    canvas.drawPath(Path()
      ..moveTo(left + scanAreaSize - cornerLength, top)
      ..lineTo(left + scanAreaSize - radius, top)
      ..arcToPoint(Offset(left + scanAreaSize, top + radius), radius: Radius.circular(radius))
      ..lineTo(left + scanAreaSize, top + cornerLength), framePaint);

    // Bottom-left corner
    canvas.drawPath(Path()
      ..moveTo(left, top + scanAreaSize - cornerLength)
      ..lineTo(left, top + scanAreaSize - radius)
      ..arcToPoint(Offset(left + radius, top + scanAreaSize), radius: Radius.circular(radius), clockwise: false)
      ..lineTo(left + cornerLength, top + scanAreaSize), framePaint);

    // Bottom-right corner
    canvas.drawPath(Path()
      ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
      ..lineTo(left + scanAreaSize - radius, top + scanAreaSize)
      ..arcToPoint(Offset(left + scanAreaSize, top + scanAreaSize - radius), radius: Radius.circular(radius), clockwise: false)
      ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength), framePaint);

    // Animated Scanning Line
    final Paint linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0),
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(left, top + (scanAreaSize * animationValue), scanAreaSize, 2))
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(left + 10, top + (scanAreaSize * animationValue)),
      Offset(left + scanAreaSize - 10, top + (scanAreaSize * animationValue)),
      linePaint..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) => oldDelegate.animationValue != animationValue;
}
