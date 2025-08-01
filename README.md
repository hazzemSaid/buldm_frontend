# BULDM 📱

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State_Management-BLoC-774898)](https://bloclibrary.dev)
[![Contributors](https://img.shields.io/github/contributors/hazzemSaid/buldm_frontend)](https://github.com/hazzemSaid/buldm_frontend/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/hazzemSaid/buldm_frontend)](https://github.com/hazzemSaid/buldm_frontend/commits/main)

Flutter frontend for the **BULDM** (Bring Up Lost or Discovered Material) platform — a cross-platform lost & found app with real-time features and AI integration.

🔗 **Backend Repository**: [buldm_backend](https://github.com/hazzemSaid/buldm_backend)

---

## 📋 Table of Contents

- [🚀 Key Features](#-key-features)
- [🛠️ Tech Stack](#%EF%B8%8F-tech-stack)
- [🏗️ Project Structure](#%EF%B8%8F-project-structure)
- [🚀 Getting Started](#-getting-started)
- [🔧 Environment Setup](#-environment-setup)
- [🤝 Contribution](#-contribution)
- [📜 License](#-license)

---

## 🚀 Key Features

### 🔐 Authentication Flow
- Email/password with verification
- Google/Apple OAuth integration
- Password recovery workflow
- First-launch onboarding
- Simplified ForgetPasswordScreen logic
- Added: ForgotPasswordUseCase, ResetPasswordUseCase, VerifyEmailUseCase
- New screens for password reset, verification code entry, email re-send
- First-launch tracking with SharedPreferences, conditional routing logic, completion state management

### 📍 Location Services
- Interactive Google Maps integration
- Geolocation-based post discovery
- Radius filtering (1km/5km/10km)

### 💬 Real-Time Communication
- Socket.IO chat implementation
- Message status tracking
- Push notifications (OneSignal)

### 🌐 Localization
- English/Arabic support
- RTL layout handling
- Dynamic locale switching

### 🎨 Theming System
- Light/dark mode support
- Custom animation framework
- Responsive layout adapters

### 🧑‍💼 User Profiles
- Public profile viewing
- Post history browsing
- SearchByNameUseCase

### 💬 Chat System
- Real-time messaging
- Socket.IO integration
- Message status tracking

---

## 🛠️ Tech Stack

| Layer         | Technologies                              |
|---------------|-------------------------------------------|
| Framework     | Flutter 3.19+                             |
| State         | BLoC + Hydrated BLoC                      |
| Navigation    | GoRouter                                  |
| Localization  | flutter_localizations + ARB files         |
| Networking    | Dio + Socket.IO                           |
| Persistence   | SharedPreferences + Hive                  |
| Maps          | google_maps_flutter + geocoding           |
| CI/CD         | GitHub Actions (iOS/Android)              |

---

## 🏗️ Project Structure

```
lib/
├── core/                  # Foundation
│   ├── app/               # Theme, routes
│   ├── domain/            # Entities, use cases
│   ├── data/              # Repositories, sources
│   └── utils/             # Helpers, extensions
│
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── chat/              # Messaging
│   ├── home/              # Main feed
│   ├── map/               # Location services
│   ├── profile/           # User management
│   └── settings/          # App configuration
│   └── search/          # App search for users
│
├── l10n/                  # Localization
├── main.dart              # Entry point
└── di.dart                # Dependency injection
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.19+
- Android Studio / Xcode
- Firebase project configured
- Backend API running

### Installation

```bash
git clone https://github.com/hazzemSaid/buldm_frontend.git
cd buldm_frontend
flutter pub get
```

---

## 🔧 Environment Setup

Create a `.env` file at the project root:

```env
# Core Services
API_BASE_URL=https://your-api.com
ONESIGNAL_APP_ID=your_app_id

# Location Services
GOOGLE_MAPS_KEY=your_key
```

---

## 🛠️ Build & Run

```bash
# Development mode
flutter run

# Production build (Android)
flutter build apk --release

# Production build (iOS)
flutter build ios --release
```



## 🤝 Contribution

- 🔍 Review open issues for current priorities
- 🍴 Fork the repository
- 🌿 Create a feature branch  
  `git checkout -b feature/description`
- 💾 Commit changes  
  `git commit -m 'Meaningful message'`
- 📤 Push to branch  
  `git push origin feature/description`
- 🔀 Open a pull request with:
  - Description of changes
  - Screenshots (if applicable)
  - Testing documentation

---

## 📜 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 📬 Contact

Hazzem Said  
📧 haazemsaidd@gmail.com  
💼 [LinkedIn](www.linkedin.com/in/hazem-said-775b66263)  
