# 🏠 Homiq AI – Virtual Interior Designer

> AI-powered Flutter app that transforms your room photos into stunning interior designs.

---

## 📁 Project Structure

```
homiq_ai/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── theme/
│   │   └── app_theme.dart                 # Colors, typography, theme
│   ├── models/
│   │   ├── user_model.dart
│   │   └── design_model.dart              # DesignModel, FurnitureItem, enums
│   ├── bloc/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── design/
│   │       ├── design_bloc.dart
│   │       ├── design_event.dart
│   │       └── design_state.dart
│   ├── services/
│   │   ├── auth_service.dart              # Auth API calls (mock → real)
│   │   └── design_service.dart            # AI design API calls (mock → real)
│   ├── utils/
│   │   └── app_router.dart                # GoRouter navigation config
│   ├── widgets/
│   │   └── common_widgets.dart            # GoldButton, HomiqTextField, etc.
│   └── screens/
│       ├── splash_screen.dart
│       ├── loading_screen.dart
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── signup_screen.dart
│       ├── home/
│       │   └── home_screen.dart           # Dashboard + History + Profile tabs
│       ├── upload/
│       │   └── upload_screen.dart
│       ├── style/
│       │   └── style_selection_screen.dart
│       └── result/
│           └── result_screen.dart         # Before/After slider + Furniture
├── android/
│   └── app/src/main/AndroidManifest.xml
├── ios/
│   └── Runner/Info.plist
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode

### Installation

```bash
# Clone / copy project
cd homiq_ai

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

---

## 🔌 Backend Integration

### Replace Mock Services

#### `lib/services/auth_service.dart`
Replace mock methods with real Laravel API calls:

```dart
// POST https://api.homiq.app/api/auth/login
final response = await dio.post('/auth/login', data: {
  'email': email,
  'password': password,
});
final user = UserModel.fromJson(response.data['user']);
await _saveToken(response.data['token']);
```

#### `lib/services/design_service.dart`
```dart
// 1. Upload image to S3/Firebase
final imageUrl = await _uploadImage(image);

// 2. POST /api/designs/generate
final response = await dio.post('/designs/generate', data: {
  'image_url': imageUrl,
  'style': style.name,
  'budget': budget.name,
});

// 3. Poll for completion
final designId = response.data['design_id'];
await _pollStatus(designId);
```

---

## 🎨 Design System

| Token | Value | Usage |
|-------|-------|-------|
| `AppColors.primary` | `#D4A853` (Warm Gold) | CTAs, active states |
| `AppColors.accent` | `#B05C3B` (Terracotta) | Accents, alerts |
| `AppColors.background` | `#0F0E0C` | App background |
| `AppColors.surface` | `#1A1915` | Cards, panels |
| Font (Display) | Playfair Display | Headings |
| Font (Body) | Inter | Body text |

---

## 📱 Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Logo animation + auth check |
| Login | `/login` | Email/Google login |
| Signup | `/signup` | Registration with 3 free designs |
| Home | `/home` | Dashboard, style showcase, recent designs |
| Upload | `/upload` | Camera/gallery image picker |
| Style Select | `/style-select` | Style + budget selection |
| Loading | `/loading` | AI processing animation |
| Result | `/result` | Before/After slider + furniture |

---

## 💰 Monetization Hooks

- `user.freeDesignsLeft` → gates free usage (3 designs)
- `user.isPremium` → unlocks unlimited designs
- Upgrade CTA shown in Profile tab and home banner
- Furniture cards have affiliate `Buy` buttons → hook up `url_launcher`

---

## 🔐 Security Notes

- Store auth tokens with `flutter_secure_storage` (not `SharedPreferences`)
- All API calls should go through HTTPS
- Image uploads should use pre-signed S3 URLs (never expose AWS keys)

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `go_router` | Navigation |
| `image_picker` | Camera/gallery |
| `shared_preferences` | Local storage |
| `share_plus` | Share designs |
| `dio` | HTTP client |

---

## 🏗️ Future Work

- [ ] Firebase Auth integration
- [ ] Real AI API (Stability AI / OpenAI DALL-E)
- [ ] Push notifications
- [ ] AR room preview
- [ ] 3D modeling
- [ ] In-app purchases (₹99/month subscription)
- [ ] Deep linking
