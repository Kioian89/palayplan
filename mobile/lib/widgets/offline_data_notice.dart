import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';

class OfflineDataNotice extends StatelessWidget {
  const OfflineDataNotice({
    required this.savedAt,
    super.key,
  });

  final DateTime savedAt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMd().add_jm().format(savedAt.toLocal());

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.of(context).offlineCachedAt(date),
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
