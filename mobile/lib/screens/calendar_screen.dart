import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_strings.dart';
import '../providers/field_provider.dart';
import '../widgets/edit_field_sheet.dart';

/// Smart Rice Cropping Calendar Generator.
/// Generates the 4 major phases from a start date + variety maturity days.
/// This is presentation logic only; the actual date math mirrors
/// `get_growth_stage()` in the backend's advisory_engine.py so the two stay
/// in sync — consider generating this from a shared schema/spec later.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _startDate = DateTime.now();
  int _daysToMaturity = 110;
  DateTime? _configuredPlantingDate;
  int? _configuredMaturityDays;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final field = FieldProvider.fieldOf(context);
    if (field.isConfigured &&
        (_configuredPlantingDate != field.plantingDate ||
            _configuredMaturityDays != field.daysToMaturity)) {
      _startDate = field.plantingDate;
      _daysToMaturity = field.daysToMaturity;
      _configuredPlantingDate = field.plantingDate;
      _configuredMaturityDays = field.daysToMaturity;
    }
  }

  static const List<_PhaseConfig> _phaseConfigs = [
    _PhaseConfig(
      icon: Icons.agriculture,
      color: Color(0xFF795548),
      label: 'Land Preparation & Sowing',
    ),
    _PhaseConfig(
      icon: Icons.energy_savings_leaf,
      color: Color(0xFF2E7D32),
      label: 'Transplanting & Vegetative Growth',
    ),
    _PhaseConfig(
      icon: Icons.science,
      color: Color(0xFFF57C00),
      label: 'Nutrient Management / Fertilization',
    ),
    _PhaseConfig(
      icon: Icons.grass,
      color: Color(0xFFE65100),
      label: 'Ripening & Harvest',
    ),
  ];

  List<_Phase> get _phases {
    return [
      _Phase(
        config: _phaseConfigs[0],
        start: _startDate,
        end: _startDate.add(const Duration(days: 10)),
      ),
      _Phase(
        config: _phaseConfigs[1],
        start: _startDate.add(const Duration(days: 11)),
        end: _startDate.add(const Duration(days: 45)),
      ),
      _Phase(
        config: _phaseConfigs[2],
        start: _startDate.add(const Duration(days: 46)),
        end: _startDate.add(Duration(days: _daysToMaturity - 20)),
      ),
      _Phase(
        config: _phaseConfigs[3],
        start: _startDate.add(Duration(days: _daysToMaturity - 19)),
        end: _startDate.add(Duration(days: _daysToMaturity)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fmt = DateFormat('MMM d, yyyy');
    final cs = Theme.of(context).colorScheme;
    final field = FieldProvider.fieldOf(context);
    final phases = _phases;
    final harvestDate = phases.last.end;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(s.calTitle),
        centerTitle: false,
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Configure Field',
            onPressed: () => EditFieldSheet.show(context),
          ),
        ],
      ),
      body: !field.isConfigured
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 48, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 16),
                    const Text(
                      'Set up your field to create a crop calendar.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => EditFieldSheet.show(context),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Set up field'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // ── Summary header ───────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.calendar_month,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Season Timeline',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${fmt.format(_startDate)} → ${fmt.format(harvestDate)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_daysToMaturity days',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Controls row ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_calendar, size: 18),
                          label: Text(
                            'Start: ${DateFormat('MMM d, yyyy').format(_startDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: cs.outline.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _daysToMaturity,
                            icon: const Icon(Icons.arrow_drop_down),
                            borderRadius: BorderRadius.circular(14),
                            items: const [105, 110, 115, 120, 125]
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      '$d days',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _daysToMaturity = val ?? 110),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Phase list ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        'GROWTH PHASES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: phases.length,
                    itemBuilder: (context, i) =>
                        _PhaseCard(phase: phases[i], fmt: fmt, index: i),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Phase Card ─────────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  final _Phase phase;
  final DateFormat fmt;
  final int index;

  const _PhaseCard(
      {required this.phase, required this.fmt, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final duration = phase.end.difference(phase.start).inDays + 1;
    final color = phase.config.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Accent bar
              Container(width: 5, color: color),
              // Icon circle
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      phase.config.icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phase ${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phase.config.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fmt.format(phase.start)} — ${fmt.format(phase.end)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Duration badge
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$duration d',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data classes ────────────────────────────────────────────────────────────

class _PhaseConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _PhaseConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}

class _Phase {
  final _PhaseConfig config;
  final DateTime start;
  final DateTime end;
  const _Phase({required this.config, required this.start, required this.end});
}
