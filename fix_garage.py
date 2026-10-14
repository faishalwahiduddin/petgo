import re
with open('lib/features/garage/garage_dashboard_screen.dart', 'r') as f:
    c = f.read()

# restore my basic replacement
with open('keys.json', 'r') as f:
    import json
    keys = json.load(f)

# Sort keys by length of the string descending, to replace longer strings first
sorted_keys = sorted(keys.items(), key=lambda x: len(x[1]), reverse=True)

if "import 'package:garagego/l10n/app_localizations.dart';" not in c:
    c = c.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:garagego/l10n/app_localizations.dart';")

for k, v in sorted_keys:
    esc_v = re.escape(v)
    c = re.sub(r'const\s+Text\s*\(\s*[\'"]' + esc_v + r'[\'"]', f'Text(AppLocalizations.of(context)!.{k}', c)
    c = re.sub(r'Text\s*\(\s*[\'"]' + esc_v + r'[\'"]', f'Text(AppLocalizations.of(context)!.{k}', c)
    c = re.sub(r'(labelText|hintText|tooltip|title|content)\s*:\s*[\'"]' + esc_v + r'[\'"]', r'\1: AppLocalizations.of(context)!.' + k, c)

c = re.sub(r'(\bclass\s+\w+\s+(?:extends|with|implements)[^{]+\{\s*)(\w+)\s*\(', r'\1const \2(', c)
c = re.sub(r'(\n\s*)([A-Z]\w+)\(\s*\{', r'\1const \2({', c)
c = c.replace("const const", "const")

# The only issue was the BuildContext async gap around line 145.
# Let's see the code there first.
with open('lib/features/garage/garage_dashboard_screen.dart', 'w') as f:
    f.write(c)
