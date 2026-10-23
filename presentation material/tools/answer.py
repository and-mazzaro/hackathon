"""answer.py quiz|bin UI_XML REPO -> prints 'x y' to tap (correct quiz option, or correct bin for the selected/first item)."""
import sys, re, html, json
mode, uixml, repo = sys.argv[1:4]
x = open(uixml, encoding='utf-8').read()
items = [(html.unescape(m.group(1)), [int(v) for v in m.groups()[1:]])
         for m in re.finditer(r'(?:text|content-desc)="([^"]+)"[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', x)]
def center(b): return f"{(b[0]+b[2])//2} {(b[1]+b[3])//2}"
if mode == 'quiz':
    qs = json.load(open(f'{repo}/assets/content/quiz_questions_it.json', encoding='utf-8'))['questions']
    texts = [t for t, _ in items]
    for q in qs:
        if any(q['question'] == t for t in texts):
            right = q['options'][q['correctIndex']]
            for t, b in items:
                if t.split('\n')[0] == right:
                    print(center(b)); sys.exit()
    first = {t.split(chr(10))[0] for t in texts}
    for q in qs:
        if all(o in first for o in q['options']):
            right = q['options'][q['correctIndex']]
            for t, b in items:
                if t.split(chr(10))[0] == right:
                    print(center(b)); sys.exit()
    sys.exit(1)
if mode == 'bin':
    waste = json.load(open(f'{repo}/assets/content/waste_items_it.json', encoding='utf-8'))['items']
    names = {w['name']: w['category'] for w in waste}
    bins = {'plastic_metal': 'Plastica e metalli', 'paper': 'Carta e cartone', 'organic': 'Organico', 'glass': 'Vetro', 'residual': 'Indifferenziato'}
    for t, b in items:
        n = t.split('\n')[0]
        if n in names and b[1] < 1400:
            label = bins[names[n]]
            for t2, b2 in items:
                if t2.split('\n')[0] == label:
                    print(center(b), center(b2)); sys.exit()
    sys.exit(1)
