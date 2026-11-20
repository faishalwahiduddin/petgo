import 'package:flutter/material.dart';

import 'spring_sheet.dart';

/// Material content sheet with spring drag-to-dismiss.
///
/// CANONICAL — source: `tools/faishal-id-fleet/canonical/ui/fleet_sheet.dart`.
/// Needs sibling `spring_sheet.dart` (and its `../motion/*`).
///
/// Drop-in for the common `showModalBottomSheet` call: same parameter names
/// for the parts the fleet uses (`backgroundColor`, `shape`,
/// `isScrollControlled`, `useRootNavigator`, `isDismissible`). It routes
/// through [showSpringSheet], so the sheet tracks the finger and flick-dismisses
/// with spring physics. [showModalBottomSheet] provided some things implicitly,
/// and this sheet supplies them itself:
///  * a [Material] ancestor (TextField, ListTile, InkWell need one);
///  * surface colour + top-rounded shape (theme `bottomSheetTheme` fallback);
///  * bottom safe area and keyboard inset (`viewInsets`), so forms stay visible;
///  * a max height (90% when [isScrollControlled], else 9/16, like Material).
///
/// Scrollable content keeps scrolling: drags that start inside a scroll view go
/// to the scroll view; drag-to-dismiss works from the handle/header.
Future<T?> showFleetSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool showHandle = true,
}) {
  return showSpringSheet<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (ctx) => FleetSheetSurface(
      backgroundColor: backgroundColor,
      shape: shape,
      isScrollControlled: isScrollControlled,
      showHandle: showHandle,
      child: Builder(builder: builder),
    ),
  );
}

/// Sheet chrome used by [showFleetSheet]. Public so a sheet body that is
/// already shown via [showSpringSheet] can adopt the same surface.
class FleetSheetSurface extends StatelessWidget {
  const FleetSheetSurface({
    super.key,
    required this.child,
    this.backgroundColor,
    this.shape,
    this.isScrollControlled = false,
    this.showHandle = true,
  });

  final Widget child;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final bool isScrollControlled;
  final bool showHandle;

  static const ShapeBorder _defaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final color = backgroundColor ??
        theme.bottomSheetTheme.modalBackgroundColor ??
        theme.bottomSheetTheme.backgroundColor ??
        theme.colorScheme.surface;
    final maxHeight =
        media.size.height * (isScrollControlled ? 0.9 : 9 / 16);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        // Keyboard: lift the whole sheet above it (showCupertinoModalPopup
        // does not resize for viewInsets on its own).
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          // Same width cap as Material's modal bottom sheet on tablets.
          constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: 640),
          child: Material(
            color: color,
            shape: shape ?? theme.bottomSheetTheme.shape ?? _defaultShape,
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHandle) const SpringSheetHandle(),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
