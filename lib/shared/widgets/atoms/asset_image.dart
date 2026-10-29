import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../login_colors.dart';

const loginAssetDir = 'assets/asset_login_page';
const berandaAssetDir = 'assets/asset_beranda_page';
const manageRoomAssetDir = 'assets/asset_manage_room';
const scheduleAssetDir = 'assets/asset_schedule_page';

class LocalAssetImage extends StatelessWidget {
  const LocalAssetImage({
    super.key,
    required this.name,
    this.directory = loginAssetDir,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String name;
  final String directory;
  final double? width;
  final double? height;
  final String? semanticLabel;

  static final Map<String, Future<Uint8List?>> _pngCache =
      {};

  static Future<Uint8List?> _embeddedPng(String asset) {
    return _pngCache.putIfAbsent(asset, () async {
      final raw = await rootBundle.loadString(asset);
      const marker = 'data:image/png;base64,';
      final start = raw.indexOf(marker);
      if (start < 0) {
        return null;
      }
      final from = start + marker.length;
      final end = raw.indexOf('"', from);
      if (end < 0) {
        return null;
      }
      return base64Decode(raw.substring(from, end));
    });
  }

  @override
  Widget build(BuildContext context) {
    final asset = '$directory/$name';
    return FutureBuilder<Uint8List?>(
      future: _embeddedPng(asset),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            name,
            style: const TextStyle(
              color: LoginColors.error,
              fontSize: 10,
            ),
          );
        }
        final bytes = snapshot.data;
        if (bytes != null) {
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.contain,
            semanticLabel: semanticLabel,
            gaplessPlayback: true,
          );
        }
        if (snapshot.connectionState !=
            ConnectionState.done) {
          return SizedBox(width: width, height: height);
        }
        return SvgPicture.asset(
          asset,
          width: width,
          height: height,
          fit: BoxFit.contain,
          semanticsLabel: semanticLabel,
        );
      },
    );
  }
}
