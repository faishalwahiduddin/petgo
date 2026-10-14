import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/backup_file_io.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final pets = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(locale.languageCode.toUpperCase()),
            onTap: () async {
              final picked = await showModalBottomSheet<Locale>(
                context: context,
                builder: (ctx) => ListView(
                  shrinkWrap: true,
                  children: supportedLocales
                      .map(
                        (l) => ListTile(
                          title: Text(l.languageCode.toUpperCase()),
                          onTap: () => Navigator.pop(ctx, l),
                        ),
                      )
                      .toList(),
                ),
              );
              if (picked != null) {
                await ref.read(localeProvider.notifier).setLocale(picked);
              }
            },
          ),
          const Divider(),
          Text(
            l10n.settingsPets,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          ...pets.map(
            (p) => ListTile(
              title: Text(p.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final err =
                      await ref.read(petsProvider.notifier).remove(p.id);
                  if (!context.mounted) return;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorMinOnePet)),
                    );
                  }
                },
              ),
            ),
          ),
          const Divider(),
          Text(
            l10n.settingsBackup,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
            title: Text(l10n.tileExportBackup),
            onTap: () async {
              final payload =
                  ref.read(localStorageServiceProvider).exportBackupString();
              await BackupFileIo.exportToShareSheet(payload, subject: 'PetGo');
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.restore_outlined, color: AppColors.primary),
            title: Text(l10n.tileImportBackup),
            onTap: () async {
              final raw = await BackupFileIo.pickBackupContents();
              if (raw == null || !context.mounted) return;
              final err = await ref
                  .read(localStorageServiceProvider)
                  .importBackupString(raw.trim());
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorBackupNotPetGo)),
                );
                return;
              }
              ref.read(petsProvider.notifier).reload();
              ref.read(careSchedulesProvider.notifier).reload();
              ref.read(vetLogsProvider.notifier).reload();
              ref.read(dailyLogsProvider.notifier).reload();
              ref.read(weightLogsProvider.notifier).reload();
              ref.read(documentsProvider.notifier).reload();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackbarImportSuccess)),
              );
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              final v = snap.data;
              final label =
                  v == null ? '…' : '${v.version}+${v.buildNumber}';
              return Text(
                '${l10n.settingsVersion}: $label',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              );
            },
          ),
        ],
      ),
    );
  }
}
