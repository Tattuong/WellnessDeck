import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/navigation/app_navigator.dart';

class DeckDialogs {
  DeckDialogs._();

  static Future<void> settleIme() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  static Future<String?> title(
    BuildContext context, {
    required String heading,
    String? initial,
    String? hintKey,
  }) async {
    await settleIme();
    final navContext = rootNavigatorKey.currentContext ?? context;
    if (!navContext.mounted) return null;

    final value = await showDialog<String>(
      context: navContext,
      useRootNavigator: true,
      builder: (_) => _TitlePrompt(
        heading: heading,
        initial: initial ?? '',
        hintKey: hintKey ?? 'taskHint',
      ),
    );
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}

class _TitlePrompt extends StatefulWidget {
  final String heading;
  final String initial;
  final String hintKey;

  const _TitlePrompt({required this.heading, required this.initial, required this.hintKey});

  @override
  State<_TitlePrompt> createState() => _TitlePromptState();
}

class _TitlePromptState extends State<_TitlePrompt> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _pop([String? value]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context, rootNavigator: true).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.heading),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: AppStrings.t(context, widget.hintKey)),
        onSubmitted: _pop,
      ),
      actions: [
        TextButton(onPressed: _pop, child: Text(AppStrings.t(context, 'cancel'))),
        FilledButton(onPressed: () => _pop(_ctrl.text), child: Text(AppStrings.t(context, 'save'))),
      ],
    );
  }
}
