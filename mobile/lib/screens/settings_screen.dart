import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/app_update_service.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/language_picker_sheet.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    this.authService,
    this.updateService,
    super.key,
  });

  final FirebaseAuthService? authService;
  final AppUpdateService? updateService;

  Future<void> _signOut(BuildContext context) async {
    final service = authService;
    if (service == null) return;

    final strings = AppStrings.of(context);
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.settingsSignOutPrompt),
        content: Text(strings.settingsSignOutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.settingsSignOut),
          ),
        ],
      ),
    );
    if (shouldSignOut != true) return;

    try {
      await service.signOut();
    } on Exception {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.settingsSignOutError)),
      );
    }
  }

  Future<void> _contactSupport(BuildContext context) async {
    const email = 'banquiladrian@gmail.com';
    final strings = AppStrings.of(context);
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'PalayPlan Inquiry / Feedback',
      },
    );

    bool launched = false;
    try {
      launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      await Clipboard.setData(const ClipboardData(text: email));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsContactCopied),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final currentLanguage = LanguageProvider.watch(context).language.nativeName;
    final user = authService?.currentUser;
    final accountLabel =
        user?.email ?? user?.displayName ?? strings.settingsGuest;

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      strings.settingsTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: strings.settingsLanguage,
              child: ListTile(
                minVerticalPadding: 12,
                leading: const _SettingsIcon(icon: Icons.language_rounded),
                title: Text(strings.settingsLanguage),
                subtitle: Text(strings.settingsLanguageSubtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLanguage,
                      style: const TextStyle(
                        color: Color(0xFF53615C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                onTap: () => LanguagePickerSheet.show(context),
              ),
            ),
            if (defaultTargetPlatform == TargetPlatform.android) ...[
              const SizedBox(height: 16),
              _SettingsGroup(
                title: strings.settingsAppUpdates,
                child: _AppUpdateTile(service: updateService),
              ),
            ],
            const SizedBox(height: 16),
            _SettingsGroup(
              title: strings.settingsPrivacy,
              child: ListTile(
                minVerticalPadding: 12,
                leading: const _SettingsIcon(icon: Icons.shield_outlined),
                title: Text(strings.settingsPrivacy),
                subtitle: Text(strings.settingsPrivacySubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: strings.settingsContact,
              child: ListTile(
                minVerticalPadding: 12,
                leading: const _SettingsIcon(icon: Icons.mail_outline_rounded),
                title: Text(strings.settingsContactTitle),
                subtitle: Text(strings.settingsContactSubtitle),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _contactSupport(context),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: strings.settingsAccount,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const _SettingsIcon(icon: Icons.person_outline_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            accountLabel,
                            style: const TextStyle(
                              color: Color(0xFF25332E),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (authService != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _signOut(context),
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(strings.settingsSignOut),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppUpdateTile extends StatefulWidget {
  const _AppUpdateTile({this.service});

  final AppUpdateService? service;

  @override
  State<_AppUpdateTile> createState() => _AppUpdateTileState();
}

class _AppUpdateTileState extends State<_AppUpdateTile> {
  bool _isChecking = false;
  AppUpdateService? _ownedService;

  AppUpdateService get _service =>
      widget.service ?? (_ownedService ??= AppUpdateService());

  @override
  void dispose() {
    _ownedService?.close();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    setState(() => _isChecking = true);
    final strings = AppStrings.of(context);
    try {
      final info = await _service.checkForUpdate();
      if (!mounted) return;

      if (!info.isUpdateAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.settingsNoUpdateAvailable)),
        );
        return;
      }

      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.settingsUpdateDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.settingsUpdateAvailable(info.latestVersion)),
                if (info.releaseNotes?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Text(
                    strings.settingsReleaseNotes,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(info.releaseNotes!.trim()),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.settingsNotNow),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.settingsUpdateNow),
            ),
          ],
        ),
      );
      if (shouldDownload != true || !mounted) return;

      final launched = await launchUrl(
        info.downloadUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.settingsDownloadError)),
        );
      }
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsUpdateCheckError),
          action: SnackBarAction(
            label: strings.offlineRetry,
            onPressed: _checkForUpdates,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return ListTile(
      minVerticalPadding: 12,
      leading: const _SettingsIcon(icon: Icons.system_update_alt_rounded),
      title: Text(strings.settingsCheckForUpdates),
      subtitle: Text(
        _isChecking
            ? strings.settingsCheckingForUpdates
            : strings.settingsAppUpdatesSubtitle,
      ),
      trailing: _isChecking
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: _isChecking ? null : _checkForUpdates,
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF53615C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7E55).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFFB84F30), size: 22),
    );
  }
}
