import re
import glob
import os

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

all_strings = set()
for fpath in files:
    if os.path.exists(fpath):
        with open(fpath, "r", encoding="utf-8") as f:
            content = f.read()
            # Match Text('...') and Text("...") and SnackBar(content: Text('...'))
            # Also text fields like labelText: '...'
            # This is a naive regex, we can adjust.
            matches = re.findall(r"(?:Text|title|subtitle|labelText|hintText|content|tooltip)\s*:\s*(?:const\s+)?Text\s*\(\s*['\"]([^'\"]+)['\"]", content)
            for m in matches:
                all_strings.add(m)
            
            # Text('...') directly
            matches = re.findall(r"Text\s*\(\s*['\"]([^'\"]+)['\"]", content)
            for m in matches:
                all_strings.add(m)
            
            matches = re.findall(r"(?:labelText|hintText|tooltip)\s*:\s*['\"]([^'\"]+)['\"]", content)
            for m in matches:
                all_strings.add(m)

            # Look for button labels or dialog actions like Text('Batal')
            # Text('Tutup') etc

for s in sorted(list(all_strings)):
    print(s)

