import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class RoomPictureSection extends StatelessWidget {
  const RoomPictureSection({
    super.key,
    required this.picture,
    required this.onAddOrChange,
    required this.onRemove,
  });

  final String? picture;
  final VoidCallback onAddOrChange;
  final VoidCallback onRemove;

  bool get _hasPicture =>
      picture != null && picture!.trim().isNotEmpty;

  bool get _isUrl {
    final value = picture?.trim() ?? '';
    return value.startsWith('http://') ||
        value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Room Information',
      subtitle: _hasPicture
          ? 'Update the classroom photo'
          : 'Upload a classroom photo for identification',
      child: _hasPicture
          ? _ExistingPhoto(
              picture: picture!.trim(),
              isUrl: _isUrl,
              onChange: onAddOrChange,
              onRemove: onRemove,
            )
          : _UploadArea(onAdd: onAddOrChange),
    );
  }
}

class _ExistingPhoto extends StatelessWidget {
  const _ExistingPhoto({
    required this.picture,
    required this.isUrl,
    required this.onChange,
    required this.onRemove,
  });

  final String picture;
  final bool isUrl;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 132,
            height: 84,
            child: isUrl
                ? Image.network(
                    picture,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const _PhotoFallback(),
                  )
                : const _PhotoFallback(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BluePill(
                label: 'Change Picture',
                icon: Icons.image_outlined,
                onPressed: onChange,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                ),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(
                    color: Color(0xFF8E939A),
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6B7076),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          const LocalAssetImage(
            directory: manageRoomAssetDir,
            name: 'Image (1).svg',
            width: 42,
            height: 36,
            semanticLabel: 'Picture',
          ),
          const SizedBox(height: 12),
          _BluePill(
            label: 'Add Picture',
            assetName: 'Add (1).svg',
            onPressed: onAdd,
          ),
          const SizedBox(height: 8),
          const Text(
            'JPG, PNG up to 30 MB',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1C1F22),
      child: Center(
        child: LocalAssetImage(
          directory: manageRoomAssetDir,
          name: 'Image (1).svg',
          width: 36,
          height: 30,
          semanticLabel: 'Picture',
        ),
      ),
    );
  }
}

class _BluePill extends StatelessWidget {
  const _BluePill({
    required this.label,
    required this.onPressed,
    this.icon,
    this.assetName,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? assetName;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: assetName != null
          ? LocalAssetImage(
              directory: manageRoomAssetDir,
              name: assetName!,
              width: 14,
              height: 12,
              semanticLabel: label,
            )
          : Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
