import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/field_model.dart';
import '../providers/field_provider.dart';
import '../l10n/app_strings.dart';
import 'field_location_picker.dart';

/// Modal bottom sheet allowing the farmer to set, customize, and manage multiple rice field profiles.
class EditFieldSheet extends StatefulWidget {
  const EditFieldSheet({
    this.startAsAdding = false,
    super.key,
  });

  final bool startAsAdding;

  static void show(BuildContext context, {bool startAsAdding = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditFieldSheet(startAsAdding: startAsAdding),
    );
  }

  @override
  State<EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<EditFieldSheet> {
  late RiceLocation _selectedLocation;
  late double _latitude;
  late double _longitude;
  late bool _hasCustomCoordinates;
  late RiceVariety _selectedVariety;
  late DateTime _plantingDate;
  late double _areaHa;
  late TextEditingController _nameController;
  late TextEditingController _municipalityController;
  late TextEditingController _provinceController;

  bool _isCustomLocation = false;
  bool _isAddingNew = false;
  int _selectedFieldIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = FieldProvider.of(context);
      _selectedFieldIndex = provider.activeFieldIndex;
      _isAddingNew = widget.startAsAdding;

      if (_isAddingNew) {
        _initForNewField(provider.fieldCount + 1);
      } else {
        _loadField(provider.field);
      }
      _initialized = true;
    }
  }

  void _loadField(FieldProfile currentField) {
    final match = RiceLocation.commonLocations.where(
      (loc) => loc.municipality.toLowerCase() == currentField.municipality.toLowerCase(),
    );

    if (match.isNotEmpty) {
      _selectedLocation = match.first;
      _isCustomLocation = false;
    } else {
      _selectedLocation = RiceLocation.commonLocations.first;
      _isCustomLocation = true;
    }

    _latitude = currentField.latitude;
    _longitude = currentField.longitude;
    _hasCustomCoordinates = currentField.hasCustomCoordinates;

    _selectedVariety = RiceVariety.commonVarieties.firstWhere(
      (v) => currentField.varietyName.contains(v.code),
      orElse: () => RiceVariety.commonVarieties.first,
    );

    _plantingDate = currentField.plantingDate;
    _areaHa = currentField.fieldAreaHa;
    _nameController = TextEditingController(text: currentField.fieldName);
    _municipalityController = TextEditingController(text: currentField.municipality);
    _provinceController = TextEditingController(text: currentField.province);
  }

  void _initForNewField(int nextNumber) {
    _selectedLocation = RiceLocation.commonLocations.first;
    _isCustomLocation = false;
    _latitude = _selectedLocation.latitude;
    _longitude = _selectedLocation.longitude;
    _hasCustomCoordinates = false;
    _selectedVariety = RiceVariety.commonVarieties.first;
    _plantingDate = DateTime.now().subtract(const Duration(days: 30));
    _areaHa = 1.0;
    _nameController = TextEditingController(text: 'Paddy $nextNumber');
    _municipalityController = TextEditingController(text: _selectedLocation.municipality);
    _provinceController = TextEditingController(text: _selectedLocation.province);
  }

  void _switchField(int index) {
    final provider = FieldProvider.of(context);
    if (index >= 0 && index < provider.fieldCount) {
      provider.selectField(index);
      setState(() {
        _selectedFieldIndex = index;
        _isAddingNew = false;
        _loadField(provider.allFields[index]);
      });
    }
  }

  void _switchToNewField() {
    final provider = FieldProvider.of(context);
    setState(() {
      _isAddingNew = true;
      _initForNewField(provider.fieldCount + 1);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _municipalityController.dispose();
    _provinceController.dispose();
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

  Future<void> _pickMapLocation() async {
    final point = await FieldLocationPicker.show(
      context,
      initialLatitude: _latitude,
      initialLongitude: _longitude,
    );
    if (point != null && mounted) {
      setState(() {
        _latitude = point.latitude;
        _longitude = point.longitude;
        _hasCustomCoordinates = true;
      });
    }
  }

  Future<void> _deleteCurrentField() async {
    final s = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.fieldDelete),
        content: Text(s.fieldDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.settingsCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.fieldDelete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = FieldProvider.of(context);
      final deleted = await provider.deleteField(_selectedFieldIndex);
      if (deleted && mounted) {
        setState(() {
          _selectedFieldIndex = provider.activeFieldIndex;
          _isAddingNew = false;
          _loadField(provider.field);
        });
      }
    }
  }

  void _save() async {
    final municipality = _isCustomLocation
        ? (_municipalityController.text.trim().isEmpty
            ? _selectedLocation.municipality
            : _municipalityController.text.trim())
        : _selectedLocation.municipality;

    final province = _isCustomLocation
        ? (_provinceController.text.trim().isEmpty
            ? _selectedLocation.province
            : _provinceController.text.trim())
        : _selectedLocation.province;

    final newProfile = FieldProfile(
      fieldName: _nameController.text.trim().isEmpty
          ? 'Main Paddy'
          : _nameController.text.trim(),
      municipality: municipality,
      province: province,
      latitude: _latitude,
      longitude: _longitude,
      hasCustomCoordinates: _hasCustomCoordinates,
      plantingDate: _plantingDate,
      varietyName: '${_selectedVariety.code} (${_selectedVariety.popularName})',
      daysToMaturity: _selectedVariety.daysToMaturity,
      fieldAreaHa: _areaHa,
    );

    try {
      final provider = FieldProvider.of(context);
      if (_isAddingNew) {
        await provider.addField(newProfile);
      } else {
        await provider.updateFieldAt(_selectedFieldIndex, newProfile);
      }
    } catch (_) {
      // Non-provider environment
    }

    if (mounted) {
      Navigator.pop(context);
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.grass_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(s.fieldSavedSnackbar)),
            ],
          ),
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

    final provider = FieldProvider.watch(context);
    final allFields = provider.allFields;
    final canDelete = allFields.length > 1 && !_isAddingNew;

    // Calculate live preview metrics
    final daysElapsed = DateTime.now()
        .difference(_plantingDate)
        .inDays
        .clamp(1, _selectedVariety.daysToMaturity);

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
                        _isAddingNew ? s.fieldAddNew : s.fieldSetupTitle,
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
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    tooltip: s.fieldDelete,
                    onPressed: _deleteCurrentField,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Multi-Field Switcher Pills ──────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...allFields.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final isSelected = !_isAddingNew && _selectedFieldIndex == idx;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          item.fieldName,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                        selectedColor: const Color(0xFF2E7D32),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        onSelected: (_) => _switchField(idx),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.add_rounded, size: 16, color: coral),
                      label: Text(
                        s.fieldAddNew,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: coral,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFFFCCBC)),
                      ),
                      onPressed: _switchToNewField,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_selectedVariety.code} · ${_isCustomLocation ? _municipalityController.text : _selectedLocation.municipality}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191D24),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 0. Field Name / Identifier ─────────────────────────────────
            Text(
              s.fieldNameLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. Main Paddy, Upper Parcel',
                  icon: Icon(Icons.badge_outlined, color: coral, size: 20),
                ),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // ── 1. Municipality / Location Picker ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.fieldLocationLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
                Flexible(
                  child: InkWell(
                    onTap: () => setState(() => _isCustomLocation = !_isCustomLocation),
                    child: Text(
                      _isCustomLocation ? 'Choose from list' : s.fieldCustomLocationToggle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: coral,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (!_isCustomLocation) ...[
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
                      if (val != null) {
                        setState(() {
                          _selectedLocation = val;
                          _latitude = val.latitude;
                          _longitude = val.longitude;
                          _hasCustomCoordinates = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ] else ...[
              // Custom Municipality and Province TextFields
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _municipalityController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: s.fieldMunicipalityLabel,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _provinceController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: s.fieldProvinceLabel,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickMapLocation,
              icon: const Icon(Icons.map_outlined, size: 19),
              label: Text(s.chooseOnMap),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF191D24),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_hasCustomCoordinates) ...[
              const SizedBox(height: 6),
              Text(
                '${s.mapPinSelected}: ${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // ── 2. Rice Variety Picker ─────────────────────────────────────
            Text(
              s.fieldVarietyLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
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

            // ── 3. Planting Date Picker ────────────────────────────────────
            Text(
              s.fieldDateLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
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
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191D24),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Change',
                      style: TextStyle(
                        color: Color(0xFFFF7E55),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 4. Field Size (Area in Hectares) ───────────────────────────
            Text(
              s.fieldAreaLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
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
                    onPressed: _areaHa > 0.25
                        ? () => setState(() => _areaHa = (_areaHa - 0.25).clamp(0.25, 20.0))
                        : null,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_areaHa.toStringAsFixed(2)} ha (${(_areaHa * 10000).toInt()} m²)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191D24),
                        ),
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

            // ── Save Button ────────────────────────────────────────────────
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
                _isAddingNew ? s.saveNewField : s.saveField,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
