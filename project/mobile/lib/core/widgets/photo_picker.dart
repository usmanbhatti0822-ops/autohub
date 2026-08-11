import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

/// Lets the user pick up to [maxPhotos] photos from their device/browser
/// and previews them in a horizontal strip before upload. Used on the
/// "Sell a car" and "List for rent" forms — actual upload happens on
/// submit via UploadsRepository, this widget just manages selection.
class PhotoPickerGrid extends StatefulWidget {
  final ValueChanged<List<XFile>> onChanged;
  final int maxPhotos;

  const PhotoPickerGrid({super.key, required this.onChanged, this.maxPhotos = 6});

  @override
  State<PhotoPickerGrid> createState() => _PhotoPickerGridState();
}

class _PhotoPickerGridState extends State<PhotoPickerGrid> {
  final _picker = ImagePicker();
  final List<XFile> _files = [];

  Future<void> _pick() async {
    final remaining = widget.maxPhotos - _files.length;
    if (remaining <= 0) return;
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      setState(() {
        _files.addAll(picked.take(remaining));
      });
      widget.onChanged(_files);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open photo picker')));
    }
  }

  void _remove(int index) {
    setState(() => _files.removeAt(index));
    widget.onChanged(_files);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < _files.length; i++) _PhotoThumb(file: _files[i], onRemove: () => _remove(i)),
              if (_files.length < widget.maxPhotos) _AddTile(onTap: _pick),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _files.isEmpty
              ? "No photos selected — a placeholder will be used"
              : '${_files.length}/${widget.maxPhotos} photos selected',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 22),
            SizedBox(height: 4),
            Text('Add', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: FutureBuilder<Uint8List>(
              future: file.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(width: 84, height: 84, color: AppColors.surface);
                }
                return Image.memory(snapshot.data!, width: 84, height: 84, fit: BoxFit.cover);
              },
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
