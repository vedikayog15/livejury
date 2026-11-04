"""Render an SVG/HTML string to a PNG of exact size with headless Chrome."""
import pathlib, subprocess, tempfile

CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
FONTS = pathlib.Path(__file__).resolve().parent.parent / 'assets' / 'fonts'
FONT_CSS = f'''@font-face{{font-family:"Fraunces";src:url("file://{FONTS}/Fraunces-Variable.ttf")}}
@font-face{{font-family:"DM Sans";src:url("file://{FONTS}/DMSans-Variable.ttf")}}'''


def render(markup, out, width, height=None, transparent=True):
    height = height or width
    page = (f'<!doctype html><html><head><meta charset="utf-8"><style>{FONT_CSS}'
            f'html,body{{margin:0;width:{width}px;height:{height}px;overflow:hidden;background:transparent}}'
            f'svg{{display:block;width:{width}px;height:{height}px}}</style></head><body>{markup}</body></html>')
    with tempfile.NamedTemporaryFile('w', suffix='.html', delete=False) as f:
        f.write(page)
    args = [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
            '--allow-file-access-from-files', '--virtual-time-budget=2000',
            f'--window-size={width},{height}', f'--screenshot={out}']
    if transparent:
        args.append('--default-background-color=00000000')
    args.append(f'file://{f.name}')
    subprocess.run(args, check=True, capture_output=True)
    pathlib.Path(f.name).unlink()
