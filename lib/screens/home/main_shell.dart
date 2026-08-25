import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/services/sound_service.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/deck_look.dart';
import '../../widgets/deck_nav.dart';
import 'build_screen.dart';
import 'patterns_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    AppTabs.index.addListener(_onTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ShopProvider>().claimDailyReward();
    });
  }

  void _onTab() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppTabs.index.removeListener(_onTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = AppTabs.index.value.clamp(0, 3);
    context.select<ShopProvider, String>((s) => '${s.activeThemeId}|${s.activeBackgroundId}|${s.activeSkinId}');

    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF1E253C),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
      backgroundColor: DeckLook.pageOf(context),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: FtrBackground(
        child: IndexedStack(
          index: index,
          children: [
            _InsetScope(active: index == 0, child: const RepaintBoundary(child: TodayScreen())),
            _InsetScope(active: index == 1, child: const RepaintBoundary(child: BuildScreen())),
            _InsetScope(active: index == 2, child: const RepaintBoundary(child: PatternsScreen())),
            _InsetScope(active: index == 3, child: const RepaintBoundary(child: SettingsScreen(embedded: true))),
          ],
        ),
      ),
      bottomNavigationBar: DeckNavBar(
        index: index,
        todayLabel: AppStrings.t(context, 'navToday'),
        buildLabel: AppStrings.t(context, 'navBuild'),
        patternsLabel: AppStrings.t(context, 'navPatterns'),
        menuLabel: AppStrings.t(context, 'navMore'),
        onSelect: (i) {
          SoundService.instance.tap();
          switch (i) {
            case 0:
              AppTabs.goToday();
            case 1:
              AppTabs.goWorkspace();
            case 2:
              AppTabs.goCockpit();
            case 3:
              AppTabs.goSettings();
          }
        },
      ),
      ),
    );
  }
}

class _InsetScope extends StatelessWidget {
  final bool active;
  final Widget child;

  const _InsetScope({required this.active, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: active ? mq : mq.copyWith(viewInsets: EdgeInsets.zero),
      child: child,
    );
  }
}
