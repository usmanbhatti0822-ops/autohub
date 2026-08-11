import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/photo_picker.dart';
import '../../../uploads/data/uploads_repository.dart';
import '../../data/listings_repository.dart';
import '../../domain/car_listing.dart';

class PostListingScreen extends ConsumerStatefulWidget {
  const PostListingScreen({super.key});

  @override
  ConsumerState<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends ConsumerState<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();
  final _price = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();
  String _transmission = 'automatic';
  String _fuelType = 'petrol';
  String _category = 'sedan';
  List<XFile> _photos = [];
  bool _submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      List<String> photoUrls;
      if (_photos.isNotEmpty) {
        photoUrls = await ref.read(uploadsRepositoryProvider).uploadImages(_photos);
      } else {
        // No photos picked — fall back to a placeholder so the listing
        // never ships with a broken/blank image.
        final seed = '${_make.text}-${_model.text}-${DateTime.now().millisecondsSinceEpoch}'
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '');
        photoUrls = ['https://picsum.photos/seed/$seed/900/600'];
      }

      final listing = CarListing(
        id: '',
        make: _make.text.trim(),
        model: _model.text.trim(),
        year: int.parse(_year.text.trim()),
        mileageKm: int.parse(_mileage.text.trim()),
        price: double.parse(_price.text.trim()),
        city: _city.text.trim(),
        transmission: _transmission,
        fuelType: _fuelType,
        category: _category,
        photoUrls: photoUrls,
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        isVerified: false,
        status: 'pending',
      );
      await ref.read(listingsRepositoryProvider).create(listing);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing submitted for review!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell your car')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            PhotoPickerGrid(onChanged: (files) => setState(() => _photos = files)),
            const SizedBox(height: AppSpacing.md),
            _field(_make, 'Make (e.g. Toyota)'),
            _field(_model, 'Model (e.g. Corolla)'),
            _field(_year, 'Year', keyboardType: TextInputType.number),
            _field(_mileage, 'Mileage (km)', keyboardType: TextInputType.number),
            _field(_price, 'Price (PKR)', keyboardType: TextInputType.number),
            _field(_city, 'City'),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'economy', child: Text('Economy')),
                DropdownMenuItem(value: 'hatchback', child: Text('Hatchback')),
                DropdownMenuItem(value: 'sedan', child: Text('Sedan')),
                DropdownMenuItem(value: 'suv', child: Text('SUV')),
                DropdownMenuItem(value: 'luxury', child: Text('Luxury')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _transmission,
                    decoration: const InputDecoration(labelText: 'Transmission'),
                    items: const [
                      DropdownMenuItem(value: 'automatic', child: Text('Automatic')),
                      DropdownMenuItem(value: 'manual', child: Text('Manual')),
                    ],
                    onChanged: (v) => setState(() => _transmission = v!),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _fuelType,
                    decoration: const InputDecoration(labelText: 'Fuel'),
                    items: const [
                      DropdownMenuItem(value: 'petrol', child: Text('Petrol')),
                      DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                      DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                      DropdownMenuItem(value: 'electric', child: Text('Electric')),
                      DropdownMenuItem(value: 'cng', child: Text('CNG')),
                    ],
                    onChanged: (v) => setState(() => _fuelType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(loading: _submitting, onPressed: _submit, child: const Text('Submit Listing')),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
