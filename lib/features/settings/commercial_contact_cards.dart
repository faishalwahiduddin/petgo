import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/contact_constants.dart';
import '../../l10n/app_localizations.dart';

/// Usage-license card plus two tappable cards (commercial use, app
/// acquisition) that open a pre-filled email to [kContactEmail].
class UsageLicenseCard extends StatelessWidget {
  const UsageLicenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InfoCard(
      icon: Icons.verified_user_outlined,
      title: l10n.licenseUsageTitle,
      description: l10n.licenseUsageNotice,
      badge: l10n.licenseBadgeText,
    );
  }
}

class CommercialContactCards extends StatelessWidget {
  const CommercialContactCards({super.key, required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _InfoCard(
          icon: Icons.business_center_outlined,
          title: l10n.commercialContactTitle,
          description: l10n.commercialContactDesc,
          trailingText: kContactEmail,
          onTap: () => _openMail(context, '[Commercial] $appName'),
        ),
        const SizedBox(height: 10),
        _InfoCard(
          icon: Icons.handshake_outlined,
          title: l10n.acquireAppTitle,
          description: l10n.acquireAppDesc,
          onTap: () => _openMail(context, '[Acquisition] $appName'),
        ),
      ],
    );
  }

  Future<void> _openMail(BuildContext context, String subject) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    var launched = false;
    try {
      final info = await PackageInfo.fromPlatform();
      final platform = kIsWeb ? 'web' : defaultTargetPlatform.name;
      final body =
          'App: $appName v${info.version}+${info.buildNumber}\nPlatform: $platform\n\n';
      final uri = Uri(
        scheme: 'mailto',
        path: kContactEmail,
        query: encodeQueryParameters({'subject': subject, 'body': body}),
      );
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (launched) return;
    var copied = true;
    try {
      await Clipboard.setData(const ClipboardData(text: kContactEmail));
    } catch (_) {
      copied = false;
    }
    if (!context.mounted) return;
    messenger?.showSnackBar(
      SnackBar(content: Text(copied ? l10n.contactEmailCopied : kContactEmail)),
    );
  }
}

/// Encodes with %20 (not '+') so mail clients show spaces correctly.
@visibleForTesting
String encodeQueryParameters(Map<String, String> params) => params.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    .join('&');

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? badge;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = context.cardBg;
    final border = context.borderColor;
    final fg = context.textPrimary;
    final muted = context.textSecondary;
    const accent = AppColors.primary;
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: onTap != null,
      label: title,
      child: Material(
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
                if (trailingText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    trailingText!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
