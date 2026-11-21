import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/ui/app_icon.dart';
import '../../core/ui/fleet_sheet.dart';
import '../../core/ui/app_states.dart';
import '../../core/ui/pet_selector_chip.dart';
import '../../core/theme/app_numeric.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/timezone_provider.dart';
import '../../core/utils/pet_format.dart';
import '../../core/services/care_reminder_service.dart';
import '../shell/navigation_shell.dart' show kShellNavBarHeight;

class CareScreen extends ConsumerWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(activePetProvider);
    final schedules =
        ref
            .watch(careSchedulesProvider)
            .where((s) => pet != null && s.petId == pet.id)
            .toList()
          ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    final loc = ref.watch(timezoneLocationProvider);
    final code = ref.watch(localeProvider).languageCode;
    final vetLogs = ref
        .watch(vetLogsProvider)
        .where((v) => pet != null && v.petId == pet.id)
        .toList();

    final totalCost =
        vetLogs.fold<double>(0.0, (sum, v) => sum + (v.cost ?? 0.0));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCare),
        actions: [
          if (pet != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PetSelectorChip(pet: pet),
            ),
        ],
      ),
      body: ListView(
        // Clear the glass nav bar (extendBody).
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kShellNavBarHeight + 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.careSchedulesTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: pet == null
                    ? null
                    : () => _editSchedule(context, ref, pet),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.actionAddSchedule),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (schedules.isEmpty)
            AppEmpty(
              dense: true,
              icon: Icons.schedule,
              title: l10n.careEmptySchedules,
              actionLabel: pet != null ? l10n.actionAddSchedule : null,
              onAction: pet != null ? () => _editSchedule(context, ref, pet) : null,
              actionColor: AppColors.primary,
            )
          else
            ...schedules.map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _kindIcon(s.kind, color: AppColors.primary, size: 24),
                  title: Text(s.title),
                  subtitle: Text(
                    '${l10n.fieldLastDone}: ${PetFormat.date(s.lastDoneAt, loc, code)} · ${l10n.everyMonths(s.intervalMonths)}',
                    style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                  ),
                  // Countdown + action share one horizontal row: stacking them
                  // in a Column overflowed the 72dp tile by 9px.
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.daysRemaining <= 0
                            ? l10n.urgencyOverdue
                            : l10n.daysRemaining(s.daysRemaining),
                        style: TextStyle(
                          color: _urgencyColor(context, s.urgency),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ).tabular,
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        tooltip: l10n.actionMarkDone,
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () async {
                          await HapticFeedback.mediumImpact();
                          await ref
                              .read(careSchedulesProvider.notifier)
                              .markDone(s.id);
                          await _resyncReminders(ref);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(l10n.snackbarScheduleDone(s.title)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () => _editSchedule(context, ref, pet!, existing: s),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.vetLogsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (totalCost > 0)
                      Text(
                        l10n.fieldTotalCost(PetFormat.rupiah(totalCost, code)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontFeatures: AppNumeric.tabularFeatures,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: pet == null
                    ? null
                    : () => _editVet(context, ref, pet),
                icon: const AppIcon('vet_clinic', size: 18),
                label: Text(l10n.actionAddVet),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (vetLogs.isEmpty)
            AppEmpty(
              dense: true,
              icon: Icons.local_hospital_outlined,
              title: l10n.careEmptyVet,
              actionLabel: pet != null ? l10n.actionAddVet : null,
              onAction: pet != null ? () => _editVet(context, ref, pet) : null,
              actionColor: AppColors.primary,
            )
          else
            ...vetLogs.map(
              (v) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const AppIcon('vet_clinic', color: AppColors.primary, size: 24),
                  title: Text(v.title),
                  subtitle: Text(
                    [
                      if (v.clinic.isNotEmpty) v.clinic,
                      if (v.medication.isNotEmpty) v.medication,
                      if (v.cost != null) PetFormat.rupiah(v.cost!, code),
                      PetFormat.date(v.date, loc, code),
                    ].join(' · '),
                    style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                  ),
                  onTap: () => _editVet(context, ref, pet!, existing: v),
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

  Color _urgencyColor(BuildContext context, ScheduleUrgency urgency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (urgency) {
      ScheduleUrgency.overdue => isDark
          ? AppColors.urgencyOverdueDark
          : AppColors.urgencyOverdueLight,
      ScheduleUrgency.dueSoon => isDark
          ? AppColors.urgencyDueSoonDark
          : AppColors.urgencyDueSoonLight,
      ScheduleUrgency.safe =>
        isDark ? AppColors.urgencySafeDark : AppColors.urgencySafeLight,
    };
  }

  Widget _kindIcon(CareKind k, {Color? color, double size = 24}) => switch (k) {
    CareKind.vaccine => AppIcon('pet_vaccine', size: size, color: color),
    CareKind.deworm => AppIcon('pet_meds', size: size, color: color),
    CareKind.flea => AppIcon('pet_meds', size: size, color: color),
    CareKind.grooming => AppIcon('pet_paw', size: size, color: color),
    CareKind.other => AppIcon('pet_paw', size: size, color: color),
  };

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
    final loc = ref.read(timezoneLocationProvider);
    final code = ref.read(localeProvider).languageCode;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final monthsCtrl = TextEditingController(
      text: '${existing?.intervalMonths ?? 3}',
    );
    var kind = existing?.kind ?? CareKind.vaccine;
    var lastDone = existing?.lastDoneAt ?? DateTime.now().toUtc();
    final formKey = GlobalKey<FormState>();
    final ok = await showFleetSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setModal) => Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null
                      ? l10n.actionAddSchedule
                      : l10n.actionEditSchedule,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l10n.fieldTitle),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.errorTitleRequired
                      : null,
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: monthsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.fieldIntervalMonths,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n < 1) return l10n.errorIntervalRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.fieldLastDone),
                  subtitle: Text(
                    PetFormat.date(lastDone, loc, code),
                    style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined, size: 18),
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
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx, true);
                    }
                  },
                  child: Text(l10n.actionSave),
                ),
                if (existing != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.actionDelete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: Text(l10n.dialogDeleteRecordTitle),
                          content: Text(l10n.dialogDeleteRecordMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: Text(l10n.actionCancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: Text(l10n.actionDelete),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      await HapticFeedback.mediumImpact();
                      await ref
                          .read(careSchedulesProvider.notifier)
                          .remove(existing.id);
                      await _resyncReminders(ref);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx, false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.snackbarRecordDeleted)),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final months = int.parse(monthsCtrl.text.trim());
    final err = await ref
        .read(careSchedulesProvider.notifier)
        .upsert(
          CareSchedule(
            id:
                existing?.id ??
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorTitleRequired)));
      return;
    }
    await HapticFeedback.mediumImpact();
    await _resyncReminders(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.snackbarSaved)));
  }

  Future<void> _editVet(
    BuildContext context,
    WidgetRef ref,
    Pet pet, {
    VetLog? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final loc = ref.read(timezoneLocationProvider);
    final code = ref.read(localeProvider).languageCode;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final clinicCtrl = TextEditingController(text: existing?.clinic ?? '');
    final medCtrl = TextEditingController(text: existing?.medication ?? '');
    final costCtrl = TextEditingController(
      text: existing?.cost?.toStringAsFixed(0) ?? '',
    );
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    var date = existing?.date ?? DateTime.now().toUtc();
    final formKey = GlobalKey<FormState>();
    final ok = await showFleetSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setModal) => Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldTitle),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.errorTitleRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: clinicCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldClinic),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: medCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.fieldMedication,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.fieldCost,
                      prefixText: 'Rp ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final raw = v.replaceAll(',', '.').trim();
                      final n = double.tryParse(raw);
                      if (n == null || n < 0) return l10n.errorCostInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.fieldNotes),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.fieldDate),
                    subtitle: Text(
                      PetFormat.date(date, loc, code),
                      style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined, size: 18),
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
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: Text(l10n.actionSave),
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.actionDelete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (dCtx) => AlertDialog(
                            title: Text(l10n.dialogDeleteRecordTitle),
                            content: Text(l10n.dialogDeleteRecordMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, false),
                                child: Text(l10n.actionCancel),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(dCtx, true),
                                child: Text(l10n.actionDelete),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        await HapticFeedback.mediumImpact();
                        await ref
                            .read(vetLogsProvider.notifier)
                            .remove(existing.id);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx, false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.snackbarRecordDeleted),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final costText = costCtrl.text.replaceAll(',', '.').trim();
    final cost = costText.isEmpty ? null : double.tryParse(costText);
    final err = await ref
        .read(vetLogsProvider.notifier)
        .upsert(
          VetLog(
            id:
                existing?.id ??
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorTitleRequired)));
      return;
    }
    await HapticFeedback.mediumImpact();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.snackbarSaved)));
  }
}
