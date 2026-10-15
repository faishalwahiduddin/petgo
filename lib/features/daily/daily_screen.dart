import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(activePetProvider);
    final logs = ref
        .watch(dailyLogsProvider)
        .where((e) => pet != null && e.petId == pet.id)
        .toList();
    final weights = ref
        .watch(weightLogsProvider)
        .where((e) => pet != null && e.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDaily)),
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
                  avatar: Icon(_icon(kind), size: 18),
                  label: Text(_dailyLabel(l10n, kind)),
                  onPressed: pet == null
                      ? null
                      : () => ref.read(dailyLogsProvider.notifier).add(
                            DailyCareLog(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              petId: pet.id,
                              date: DateTime.now().toUtc(),
                              kind: kind,
                            ),
                          ),
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
            Text(l10n.dailyEmpty,
                style: const TextStyle(color: AppColors.inkSoft))
          else
            ...logs.take(30).map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_icon(e.kind), color: AppColors.primary),
                      title: Text(_dailyLabel(l10n, e.kind)),
                      subtitle: Text(
                        e.date.toLocal().toString().split('.').first,
                      ),
                      onLongPress: () =>
                          ref.read(dailyLogsProvider.notifier).remove(e.id),
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
                    title: Text('${w.weightKg.toStringAsFixed(1)} kg'),
                    subtitle: Text(
                      w.date.toLocal().toString().split('.').first,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(weightLogsProvider.notifier).remove(w.id),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.actionAddWeight),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.fieldWeightKg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final w = double.tryParse(ctrl.text.trim());
    if (w == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWeightInvalid)),
      );
      return;
    }
    final err = await ref.read(weightLogsProvider.notifier).add(
          WeightLog(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            date: DateTime.now().toUtc(),
            weightKg: w,
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWeightInvalid)),
      );
    }
  }
}
