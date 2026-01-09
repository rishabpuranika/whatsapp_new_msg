# InstaNewMsg 💬⚡

A Flutter mobile app to send WhatsApp messages without saving contacts.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)

## Features

- 📱 **Quick WhatsApp Messaging** - Send messages to any number without adding to contacts
- 🌍 **Country Code Selector** - Choose from 15+ country codes with flag emojis
- 💬 **Optional Message** - Pre-fill a message before opening WhatsApp
- 🕐 **Recent Numbers** - Quick access to your last 5 contacted numbers
- 🎨 **Modern UI** - Beautiful dark theme with WhatsApp-inspired green accents

## Screenshots

The app features a clean, dark-themed interface with:
- Gradient background
- Country code dropdown with flags
- Phone number input with smart validation
- Optional message field
- Recent numbers history

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/insta_new_msg.git
   cd insta_new_msg
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Build APK

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## Usage

1. **Select Country Code** - Tap the dropdown to choose your country
2. **Enter Phone Number** - Type the phone number (country code is added automatically)
3. **Add Message (Optional)** - Type a pre-filled message
4. **Tap "Open in WhatsApp"** - The app opens WhatsApp with the chat ready

## Supported Countries

🇮🇳 India (+91) | 🇺🇸 USA (+1) | 🇬🇧 UK (+44) | 🇦🇪 UAE (+971) | 🇸🇦 Saudi Arabia (+966)
🇸🇬 Singapore (+65) | 🇦🇺 Australia (+61) | 🇩🇪 Germany (+49) | 🇫🇷 France (+33) | 🇯🇵 Japan (+81)
🇨🇳 China (+86) | 🇧🇷 Brazil (+55) | 🇿🇦 South Africa (+27) | 🇳🇬 Nigeria (+234) | 🇰🇪 Kenya (+254)

## Dependencies

- `url_launcher` - Opens WhatsApp with the phone number
- `shared_preferences` - Stores recent numbers locally
- `cupertino_icons` - iOS-style icons

## License

This project is open source and available under the MIT License.

---

Made with ❤️ using Flutter
