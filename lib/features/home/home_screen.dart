import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
        onPressed: () => _showPetEditor(context, ref),
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
              child: ListTile(
                leading: _PetAvatar(pet: active),
                title: Text(
                  active.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  [
                    _speciesLabel(l10n, active.species),
                    if (active.breed.isNotEmpty) active.breed,
                    if (active.weightKg != null)
                      '${active.weightKg!.toStringAsFixed(1)} kg',
                    if (active.dateOfBirth != null)
                      _formatDob(active.dateOfBirth!),
                  ].join(' · '),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      _showPetEditor(context, ref, existing: active),
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
                leading: _PetAvatar(pet: p, radius: 18),
                title: Text(p.name),
                subtitle: Text(_speciesLabel(l10n, p.species)),
                selected: p.id == active?.id,
                onTap: () =>
                    ref.read(activePetIdProvider.notifier).setActiveId(p.id),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () =>
                      _showPetEditor(context, ref, existing: p),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDob(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  String _speciesLabel(AppLocalizations l10n, PetSpecies s) => switch (s) {
        PetSpecies.dog => l10n.speciesDog,
        PetSpecies.cat => l10n.speciesCat,
        PetSpecies.bird => l10n.speciesBird,
        PetSpecies.rabbit => l10n.speciesRabbit,
        PetSpecies.other => l10n.speciesOther,
      };

  Future<void> _showPetEditor(
    BuildContext context,
    WidgetRef ref, {
    Pet? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final breedCtrl = TextEditingController(text: existing?.breed ?? '');
    final weightCtrl = TextEditingController(
      text: existing?.weightKg?.toStringAsFixed(1) ?? '',
    );
    var species = existing?.species ?? PetSpecies.dog;
    DateTime? dob = existing?.dateOfBirth;
    String? photoPath = existing?.photoPath;
    final formKey = GlobalKey<FormState>();

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
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existing == null
                            ? l10n.actionAddPet
                            : l10n.actionEditPet,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: kIsWeb
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final file = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1024,
                                  );
                                  if (file != null) {
                                    setModal(() => photoPath = file.path);
                                  }
                                },
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            backgroundImage: (!kIsWeb &&
                                    photoPath != null &&
                                    File(photoPath!).existsSync())
                                ? FileImage(File(photoPath!))
                                : null,
                            child: (photoPath == null)
                                ? const Icon(Icons.camera_alt_outlined,
                                    color: AppColors.primary)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration:
                            InputDecoration(labelText: l10n.fieldPetName),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return l10n.errorPetNameRequired;
                          }
                          return null;
                        },
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
                        decoration:
                            InputDecoration(labelText: l10n.fieldSpecies),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: breedCtrl,
                        decoration: InputDecoration(labelText: l10n.fieldBreed),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            InputDecoration(labelText: l10n.fieldWeightKg),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final w = double.tryParse(v.trim());
                          if (w == null || w <= 0 || w > 500) {
                            return l10n.errorWeightInvalid;
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.fieldDateOfBirth),
                        subtitle: Text(
                          dob == null
                              ? l10n.fieldOptional
                              : _formatDob(dob!),
                        ),
                        trailing: const Icon(Icons.cake_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: dob != null
                                ? dob!.toLocal()
                                : DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModal(
                              () => dob = DateTime.utc(
                                picked.year,
                                picked.month,
                                picked.day,
                              ),
                            );
                          }
                        },
                      ),
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx, true);
                          }
                        },
                        child: Text(l10n.actionSave),
                      ),
                    ],
                  ),
                ),
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
            id: existing?.id ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            name: nameCtrl.text.trim(),
            species: species,
            breed: breedCtrl.text.trim(),
            weightKg: weight,
            dateOfBirth: dob,
            photoPath: photoPath,
            notes: existing?.notes ?? '',
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

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.pet, this.radius = 24});

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
      child: Icon(Icons.pets, color: AppColors.primary, size: radius),
    );
  }
}
