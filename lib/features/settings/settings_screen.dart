import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/care_reminder_service.dart';
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
            subtitle: Text(_languageLabel(locale)),
            onTap: () async {
              final picked = await showModalBottomSheet<Locale>(
                context: context,
                useRootNavigator: true,
                builder: (ctx) => SafeArea(
                  top: false,
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Text(
                          l10n.settingsLanguage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...supportedLocales.map(
                        (l) => ListTile(
                          // Autonyms: a language is always listed in its own
                          // script so it stays findable whatever the UI locale.
                          title: Text(_languageLabel(l)),
                          // Compact rows keep all eight locales above the
                          // sheet edge instead of clipping the last one.
                          visualDensity: VisualDensity.compact,
                          trailing: l.languageCode == locale.languageCode
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(ctx).colorScheme.primary,
                                )
                              : null,
                          selected: l.languageCode == locale.languageCode,
                          onTap: () => Navigator.pop(ctx, l),
                        ),
                      ),
                    ],
                  ),
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
          SwitchListTile(
            title: Text(l10n.settingsReminders),
            subtitle: Text(l10n.settingsRemindersSubtitle),
            value: ref.watch(remindersEnabledProvider),
            onChanged: (v) async {
              await ref.read(remindersEnabledProvider.notifier).setEnabled(v);
              await CareReminderService.instance.reschedule(
                ref.read(careSchedulesProvider),
                enabled: v,
              );
            },
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
                style: TextStyle(color: context.textSecondary),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Native name for each supported locale (no l10n round-trip needed).
  String _languageLabel(Locale l) => switch (l.languageCode) {
        'id' => 'Bahasa Indonesia',
        'en' => 'English',
        'ar' => 'العربية',
        'jv' => 'Basa Jawa',
        'su' => 'Basa Sunda',
        'zh' => '中文',
        'ja' => '日本語',
        'es' => 'Español',
        _ => l.languageCode.toUpperCase(),
      };
}
