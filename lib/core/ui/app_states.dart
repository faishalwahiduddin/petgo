import 'package:flutter/cupertino.dart';

import 'press_scale.dart';

/// Optional localized defaults for [AppLoading] / [AppError].
///
/// CANONICAL FILE -- fleet superset of every per-app `app_states.dart`.
/// This file is l10n-neutral: it contains no UI strings. Per-call labels
/// (`message`, `retryLabel`, `actionLabel`) always win. When a call omits them,
/// the nearest [AppStatesLabels] supplies the default. Mount one above the
/// router (e.g. in `CupertinoApp.builder`):
///
/// ```dart
/// builder: (context, child) {
///   final l = AppLocalizations.of(context)!;
///   return AppStatesLabels(
///     loading: l.loading,
///     retry: l.tryAgain,
///     child: child!,
///   );
/// },
/// ```
///
/// Without one, a missing loading label is simply absent and a missing retry
/// label degrades to a refresh icon button.
class AppStatesLabels extends InheritedWidget {
  const AppStatesLabels({
    super.key,
    this.loading,
    this.retry,
    this.showLoadingText = false,
    required super.child,
  });

  /// Default loading text / accessibility label.
  final String? loading;

  /// Default retry-button label.
  final String? retry;

  /// When true, [loading] is also drawn under the spinner for [AppLoading]
  /// calls without an explicit message. When false it is announced to screen
  /// readers only.
  final bool showLoadingText;

  static AppStatesLabels? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStatesLabels>();

  @override
  bool updateShouldNotify(AppStatesLabels old) =>
      loading != old.loading ||
      retry != old.retry ||
      showLoadingText != old.showLoadingText;
}

const double _kSm = 8;
const double _kMd = 12;
const double _kLg = 16;
const double _kXl = 24;

TextStyle _text(
    BuildContext context, double size, FontWeight? weight, Color? color) {
  return CupertinoTheme.of(context).textTheme.textStyle.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}

/// Primary call-to-action button.
///
/// Defaults to the ambient `CupertinoTheme.primaryColor` with white label.
/// Pass [color] / [labelColor] for brand-specific (e.g. dark-mode) grounds.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: _kXl, vertical: _kMd),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.color,
    this.labelColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? labelColor;

  /// Shown instead of [label] text when [label] is empty (icon-only fallback).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = labelColor ?? CupertinoColors.white;
    return CupertinoButton(
      padding: padding,
      minimumSize: const Size(44, 44),
      borderRadius: borderRadius,
      color: color ?? CupertinoTheme.of(context).primaryColor,
      onPressed: onPressed,
      child: label.isEmpty && icon != null
          ? Icon(icon, size: 20, color: fg)
          : Text(label, style: _text(context, 15, FontWeight.w600, fg)),
    );
  }
}

/// Centered loading indicator (use for AsyncValue.loading).
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  /// Visible caption under the spinner; also the screen-reader label.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final labels = AppStatesLabels.maybeOf(context);
    final fallback = labels?.loading;
    final visible =
        message ?? ((labels?.showLoadingText ?? false) ? fallback : null);
    return Center(
      child: Semantics(
        label: message ?? fallback ?? '',
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 14),
            if (visible != null && visible.isNotEmpty) ...[
              const SizedBox(height: _kMd),
              Text(
                visible,
                textAlign: TextAlign.center,
                style: _text(context, 14, null,
                    CupertinoColors.label
                        .resolveFrom(context)
                        .withValues(alpha: 0.72)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly empty state with optional primary CTA.
///
/// The CTA renders only when both [actionLabel] and [onAction] are set.
class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    this.icon = CupertinoIcons.tray,
    this.iconWidget,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionColor,
    this.actionLabelColor,
    this.dense = false,
  });

  final IconData icon;

  /// Replaces [icon] with a custom illustration.
  final Widget? iconWidget;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional brand overrides for the CTA (see [AppPrimaryButton]).
  final Color? actionColor;
  final Color? actionLabelColor;

  /// Compact variant for an empty *section* inside a screen that has other
  /// content (smaller icon, tighter spacing). Default is the full-screen form.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final gap = dense ? _kSm : _kLg;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: _kXl, vertical: dense ? _kLg : _kXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget ??
                Icon(icon,
                    size: dense ? 32 : 48,
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context)),
            SizedBox(height: gap),
            Text(title,
                textAlign: TextAlign.center,
                style: _text(context, dense ? 15 : 17, FontWeight.w600,
                    CupertinoColors.label.resolveFrom(context))),
            if (message != null) ...[
              const SizedBox(height: _kSm),
              Text(message!,
                  textAlign: TextAlign.center,
                  // label @72% (not secondaryLabel @60%, which is ~3.5:1 on white,
                  // below AA): ~10:1 in light and dark.
                  style: _text(context, 14, null,
                      CupertinoColors.label
                          .resolveFrom(context)
                          .withValues(alpha: 0.72))),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: gap),
              PressScale(
                child: AppPrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  color: actionColor,
                  labelColor: actionLabelColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a recovery path (required for AsyncValue.error).
class AppError extends StatelessWidget {
  const AppError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.actionColor,
    this.actionLabelColor,
  });

  final String message;
  final VoidCallback? onRetry;

  /// Falls back to [AppStatesLabels.retry]; if that is absent too, the button
  /// shows a refresh icon instead of text.
  final String? retryLabel;
  final Color? actionColor;
  final Color? actionLabelColor;

  @override
  Widget build(BuildContext context) {
    final label = retryLabel ?? AppStatesLabels.maybeOf(context)?.retry ?? '';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_kXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle,
                size: 44,
                color: CupertinoColors.systemRed.resolveFrom(context)),
            const SizedBox(height: _kLg),
            Text(message,
                textAlign: TextAlign.center,
                style: _text(context, 15, FontWeight.w500,
                    CupertinoColors.label.resolveFrom(context))),
            if (onRetry != null) ...[
              const SizedBox(height: _kLg),
              PressScale(
                child: AppPrimaryButton(
                  label: label,
                  icon: CupertinoIcons.refresh,
                  onPressed: onRetry,
                  color: actionColor,
                  labelColor: actionLabelColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
