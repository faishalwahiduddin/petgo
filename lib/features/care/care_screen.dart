import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/care_reminder_service.dart';

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
            onPressed: pet == null
                ? null
                : () => _editVet(context, ref, pet),
            icon: const Icon(Icons.local_hospital_outlined),
            label: Text(l10n.actionAddVet),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'sch',
            onPressed: pet == null
                ? null
                : () => _editSchedule(context, ref, pet),
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
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
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
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(careSchedulesProvider.notifier)
                              .markDone(s.id);
                          await _resyncReminders(ref);
                        },
                        child: Text(l10n.actionMarkDone),
                      ),
                    ],
                  ),
                  onTap: () => _editSchedule(context, ref, pet!, existing: s),
                  onLongPress: () async {
                    await ref
                        .read(careSchedulesProvider.notifier)
                        .remove(s.id);
                    await _resyncReminders(ref);
                  },
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
                      if (v.cost != null) 'Rp ${v.cost!.toStringAsFixed(0)}',
                      v.date.toLocal().toString().split('.').first,
                    ].join(' · '),
                  ),
                  onTap: () => _editVet(context, ref, pet!, existing: v),
                  onLongPress: () =>
                      ref.read(vetLogsProvider.notifier).remove(v.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _resyncReminders(WidgetRef ref) async {
    await CareReminderService.instance.reschedule(
      ref.read(careSchedulesProvider),
      enabled: ref.read(remindersEnabledProvider),
    );
  }

  String _kindLabel(AppLocalizations l10n, CareKind k) => switch (k) {
        CareKind.vaccine => l10n.careVaccine,
        CareKind.deworm => l10n.careDeworm,
        CareKind.flea => l10n.careFlea,
        CareKind.grooming => l10n.careGrooming,
        CareKind.other => l10n.careOther,
      };

  Future<void> _editSchedule(
    BuildContext context,
    WidgetRef ref,
    Pet pet, {
    CareSchedule? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final monthsCtrl = TextEditingController(
      text: '${existing?.intervalMonths ?? 3}',
    );
    var kind = existing?.kind ?? CareKind.vaccine;
    var lastDone = existing?.lastDoneAt ?? DateTime.now().toUtc();
    final formKey = GlobalKey<FormState>();
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
          builder: (context, setModal) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null
                      ? l10n.actionAddSchedule
                      : l10n.actionEditSchedule,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l10n.fieldTitle),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.errorTitleRequired : null,
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
                TextFormField(
                  controller: monthsCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: l10n.fieldIntervalMonths),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n < 1) return l10n.errorIntervalRequired;
                    return null;
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.fieldLastDone),
                  subtitle: Text(
                    lastDone.toLocal().toString().split(' ').first,
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: lastDone.toLocal(),
                      firstDate: DateTime(2015),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) {
                      setModal(
                        () => lastDone = DateTime.utc(d.year, d.month, d.day),
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
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final months = int.parse(monthsCtrl.text.trim());
    final err = await ref.read(careSchedulesProvider.notifier).upsert(
          CareSchedule(
            id: existing?.id ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            title: titleCtrl.text.trim(),
            kind: kind,
            intervalMonths: months,
            lastDoneAt: lastDone,
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorTitleRequired)),
      );
      return;
    }
    await _resyncReminders(ref);
  }

  Future<void> _editVet(
    BuildContext context,
    WidgetRef ref,
    Pet pet, {
    VetLog? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final clinicCtrl = TextEditingController(text: existing?.clinic ?? '');
    final medCtrl = TextEditingController(text: existing?.medication ?? '');
    final costCtrl = TextEditingController(
      text: existing?.cost?.toStringAsFixed(0) ?? '',
    );
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    var date = existing?.date ?? DateTime.now().toUtc();
    final formKey = GlobalKey<FormState>();
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
          builder: (context, setModal) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? l10n.actionAddVet : l10n.actionEditVet,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldTitle),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.errorTitleRequired
                        : null,
                  ),
                  TextFormField(
                    controller: clinicCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldClinic),
                  ),
                  TextFormField(
                    controller: medCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldMedication),
                  ),
                  TextFormField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.fieldCost),
                  ),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.fieldNotes),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.fieldDate),
                    subtitle: Text(
                      date.toLocal().toString().split(' ').first,
                    ),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: date.toLocal(),
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) {
                        setModal(
                          () => date = DateTime.utc(d.year, d.month, d.day),
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
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final cost = double.tryParse(costCtrl.text.trim());
    final err = await ref.read(vetLogsProvider.notifier).upsert(
          VetLog(
            id: existing?.id ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            date: date,
            title: titleCtrl.text.trim(),
            clinic: clinicCtrl.text.trim(),
            medication: medCtrl.text.trim(),
            cost: cost,
            notes: notesCtrl.text.trim(),
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
