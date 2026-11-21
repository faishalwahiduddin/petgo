import 'package:file_picker/file_picker.dart';
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
import '../shell/navigation_shell.dart' show kShellNavBarHeight;

class DocsScreen extends ConsumerWidget {
  const DocsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(activePetProvider);
    final loc = ref.watch(timezoneLocationProvider);
    final code = ref.watch(localeProvider).languageCode;
    final docs = ref
        .watch(documentsProvider)
        .where((d) => pet != null && d.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDocs),
        actions: [
          if (pet != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PetSelectorChip(pet: pet),
            ),
        ],
      ),
      floatingActionButton: Padding(
        // Lift above the shell's glass nav bar (extendBody) so it stays tappable.
        padding: const EdgeInsets.only(bottom: kShellNavBarHeight),
        child: FloatingActionButton.extended(
          onPressed: pet == null ? null : () => _editDoc(context, ref, pet),
          icon: const Icon(Icons.add),
          label: Text(l10n.actionAddDoc),
        ),
      ),
      body: docs.isEmpty
          ? AppEmpty(
              icon: Icons.description_outlined,
              title: l10n.docsEmpty,
              actionLabel: pet != null ? l10n.actionAddDoc : null,
              onAction: pet != null ? () => _editDoc(context, ref, pet) : null,
              actionColor: AppColors.primary,
            )
          : ListView.separated(
              // Clear the FAB (56) and its margin above the nav bar.
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                kShellNavBarHeight +
                    kFloatingActionButtonMargin +
                    56 +
                    kFloatingActionButtonMargin,
              ),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = docs[i];
                final kindLabel = _docLabel(l10n, d.kind);
                final repeatsKind =
                    d.title.trim().toLowerCase() == kindLabel.toLowerCase();
                return Card(
                  child: ListTile(
                    leading: const AppIcon('nav_docs',
                        color: AppColors.primary, size: 24),
                    title: Text(d.title),
                    subtitle: Text(
                      [
                        if (!repeatsKind) kindLabel,
                        if (d.expiresAt != null)
                          '${l10n.fieldExpires}: ${PetFormat.date(d.expiresAt!, loc, code)}',
                      ].join(' · '),
                      style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                    ),
                    trailing: d.filePath != null
                        ? Icon(
                            Icons.attach_file,
                            size: 20,
                            color: context.textSecondary,
                          )
                        : null,
                    onTap: () => _editDoc(context, ref, pet!, existing: d),
                  ),
                );
              },
            ),
    );
  }

  String _docLabel(AppLocalizations l10n, DocKind k) => switch (k) {
        DocKind.vaccineCard => l10n.docVaccineCard,
        DocKind.prescription => l10n.docPrescription,
        DocKind.insurance => l10n.docInsurance,
        DocKind.other => l10n.docOther,
      };

  Future<void> _editDoc(
    BuildContext context,
    WidgetRef ref,
    Pet pet, {
    PetDocument? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final loc = ref.read(timezoneLocationProvider);
    final code = ref.read(localeProvider).languageCode;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    var kind = existing?.kind ?? DocKind.vaccineCard;
    DateTime? expires = existing?.expiresAt;
    String? filePath = existing?.filePath;
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
                  existing == null ? l10n.actionAddDoc : l10n.actionEditDoc,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
                DropdownButtonFormField<DocKind>(
                  // ignore: deprecated_member_use
                  value: kind,
                  items: DocKind.values
                      .map(
                        (k) => DropdownMenuItem(
                          value: k,
                          child: Text(_docLabel(l10n, k)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setModal(() => kind = v);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.fieldExpires),
                  subtitle: Text(
                    expires == null
                        ? l10n.fieldOptional
                        : PetFormat.date(expires!, loc, code),
                    style: const TextStyle(fontFeatures: AppNumeric.tabularFeatures),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: expires?.toLocal() ?? DateTime.now(),
                      firstDate: DateTime(2015),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (d != null) {
                      setModal(
                        () => expires = DateTime.utc(d.year, d.month, d.day),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await FilePicker.pickFiles();
                    if (picked.isNotEmpty && picked.first.path != null) {
                      setModal(() => filePath = picked.first.path);
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    filePath == null ? l10n.actionAttachFile : l10n.docHasFile,
                  ),
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
                          .read(documentsProvider.notifier)
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
    );
    if (ok != true || !context.mounted) return;
    final err = await ref.read(documentsProvider.notifier).upsert(
          PetDocument(
            id: existing?.id ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            title: titleCtrl.text.trim(),
            kind: kind,
            expiresAt: expires,
            filePath: filePath,
            notes: existing?.notes ?? '',
          ),
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorTitleRequired)),
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
