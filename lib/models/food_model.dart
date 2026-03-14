import 'dart:convert';

/// Food model representing Indonesian food items with complete nutrition data
class FoodModel {
  final int? id;
  final String name;
  final String description;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String servingSize;
  final String healthBenefits;
  final String ingredients;
  final String preparationTime;
  final String tips;
  final String allergens;
  final String recommendedFor;
  final String? imageUrl;
  final Map<String, dynamic>?
      nutritionBreakdown; // Detail breakdown nutrisi per sumber

  FoodModel({
    this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servingSize,
    required this.healthBenefits,
    required this.ingredients,
    required this.preparationTime,
    required this.tips,
    required this.allergens,
    required this.recommendedFor,
    this.imageUrl,
    this.nutritionBreakdown,
  });

  /// Convert FoodModel to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'serving_size': servingSize,
      'health_benefits': healthBenefits,
      'ingredients': ingredients,
      'preparation_time': preparationTime,
      'tips': tips,
      'allergens': allergens,
      'recommended_for': recommendedFor,
      'image_url': imageUrl,
      'nutrition_breakdown':
          nutritionBreakdown != null ? jsonEncode(nutritionBreakdown) : null,
    };
  }

  /// Helper untuk decode JSON string di nutrition_breakdown
  static Map<String, dynamic>? _decodeNutritionBreakdown(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Create FoodModel from Map (database query result)
  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      calories: map['calories'] as int,
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      fiber: (map['fiber'] as num).toDouble(),
      servingSize: map['serving_size'] as String,
      healthBenefits: map['health_benefits'] as String,
      ingredients: map['ingredients'] as String,
      preparationTime: map['preparation_time'] as String,
      tips: map['tips'] as String,
      allergens: map['allergens'] as String,
      recommendedFor: map['recommended_for'] as String,
      imageUrl: map['image_url'] as String?,
      nutritionBreakdown: _decodeNutritionBreakdown(map['nutrition_breakdown']),
    );
  }

  /// Convert FoodModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'serving_size': servingSize,
      'health_benefits': healthBenefits,
      'ingredients': ingredients,
      'preparation_time': preparationTime,
      'tips': tips,
      'allergens': allergens,
      'recommended_for': recommendedFor,
      'image_url': imageUrl,
      'nutrition_breakdown': nutritionBreakdown,
    };
  }

  /// Create FoodModel from JSON
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      servingSize: json['serving_size'] as String,
      healthBenefits: json['health_benefits'] as String,
      ingredients: json['ingredients'] as String,
      preparationTime: json['preparation_time'] as String,
      tips: json['tips'] as String,
      allergens: json['allergens'] as String,
      recommendedFor: json['recommended_for'] as String,
      imageUrl: json['image_url'] as String?,
      nutritionBreakdown: json['nutrition_breakdown'] as Map<String, dynamic>?,
    );
  }

  /// Calculate total macronutrients
  double get totalMacros => protein + carbs + fat;

  /// Get protein percentage
  double get proteinPercentage => (protein * 4 / calories * 100);

  /// Get carbs percentage
  double get carbsPercentage => (carbs * 4 / calories * 100);

  /// Get fat percentage
  double get fatPercentage => (fat * 9 / calories * 100);

  /// Check if food is high protein (>20% calories from protein)
  bool get isHighProtein => proteinPercentage > 20;

  /// Check if food is low carb (<40% calories from carbs)
  bool get isLowCarb => carbsPercentage < 40;

  /// Check if food is low fat (<30% calories from fat)
  bool get isLowFat => fatPercentage < 30;

  @override
  String toString() {
    return 'FoodModel(name: $name, calories: $calories, protein: ${protein}g, carbs: ${carbs}g, fat: ${fat}g)';
  }

  /// Create a copy with modified fields
  FoodModel copyWith({
    int? id,
    String? name,
    String? description,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    String? servingSize,
    String? healthBenefits,
    String? ingredients,
    String? preparationTime,
    String? tips,
    String? allergens,
    String? recommendedFor,
    String? imageUrl,
    Map<String, dynamic>? nutritionBreakdown,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      servingSize: servingSize ?? this.servingSize,
      healthBenefits: healthBenefits ?? this.healthBenefits,
      ingredients: ingredients ?? this.ingredients,
      preparationTime: preparationTime ?? this.preparationTime,
      tips: tips ?? this.tips,
      allergens: allergens ?? this.allergens,
      recommendedFor: recommendedFor ?? this.recommendedFor,
      imageUrl: imageUrl ?? this.imageUrl,
      nutritionBreakdown: nutritionBreakdown ?? this.nutritionBreakdown,
    );
  }
}
