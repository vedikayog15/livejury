# Live Jury brand assets

The logo is a round table drawn as a speech-bubble ring, with a glowing apricot
seat in a notch at the top: a seat at the table, and a conversation. It
deliberately implies no player count.

- `logo.py`: the vector source (icon and Play Store feature graphic)
- `build_assets.py`: regenerates every platform icon from that source
- `play-store/`: upload these to the Play Console
  - `icon-512.png`: app icon (512×512)
  - `feature-graphic-1024x500.png`: feature graphic (1024×500)

```sh
python3 branding/build_assets.py   # needs Google Chrome and Pillow
```

The script writes Android launcher icons (legacy, adaptive and themed
monochrome), the Android splash logo, iOS and macOS app icons, the Windows
.ico, the Flutter web icons, the website icons and social image, and
`assets/brand/logo-mark.png` used inside the app.
