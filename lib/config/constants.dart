import 'package:flutter/material.dart';

class AppConstants {
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Color(0xFFF59E0B)},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Color(0xFF3B82F6)},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Color(0xFFEC4899)},
    {'name': 'Bills', 'icon': Icons.electric_bolt, 'color': Color(0xFF8B5CF6)},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Color(0xFFF97316)},
    {'name': 'Health', 'icon': Icons.favorite, 'color': Color(0xFFEF4444)},
    {'name': 'Others', 'icon': Icons.category, 'color': Color(0xFF6B7280)},
  ];

  static const String firestoreCollection = 'expenses';
}
