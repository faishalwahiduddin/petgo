import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.onboardingHeadline,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => ref.read(disclaimerProvider.notifier).accept(),
                child: Text(l10n.onboardingContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
