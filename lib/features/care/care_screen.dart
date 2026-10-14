import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';

class CareScreen extends ConsumerWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(activePetProvider);
    final schedules = ref
        .watch(careSchedulesProvider)
        .where((s) => pet != null && s.petId == pet.id)
        .toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    final vetLogs = ref
        .watch(vetLogsProvider)
        .where((v) => pet != null && v.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCare)),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'vet',
            onPressed: pet == null ? null : () => _addVet(context, ref, pet),
            icon: const Icon(Icons.local_hospital_outlined),
            label: Text(l10n.actionAddVet),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'sch',
            onPressed:
                pet == null ? null : () => _addSchedule(context, ref, pet),
            icon: const Icon(Icons.add),
            label: Text(l10n.actionAddSchedule),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        children: [
          Text(
            l10n.careSchedulesTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (schedules.isEmpty)
            Text(l10n.careEmptySchedules,
                style: const TextStyle(color: AppColors.inkSoft))
          else
            ...schedules.map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(s.title),
                  subtitle: Text(
                    '${_kindLabel(l10n, s.kind)} · ${l10n.everyMonths(s.intervalMonths)}',
                  ),
                  trailing: Text(
                    s.daysRemaining <= 0
                        ? l10n.urgencyOverdue
                        : l10n.daysRemaining(s.daysRemaining),
                    style: TextStyle(
                      color: s.urgency == ScheduleUrgency.overdue
                          ? AppColors.danger
                          : s.urgency == ScheduleUrgency.dueSoon
                              ? AppColors.warning
                              : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onLongPress: () =>
                      ref.read(careSchedulesProvider.notifier).remove(s.id),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            l10n.vetLogsTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (vetLogs.isEmpty)
            Text(l10n.careEmptyVet,
                style: const TextStyle(color: AppColors.inkSoft))
          else
            ...vetLogs.map(
              (v) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(v.title),
                  subtitle: Text(
                    [
                      if (v.clinic.isNotEmpty) v.clinic,
                      if (v.medication.isNotEmpty) v.medication,
                      v.date.toLocal().toString().split('.').first,
                    ].join(' · '),
                  ),
                  onLongPress: () =>
                      ref.read(vetLogsProvider.notifier).remove(v.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _kindLabel(AppLocalizations l10n, CareKind k) => switch (k) {
        CareKind.vaccine => l10n.careVaccine,
        CareKind.deworm => l10n.careDeworm,
        CareKind.flea => l10n.careFlea,
        CareKind.grooming => l10n.careGrooming,
        CareKind.other => l10n.careOther,
      };

  Future<void> _addSchedule(
    BuildContext context,
    WidgetRef ref,
    Pet pet,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final monthsCtrl = TextEditingController(text: '3');
    var kind = CareKind.vaccine;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModal) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.actionAddSchedule,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l10n.fieldTitle),
              ),
              DropdownButtonFormField<CareKind>(
                // ignore: deprecated_member_use
                value: kind,
                items: CareKind.values
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(_kindLabel(l10n, k)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setModal(() => kind = v);
                },
              ),
              TextField(
                controller: monthsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.fieldIntervalMonths),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final months = int.tryParse(monthsCtrl.text.trim()) ?? 0;
    final err = await ref.read(careSchedulesProvider.notifier).upsert(
          CareSchedule(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            title: titleCtrl.text.trim(),
            kind: kind,
            intervalMonths: months,
            lastDoneAt: DateTime.now().toUtc(),
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err == 'errorTitleRequired'
                ? l10n.errorTitleRequired
                : l10n.errorIntervalRequired,
          ),
        ),
      );
    }
  }

  Future<void> _addVet(BuildContext context, WidgetRef ref, Pet pet) async {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final clinicCtrl = TextEditingController();
    final medCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.actionAddVet,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: l10n.fieldTitle),
            ),
            TextField(
              controller: clinicCtrl,
              decoration: InputDecoration(labelText: l10n.fieldClinic),
            ),
            TextField(
              controller: medCtrl,
              decoration: InputDecoration(labelText: l10n.fieldMedication),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await ref.read(vetLogsProvider.notifier).upsert(
          VetLog(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            date: DateTime.now().toUtc(),
            title: titleCtrl.text.trim(),
            clinic: clinicCtrl.text.trim(),
            medication: medCtrl.text.trim(),
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorTitleRequired)),
      );
    }
  }
}
