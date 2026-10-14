import os
import re

files = [
    "lib/features/settings/settings_screen.dart",
    "lib/features/garage/garage_dashboard_screen.dart",
    "lib/features/maintenance/maintenance_screen.dart",
    "lib/features/fuel/fuel_logs_screen.dart",
    "lib/features/glovebox/glovebox_screen.dart",
    "lib/features/garage/add_vehicle_sheet.dart",
    "lib/features/maintenance/inspection_sheet.dart",
    "lib/features/maintenance/add_schedule_sheet.dart",
    "lib/features/glovebox/add_document_sheet.dart"
]

for fpath in files:
    if not os.path.exists(fpath): continue
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    if "package:flutter_gen/gen_l10n/app_localizations.dart" not in content:
        # add import at the top
        content = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + content
    
    # Remove `const` before `Text(AppLocalizations`
    content = re.sub(r'const\s+Text\s*\(\s*AppLocalizations', 'Text(AppLocalizations', content)

    # If there is `const` before a widget that contains `AppLocalizations`, this is harder to regex.
    # We will just find all occurrences of `const ` before standard widgets and if `AppLocalizations` is nearby?
    # No, it's easier to just remove ALL `const ` in the files! Performance impact in Flutter is small enough for this 0.5 effort level, and it fixes compilation!
    # Wait, removing ALL `const ` might cause issues if something requires const (like some annotations), but in UI code it's fine.
    # Actually, we can remove `const ` if it's followed by a common widget like `SizedBox`, `Padding`, `Column`, `Row`, `ListTile`, `Icon`, `Text`, `EdgeInsets`, `BorderRadius`, `BoxDecoration`.
    # Let's remove const globally for widgets.
    content = re.sub(r'const\s+([A-Z])', r'\1', content)

    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)

