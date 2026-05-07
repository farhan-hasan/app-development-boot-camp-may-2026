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
      'emoji': '⚡',
      'title': 'Log in Seconds',
      'description': 'Add expenses faster than ever. Simple, focused forms with smart keyboard navigation.',
      'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
      'accent': Color(0xFF06B6D4),
    },
    {
      'emoji': '📦',
      'title': 'Group Your Purchases',
      'description': 'Bundle related items together. Track groceries, shopping trips, or bills as one list with individual breakdowns.',
      'gradient': [Color(0xFFA855F7), Color(0xFF9333EA)],
      'accent': Color(0xFFA855F7),
    },
    {
      'emoji': '📊',
      'title': 'Visualize Patterns',
      'description': 'Interactive pie charts and category breakdown. Tap any segment to drill down into specific spending categories and transactions.',
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      'accent': Color(0xFF8B5CF6),
    },
    {
      'emoji': '✨',
      'title': 'Customize Your Way',
      'description': 'Create custom categories with emojis, search expenses, filter by category, choose from 5 currencies, and toggle dark mode. Your expense tracker, your rules.',
      'gradient': [Color(0xFFEC4899), Color(0xFFBE185D)],
      'accent': Color(0xFFEC4899),
    },
    {
      'emoji': '☁️',
      'title': 'Your Data, Secure',
      'description': 'All expenses synced to the cloud with Firebase. Your financial data is always backed up and accessible from any device.',
      'gradient': [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      'accent': Color(0xFF0EA5E9),
    },
  ];
}
