# 🚀 FluxConverter

A modern, high-performance currency converter built with **Flutter** and **Dart**. FluxConverter provides real-time exchange rates for global currencies with a sleek, user-friendly interface.

---

## ✨ Features
- **Real-time Rates**: Powered by [ExchangeRate-API](https://www.exchangerate-api.com/).
- **Modern UI**: Clean, card-based design with smooth gradients.
- **Smart Swap**: Instantly flip between source and target currencies.
- **Secure**: Sensitive API keys are managed via environment variables (`.env`).
- **Multi-platform**: Runs on Android, iOS, Web, and macOS.

---

## 🛠️ Installation & Setup

1. Clone the repository
   ```bash
   git clone https://github.com/lucadani7/FluxConverter.git
   cd FluxConverter
   ```
2. Add your API Key, creating a `.env` file in the root directory:
   ```bash
   API_KEY=your_free_api_key_here
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app
   ```bash
   flutter run
   ```
---

## 🏗️ Tech Stack
- **Framework**: Flutter (Dart)
- **IDE**: [Android Studio](https://developer.android.com/studio)
- **State Management**: StatefulWidgets
- **Networking:**: `http` package
- **Config**: `flutter_dotenv`
- **Logging**: `dart:developer` (Production-ready logging)

---

## 📄 License
This project is licensed under the Apache-2.0 License.
