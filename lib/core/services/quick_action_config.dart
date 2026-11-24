import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'quick_action_notification.dart';

const int kQuickNotifAccentColor = 0xFFD97706;

const List<QuickNotifAction> kQuickNotifActions = [
  QuickNotifAction(id: 'home', label: 'Pets', route: '/', iconRes: 'ic_qa_home'),
  QuickNotifAction(id: 'care', label: 'Care', route: '/care', iconRes: 'ic_qa_care'),
  QuickNotifAction(id: 'daily', label: 'Daily', route: '/daily', iconRes: 'ic_qa_daily'),
  QuickNotifAction(id: 'docs', label: 'Docs', route: '/docs', iconRes: 'ic_qa_docs'),
];

bool _quickActionWired = false;

extension QuickActionGoRouterX on GoRouter {
  GoRouter withQuickActions() {
    wireQuickActionRouter(this);
    return this;
  }
}

/// Wires CamScanner-style Quick Action Notification taps to [router].
void wireQuickActionRouter(GoRouter router) {
  if (!QuickActionNotificationService.isSupported || _quickActionWired) return;
  _quickActionWired = true;
  QuickActionNotificationService.setActionHandler((route) {
    router.go(route);
  });
  QuickActionNotificationService.getInitialActionRoute().then((route) {
    if (route != null && route.isNotEmpty) {
      router.go(route);
    }
  });
}

/// Shows or hides the 4-action Quick Actions notification bar.
Future<bool> setQuickActionNotificationEnabled(bool enabled) async {
  if (enabled) {
    return QuickActionNotificationService.show(
      actions: kQuickNotifActions,
      accentColorArgb: kQuickNotifAccentColor,
    );
  }
  await QuickActionNotificationService.hide();
  return true;
}

/// Self-contained Settings switch for toggling the Quick Actions notification bar.
class QuickActionNotifSwitchTile extends StatefulWidget {
  const QuickActionNotifSwitchTile({
    super.key,
    this.title = 'Quick Actions Bar',
    this.subtitle = 'Pin 4 shortcuts in the Android notification shade',
  });

  final String title;
  final String subtitle;

  @override
  State<QuickActionNotifSwitchTile> createState() =>
      _QuickActionNotifSwitchTileState();
}

class _QuickActionNotifSwitchTileState
    extends State<QuickActionNotifSwitchTile> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    if (QuickActionNotificationService.isSupported) {
      QuickActionNotificationService.isEnabled().then((val) {
        if (mounted) setState(() => _enabled = val);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!QuickActionNotificationService.isSupported) {
      return const SizedBox.shrink();
    }
    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.bolt_rounded),
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      value: _enabled,
      onChanged: (value) async {
        final ok = await setQuickActionNotificationEnabled(value);
        if (!mounted) return;
        setState(() => _enabled = value && ok);
      },
    );
  }
}
