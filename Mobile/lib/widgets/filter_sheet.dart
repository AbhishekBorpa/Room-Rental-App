import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterSheet extends StatefulWidget {
  final Map<String, String>? initialFilters;
  const FilterSheet({super.key, this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late RangeValues _currentRange;
  String _selectedRoomType = 'Any';
  String _selectedFurnishing = 'Any';
  String _selectedGender = 'Any';
  bool _nearMetro = false;

  final List<String> _roomTypes = ['Any', 'single', 'double', 'dorm', 'shared'];
  final List<String> _furnishingTypes = ['Any', 'fully', 'semi', 'unfurnished'];
  final List<String> _genderPrefs = ['Any', 'any', 'male', 'female'];

  @override
  void initState() {
    super.initState();
    // Parse initial filters if they exist
    double min = double.tryParse(widget.initialFilters?['minRent'] ?? '0') ?? 0;
    double max = double.tryParse(widget.initialFilters?['maxRent'] ?? '50000') ?? 50000;
    _currentRange = RangeValues(min, max);
    _selectedRoomType = widget.initialFilters?['roomType'] ?? 'Any';
    _selectedFurnishing = widget.initialFilters?['furnishing'] ?? 'Any';
    _selectedGender = widget.initialFilters?['genderPreference'] ?? 'Any';
    _nearMetro = widget.initialFilters?['nearMetro'] == 'true';
  }

  void _applyFilters() {
    Map<String, String> filters = {};
    if (_currentRange.start > 0) filters['minRent'] = _currentRange.start.round().toString();
    if (_currentRange.end < 50000) filters['maxRent'] = _currentRange.end.round().toString();
    if (_selectedRoomType != 'Any') filters['roomType'] = _selectedRoomType;
    if (_selectedFurnishing != 'Any') filters['furnishing'] = _selectedFurnishing;
    if (_selectedGender != 'Any') filters['genderPreference'] = _selectedGender;
    if (_nearMetro) filters['nearMetro'] = 'true';

    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.displaySmall),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),

          // Price Range
          Text('Price Range (₹)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          RangeSlider(
            values: _currentRange,
            min: 0,
            max: 50000,
            divisions: 50,
            activeColor: AppTheme.primaryColor,
            labels: RangeLabels(
              '₹${_currentRange.start.round()}',
              '₹${_currentRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _currentRange = values),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹0', style: TextStyle(color: Colors.grey[600])),
              Text('₹50,000+', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 32),

          // Room Type
          Text('Room Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildChipList(_roomTypes, _selectedRoomType, (val) => setState(() => _selectedRoomType = val)),
          const SizedBox(height: 24),

          // Furnishing
          Text('Furnishing', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildChipList(_furnishingTypes, _selectedFurnishing, (val) => setState(() => _selectedFurnishing = val)),
          const SizedBox(height: 24),

          // Amenities / Miscellaneous
          SwitchListTile(
            title: const Text('Near Metro Station', style: TextStyle(fontWeight: FontWeight.w600)),
            value: _nearMetro,
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _nearMetro = val),
          ),

          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Apply Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items, String selected, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      children: items.map((item) {
        bool isSelected = selected == item;
        return ChoiceChip(
          label: Text(item[0].toUpperCase() + item.substring(1)),
          selected: isSelected,
          onSelected: (selected) => onSelected(item),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
