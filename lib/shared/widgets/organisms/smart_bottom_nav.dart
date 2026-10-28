import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../atoms/asset_image.dart';

class SmartNavItem {
  const SmartNavItem({
    required this.label,
    required this.activeAsset,
    required this.inactiveAsset,
  });

  final String label;
  final String activeAsset;
  final String inactiveAsset;
}

class SmartBottomNav extends StatelessWidget {
  const SmartBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<SmartNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (
                    var index = 0;
                    index < items.length;
                    index++
                  ) ...[
                    if (index > 0) const SizedBox(width: 6),
                    _NavSlot(
                      item: items[index],
                      selected: index == currentIndex,
                      onTap: () => onSelected(index),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final SmartNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final slot = Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 48,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : const Color(0xFF242424),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavIcon(
                asset: selected
                    ? item.activeAsset
                    : item.inactiveAsset,
                label: item.label,
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(
                    milliseconds: 280,
                  ),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: selected ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return slot;
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.label,
  });

  final String asset;
  final String label;

  static final Map<String, Future<double?>>
  _embeddedOpacity = {};

  /// SVG Figma yang hanya membungkus PNG tidak tergambar oleh
  /// SvgPicture. Opasitas dikembalikan hanya untuk kasus itu.
  static Future<double?> _readEmbeddedOpacity(
    String asset,
  ) {
    return _embeddedOpacity.putIfAbsent(asset, () async {
      final raw = await rootBundle.loadString(asset);
      if (!raw.contains('data:image/png;base64,')) {
        return null;
      }
      final match = RegExp(r'fill-opacity="([0-9.]+)"')
          .firstMatch(raw);
      if (match == null) {
        return 1;
      }
      return double.tryParse(match.group(1)!) ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    if (asset.endsWith('.png')) {
      return Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        semanticLabel: label,
      );
    }

    final slash = asset.lastIndexOf('/');
    final image = LocalAssetImage(
      directory: asset.substring(0, slash),
      name: asset.substring(slash + 1),
      width: size,
      height: size,
      semanticLabel: label,
    );
    return FutureBuilder<double?>(
      future: _readEmbeddedOpacity(asset),
      builder: (context, snapshot) {
        final opacity = snapshot.data;
        if (opacity == null || opacity >= 1) {
          return image;
        }
        return Opacity(opacity: opacity, child: image);
      },
    );
  }
}
