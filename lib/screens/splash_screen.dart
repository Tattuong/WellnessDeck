import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/services/sound_service.dart';
import '../providers/wellness_provider.dart';
import 'home/main_shell.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _enterCtrl.forward();
    _boot();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      await Future.wait([
        context.read<WellnessProvider>().init(),
        Future<void>.delayed(const Duration(milliseconds: 500)),
      ]).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Splash boot timeout/error: $e');
    }
    if (!mounted) return;
    SoundService.instance.navigate();
    final onboarded = context.read<WellnessProvider>().onboardingComplete;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => onboarded ? const MainShell() : const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B2740);
    const cream = Color(0xFFF4F1EC);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: cream,
      ),
      child: Scaffold(
        backgroundColor: cream,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          color: cream,
                          child: Image.asset(
                            'assets/logo_padded.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          AppStrings.t(context, 'appName'),
                          style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, color: navy),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            AppStrings.t(context, 'appTagline'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF6B7288)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                Text(AppStrings.t(context, 'loading'), style: GoogleFonts.nunito(color: const Color(0xFF6B7288), fontWeight: FontWeight.w600)),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
