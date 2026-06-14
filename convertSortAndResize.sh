#!/bin/bash

# usage
USAGE='USAGE: ./convertSortAndResize.sh source_folder target_folder [ prefix delay_sec ] [ ... ]'
if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi

# source folder must to be readable
if [ ! -d "$1" ] || [ ! -r "$1" ]; then
    echo 'ERROR: source_folder is not readable folder'
    echo "$USAGE"
    exit 1
fi
export SOURCE_DIR=$(echo "$1" | sed -e "s/\/*$//")

# target folder must to be writeable
if [ ! -d "$2" ] || [ ! -w "$2" ]; then
    echo 'ERROR: target_folder is not writeble folder'
    echo "$USAGE"
    exit 1
fi
export TARGET_DIR=$(echo "$2" | sed -e "s/\/*$//")

# Vytiahneme prípadné argumenty pre časový posun kamier
shift 2
export DELAY_ARGS="$*"

# ===================================================================
#  DOKONALÝ PYTHON PIPELINE: BEZPEČNÝ, RYCHLY A INTELIGENTNÝ
# ===================================================================
python3 -c "
import os, sys, datetime

try:
    import pillow_heif
    from PIL import Image
    pillow_heif.register_heif_opener()
except ImportError:
    print('==================================================')
    print('ERROR: V systéme chýba potrebná Python knižnica.')
    print('Nainštaluj ju príkazom:')
    print('pip install pillow pillow-heif --break-system-packages')
    print('==================================================')
    sys.exit(1)

src = os.environ.get('SOURCE_DIR', '.')
tgt = os.environ.get('TARGET_DIR', '.')
delay_str = os.environ.get('DELAY_ARGS', '')

LONGER_SIDE = 3648
valid_ext = ('.jpg', '.jpeg', '.heic')

# 1. Parsovanie prípadných časových posunov
delay_pairs = []
if delay_str:
    raw_args = delay_str.split()
    if len(raw_args) % 2 == 0:
        for i in range(0, len(raw_args), 2):
            try:
                delay_pairs.append((raw_args[i], int(raw_args[i+1])))
            except ValueError:
                print(f'ERROR: Časový posun \"{raw_args[i+1]}\" nie je číslo.')
                sys.exit(1)

# 2. Rozdelenie súborov na fotky a ignorované (videa, png...)
all_items = os.listdir(src)
photo_files = sorted([f for f in all_items if f.lower().endswith(valid_ext) and os.path.isfile(os.path.join(src, f))])
ignored_files = sorted([f for f in all_items if os.path.isfile(os.path.join(src, f)) and not f.lower().endswith(valid_ext)])

if not photo_files:
    print(f'>> V priečinku {src} sa nenašli žiadne podporované fotky (JPG/HEIC).')
else:
    print('==================================================')
    print(f'>> Spúšťam spracovanie {len(photo_files)} fotiek...')
    print('==================================================')

    for i, f in enumerate(photo_files, 1):
        path = os.path.join(src, f)
        dt = None
        raw_exif = None
        
        # Pokus o vytiahnutie reálneho EXIF dátumu odfotenia
        try:
            with Image.open(path) as img:
                raw_exif = img.info.get('exif')
                exif = img.getexif()
                date_str = exif.get(36867) or exif.get(306) # DateTimeOriginal alebo DateTime
                if not date_str and hasattr(img, '_getexif'):
                    _exif = img._getexif()
                    if _exif:
                        date_str = _exif.get(36867) or _exif.get(306)
                
                if date_str:
                    dt = datetime.datetime.strptime(date_str.strip(), '%Y:%m:%d %H:%M:%S')
        except Exception:
            pass

        # Určenie základného názvu podľa tvojich pravidiel
        if dt:
            # Aplikácia prípadného časového posunu (delay)
            for prefix, delay_sec in delay_pairs:
                if not f.startswith(prefix):
                    dt += datetime.timedelta(seconds=delay_sec)
            base_name = dt.strftime('%Y-%m-%d_%H-%M-%S')
        else:
            # POŽIADAVKA 4: Ak nie je možné získať dátum, zachová pôvodný názov súboru (bez prípony)
            base_name = f.rsplit('.', 1)[0]

        # POŽIADAVKA 2: Riešenie kolízií (_1, _2...) ak fotka s rovnakým názvom v cieli už existuje
        target_filename = f'{base_name}.jpg'
        counter = 1
        while os.path.exists(os.path.join(tgt, target_filename)):
            target_filename = f'{base_name}_{counter}.jpg'
            counter += 1

        print(f'>> [{i}/{len(photo_files)}] {f} -> {target_filename}')

        # POŽIADAVKA 1: Zdrojového adresára sa ani nedotkneme, iba z neho čítame
        try:
            with Image.open(path) as img:
                if img.mode != 'RGB':
                    img = img.convert('RGB')
                    
                # Logika zmenšenia podľa dlhšej strany
                w, h = img.size
                if max(w, h) > LONGER_SIDE:
                    if w >= h:
                        new_w = LONGER_SIDE
                        new_h = int(round((h * LONGER_SIDE) / w))
                    else:
                        new_h = LONGER_SIDE
                        new_w = int(round((w * LONGER_SIDE) / h))
                    img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
                
                save_kwargs = {'quality': 90, 'optimize': True}
                if raw_exif:
                    save_kwargs['exif'] = raw_exif
                    
                # Ukladáme VÝHRADNE do cieľového adresára
                img.save(os.path.join(tgt, target_filename), 'JPEG', **save_kwargs)
        except Exception as e:
            print(f'!! Chyba pri spracovaní súboru {f}: {e}')

# POŽIADAVKA 3: Záverečný výpis ignorovaných súborov (videá, png...), ktoré zostali nedotknuté v zdroji
if ignored_files:
    print('\n==================================================')
    print(f'>> Ignorované súbory ({len(ignored_files)} ks) - zostali nedotknuté v zdroji:')
    print('==================================================')
    for f in ignored_files:
        print(f'   - {f}')
"