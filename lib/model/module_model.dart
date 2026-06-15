import 'dart:convert';
import 'package:flutter/material.dart';

class ModuleModel {
  final String id;
  final String title;
  final String price;
  final String rating;
  final String installs;
  final String badge;
  final IconData icon;
  final String iconName;
  final List<String> features;
  final String category;
  final String developer;
  final String discountPrice;
  final String originalPrice;
  final String description;

  ModuleModel({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.installs,
    required this.badge,
    required this.icon,
    required this.iconName,
    required this.features,
    required this.category,
    this.developer = 'Stitch Labs',
    this.discountPrice = '₹14,999',
    this.originalPrice = '₹19,999',
    this.description = 'No description provided.',
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    // Parse features list robustly
    List<String> parsedFeatures = [];
    if (json['features'] != null) {
      if (json['features'] is List) {
        parsedFeatures = (json['features'] as List).map((e) => e.toString()).toList();
      } else if (json['features'] is String) {
        try {
          final decoded = jsonDecode(json['features']);
          if (decoded is List) {
            parsedFeatures = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          parsedFeatures = [json['features'].toString()];
        }
      }
    }

    final String iconStr = json['icon']?.toString() ?? 'extension';

    return ModuleModel(
      id: json['id']?.toString() ?? json['module_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '₹0',
      rating: json['rating']?.toString() ?? '5.0',
      installs: json['installs']?.toString() ?? '0 Installs',
      badge: json['badge']?.toString() ?? '',
      icon: _parseIcon(iconStr),
      iconName: iconStr,
      features: parsedFeatures,
      category: json['category']?.toString() ?? '',
      developer: json['developer']?.toString() ?? 'Stitch Labs',
      discountPrice: json['discount_price']?.toString() ?? json['price']?.toString() ?? '₹14,999',
      originalPrice: json['original_price']?.toString() ?? '₹19,999',
      description: json['description']?.toString() ?? json['about']?.toString() ?? 'No description provided.',
    );
  }

  static IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'shopping_cart':
      case 'shopping_bag':
      case 'e-commerce':
      case 'ecommerce':
        return Icons.shopping_cart;
      case 'work':
      case 'jobs':
      case 'job':
        return Icons.work;
      case 'event':
      case 'events':
        return Icons.event;
      case 'extension':
      case 'module':
        return Icons.extension;
      case 'verified':
        return Icons.verified;
      default:
        return Icons.extension;
    }
  }
}
