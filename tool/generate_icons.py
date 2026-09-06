"""Generate the original six-seat app mark. No downloaded/generated imagery."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import math, json
root = Path(__file__).resolve().parents[1]
size=1024
im=Image.new('RGB',(size,size),'#101426')
d=ImageDraw.Draw(im)
center=(512,512)
for radius,alpha in [(216,'#64697D'),(253,'#32374D'),(394,'#32374D')]:
    d.ellipse((512-radius,512-radius,512+radius,512+radius),outline=alpha,width=3)
for i in range(6):
    angle=-math.pi/2+i*math.pi/3
    x,y=512+math.cos(angle)*324,512+math.sin(angle)*324
    d.rounded_rectangle((x-57,y-48,x+57,y+48),radius=24,fill='#F5CAA5' if i==0 else '#282D49',outline='#F5CAA5' if i==0 else '#C1C3D4',width=3)
font=ImageFont.truetype(str(root/'assets/fonts/Outfit-500.ttf'),175)
d.text(center,'VI',font=font,anchor='mm',fill='#F5CAA5')
def save(path,px):
    path=root/path;path.parent.mkdir(parents=True,exist_ok=True);im.resize((px,px),Image.Resampling.LANCZOS).save(path)
for density,px in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    save(Path(f'android/app/src/main/res/mipmap-{density}/ic_launcher.png'),px)
for px in [192,512]:
    save(Path(f'web/icons/Icon-{px}.png'),px);save(Path(f'web/icons/Icon-maskable-{px}.png'),px)
save(Path('web/favicon.png'),32)
for platform in ['ios','macos']:
    folder=root/platform/'Runner/Assets.xcassets/AppIcon.appiconset'
    contents=json.loads((folder/'Contents.json').read_text())
    for item in contents['images']:
        if 'filename' in item:
            px=round(float(item['size'].split('x')[0])*float(item.get('scale','1x').rstrip('x')))
            save((folder/item['filename']).relative_to(root),px)
save(Path('assets/app-icon.png'),1024)
im.save(root/'windows/runner/resources/app_icon.ico',sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])
print('Generated six-seat icons for Android, iOS, web, macOS, and Windows.')
