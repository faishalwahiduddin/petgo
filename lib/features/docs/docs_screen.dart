import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/pet.dart';
import '../../core/providers/app_providers.dart';

class DocsScreen extends ConsumerWidget {
  const DocsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(activePetProvider);
    final docs = ref
        .watch(documentsProvider)
        .where((d) => pet != null && d.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDocs)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pet == null ? null : () => _editDoc(context, ref, pet),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionAddDoc),
      ),
      body: docs.isEmpty
          ? Center(
              child: Text(
                l10n.docsEmpty,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = docs[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: AppColors.primary),
                    title: Text(d.title),
                    subtitle: Text(
                      [
                        _docLabel(l10n, d.kind),
                        if (d.expiresAt != null)
                          '${l10n.fieldExpires}: ${d.expiresAt!.toLocal().toString().split(' ').first}',
                        if (d.filePath != null) l10n.docHasFile,
                      ].join(' · '),
                    ),
                    onTap: () => _editDoc(context, ref, pet!, existing: d),
                    onLongPress: () =>
                        ref.read(documentsProvider.notifier).remove(d.id),
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
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    var kind = existing?.kind ?? DocKind.vaccineCard;
    DateTime? expires = existing?.expiresAt;
    String? filePath = existing?.filePath;
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
                  existing == null ? l10n.actionAddDoc : l10n.actionEditDoc,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l10n.fieldTitle),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.errorTitleRequired
                      : null,
                ),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.fieldExpires),
                  subtitle: Text(
                    expires == null
                        ? l10n.fieldOptional
                        : expires!.toLocal().toString().split(' ').first,
                  ),
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
                const SizedBox(height: 12),
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
    }
  }
}
