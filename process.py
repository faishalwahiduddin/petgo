import re
import os
import json

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

def make_key(text):
    # remove vars
    clean = re.sub(r'\$\{.*?\}', '', text)
    clean = re.sub(r'[^a-zA-Z0-9\s]', '', clean)
    words = clean.split()
    if not words:
        return "dynamicKey"
    key = words[0].lower() + "".join(w.capitalize() for w in words[1:5])
    return key

# We will read each file, find Text('...') or Text("...") and replace it with AppLocalizations.of(context)!.key
# We also need to find labelText: '...' etc.

def process_dart_files():
    keys_dict = {}
    
    for fpath in files:
        if not os.path.exists(fpath): continue
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()

        # We need to make sure we don't replace things that are already l10n or non-UI.
        
        # 1. Text('...')
        def repl_text(m):
            txt = m.group(1)
            # Skip if it's already a variable or contains a mix that we can't easily parse
            if '$' in txt: 
                return m.group(0) # skip for now, we'll handle manually or ignore if complex
            key = make_key(txt)
            if key not in keys_dict:
                keys_dict[key] = txt
            # If there's a const before Text, we need to remove it
            return f"Text(AppLocalizations.of(context)!.{key}"
            
        # Regex to remove const before Text('...')
        content = re.sub(r'const\s+Text\s*\(\s*\'([^\'\$]+)\'', lambda m: f"Text(AppLocalizations.of(context)!.{make_key(m.group(1))}", content)
        content = re.sub(r'Text\s*\(\s*\'([^\'\$]+)\'', lambda m: f"Text(AppLocalizations.of(context)!.{make_key(m.group(1))}", content)

        # 2. labelText: '...'
        def repl_prop(m):
            prop = m.group(1)
            txt = m.group(2)
            if '$' in txt: return m.group(0)
            key = make_key(txt)
            if key not in keys_dict:
                keys_dict[key] = txt
            return f"{prop}: AppLocalizations.of(context)!.{key}"

        content = re.sub(r'(labelText|hintText|tooltip|title)\s*:\s*\'([^\'\$]+)\'', repl_prop, content)
        content = re.sub(r'(labelText|hintText|tooltip|title)\s*:\s*"([^"\$]+)"', repl_prop, content)

        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)
            
    with open('extracted_keys.json', 'w', encoding='utf-8') as f:
        json.dump(keys_dict, f, indent=2)

process_dart_files()
