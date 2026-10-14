import json
import urllib.request
import urllib.parse
import time
import os
import re

locales = {
    'id': 'id',
    'en': 'en',
    'ar': 'ar',
    'jv': 'jv',
    'su': 'su',
    'zh': 'zh-CN',
    'ja': 'ja',
    'es': 'es'
}

def translate(text, target_lang):
    if target_lang == 'id':
        return text
    # Avoid translating numbers or short symbols
    if re.match(r'^[\d\W]+$', text): return text
    if "{\\n" in text: return text # skip JSON dump
    
    url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=id&tl=" + target_lang + "&dt=t&q=" + urllib.parse.quote(text)
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            res = json.loads(response.read().decode('utf-8'))
            return "".join([x[0] for x in res[0]])
    except Exception as e:
        print(f"Error translating '{text}' to {target_lang}: {e}")
        return text

with open('keys.json', 'r') as f:
    id_keys = json.load(f)

# Load existing arb files
def load_arb(lang):
    path = f"lib/l10n/app_{lang}.arb"
    if os.path.exists(path):
        with open(path, 'r') as f:
            return json.load(f)
    return {}

existing_arbs = {lang: load_arb(lang) for lang in locales.keys()}

# Clean keys: remove unwanted like numeric keys, json dumps
keys_to_remove = ["13700", "15000", "20000", "2023", "25000", "2500000", "25500", "355", "450000", "5000", "6", "nVersion110NVehiclesN", "b1234Abc", "b1234Cd", "misalBengkelResmiAstra", "misalGantiOliMesinFilter", "misalHondaHrVYamahaNmax", "misalKurasMinyakRemDot4", "misalPajakPkbTahunanStnk2026", "misalStnkDiDompetBpkbDiLemariA", "pertamina3415321Serpong", "garagego", "usageLicense", "licenciaDeUso"]
for k in keys_to_remove:
    if k in id_keys:
        del id_keys[k]

new_arbs = {lang: {} for lang in locales.keys()}

total_keys = len(id_keys)
print(f"Total keys to translate: {total_keys}")

for i, (key, text) in enumerate(id_keys.items()):
    print(f"Translating {i+1}/{total_keys}: {key}")
    for lang, code in locales.items():
        if key in existing_arbs[lang]:
            new_arbs[lang][key] = existing_arbs[lang][key]
        else:
            trans = translate(text, code)
            new_arbs[lang][key] = trans
            time.sleep(0.1)

# Merge back with existing arb keys to ensure 100% key parity
all_keys = set()
for lang in locales.keys():
    for k in existing_arbs[lang].keys():
        if not k.startswith('@'):
            all_keys.add(k)
    for k in new_arbs[lang].keys():
        all_keys.add(k)

final_arbs = {lang: {} for lang in locales.keys()}

for k in all_keys:
    # Ensure every lang has this key
    base_text = new_arbs['id'].get(k) or existing_arbs['id'].get(k) or k
    for lang, code in locales.items():
        val = new_arbs[lang].get(k) or existing_arbs[lang].get(k)
        if val is None:
            val = translate(base_text, code)
            time.sleep(0.1)
        final_arbs[lang][k] = val

for lang in locales.keys():
    path = f"lib/l10n/app_{lang}.arb"
    with open(path, 'w') as f:
        json.dump(final_arbs[lang], f, indent=2, ensure_ascii=False)

print("Translation complete!")
