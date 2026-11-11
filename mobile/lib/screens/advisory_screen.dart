import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../widgets/risk_status_card.dart';
import '../providers/field_provider.dart';
import '../l10n/app_strings.dart';
import '../widgets/offline_data_notice.dart';
import '../widgets/edit_field_sheet.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  final ApiService _api = ApiService();
  List<Advisory> _advisories = [];
  bool _loading = true;
  bool _usingCachedData = false;
  DateTime? _dataSavedAt;
  bool _unavailable = false;
  bool _needsFieldSetup = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final field = FieldProvider.fieldOf(context);
    if (!field.isConfigured) {
      if (mounted) {
        setState(() {
          _loading = false;
          _unavailable = false;
          _needsFieldSetup = true;
          _advisories = [];
        });
      }
      return;
    }

    try {
      final data = await _api.getAdvisories(
        municipality: field.municipality,
        lat: field.latitude,
        lon: field.longitude,
        startDate: field.plantingDate,
        daysToMaturity: field.daysToMaturity,
      );
      if (mounted) {
        setState(() {
          _advisories = data;
          _usingCachedData = _api.lastResponseWasCached;
          _dataSavedAt = _api.lastResponseAt;
          _loading = false;
          _unavailable = false;
          _needsFieldSetup = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _unavailable = _advisories.isEmpty;
          if (_advisories.isNotEmpty) _usingCachedData = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fmt = DateFormat('MMM d');
    final cs = Theme.of(context).colorScheme;
    final count = _advisories.length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(s.advTitle),
        centerTitle: false,
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        actions: [
          if (!_loading && count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count ${count == 1 ? "advisory" : "advisories"}',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? _buildLoading(cs, s)
          : _needsFieldSetup
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 48, color: Color(0xFF2E7D32)),
                        const SizedBox(height: 16),
                        const Text(
                          'Set up your field to get local crop advisories.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await EditFieldSheet.show(context);
                            setState(() => _loading = true);
                            await _load();
                          },
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Set up field'),
                        ),
                      ],
                    ),
                  ),
                )
              : _unavailable && _advisories.isEmpty
                  ? _buildUnavailable(cs, s)
                  : _advisories.isEmpty
                      ? _buildEmptyState(cs)
                      : _buildList(fmt, cs),
    );
  }

  Widget _buildUnavailable(ColorScheme cs, AppStrings s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              s.offlineNoCachedData,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              icon: const Icon(Icons.refresh),
              label: Text(s.offlineRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme cs, AppStrings s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 16),
          Text(
            s.advLoading,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_usingCachedData && _dataSavedAt != null)
              OfflineDataNotice(savedAt: _dataSavedAt!),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 44,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Clear!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No active advisories for your field.\nConditions look good — keep monitoring.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(DateFormat fmt, ColorScheme cs) {
    return CustomScrollView(
      slivers: [
        if (_usingCachedData && _dataSavedAt != null)
          SliverToBoxAdapter(
            child: OfflineDataNotice(savedAt: _dataSavedAt!),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'ACTIVE FIELD ADVISORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final a = _advisories[i];
              return RiskStatusCard(
                title: '${a.stage} · ${fmt.format(a.date)}',
                message: a.message,
                riskLevel: a.severity == 'critical'
                    ? 'high'
                    : a.severity == 'warning'
                        ? 'medium'
                        : 'low',
              );
            },
            childCount: _advisories.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}
