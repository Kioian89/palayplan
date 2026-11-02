import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final sections = [
      (strings.privacyInfoTitle, strings.privacyInfoBody),
      (strings.privacyProcessingTitle, strings.privacyProcessingBody),
      (strings.privacyStorageTitle, strings.privacyStorageBody),
      (strings.privacySharingTitle, strings.privacySharingBody),
      (strings.privacyChoicesTitle, strings.privacyChoicesBody),
      (strings.privacyContactTitle, strings.privacyContactBody),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.privacyTitle)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_outlined,
                      color: Colors.white, size: 28),
                  const SizedBox(height: 16),
                  Text(
                    strings.privacyTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.privacyIntro,
                    style: const TextStyle(
                      color: Color(0xFFE5EEE8),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.privacyLastUpdated,
                    style: const TextStyle(
                      color: Color(0xFFD4E3D8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final section in sections) ...[
              _PolicySection(title: section.$1, body: section.$2),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1B4332),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                color: Color(0xFF37443F),
                fontSize: 15,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
