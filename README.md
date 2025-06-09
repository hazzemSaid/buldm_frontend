<div align="center">
  <img src="https://img.shields.io/badge/status-developing-yellow" alt="Status">
  <img src="https://img.shields.io/github/issues/hazzemSaid/buldm_frontend" alt="Issues">
  <img src="https://img.shields.io/github/issues-pr/hazzemSaid/buldm_frontend" alt="Pull Requests">
</div>
<div align="center">
  <h1>BULDM Frontend</h1>
  <p>
    <strong>Lost & Found Social Media App (Flutter)</strong><br>
    <em>Find what you’ve lost. Return what you’ve found.</em>
  </p>
  <p>
    <a href="https://github.com/hazzemSaid/buldm_backend">Backend API</a> |
    <a href="https://github.com/hazzemSaid">@hazzemSaid</a>
  </p>
  <sub>Last Updated: 2025-06-09</sub>
</div>

---

## 🗂️ Table of Contents

- [About the App](#about-the-app)
- [Core Features](#core-features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Localization](#localization)
- [API & Backend](#api--backend)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## 📱 About the App

**BULDM** (“Find it” in Arabic) is a community-powered social mobile app for lost and found items. Anyone can report lost or found objects and help return them to their owners, building trust and kindness in our local communities.

The app is under active development and connects seamlessly to a robust backend for real-time data, notifications, and user management.

---

## 🚩 Core Features

- **Authentication**
  - Secure sign-up & login (email/password, Google, Apple)
  - Email verification for safety

- **Lost & Found Post Management**
  - Add, edit, and delete lost/found posts with images, categories, and precise locations
  - Search for items by location, category, or text

- **Location Awareness**
  - Find posts near you using geolocation
  - (Planned) Map view for browsing posts

- **Profiles & User Management**
  - Customizable profiles with avatar, contact info, and item history

- **Push Notifications**
  - Instant alerts for matches, updates, or messages (OneSignal powered)

- **Multilingual**
  - English & Arabic (easy to extend)

- **Modern UI/UX**
  - Clean, responsive, and intuitive design

---

## 🖼️ Screenshots

*Screenshots will be added as the app matures. Stay tuned!*

---

## ⚙️ Tech Stack

- **Flutter** (Dart) for cross-platform mobile development
- **Firebase** for core cloud services (analytics, messaging, etc.)
- **OneSignal** for push notifications
- **Hydrated BLoC** for persistent, reactive state management
- **REST API**: Connects to [buldm_backend](https://github.com/hazzemSaid/buldm_backend) (Node.js, Express, MongoDB)

---

## 🚀 Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/hazzemSaid/buldm_frontend.git
   cd buldm_frontend
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   - Create a `.env` file in the root directory:
     ```
     ONESIGNAL_APP_ID=your_onesignal_app_id
     API_BASE_URL=your_backend_api_url
     ```
   - Set up Firebase for your platforms (see [FlutterFire docs](https://firebase.flutter.dev/docs/overview/))

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🏗️ Project Structure

```
lib/
├── features/             # Main application features/modules
│   ├── auth/             # Auth flow
│   ├── home/             # Home feed
│   ├── onboarding/       # Onboarding UI
│   ├── profile/          # User profile & settings
│   └── setting/          # App settings
├── l10n/                 # Localization resources
├── provider/             # BLoC state management
├── routes/               # App navigation
├── utils/                # Common widgets and helpers
└── main.dart             # App entrypoint
```

---

## 🌍 Localization

- Fully supports **English** and **Arabic**
- Easily add more languages via `lib/l10n/`
- Switch language instantly in-app

---

## 🔗 API & Backend

BULDM Frontend communicates with the [BULDM Backend](https://github.com/hazzemSaid/buldm_backend) for:

- User authentication & management
- Post CRUD & geolocation search
- Notifications & reporting

**Backend features:** JWT Auth, Express.js, MongoDB, MailerSend, Cloudinary, and more.

---

## 🤝 Contributing

We welcome your ideas and help!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Describe your feature'`)
4. Push to your branch (`git push origin feature/your-feature`)
5. Open a Pull Request

Please check [open issues](https://github.com/hazzemSaid/buldm_frontend/issues) or suggest new ones!

---

## 🛤️ Roadmap

- [ ] Map-based browsing & location picker
- [ ] In-app chat/messaging
- [ ] AI-powered image/item recognition
- [ ] Advanced filters & recommendations
- [ ] Admin/moderation dashboard
- [ ] More themes, animations, and polish

---

## 📜 License

This project is currently unlicensed. For usage, distribution, or partnership, please contact [@hazzemSaid](https://github.com/hazzemSaid).

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [OneSignal](https://onesignal.com/)
- [Lottie](https://lottiefiles.com/) for beautiful animations

---

> **Backend:** See [buldm_backend](https://github.com/hazzemSaid/buldm_backend) for API/server code.
