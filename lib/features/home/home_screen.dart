import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pets = ref.watch(petsProvider);
    final active = ref.watch(activePetProvider);
    final schedules = ref.watch(careSchedulesProvider);
    final due = schedules
        .where((s) => active != null && s.petId == active.id)
        .where((s) => s.urgency != ScheduleUrgency.safe)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionAddPet),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Text(
            l10n.homeActivePet,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (pets.isEmpty)
            Text(l10n.homeNoPets)
          else
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: active?.id,
              items: pets
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.name} · ${_speciesLabel(l10n, p.species)}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(activePetIdProvider.notifier).setActiveId(v);
                }
              },
            ),
          if (active != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        _speciesLabel(l10n, active.species),
                        if (active.breed.isNotEmpty) active.breed,
                        if (active.weightKg != null)
                          '${active.weightKg!.toStringAsFixed(1)} kg',
                      ].join(' · '),
                      style: const TextStyle(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            l10n.homeDueSoon,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (due.isEmpty)
            Text(l10n.homeNoDue, style: const TextStyle(color: AppColors.inkSoft))
          else
            ...due.map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    s.urgency == ScheduleUrgency.overdue
                        ? Icons.warning_amber_rounded
                        : Icons.schedule,
                    color: s.urgency == ScheduleUrgency.overdue
                        ? AppColors.danger
                        : AppColors.warning,
                  ),
                  title: Text(s.title),
                  subtitle: Text(
                    s.daysRemaining <= 0
                        ? l10n.urgencyOverdue
                        : l10n.daysRemaining(s.daysRemaining),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            l10n.homeAllPets,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...pets.map(
            (p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.pets, color: AppColors.primary),
                title: Text(p.name),
                subtitle: Text(_speciesLabel(l10n, p.species)),
                selected: p.id == active?.id,
                onTap: () =>
                    ref.read(activePetIdProvider.notifier).setActiveId(p.id),
              ),
            ),
          ),
        ],
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

  Future<void> _showAddPet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    var species = PetSpecies.dog;
    final weightCtrl = TextEditingController();
    final breedCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.actionAddPet,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldPetName),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PetSpecies>(
                    // ignore: deprecated_member_use
                    value: species,
                    items: PetSpecies.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_speciesLabel(l10n, s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModal(() => species = v);
                    },
                    decoration: InputDecoration(labelText: l10n.fieldSpecies),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: breedCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldBreed),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.fieldWeightKg),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l10n.actionSave),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (ok != true || !context.mounted) return;
    final weight = double.tryParse(weightCtrl.text.trim());
    final err = await ref.read(petsProvider.notifier).upsert(
          Pet(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: nameCtrl.text.trim(),
            species: species,
            breed: breedCtrl.text.trim(),
            weightKg: weight,
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapErr(l10n, err))),
      );
    }
  }

  String _mapErr(AppLocalizations l10n, String code) => switch (code) {
        'errorPetNameRequired' => l10n.errorPetNameRequired,
        'errorPetNameTooLong' => l10n.errorPetNameTooLong,
        'errorWeightInvalid' => l10n.errorWeightInvalid,
        _ => code,
      };
}
