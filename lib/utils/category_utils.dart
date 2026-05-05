import 'package:flutter/material.dart';
import 'package:hisabi/config/constants.dart';

Color getCategoryColor(String category, {List<Map<String, dynamic>> extra = const []}) {
  final all = [...AppConstants.categories, ...extra];
  final match = all.firstWhere((c) => c['name'] == category, orElse: () => AppConstants.categories.last);
  return match['color'] as Color;
}

IconData getCategoryIcon(String category, {List<Map<String, dynamic>> extra = const []}) {
  final all = [...AppConstants.categories, ...extra];
  final match = all.firstWhere((c) => c['name'] == category, orElse: () => AppConstants.categories.last);
  return match['icon'] as IconData;
}

String getCategoryEmoji(String category, {List<Map<String, dynamic>> extra = const []}) {
  final all = [...AppConstants.categories, ...extra];
  final match = all.firstWhere((c) => c['name'] == category, orElse: () => AppConstants.categories.last);
  return match['emoji'] as String;
}
