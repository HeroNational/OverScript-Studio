import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpPageTitle),
        backgroundColor: const Color(0xFF111827),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildSection(
                  context,
                  icon: Icons.waving_hand,
                  iconColor: const Color(0xFFFBBF24),
                  title: l10n.helpWelcomeTitle,
                  content: l10n.helpWelcomeDescription,
                ),
                const SizedBox(height: 32),

                // Getting Started
                _buildSection(
                  context,
                  icon: Icons.rocket_launch,
                  iconColor: const Color(0xFF8B5CF6),
                  title: l10n.helpGettingStarted,
                  content: null,
                ),
                const SizedBox(height: 16),
                _buildStepCard(context, l10n.helpStep1Title, l10n.helpStep1Description, Icons.add_circle_outline),
                const SizedBox(height: 12),
                _buildStepCard(context, l10n.helpStep2Title, l10n.helpStep2Description, Icons.tune),
                const SizedBox(height: 12),
                _buildStepCard(context, l10n.helpStep3Title, l10n.helpStep3Description, Icons.play_circle_outline),
                const SizedBox(height: 32),

                // Key Features
                _buildSection(
                  context,
                  icon: Icons.star,
                  iconColor: const Color(0xFF10B981),
                  title: l10n.helpFeaturesTitle,
                  content: null,
                ),
                const SizedBox(height: 16),
                _buildFeatureList(context, [
                  l10n.helpFeature1,
                  l10n.helpFeature2,
                  l10n.helpFeature3,
                  l10n.helpFeature4,
                  l10n.helpFeature5,
                ]),
                const SizedBox(height: 32),

                // System Requirements (Windows)
                _buildSection(
                  context,
                  icon: Icons.computer,
                  iconColor: const Color(0xFF3B82F6),
                  title: l10n.helpSystemRequirementsTitle,
                  content: l10n.helpSystemRequirementsDescription,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl('https://aka.ms/highdpimfc2013x64enu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.download),
                    label: Text(
                      l10n.helpDownloadVCRedist,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Troubleshooting
                _buildSection(
                  context,
                  icon: Icons.build,
                  iconColor: const Color(0xFFF59E0B),
                  title: l10n.helpTroubleshootingTitle,
                  content: null,
                ),
                const SizedBox(height: 16),
                _buildTroubleshootCard(context, l10n.helpTroubleshoot1Title, l10n.helpTroubleshoot1Description),
                const SizedBox(height: 12),
                _buildTroubleshootCard(context, l10n.helpTroubleshoot2Title, l10n.helpTroubleshoot2Description),
                const SizedBox(height: 12),
                _buildTroubleshootCard(context, l10n.helpTroubleshoot3Title, l10n.helpTroubleshoot3Description),
                const SizedBox(height: 32),

                // Support & Contact
                _buildSection(
                  context,
                  icon: Icons.support_agent,
                  iconColor: const Color(0xFFEC4899),
                  title: l10n.helpSupportTitle,
                  content: l10n.helpSupportDescription,
                ),
                const SizedBox(height: 16),
                Center(
                  child: InkWell(
                    onTap: () => _launchUrl('mailto:${l10n.helpSupportEmail}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Text(
                            l10n.helpSupportEmail,
                            style: const TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (content != null) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context, List<String> features) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: features
            .map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTroubleshootCard(BuildContext context, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
