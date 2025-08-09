# MemorySwipe

A tiny Flutter memory game: watch the arrow sequence, then **swipe** it back in order. Sequences grow each round. Miss = game over.

## Features
- Swipe-based Simon-style gameplay
- Flash feedback (green ✅ / red ❌)
- Music toggle with saved preference (persists across launches)
- Smooth swipe trail effect

## Quick Start
```bash
git clone https://github.com/JahanzebKhan796/MemorySwipe.git
cd MemorySwipe
flutter pub get
flutter run
```

## Project Bits
- `lib/main.dart` — app entry & start screen  
- `lib/game.dart` — game logic/UI  
- Assets (e.g., `assets/music.mp3`) — declare in `pubspec.yaml`

## Requirements
- Flutter
