import 'package:flutter/material.dart';

class AppConstants {
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'emoji': '🍔', 'icon': Icons.restaurant, 'color': Color(0xFFF59E0B)},
    {'name': 'Transport', 'emoji': '🚗', 'icon': Icons.directions_car, 'color': Color(0xFF3B82F6)},
    {'name': 'Shopping', 'emoji': '🛍️', 'icon': Icons.shopping_bag, 'color': Color(0xFFEC4899)},
    {'name': 'Bills', 'emoji': '💡', 'icon': Icons.electric_bolt, 'color': Color(0xFF8B5CF6)},
    {'name': 'Entertainment', 'emoji': '🎬', 'icon': Icons.movie, 'color': Color(0xFFF97316)},
    {'name': 'Health', 'emoji': '🏥', 'icon': Icons.favorite, 'color': Color(0xFFEF4444)},
    {'name': 'Others', 'emoji': '📦', 'icon': Icons.category, 'color': Color(0xFF6B7280)},
  ];

  static const String firestoreCollection = 'expenses';

  static const List<Map<String, String>> currencies = [
    {'symbol': '৳', 'name': 'Bangladeshi Taka'},
    {'symbol': '\$', 'name': 'US Dollar'},
    {'symbol': '€', 'name': 'Euro'},
    {'symbol': '£', 'name': 'British Pound'},
    {'symbol': '₹', 'name': 'Indian Rupee'},
  ];

  static const List<Map<String, dynamic>> onboardingSlides = [
    {
      'emoji': '💰',
      'title': 'Track Every Penny',
      'description': 'Log your daily expenses in seconds. Stay on top of your spending effortlessly.',
      'gradient': [Color(0xFF0D9488), Color(0xFF0F766E)],
      'accent': Color(0xFF0D9488),
    },
    {
      'emoji': '📊',
      'title': 'Visualize Your Spending',
      'description': 'Beautiful charts break down your spending by category so you always know where money goes.',
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      'accent': Color(0xFF8B5CF6),
    },
    {
      'emoji': '🎯',
      'title': 'Spend Smarter',
      'description': 'Monthly insights help you spot patterns and make better financial decisions.',
      'gradient': [Color(0xFFF97316), Color(0xFFEA580C)],
      'accent': Color(0xFFF97316),
    },
  ];
}
