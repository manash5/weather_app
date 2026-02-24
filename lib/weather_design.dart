import 'dart:ui';

import 'package:flutter/material.dart';

class WeatherDesign {
  static IconData getWeatherIcon(String condition, {bool isNight = false}) {
    switch (condition) {
      case 'Clear':
        return isNight ? Icons.nights_stay : Icons.sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
      case 'Drizzle':
        return Icons.umbrella;
      case 'Snow':
        return Icons.ac_unit;
      case 'Thunderstorm':
        return Icons.flash_on;
      case 'Fog':
      case 'Mist':
      case 'Haze':
        return Icons.blur_on;
      case 'Tornado':
        return Icons.tornado;
      case 'Windy':
        return Icons.air;
      default:
        return Icons.help_outline;
    }
  }

  static Color getWeatherIconColor(String condition, {required bool isNight}) {
    switch (condition) {
      case 'Clear':
        return isNight ? const Color(0xFFFFF59D) : const Color(0xFFFFC107);
      case 'Clouds':
        return const Color(0xFFE3F2FD);
      case 'Rain':
      case 'Drizzle':
        return const Color(0xFF4FC3F7);
      case 'Thunderstorm':
        return const Color(0xFFFFD54F);
      case 'Snow':
        return const Color(0xFFB3E5FC);
      case 'Fog':
      case 'Mist':
      case 'Haze':
        return const Color(0xFFCFD8DC);
      default:
        return Colors.white;
    }
  }

  static bool isNightFromIcon(String iconCode) {
    return iconCode.endsWith('n');
  }

  static Widget buildWeatherBackground(String condition, bool isNight) {
    List<Color> gradientColors;

    switch (condition) {
      case 'Clear':
        gradientColors = isNight
            ? const [Color(0xFF061133), Color(0xFF162A72)]
            : const [Color(0xFF4AA8FF), Color(0xFF8FD3FF), Color(0xFFCFEFFF)];
        break;
      case 'Clouds':
        gradientColors = isNight
            ? const [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF475569)]
            : const [Color(0xFF6B7F99), Color(0xFF9FB1C7), Color(0xFFD6DEE8)];
        break;
      case 'Rain':
      case 'Drizzle':
        gradientColors = const [
          Color(0xFF2C3E50),
          Color(0xFF4A6072),
          Color(0xFF5F7384),
        ];
        break;
      case 'Thunderstorm':
        gradientColors = const [
          Color(0xFF111827),
          Color(0xFF1F2937),
          Color(0xFF374151),
        ];
        break;
      default:
        gradientColors = const [
          Color(0xFF355C7D),
          Color(0xFF6C5B7B),
          Color(0xFFC06C84),
        ];
    }

    final bool isClear = condition == 'Clear';
    final bool isCloudy = condition == 'Clouds';
    final bool isRainy = condition == 'Rain' || condition == 'Drizzle';
    final bool isThunder = condition == 'Thunderstorm';

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
        ),
        if (isClear && !isNight)
          Positioned(
            top: -130,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x66FFF176),
                    Color(0x44FFEE58),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
        if (isClear && !isNight)
          Positioned(
            top: 20,
            right: 30,
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF176),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x88FFEE58),
                    blurRadius: 40,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        if (isCloudy || isRainy || isThunder) ..._buildCloudLayer(),
        if (isRainy || isThunder) ..._buildRainDroplets(),
        if (isThunder) ..._buildLightningLayer(),
      ],
    );
  }

  static Widget glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  static List<Widget> _buildCloudLayer() {
    return [
      Positioned(
        top: 60,
        left: -10,
        child: Icon(
          Icons.cloud,
          size: 160,
          color: const Color(0xFFAEDBFF).withOpacity(0.38),
        ),
      ),
      Positioned(
        top: 105,
        right: -20,
        child: Icon(
          Icons.cloud,
          size: 140,
          color: const Color(0xFFC7E7FF).withOpacity(0.34),
        ),
      ),
      Positioned(
        top: 160,
        left: 120,
        child: Icon(
          Icons.cloud,
          size: 120,
          color: const Color(0xFFD9EEFF).withOpacity(0.3),
        ),
      ),
    ];
  }

  static List<Widget> _buildRainDroplets() {
    final drops = <Map<String, double>>[
      {'top': 190, 'left': 32, 'height': 32},
      {'top': 205, 'left': 78, 'height': 28},
      {'top': 220, 'left': 126, 'height': 36},
      {'top': 188, 'left': 176, 'height': 30},
      {'top': 234, 'left': 228, 'height': 34},
      {'top': 206, 'left': 278, 'height': 30},
      {'top': 222, 'left': 322, 'height': 34},
      {'top': 246, 'left': 372, 'height': 32},
    ];

    return drops
        .map(
          (drop) => Positioned(
            top: drop['top']!,
            left: drop['left']!,
            child: Transform.rotate(
              angle: -0.23,
              child: Container(
                width: 2.8,
                height: drop['height']!,
                decoration: BoxDecoration(
                  color: const Color(0xFF8ED6FF).withOpacity(0.72),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  static List<Widget> _buildLightningLayer() {
    return [
      Positioned(
        top: 138,
        right: 70,
        child: Icon(
          Icons.bolt,
          size: 56,
          color: const Color(0xFFFFF176).withOpacity(0.9),
        ),
      ),
      Positioned(
        top: 208,
        left: 110,
        child: Icon(
          Icons.bolt,
          size: 38,
          color: const Color(0xFFFFD54F).withOpacity(0.86),
        ),
      ),
    ];
  }
}
