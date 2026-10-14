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
        onPressed: pet == null ? null : () => _addDoc(context, ref, pet),
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
                    subtitle: Text(_docLabel(l10n, d.kind)),
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

  Future<void> _addDoc(BuildContext context, WidgetRef ref, Pet pet) async {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    var kind = DocKind.vaccineCard;
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
              Text(l10n.actionAddDoc,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l10n.fieldTitle),
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
    final err = await ref.read(documentsProvider.notifier).upsert(
          PetDocument(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            petId: pet.id,
            title: titleCtrl.text.trim(),
            kind: kind,
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
