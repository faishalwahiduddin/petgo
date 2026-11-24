import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petgo/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/ui/fleet_sheet.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/care_reminder_service.dart';
import '../../core/utils/backup_file_io.dart';
import 'commercial_contact_cards.dart';
import '../../core/constants/contact_constants.dart';
import 'package:petgo/core/services/quick_action_config.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final pets = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const QuickActionNotifSwitchTile(),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(_languageLabel(locale)),
            onTap: () async {
              final picked = await showFleetSheet<Locale>(
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
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
            title: Text(l10n.settingsTheme),
            subtitle: Text(_themeLabel(l10n, themeMode)),
            onTap: () async {
              final picked = await showFleetSheet<ThemeMode>(
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
                          l10n.settingsTheme,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final m in [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
                        ListTile(
                          title: Text(_themeLabel(l10n, m)),
                          trailing: m == themeMode
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(ctx).colorScheme.primary,
                                )
                              : null,
                          selected: m == themeMode,
                          onTap: () => Navigator.pop(ctx, m),
                        ),
                    ],
                  ),
                ),
              );
              if (picked != null) {
                await ref.read(themeModeProvider.notifier).setThemeMode(picked);
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
              trailing: SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.actionDelete,
                  onPressed: () async {
                    final schCount = ref
                        .read(careSchedulesProvider)
                        .where((s) => s.petId == p.id)
                        .length;
                    final vetCount = ref
                        .read(vetLogsProvider)
                        .where((v) => v.petId == p.id)
                        .length;
                    final dayCount = ref
                        .read(dailyLogsProvider)
                        .where((d) => d.petId == p.id)
                        .length;
                    final wtCount = ref
                        .read(weightLogsProvider)
                        .where((w) => w.petId == p.id)
                        .length;
                    final docCount = ref
                        .read(documentsProvider)
                        .where((d) => d.petId == p.id)
                        .length;
                    final totalCount = schCount + vetCount + dayCount + wtCount + docCount;

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.dialogDeletePetTitle(p.name)),
                        content: Text(
                          l10n.dialogDeletePetMessage(p.name, totalCount),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.actionCancel),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n.actionDelete),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true || !context.mounted) return;
                    await HapticFeedback.mediumImpact();
                    final err =
                        await ref.read(petsProvider.notifier).remove(p.id);
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.errorMinOnePet)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.snackbarDeleted)),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.settingsReminders),
            subtitle: Text(l10n.settingsRemindersSubtitle),
            value: ref.watch(remindersEnabledProvider),
            onChanged: (v) async {
              if (v) {
                final proceed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.notificationPermissionTitle),
                    content: Text(l10n.notificationPermissionMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.actionNotNow),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.actionAllow),
                      ),
                    ],
                  ),
                );
                if (proceed != true) return;
                final granted =
                    await CareReminderService.instance.requestPermission();
                if (!context.mounted) return;
                if (!granted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.notificationPermissionDenied)),
                  );
                }
                await ref
                    .read(remindersEnabledProvider.notifier)
                    .setEnabled(granted);
                await CareReminderService.instance.reschedule(
                  ref.read(careSchedulesProvider),
                  enabled: granted,
                );
              } else {
                await ref
                    .read(remindersEnabledProvider.notifier)
                    .setEnabled(false);
                await CareReminderService.instance.reschedule(
                  ref.read(careSchedulesProvider),
                  enabled: false,
                );
              }
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
          const SizedBox(height: 10),
          const UsageLicenseCard(),
          const SizedBox(height: 10),
          CommercialContactCards(appName: kAppBrandName),
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

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.themeSystem,
        ThemeMode.light => l10n.themeLight,
        ThemeMode.dark => l10n.themeDark,
      };
}
