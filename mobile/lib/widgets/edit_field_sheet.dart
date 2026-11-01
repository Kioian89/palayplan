import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/field_model.dart';
import '../providers/field_provider.dart';
import '../l10n/app_strings.dart';

/// Modal bottom sheet allowing the farmer to set and customize their field profile.
class EditFieldSheet extends StatefulWidget {
  const EditFieldSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditFieldSheet(),
    );
  }

  @override
  State<EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<EditFieldSheet> {
  late RiceLocation _selectedLocation;
  late RiceVariety _selectedVariety;
  late DateTime _plantingDate;
  late double _areaHa;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Retrieve initial values from FieldProvider safely
    final currentField = FieldProvider.fieldOf(context);

    _selectedLocation = RiceLocation.commonLocations.firstWhere(
      (loc) => loc.municipality.toLowerCase() == currentField.municipality.toLowerCase(),
      orElse: () => RiceLocation.commonLocations.first,
    );

    _selectedVariety = RiceVariety.commonVarieties.firstWhere(
      (v) => currentField.varietyName.contains(v.code),
      orElse: () => RiceVariety.commonVarieties.first,
    );

    _plantingDate = currentField.plantingDate;
    _areaHa = currentField.fieldAreaHa;
    _nameController = TextEditingController(text: currentField.fieldName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 150)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7E55),
              onPrimary: Colors.white,
              onSurface: Color(0xFF191D24),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _plantingDate = picked);
    }
  }

  void _save() async {
    final newProfile = FieldProfile(
      fieldName: _nameController.text.trim().isEmpty ? 'Main Paddy' : _nameController.text.trim(),
      municipality: _selectedLocation.municipality,
      province: _selectedLocation.province,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      plantingDate: _plantingDate,
      varietyName: '${_selectedVariety.code} (${_selectedVariety.popularName})',
      daysToMaturity: _selectedVariety.daysToMaturity,
      fieldAreaHa: _areaHa,
    );

    try {
      final provider = FieldProvider.of(context);
      await provider.updateField(newProfile);
    } catch (_) {
      // Non-provider environment
    }

    if (mounted) {
      Navigator.pop(context);
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🌾 ${s.fieldSavedSnackbar}'),
          backgroundColor: const Color(0xFF191D24),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    const coral = Color(0xFFFF7E55);
    final dateStr = DateFormat('MMMM d, yyyy').format(_plantingDate);

    // Calculate live preview metrics
    final daysElapsed = DateTime.now().difference(_plantingDate).inDays.clamp(1, _selectedVariety.daysToMaturity);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: coral.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.terrain_rounded, color: coral, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.fieldSetupTitle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF191D24),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.fieldSetupSub,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live Status Preview Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: coral.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: coral.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: coral,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Day $daysElapsed of ${_selectedVariety.daysToMaturity}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_selectedVariety.code} · ${_selectedLocation.municipality}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF191D24)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 1. Municipality / Location Picker
            Text(
              s.fieldLocationLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RiceLocation>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFFF7E55)),
                  items: RiceLocation.commonLocations.map((loc) {
                    return DropdownMenuItem<RiceLocation>(
                      value: loc,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFFF7E55)),
                          const SizedBox(width: 8),
                          Text(loc.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLocation = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Rice Variety Picker
            Text(
              s.fieldVarietyLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RiceVariety>(
                  value: _selectedVariety,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFFF7E55)),
                  items: RiceVariety.commonVarieties.map((v) {
                    return DropdownMenuItem<RiceVariety>(
                      value: v,
                      child: Row(
                        children: [
                          const Icon(Icons.grain_rounded, size: 18, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              v.displayName,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVariety = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Planting Date Picker
            Text(
              s.fieldDateLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFFF7E55)),
                    const SizedBox(width: 10),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFF191D24)),
                    ),
                    const Spacer(),
                    const Text('Change', style: TextStyle(color: Color(0xFFFF7E55), fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Field Size (Area in Hectares)
            Text(
              s.fieldAreaLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFFF7E55)),
                    onPressed: _areaHa > 0.25 ? () => setState(() => _areaHa = (_areaHa - 0.25).clamp(0.25, 20.0)) : null,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_areaHa.toStringAsFixed(2)} ha (${(_areaHa * 10000).toInt()} m²)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF191D24)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF7E55)),
                    onPressed: () => setState(() => _areaHa = (_areaHa + 0.25).clamp(0.25, 20.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: coral,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                s.saveField,
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
