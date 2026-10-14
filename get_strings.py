import re, json, os

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

strings = set()
for f in files:
    if not os.path.exists(f): continue
    with open(f, 'r') as fp:
        c = fp.read()
        for m in re.findall(r"Text\s*\(\s*'([^'\$]+)'", c): strings.add(m)
        for m in re.findall(r"Text\s*\(\s*\"([^\'\$]+)\"", c): strings.add(m)
        for m in re.findall(r"(?:labelText|hintText|tooltip|title|content)\s*:\s*'([^'\$]+)'", c): strings.add(m)
        # SnackBar(content: Text('...'))
        for m in re.findall(r"SnackBar\(\s*content:\s*Text\s*\(\s*'([^'\$]+)'", c): strings.add(m)

# remove already localized
keys = {}
for i, s in enumerate(sorted(list(strings))):
    if len(s.strip()) == 0: continue
    # simplified key
    k = re.sub(r'[^a-zA-Z0-9]', ' ', s).strip().title().replace(' ', '')
    if len(k) > 0:
        k = k[0].lower() + k[1:30]
        keys[k] = s

print(json.dumps(keys, indent=2))
