import 'package:flutter/material.dart';

import '../../login_colors.dart';
import '../organisms/login_hero.dart';

class LoginTemplate extends StatelessWidget {
  const LoginTemplate({super.key, required this.card});

  final Widget card;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heroHeight = media.viewInsets.bottom > 0
        ? 150.0
        : media.size.height * 0.40;

    return Scaffold(
      backgroundColor: LoginColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: const LoginHero(),
          ),
          Positioned(
            top: heroHeight - 32,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: LoginColors.card,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  24 + media.padding.bottom,
                ),
                child: card,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
