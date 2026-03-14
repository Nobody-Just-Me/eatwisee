/// Service untuk mapping 13 AI detections ke 47+ makanan
class FoodMappingService {
  // Mapping dari AI detection ke makanan serupa
  static const Map<String, List<String>> similarFoods = {
    'Nasi Goreng': [
      'Nasi Goreng',
      'Nasi Uduk',
      'Nasi Kuning',
      'Nasi Liwet',
      'Nasi Putih',
    ],
    'Mie Goreng': [
      'Mie Goreng',
      'Mie Ayam',
      'Bakso',
      'Lontong Sayur',
    ],
    'Ayam Goreng': [
      'Ayam Goreng',
      'Ayam Bakar',
      'Opor Ayam',
    ],
    'Rendang': [
      'Rendang',
      'Gulai Kambing',
      'Opor Ayam',
    ],
    'Sate': [
      'Sate',
      'Ayam Bakar',
      'Ayam Goreng',
    ],
    'Ikan Goreng': [
      'Ikan Goreng',
      'Ikan Bakar',
      'Pecel Lele',
    ],
    'Gado-Gado': [
      'Gado-Gado',
      'Pecel',
      'Ketoprak',
      'Capcay',
      'Sayur Asem',
      'Sayur Lodeh',
    ],
    'Soto': [
      'Soto',
      'Rawon',
      'Sop Buntut',
      'Bakso',
      'Bubur Ayam',
    ],
    'Rawon': [
      'Rawon',
      'Soto',
      'Sop Buntut',
      'Bakso',
    ],
    'Nasi Padang': [
      'Nasi Padang',
      'Rendang',
      'Gulai Kambing',
      'Opor Ayam',
    ],
    'Burger': [
      'Burger',
      'Sandwich',
      'Roti Bakar',
    ],
    'Pizza': [
      'Pizza',
      'Martabak Manis',
      'Martabak Telur',
    ],
    'French Fries': [
      'French Fries',
      'Pisang Goreng',
      'Bakwan',
      'Tempe Goreng',
      'Tahu Goreng',
    ],
  };

  static List<String> getSimilarFoods(String detectedFood) {
    return similarFoods[detectedFood] ?? [detectedFood];
  }

  static List<String> getAllFoods() {
    return [
      // Makanan Berat
      'Nasi Goreng',
      'Nasi Padang',
      'Nasi Putih',
      'Nasi Uduk',
      'Nasi Kuning',
      'Nasi Liwet',
      'Mie Goreng',
      'Mie Ayam',
      'Bakso',
      'Bubur Ayam',
      'Gado-Gado',
      'Ketoprak',
      'Lontong Sayur',
      'Gudeg',
      // Lauk Pauk
      'Ayam Goreng',
      'Ayam Bakar',
      'Rendang',
      'Opor Ayam',
      'Gulai Kambing',
      'Sate',
      'Ikan Goreng',
      'Ikan Bakar',
      'Pecel Lele',
      'Tempe Goreng',
      'Tahu Goreng',
      'Telur Dadar',
      'Pecel',
      'Capcay',
      // Makanan Berkuah
      'Soto',
      'Rawon',
      'Sop Buntut',
      'Sayur Asem',
      'Sayur Lodeh',
      // Fast Food
      'Burger',
      'Pizza',
      'French Fries',
      // Snack
      'Pisang Goreng',
      'Bakwan',
      'Pempek',
      'Martabak Telur',
      'Martabak Manis',
      'Risoles',
      'Lumpia',
      'Roti Bakar',
      'Sandwich',
      // Minuman
      'Kopi',
      'Es Teh Manis',
    ];
  }
}
