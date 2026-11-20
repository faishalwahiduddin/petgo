import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/core/constants/app_colors.dart';
import 'package:petgo/core/models/pet.dart';
import 'package:petgo/core/providers/app_providers.dart';
import 'package:petgo/core/ui/fleet_sheet.dart';
import 'package:petgo/l10n/app_localizations.dart';

class PetSelectorChip extends ConsumerWidget {
  const PetSelectorChip({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: pet.name,
      child: Material(
        color: isDark ? AppColors.bgSurface : AppColors.bgLightElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openSwitcher(context, ref, pets),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniAvatar(pet: pet),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      pet.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSwitcher(BuildContext context, WidgetRef ref, List<Pet> pets) {
    final l10n = AppLocalizations.of(context)!;
    showFleetSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  l10n.homeAllPets,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...pets.map((p) {
                final isSelected = p.id == pet.id;
                return ListTile(
                  leading: _MiniAvatar(pet: p, radius: 16),
                  title: Text(
                    p.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(_speciesLabel(l10n, p.species)),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(ctx).colorScheme.primary,
                        )
                      : null,
                  onTap: () async {
                    await HapticFeedback.selectionClick();
                    await ref.read(activePetIdProvider.notifier).setActiveId(p.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _speciesLabel(AppLocalizations l10n, PetSpecies s) => switch (s) {
        PetSpecies.dog => l10n.speciesDog,
        PetSpecies.cat => l10n.speciesCat,
        PetSpecies.bird => l10n.speciesBird,
        PetSpecies.rabbit => l10n.speciesRabbit,
        PetSpecies.other => l10n.speciesOther,
      };
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.pet, this.radius = 11});

  final Pet pet;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final path = pet.photoPath;
    if (!kIsWeb && path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Icon(Icons.pets, color: AppColors.primary, size: radius * 1.1),
    );
  }
}
