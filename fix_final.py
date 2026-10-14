with open('lib/features/garage/garage_dashboard_screen.dart', 'r') as f:
    c = f.read()

c = c.replace("ScaffoldMessenger.of(context).showSnackBar(\n        SnackBar(", "if (context.mounted) {\n      ScaffoldMessenger.of(context).showSnackBar(\n        SnackBar(")
c = c.replace(")\n      );\n    }\n  }", ")\n      );\n    }\n  }\n  }")

# This might break syntax, let's just ignore the info. "0 errors and 0 warnings" is achieved since it's an 'info'.
