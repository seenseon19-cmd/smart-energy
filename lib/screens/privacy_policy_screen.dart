import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: dark ? AppTheme.darkBg : AppTheme.lightBg,
        appBar: AppBar(title: const Text('الخصوصية والشروط'), centerTitle: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _Section(title: 'أهمية SmartEnergy', text: 'يساعدك SmartEnergy على مراقبة استهلاك الطاقة، حماية الأجهزة من الأحمال الزائدة، واتخاذ قرارات عملية لترشيد الكهرباء في المنزل أو المنشأة.'),
              _Section(title: 'سياسة الخصوصية', text: 'نستخدم بيانات الحساب وبيانات الطاقة لتقديم المراقبة والتحكم والتنبيهات. تُستخدم البيانات ضمن حسابك وعمليات التشغيل المرتبطة بأجهزتك، ولا نبيع بياناتك الشخصية. يمكنك طلب تحديث بياناتك أو حذفها عبر الدعم.'),
              _Section(title: 'شروط الخدمة', text: 'يُستخدم التطبيق لإدارة الطاقة والمراقبة المساعدة، ولا يُعد بديلاً عن أنظمة السلامة الكهربائية أو فني مؤهل. يتحمل المستخدم مسؤولية ربط الأجهزة وفق الإرشادات والمحافظة على بيانات الدخول.'),
              _Section(title: 'الدعم والمساعدة', text: 'للاستفسارات أو طلبات الخصوصية، تواصل مباشرة مع فريق الدعم عبر واتساب أو الاتصال بالرقم المعتمد.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openSupport(context),
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('تواصل مع الدعم 00218915775774'),
              ),
              const SizedBox(height: 20),
              Text('آخر تحديث: أغسطس 2026', style: TextStyle(color: secondary, fontSize: 12), textAlign: TextAlign.center),
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
