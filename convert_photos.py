#!/usr/bin/env python3
import os
import sys
import datetime

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

# Kontrola argumentov z Bashu
if len(sys.argv) < 3:
    print("ERROR: Python nedostal dostatok argumentov.")
    sys.exit(1)

src = sys.argv[1]
tgt = sys.argv[2]
raw_delay_args = sys.argv[3:]  # Všetky ostatné argumenty sú páry prefix + sekundy

LONGER_SIDE = 3648
valid_ext = ('.jpg', '.jpeg', '.heic')

# 1. Parsovanie prípadných časových posunov
delay_pairs = []
if len(raw_delay_args) % 2 == 0:
    for i in range(0, len(raw_delay_args), 2):
        try:
            delay_pairs.append((raw_delay_args[i], int(raw_delay_args[i+1])))
        except ValueError:
            print(f'ERROR: Časový posun "{raw_delay_args[i+1]}" nie je číslo.')
            sys.exit(1)

# 2. Načítanie súborov z hlavného priečinka AJ podadresárov (1. úroveň)
all_photo_tasks = []
all_ignored = []

def add_file(filename, current_src, current_tgt, rel_dir):
    if filename.lower().endswith(valid_ext):
        all_photo_tasks.append((filename, current_src, current_tgt, rel_dir))
    else:
        all_ignored.append((filename, rel_dir))

# Prechádzame hlavný zdrojový priečinok
for item in sorted(os.listdir(src)):
    item_path = os.path.join(src, item)
    
    if os.path.isfile(item_path):
        add_file(item, src, tgt, '')
        
    elif os.path.isdir(item_path):
        sub_tgt = os.path.join(tgt, item)
        for sub_item in sorted(os.listdir(item_path)):
            sub_item_path = os.path.join(item_path, sub_item)
            if os.path.isfile(sub_item_path):
                add_file(sub_item, item_path, sub_tgt, item)

# 3. Vyhodnotenie a spracovanie fotiek
total = len(all_photo_tasks)
if total == 0:
    print(f'>> V priečinku {src} ani v jeho podadresároch sa nenašli žiadne fotky.')
    sys.exit(0)

print('==================================================')
print(f'>> Spúšťam spracovanie {total} fotiek vrátane podadresárov...')
print('==================================================')

for i, (f, src_dir, tgt_dir, rel_dir) in enumerate(all_photo_tasks, 1):
    path = os.path.join(src_dir, f)
    dt = None
    raw_exif = None
    
    try:
        with Image.open(path) as img:
            raw_exif = img.info.get('exif')
            exif = img.getexif()
            date_str = exif.get(36867) or exif.get(306)
            if not date_str and hasattr(img, '_getexif'):
                _exif = img._getexif()
                if _exif:
                    date_str = _exif.get(36867) or _exif.get(306)
            
            if date_str:
                dt = datetime.datetime.strptime(date_str.strip(), '%Y:%m:%d %H:%M:%S')
    except Exception:
        pass

    if dt:
        for prefix, delay_sec in delay_pairs:
            if not f.startswith(prefix):
                dt += datetime.timedelta(seconds=delay_sec)
        base_name = dt.strftime('%Y-%m-%d_%H-%M-%S')
    else:
        base_name = f.rsplit('.', 1)[0]

    os.makedirs(tgt_dir, exist_ok=True)

    target_filename = f'{base_name}.jpg'
    counter = 1
    while os.path.exists(os.path.join(tgt_dir, target_filename)):
        target_filename = f'{base_name}_{counter}.jpg'
        counter += 1

    display_src = os.path.join(rel_dir, f) if rel_dir else f
    display_tgt = os.path.join(rel_dir, target_filename) if rel_dir else target_filename
    print(f'>> [{i}/{total}] {display_src} -> {display_tgt}')

    try:
        with Image.open(path) as img:
            if img.mode != 'RGB':
                img = img.convert('RGB')
                
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
                
            img.save(os.path.join(tgt_dir, target_filename), 'JPEG', **save_kwargs)
    except Exception as e:
        print(f'!! Chyba pri spracovaní súboru {f}: {e}')

if all_ignored:
    print('\n==================================================')
    print(f'>> Ignorované súbory ({len(all_ignored)} ks) - zostali nedotknuté v zdroji:')
    print('==================================================')
    for f, rel_dir in all_ignored:
        display_path = os.path.join(rel_dir, f) if rel_dir else f
        print(f'   - {display_path}')