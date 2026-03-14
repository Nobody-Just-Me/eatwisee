import 'dart:io';
import 'package:image/image.dart' as img;

/// Simple color-based food detector (fallback when AI model is not accurate)
class ColorBasedDetector {
  
  /// Detect food based on dominant colors
  static Future<Map<String, dynamic>> detectByColor(String imagePath) async {
    try {
      // Read image
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return {'success': false, 'error': 'Cannot read image'};
      }
      
      // Resize for faster processing
      final resized = img.copyResize(image, width: 100, height: 100);
      
      // Calculate average color
      int totalR = 0, totalG = 0, totalB = 0;
      int pixelCount = 0;
      
      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final pixel = resized.getPixel(x, y);
          totalR += pixel.r.toInt();
          totalG += pixel.g.toInt();
          totalB += pixel.b.toInt();
          pixelCount++;
        }
      }
      
      final avgR = totalR / pixelCount;
      final avgG = totalG / pixelCount;
      final avgB = totalB / pixelCount;
      
      // Detect food based on color
      final detectedFood = _detectFoodFromColor(avgR, avgG, avgB);
      
      return {
        'success': true,
        'predicted_class': detectedFood['name'],
        'confidence': detectedFood['confidence'],
        'method': 'color_based',
        'color': {
          'r': avgR.toInt(),
          'g': avgG.toInt(),
          'b': avgB.toInt(),
        }
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  /// Map color to food with improved accuracy
  static Map<String, dynamic> _detectFoodFromColor(double r, double g, double b) {
    // Calculate color properties
    final brightness = (r + g + b) / 3;
    final saturation = _calculateSaturation(r, g, b);
    
    // Very Dark Brown/Black (Rawon, Kopi)
    if (brightness < 80 && r < 100 && g < 90 && b < 80) {
      return {'name': 'Rawon', 'confidence': 0.70};
    }
    
    // Dark Brown (Rendang, Gulai Kambing)
    if (brightness < 120 && r > g && r > b && g > b) {
      if (r - b > 30) {
        return {'name': 'Rendang', 'confidence': 0.68};
      }
    }
    
    // Medium Brown/Orange (Nasi Goreng, Mie Goreng, Ayam Goreng)
    if (r > 140 && g > 90 && b < 100 && r > g && g > b) {
      if (r - g < 50) {
        return {'name': 'Nasi Goreng', 'confidence': 0.65};
      } else {
        return {'name': 'Ayam Goreng', 'confidence': 0.63};
      }
    }
    
    // Golden Yellow (Soto, Opor Ayam, Nasi Kuning)
    if (r > 170 && g > 140 && b < 120 && r > g && g > b) {
      if (brightness > 150) {
        return {'name': 'Nasi Kuning', 'confidence': 0.72};
      } else {
        return {'name': 'Soto', 'confidence': 0.70};
      }
    }
    
    // Light Yellow/Cream (Bubur Ayam, Opor)
    if (r > 180 && g > 170 && b > 140 && brightness > 170) {
      return {'name': 'Bubur Ayam', 'confidence': 0.65};
    }
    
    // Green (Gado-Gado, Sayur Asem, Sayur Lodeh, Capcay)
    if (g > r && g > b && g > 110) {
      if (brightness > 140) {
        return {'name': 'Gado-Gado', 'confidence': 0.68};
      } else {
        return {'name': 'Sayur Asem', 'confidence': 0.65};
      }
    }
    
    // White/Very Light (Nasi Putih, Lontong, Ketoprak)
    if (brightness > 200 && r > 190 && g > 190 && b > 190) {
      return {'name': 'Nasi Putih', 'confidence': 0.70};
    }
    
    // Light Brown/Beige (Sate, Pecel, Ketoprak)
    if (r > 150 && g > 130 && b > 100 && brightness > 140) {
      return {'name': 'Sate', 'confidence': 0.62};
    }
    
    // Red/Orange (Pizza, Rendang, Sambal)
    if (r > 160 && r > g && r > b && g < 130) {
      if (brightness < 120) {
        return {'name': 'Rendang', 'confidence': 0.60};
      } else {
        return {'name': 'Pizza', 'confidence': 0.58};
      }
    }
    
    // Yellow-Orange (French Fries, Pisang Goreng, Tempe Goreng)
    if (r > 180 && g > 140 && b < 100 && r - b > 80) {
      return {'name': 'French Fries', 'confidence': 0.65};
    }
    
    // Brown with high saturation (Ayam Bakar, Ikan Bakar)
    if (r > 120 && g > 80 && b < 80 && saturation > 0.3) {
      return {'name': 'Ayam Bakar', 'confidence': 0.63};
    }
    
    // Gray/Brown (Bakso, Sop Buntut)
    if (brightness > 100 && brightness < 160 && saturation < 0.2) {
      return {'name': 'Bakso', 'confidence': 0.60};
    }
    
    // Default: low confidence, suggest manual selection
    return {'name': 'Nasi Goreng', 'confidence': 0.35};
  }
  
  /// Calculate color saturation
  static double _calculateSaturation(double r, double g, double b) {
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    
    if (max == 0) return 0;
    return (max - min) / max;
  }
}
