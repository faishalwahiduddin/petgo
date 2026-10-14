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

for f in files:
    with open(f, 'r') as fp:
        c = fp.read()
    
    # find something like `class Name extends Widget { Name({`
    # and change the constructor to `const Name({`
    c = re.sub(r'(\bclass\s+\w+\s+(?:extends|with|implements)[^{]+\{\s*)(\w+)\s*\(', r'\1const \2(', c)
    
    with open(f, 'w') as fp:
        fp.write(c)

