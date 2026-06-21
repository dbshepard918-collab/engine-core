import csv, json, argparse
from pathlib import Path

STYLE = "original cyberpunk isometric ARPG game asset, neon magenta cyan accents, dystopian city, readable silhouette, production concept, no logos, no text, no copyrighted characters"
NEG = "text, logo, watermark, existing game character, copyrighted franchise, blurry, low contrast, messy silhouette, extra limbs, malformed geometry"

def build_prompt(row):
    return f"{row['subject']}, {row.get('material','')}, {row.get('lighting','neon rim light')}, {row.get('camera','orthographic isometric')}, {STYLE}"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--csv', required=True)
    ap.add_argument('--out', required=True)
    args = ap.parse_args()
    out = []
    with open(args.csv, newline='', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            out.append({
                'id': row['id'],
                'category': row['category'],
                'prompt': build_prompt(row),
                'negative_prompt': row.get('negative_prompt') or NEG,
                'width': int(row.get('width') or 1024),
                'height': int(row.get('height') or 1024),
                'seed': int(row.get('seed') or 0),
                'target_path': row.get('target_path','')
            })
    Path(args.out).write_text(json.dumps(out, indent=2), encoding='utf-8')

if __name__ == '__main__': main()
