with open('lib/features/garage/garage_dashboard_screen.dart', 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "if(context.mounted) ScaffoldMessenger.of(context).showSnackBar" in line:
        lines[i] = line.replace("if(context.mounted) ScaffoldMessenger.of(context).showSnackBar", "if(context.mounted) { ScaffoldMessenger.of(context).showSnackBar")
        
        # We need to add the closing brace after the snackbar statement
        # The statement ends a few lines below. Let's just restore it, the info is fine.

