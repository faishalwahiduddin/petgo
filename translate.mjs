import { translate } from '@vitalets/google-translate-api';
import fs from 'fs';

const idKeys = JSON.parse(fs.readFileSync('keys.json', 'utf8'));

const locales = {
    'id': 'id',
    'en': 'en',
    'ar': 'ar',
    'jv': 'jw', // Javanese in google translate is jw
    'su': 'su',
    'zh': 'zh-CN',
    'ja': 'ja',
    'es': 'es'
};

const keysToRemove = ["13700", "15000", "20000", "2023", "25000", "2500000", "25500", "355", "450000", "5000", "6", "nVersion110NVehiclesN", "b1234Abc", "b1234Cd", "misalBengkelResmiAstra", "misalGantiOliMesinFilter", "misalHondaHrVYamahaNmax", "misalKurasMinyakRemDot4", "misalPajakPkbTahunanStnk2026", "misalStnkDiDompetBpkbDiLemariA", "pertamina3415321Serpong", "garagego", "usageLicense", "licenciaDeUso"];
for (const k of keysToRemove) {
    delete idKeys[k];
}

async function doTranslation() {
    const newArbs = {};
    for (const l in locales) newArbs[l] = {};

    let i = 0;
    const total = Object.keys(idKeys).length;
    for (const [key, text] of Object.entries(idKeys)) {
        i++;
        console.log(`Translating ${i}/${total}: ${key}`);
        for (const [lang, code] of Object.entries(locales)) {
            if (code === 'id') {
                newArbs[lang][key] = text;
                continue;
            }
            try {
                const res = await translate(text, { to: code });
                newArbs[lang][key] = res.text;
                // delay to avoid limit
                await new Promise(r => setTimeout(r, 250));
            } catch (e) {
                console.error(`Error translating to ${code}:`, e.message);
                newArbs[lang][key] = text; // fallback
            }
        }
    }

    // load existing and merge
    for (const lang of Object.keys(locales)) {
        let existing = {};
        const path = `lib/l10n/app_${lang}.arb`;
        if (fs.existsSync(path)) {
            existing = JSON.parse(fs.readFileSync(path, 'utf8'));
        }
        const merged = { ...existing, ...newArbs[lang] };
        fs.writeFileSync(path, JSON.stringify(merged, null, 2));
    }
}

doTranslation();
