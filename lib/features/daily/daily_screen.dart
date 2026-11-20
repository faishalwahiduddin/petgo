import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/ui/app_states.dart';
import '../../core/ui/pet_selector_chip.dart';
import '../../core/theme/app_numeric.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/timezone_provider.dart';
import '../../core/utils/pet_format.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(activePetProvider);
    final loc = ref.watch(timezoneLocationProvider);
    final code = ref.watch(localeProvider).languageCode;
    final logs = ref
        .watch(dailyLogsProvider)
        .where((e) => pet != null && e.petId == pet.id)
        .toList();
    final weights = ref
        .watch(weightLogsProvider)
        .where((e) => pet != null && e.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDaily),
        actions: [
          if (pet != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PetSelectorChip(pet: pet),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Text(
            l10n.dailyQuickAdd,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in [
                DailyCareKind.feed,
                DailyCareKind.walk,
                DailyCareKind.litter,
              ])
                ActionChip(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  avatar: Icon(_icon(kind), size: 20),
                  label: Text(
                    _dailyLabel(l10n, kind),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: pet == null
                      ? null
                      : () async {
                          await HapticFeedback.mediumImpact();
                          await ref.read(dailyLogsProvider.notifier).add(
                                DailyCareLog(
                                  id: DateTime.now()
                                      .microsecondsSinceEpoch
                                      .toString(),
                                  petId: pet.id,
                                  date: DateTime.now().toUtc(),
                                  kind: kind,
                                ),
                              );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.snackbarQuickLogDone(
                                  _dailyLabel(l10n, kind),
                                ),
                              ),
                            ),
                          );
                        },
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: pet == null ? null : () => _addWeight(context, ref, pet),
            icon: const Icon(Icons.monitor_weight_outlined),
            label: Text(l10n.actionAddWeight),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.dailyTimeline,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            AppEmpty(dense: true, icon: Icons.history, title: l10n.dailyEmpty)
          else
            ...logs.take(30).map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_icon(e.kind), color: AppColors.primary),
                      title: Text(_dailyLabel(l10n, e.kind)),
                      subtitle: Text(
                        PetFormat.dateTime(e.date, loc, code),
                        style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                      ),
                      trailing: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: l10n.actionDelete,
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: Text(l10n.dialogDeleteRecordTitle),
                                content: Text(l10n.dialogDeleteRecordMessage),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dCtx, false),
                                    child: Text(l10n.actionCancel),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.danger,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dCtx, true),
                                    child: Text(l10n.actionDelete),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;
                            final deleted = e;
                            await HapticFeedback.mediumImpact();
                            await ref
                                .read(dailyLogsProvider.notifier)
                                .remove(e.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.snackbarDailyLogDeleted),
                                action: SnackBarAction(
                                  label: l10n.actionUndo,
                                  onPressed: () async {
                                    await ref
                                        .read(dailyLogsProvider.notifier)
                                        .add(deleted);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
          if (weights.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.weightHistory,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...weights.map(
                  (w) => ListTile(
                    title: Text(
                      '${w.weightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                    ),
                    subtitle: Text(
                      PetFormat.dateTime(w.date, loc, code),
                      style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                    ),
                    trailing: SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: l10n.actionDelete,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              title: Text(l10n.dialogDeleteRecordTitle),
                              content: Text(l10n.dialogDeleteRecordMessage),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dCtx, false),
                                  child: Text(l10n.actionCancel),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dCtx, true),
                                  child: Text(l10n.actionDelete),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                          await HapticFeedback.mediumImpact();
                          await ref
                              .read(weightLogsProvider.notifier)
                              .remove(w.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.snackbarRecordDeleted),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  IconData _icon(DailyCareKind k) => switch (k) {
        DailyCareKind.feed => Icons.restaurant,
        DailyCareKind.walk => Icons.directions_walk,
        DailyCareKind.litter => Icons.delete_outline,
        DailyCareKind.other => Icons.pets,
      };

  String _dailyLabel(AppLocalizations l10n, DailyCareKind k) => switch (k) {
        DailyCareKind.feed => l10n.dailyFeed,
        DailyCareKind.walk => l10n.dailyWalk,
        DailyCareKind.litter => l10n.dailyLitter,
        DailyCareKind.other => l10n.dailyOther,
      };

  Future<void> _addWeight(
    BuildContext context,
    WidgetRef ref,
    Pet pet,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(
      text: pet.weightKg?.toStringAsFixed(1) ?? '',
    );
    String? inlineError;

    final savedWeight = await showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.actionAddWeight),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.fieldWeightKg,
              errorText: inlineError,
            ),
            onChanged: (_) {
              if (inlineError != null) {
                setDialogState(() => inlineError = null);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                final raw = ctrl.text.replaceAll(',', '.').trim();
                final w = double.tryParse(raw);
                if (w == null || w <= 0 || w > 500) {
                  setDialogState(() {
                    inlineError = l10n.errorWeightInvalid;
                  });
                  return;
                }
                Navigator.pop(ctx, w);
              },
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
    if (savedWeight == null || !context.mounted) return;
    final err = await ref.read(weightLogsProvider.notifier).add(
          WeightLog(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            date: DateTime.now().toUtc(),
            weightKg: savedWeight,
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWeightInvalid)),
      );
    } else {
      await HapticFeedback.mediumImpact();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackbarSaved)),
      );
    }
  }
}
