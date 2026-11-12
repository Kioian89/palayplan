import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_strings.dart';

/// Floating language-picker bottom sheet.
/// Call [LanguagePickerSheet.show(context)] from any widget.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    LanguageProvider? provider;
    try {
      provider = Provider.of<LanguageProvider>(context);
    } catch (_) {
      provider = null;
    }
    final current = provider?.language ?? AppLanguage.english;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            s.langPickerTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191D24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pili-a / Piliin / Choose language',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          // Language tiles
          ...AppLanguage.values.map((lang) {
            final isSelected = lang == current;
            return _LanguageTile(
              lang: lang,
              isSelected: isSelected,
              onTap: () async {
                if (provider != null) {
                  await provider.setLanguage(lang);
                }
                if (context.mounted) Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  String get _subtitle {
    switch (lang) {
      case AppLanguage.english:
        return 'International • Default';
      case AppLanguage.filipino:
        return 'Pambansang Wika · Tagalog';
      case AppLanguage.bisaya:
        return 'Cebuano · Visayas & Mindanao';
    }
  }

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF7E55);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? coral.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? coral : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag + lang initial badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? coral.withValues(alpha: 0.15)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  lang.flagEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? coral : const Color(0xFF191D24),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

            // Check mark
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: coral, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFD1D5DB), size: 22),
          ],
        ),
      ),
    );
  }
}

