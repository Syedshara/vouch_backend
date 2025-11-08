# Vouch App Icon Setup Instructions

## Current Status
The app name has been changed to "Vouch" successfully. However, the app icon still shows the default Flutter icon.

## SVG Icons Created
I've created two SVG icon files in the `assets/` folder:
- `icon.svg` - Main app icon with purple background circle
- `icon_foreground.svg` - Foreground layer for Android adaptive icons

## To Complete Icon Setup:

### Option 1: Convert SVG to PNG (Recommended)
1. Open `assets/icon.svg` in a browser
2. Right-click and "Save Image As" or take a screenshot
3. Use an online tool like https://cloudconvert.com/svg-to-png to convert both SVG files to PNG (1024x1024)
4. Save as `assets/icon.png` and `assets/icon_foreground.png`
5. Run: `flutter pub run flutter_launcher_icons`

### Option 2: Use macOS Preview (if on Mac)
1. Open `assets/icon.svg` with Preview
2. File → Export → Format: PNG, Resolution: 300 DPI
3. Save as `icon.png`
4. Repeat for `icon_foreground.svg`
5. Run: `flutter pub run flutter_launcher_icons`

### Option 3: Use Homebrew (if on Mac)
```bash
brew install librsvg
cd assets
rsvg-convert -w 1024 -h 1024 icon.svg > icon.png
rsvg-convert -w 1024 -h 1024 icon_foreground.svg > icon_foreground.png
cd ..
flutter pub run flutter_launcher_icons
```

### Option 4: Use Python PIL
```bash
pip3 install Pillow cairosvg
cd assets
python3 << 'EOF'
import cairosvg
cairosvg.svg2png(url='icon.svg', write_to='icon.png', output_width=1024, output_height=1024)
cairosvg.svg2png(url='icon_foreground.svg', write_to='icon_foreground.png', output_width=1024, output_height=1024)
print("Icons converted!")
EOF
cd ..
flutter pub run flutter_launcher_icons
```

## After Converting:
Once you have the PNG files, run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter clean
flutter run
```

The app icon will be updated on both Android and iOS!

