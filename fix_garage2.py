import re
with open('lib/features/garage/garage_dashboard_screen.dart', 'r') as f:
    c = f.read()

c = re.sub(r'const\s+Text\s*\(\s*AppLocalizations', 'Text(AppLocalizations', c)
c = c.replace("AppLocalizations.of(context)!.garagego", "'GarageGo'")
c = re.sub(r'const\s+([A-Z])', r'\1', c)
c = re.sub(r'(\bclass\s+\w+\s+(?:extends|with|implements)[^{]+\{\s*)(\w+)\s*\(', r'\1const \2(', c)

with open('lib/features/garage/garage_dashboard_screen.dart', 'w') as f:
    f.write(c)
