import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/providers/app_providers.dart';
import '../../core/ui/fleet_consent_gate.dart';

/// First-run consent. The copy and the accept behaviour are unchanged; the
/// presentation is the fleet's Character Welcome gate.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return FleetConsentGate(
      appName: l10n.appTitle,
      headline: l10n.onboardingHeadline,
      body: l10n.onboardingDescription,
      ctaLabel: l10n.onboardingContinue,
      primary: scheme.primary,
      accent: scheme.tertiary,
      icon: Icons.pets,
      onAccept: () => ref.read(disclaimerProvider.notifier).accept(),
    );
  }
}
