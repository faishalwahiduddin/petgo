import re

with open("lib/features/settings/settings_screen.dart", "r") as f:
    c = f.read()

c = c.replace("title: AppLocalizations.of(context)!.lisensiPenggunaan,", "title: 'Lisensi Penggunaan',")
c = c.replace("title: AppLocalizations.of(context)!.lisensiPanganggo,", "title: 'Lisensi Panganggo',")
c = c.replace("title: AppLocalizations.of(context)!.lisensiPamakean,", "title: 'Lisensi Pamakean',")

with open("lib/features/settings/settings_screen.dart", "w") as f:
    f.write(c)
