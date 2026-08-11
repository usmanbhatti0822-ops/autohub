import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'category_chip.dart';
import 'loading_button.dart';

class FilterSheetResult {
  final String? category;
  final String? transmission;
  final String? fuelType;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const FilterSheetResult({
    this.category,
    this.transmission,
    this.fuelType,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });
}

const _categories = ['economy', 'hatchback', 'sedan', 'suv', 'luxury'];
const _categoryIcons = {
  'economy': Icons.savings_outlined,
  'hatchback': Icons.directions_car_outlined,
  'sedan': Icons.directions_car_filled_outlined,
  'suv': Icons.airport_shuttle_outlined,
  'luxury': Icons.diamond_outlined,
};
const _fuelTypes = ['petrol', 'diesel', 'hybrid', 'electric', 'cng'];

/// Shared filter/sort bottom sheet used by both the marketplace and rentals
/// search screens. [showFuelType] hides that section for rentals, which
/// don't currently filter by fuel type in the UI.
Future<FilterSheetResult?> showFilterSheet(
  BuildContext context, {
  required FilterSheetResult initial,
  bool showFuelType = true,
  String priceLabelSuffix = '',
}) {
  return showModalBottomSheet<FilterSheetResult>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _FilterSheetBody(
      initial: initial,
      showFuelType: showFuelType,
      priceLabelSuffix: priceLabelSuffix,
    ),
  );
}

class _FilterSheetBody extends StatefulWidget {
  final FilterSheetResult initial;
  final bool showFuelType;
  final String priceLabelSuffix;
  const _FilterSheetBody({required this.initial, required this.showFuelType, required this.priceLabelSuffix});

  @override
  State<_FilterSheetBody> createState() => _FilterSheetBodyState();
}

class _FilterSheetBodyState extends State<_FilterSheetBody> {
  String? _category;
  String? _transmission;
  String? _fuelType;
  String? _sortBy;
  late final TextEditingController _minPrice;
  late final TextEditingController _maxPrice;

  @override
  void initState() {
    super.initState();
    _category = widget.initial.category;
    _transmission = widget.initial.transmission;
    _fuelType = widget.initial.fuelType;
    _sortBy = widget.initial.sortBy ?? 'newest';
    _minPrice = TextEditingController(text: widget.initial.minPrice?.toStringAsFixed(0) ?? '');
    _maxPrice = TextEditingController(text: widget.initial.maxPrice?.toStringAsFixed(0) ?? '');
  }

  void _clear() {
    setState(() {
      _category = null;
      _transmission = null;
      _fuelType = null;
      _sortBy = 'newest';
      _minPrice.clear();
      _maxPrice.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters & Sort', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: _clear, child: const Text('Clear all')),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _categories
                  .map((c) => CategoryFilterChip(
                        label: c[0].toUpperCase() + c.substring(1),
                        icon: _categoryIcons[c] ?? Icons.directions_car,
                        selected: _category == c,
                        onTap: () => setState(() => _category = _category == c ? null : c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Price range (PKR${widget.priceLabelSuffix})', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _maxPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Transmission', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: ['automatic', 'manual']
                  .map((t) => ChoiceChip(
                        label: Text(t[0].toUpperCase() + t.substring(1)),
                        selected: _transmission == t,
                        onSelected: (_) => setState(() => _transmission = _transmission == t ? null : t),
                      ))
                  .toList(),
            ),
            if (widget.showFuelType) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Fuel type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: _fuelTypes
                    .map((f) => ChoiceChip(
                          label: Text(f[0].toUpperCase() + f.substring(1)),
                          selected: _fuelType == f,
                          onSelected: (_) => setState(() => _fuelType = _fuelType == f ? null : f),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('Sort by', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            _SortRow(current: _sortBy, onChanged: (v) => setState(() => _sortBy = v)),
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(
              loading: false,
              onPressed: () {
                Navigator.pop(
                  context,
                  FilterSheetResult(
                    category: _category,
                    transmission: _transmission,
                    fuelType: _fuelType,
                    minPrice: double.tryParse(_minPrice.text),
                    maxPrice: double.tryParse(_maxPrice.text),
                    sortBy: _sortBy,
                  ),
                );
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption {
  final String value;
  final String label;
  const _SortOption({required this.value, required this.label});
}

class _SortRow extends StatelessWidget {
  final String? current;
  final ValueChanged<String> onChanged;
  const _SortRow({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      _SortOption(value: 'newest', label: 'Newest'),
      _SortOption(value: 'price_asc', label: 'Price: Low to High'),
      _SortOption(value: 'price_desc', label: 'Price: High to Low'),
    ];
    return Wrap(
      spacing: AppSpacing.xs,
      children: options
          .map((o) => ChoiceChip(
                label: Text(o.label),
                selected: current == o.value,
                onSelected: (_) => onChanged(o.value),
              ))
          .toList(),
    );
  }
}
