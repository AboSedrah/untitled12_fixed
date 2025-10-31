// lib/core/navigation.dart
import 'package:flutter/material.dart';

/// مفتاح ملاحة عام لفتح الشاشات من أي مكان (خارج الـ BuildContext)
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
