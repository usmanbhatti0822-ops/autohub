import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/photo_picker.dart';
import '../../../uploads/data/uploads_repository.dart';
import '../../data/rentals_repository.dart';
import '../../domain/rental_models.dart';

class ListForRentScreen extends ConsumerStatefulWidget {
  const ListForRentScreen({super.key});

  @override
  ConsumerState<ListForRentScreen> createState() => _ListForRentScreenState();
}

class _ListForRentScreenState extends ConsumerState<ListForRentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _city = TextEditingController();
  final _pickupLocation = TextEditingController();
  final _dailyRate = TextEditingController();
  final _securityDeposit = TextEditingController(text: '0');
  String _transmission = 'automatic';
  String _fuelType = 'petrol';
  String _category = 'sedan';
  bool _driverAvailable = false;
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
        final seed = '${_make.text}-${_model.text}-${DateTime.now().millisecondsSinceEpoch}'
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '');
        photoUrls = ['https://picsum.photos/seed/$seed/900/600'];
      }
      final vehicle = RentalVehicle(
        id: '',
        make: _make.text.trim(),
        model: _model.text.trim(),
        year: int.parse(_year.text.trim()),
        transmission: _transmission,
        fuelType: _fuelType,
        category: _category,
        city: _city.text.trim(),
        pickupLocation: _pickupLocation.text.trim(),
        dailyRate: double.parse(_dailyRate.text.trim()),
        securityDeposit: double.tryParse(_securityDeposit.text.trim()) ?? 0,
        driverAvailable: _driverAvailable,
        photoUrls: photoUrls,
      );
      await ref.read(rentalsRepositoryProvider).create(vehicle);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle submitted for review!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List your car for rent')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            PhotoPickerGrid(onChanged: (files) => setState(() => _photos = files)),
            const SizedBox(height: AppSpacing.md),
            _field(_make, 'Make'),
            _field(_model, 'Model'),
            _field(_year, 'Year', keyboardType: TextInputType.number),
            _field(_city, 'City'),
            _field(_pickupLocation, 'Pickup location / area'),
            _field(_dailyRate, 'Daily rate (PKR)', keyboardType: TextInputType.number),
            _field(_securityDeposit, 'Security deposit (PKR, optional)',
                keyboardType: TextInputType.number, required: false),
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
            SwitchListTile(
              value: _driverAvailable,
              onChanged: (v) => setState(() => _driverAvailable = v),
              title: const Text('Offer with-driver option'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(loading: _submitting, onPressed: _submit, child: const Text('Submit for Review')),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }
}
