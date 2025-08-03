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
[https://github.com/user-attachments/assets/a6b724d9-3c12-43af-999a-3349e11f168a](https://github.com/user-attachments/assets/20644e50-9640-4bf6-98cb-43c86985bbda)

<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/7721cec1-a277-4183-b7cb-15c6ffa92777" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/e41caa63-4f29-49db-97b2-37c1d4d2ed27" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/f7c3b9ad-3244-4d0f-859d-32e6d5e68dbe" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/b3701a6b-8d8e-4dc5-bf12-d83fabb4ffb0" />

<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/653f93f5-2ef6-49d9-b1a7-d306cd6ffdaf" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/b9481474-2e91-49f5-b9e5-9a9d8ffd8855" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/374d43ec-2724-46a5-aaa9-2a4d86bb0c7e" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/008ddb7a-2e45-4039-8d22-d503a8980dbc" />

<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/41fb4fdc-c5ca-4531-9587-ad2c52796fce" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/e1e52b40-a190-45f9-aa00-7d557860a16e" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/0f0d2229-554d-4279-8e04-960cbf2c91ce" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/45f047d0-6df5-4202-b932-5750508b6c47" />

<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/40eec375-e8ac-4609-ae28-a4395acd54d8" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/5f085624-4060-4597-965e-deb00445a96d" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/e589d5e8-c33e-4dc3-8bf6-1a75417f1365" />
<img width="225" height="450" alt="Image" src="https://github.com/user-attachments/assets/0f54f30a-114b-400e-9be2-dc767d934d49" />



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
