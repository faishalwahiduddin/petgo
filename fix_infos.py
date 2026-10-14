import re

files = [
    "lib/features/glovebox/add_document_sheet.dart",
    "lib/features/maintenance/add_schedule_sheet.dart",
    "lib/features/maintenance/inspection_sheet.dart",
    "lib/features/settings/settings_screen.dart",
    "lib/features/garage/garage_dashboard_screen.dart"
]

for f in files:
    with open(f, 'r') as fp:
        c = fp.read()
    
    # some didn't match my previous regex because they might have super.key
    # like `AddDocumentSheet({super.key`
    c = re.sub(r'(\n\s*)([A-Z]\w+)\(\s*\{', r'\1const \2({', c)
    # double const might happen, fix it
    c = c.replace("const const", "const")
    
    # fix use_build_context_synchronously in garage_dashboard_screen.dart
    if 'garage_dashboard_screen' in f:
        c = c.replace("ScaffoldMessenger.of(context).showSnackBar(", "if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(")
        
    if 'settings_screen' in f:
        c = c.replace("Map<String, ({", "final Map<String, ({")
        c = c.replace("Map<String, ({", "final Map<String, ({")
        
    with open(f, 'w') as fp:
        fp.write(c)

