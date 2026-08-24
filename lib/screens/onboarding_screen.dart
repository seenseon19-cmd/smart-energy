/// ═══════════════════════════════════════════════════════════════
/// شاشة الترحيب — OnboardingScreen (Lovable Light Design)
/// الوظيفة: 4 صفحات تعريفية بأيقونات متحركة وتأثير نبض نيوني
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final pages = [
      _OnboardingData(
        icon: FontAwesomeIcons.chartLine,
        title: loc.tr('onboard1Title'),
        desc: loc.tr('onboard1Desc'),
        gradientColors: [AppTheme.primaryBlue, AppTheme.accentCyan],
      ),
      _OnboardingData(
        icon: FontAwesomeIcons.toggleOn,
        title: loc.tr('onboard2Title'),
        desc: loc.tr('onboard2Desc'),
        gradientColors: [AppTheme.accentCyan, AppTheme.accentGreen],
      ),
      _OnboardingData(
        icon: FontAwesomeIcons.shieldHalved,
        title: loc.tr('onboard3Title'),
        desc: loc.tr('onboard3Desc'),
        gradientColors: [AppTheme.accentAmber, AppTheme.primaryBlue],
      ),
      _OnboardingData(
        icon: FontAwesomeIcons.leaf,
        title: loc.tr('onboard4Title'),
        desc: loc.tr('onboard4Desc'),
        gradientColors: [AppTheme.accentGreen, AppTheme.accentCyan],
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: AppTheme.lightBackgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.webp',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SmartEnergy',
                      style: AppTheme.getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) => _OnboardingPageWidget(
                      page: pages[index],
                      isActive: _currentPage == index,
                    ),
                  ),
                ),
                // مؤشرات الصفحات — نيونية
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? AppTheme.accentCyan : AppTheme.lightBorder.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _currentPage == i
                            ? [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.4), blurRadius: 6)]
                            : [],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (_currentPage == pages.length - 1) {
                                widget.onComplete();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              _currentPage == pages.length - 1 ? loc.tr('getStarted') : loc.tr('next'),
                              style: AppTheme.getTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_currentPage < pages.length - 1)
                        TextButton(
                          onPressed: widget.onComplete,
                          child: Text(
                            loc.tr('skip'),
                            style: AppTheme.getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF414751),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatefulWidget {
  final _OnboardingData page;
  final bool isActive;
  const _OnboardingPageWidget({required this.page, required this.isActive});
  @override
  State<_OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<_OnboardingPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.page.gradientColors[0].withOpacity(0.12 * _pulseAnimation.value),
                        widget.page.gradientColors[1].withOpacity(0.04 * _pulseAnimation.value),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.page.gradientColors[0].withOpacity(0.15 * _pulseAnimation.value),
                        blurRadius: 50,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.page.gradientColors.map((c) => c.withOpacity(0.15)).toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.page.gradientColors[0].withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: FaIcon(
                      widget.page.icon,
                      size: 70,
                      color: widget.page.gradientColors[0],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          AppTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Text(
                    widget.page.title,
                    style: AppTheme.getTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C21),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.page.desc,
                    style: AppTheme.getTextStyle(
                      fontSize: 15,
                      color: const Color(0xFF414751),
                    ).copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final FaIconData icon;
  final String title, desc;
  final List<Color> gradientColors;
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.desc,
    required this.gradientColors,
  });
}
