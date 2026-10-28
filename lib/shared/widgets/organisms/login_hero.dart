import 'package:flutter/material.dart';

import '../../login_colors.dart';
import '../atoms/asset_image.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          '$loginAssetDir/FotoKelas.png',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                LoginColors.heroOverlayTop,
                LoginColors.heroOverlayBottom,
              ],
            ),
          ),
        ),
        const SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LocalAssetImage(
                  name: 'LogoSmartClass.svg',
                  width: 176,
                  semanticLabel: 'Logo Smart Class',
                ),
                SizedBox(height: 8),
                Text(
                  'Sistem Monitoring dan\nPengelolaan Kelas Pintar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: LoginColors.text,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
