import 'package:flutter/material.dart';

import '../../login_colors.dart';
import '../atoms/asset_image.dart';

class RegistrationPrompt extends StatelessWidget {
  const RegistrationPrompt({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoginColors.registerCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              LocalAssetImage(
                name: 'Add User Male.svg',
                height: 28,
                semanticLabel: 'Daftar petugas',
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: TextStyle(
                        color: LoginColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Daftar sebagai petugas',
                      style: TextStyle(
                        color: LoginColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              LocalAssetImage(
                name: 'Arrow.svg',
                height: 16,
                semanticLabel: 'Daftar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
