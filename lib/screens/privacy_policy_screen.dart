import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const supportNumber = '00218915775774';

  Future<void> _openSupport(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/$supportNumber');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      final tel = Uri.parse('tel:$supportNumber');
      await launchUrl(tel, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? Colors.white : const Color(0xFF0F172A);
    final secondary = dark ? Colors.white70 : const Color(0xFF64748B);
    final loc = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: dark ? AppTheme.darkBg : AppTheme.lightBg,
        appBar: AppBar(title: Text(loc.tr('privacyAndTerms')), centerTitle: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _Section(title: loc.tr('aboutSmartEnergy'), text: loc.tr('aboutSmartEnergyText')),
              _Section(title: loc.tr('privacyPolicy'), text: loc.tr('privacyPolicyText')),
              _Section(title: loc.tr('termsOfService'), text: loc.tr('termsOfServiceText')),
              _Section(title: loc.tr('supportAndHelp'), text: loc.tr('supportAndHelpText')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openSupport(context),
                icon: const Icon(Icons.support_agent_rounded),
                label: Text('${loc.tr('contactSupport')} 00218915775774'),
              ),
              const SizedBox(height: 20),
              Text(loc.tr('lastUpdatedAugust2026'), style: TextStyle(color: secondary, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String text;
  const _Section({required this.title, required this.text});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 7),
        Text(text, style: TextStyle(fontSize: 15, height: 1.65, color: dark ? Colors.white70 : const Color(0xFF475569))),
      ]),
    );
  }
}
