import json
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

with open('keys.json', 'r') as f:
    keys = json.load(f)

# Sort keys by length of the string descending, to replace longer strings first
sorted_keys = sorted(keys.items(), key=lambda x: len(x[1]), reverse=True)

for fpath in files:
    if not os.path.exists(fpath): continue
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    # First add import if not present
    if "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" not in content:
        # insert after first import
        content = re.sub(r"(import 'package:flutter/material.dart';)", r"\1\nimport 'package:flutter_gen/gen_l10n/app_localizations.dart';", content)

    for k, v in sorted_keys:
        if k in ["13700", "15000", "20000", "2023", "25000", "2500000", "25500", "355", "450000", "5000", "6", "nVersion110NVehiclesN", "b1234Abc", "b1234Cd", "misalBengkelResmiAstra", "misalGantiOliMesinFilter", "misalHondaHrVYamahaNmax", "misalKurasMinyakRemDot4", "misalPajakPkbTahunanStnk2026", "misalStnkDiDompetBpkbDiLemariA", "pertamina3415321Serpong", "garagego", "usageLicense", "licenciaDeUso"]:
            continue
            
        # We need to replace safely.
        # We can look for `const Text('v'` -> `Text(AppLocalizations.of(context)!.k`
        # `Text('v'` -> `Text(AppLocalizations.of(context)!.k`
        # `const Text("v"` -> `Text(AppLocalizations.of(context)!.k`
        # `Text("v"` -> `Text(AppLocalizations.of(context)!.k`
        # `labelText: 'v'` -> `labelText: AppLocalizations.of(context)!.k`
        
        # Escape for regex
        esc_v = re.escape(v)
        
        # For Text()
        content = re.sub(r'const\s+Text\s*\(\s*[\'"]' + esc_v + r'[\'"]', f'Text(AppLocalizations.of(context)!.{k}', content)
        content = re.sub(r'Text\s*\(\s*[\'"]' + esc_v + r'[\'"]', f'Text(AppLocalizations.of(context)!.{k}', content)
        
        # For properties
        content = re.sub(r'(labelText|hintText|tooltip|title|content)\s*:\s*[\'"]' + esc_v + r'[\'"]', r'\1: AppLocalizations.of(context)!.' + k, content)

    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Replacement complete.")
