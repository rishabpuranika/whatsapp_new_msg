# WhatsApp Quick Message 💬⚡

A Flutter app to send WhatsApp messages without saving contacts. Now supporting Android, iOS, and Windows.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-blue)

## Features

- 📱 **Quick WhatsApp Messaging** - Send messages to any number without adding to contacts
- 🌍 **Country Code Selector** - Choose from 15+ country codes with flag emojis
- 💬 **Optional Message** - Pre-fill a message before opening WhatsApp
- 🕐 **Recent Numbers** - Quick access to your last 5 contacted numbers
- 🎨 **Modern Design** - Beautiful dark theme with Glassmorphism UI and smooth animations
- 💻 **Windows Support** - Fully optimized for Desktop usage

## Screenshots

The app features a clean, dark-themed interface with:
- Animated gradient background
- Glassmorphism cards and elements
- Country code dropdown with flags
- Phone number input with smart validation
- Recent numbers history

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Android Studio / VS Code
- Android device, emulator, or Windows PC

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/whatsapp_quick_message.git
   cd whatsapp_quick_message
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Build

### Android APK

```bash
flutter build apk --release
```
The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

### Windows Installer (MSIX)

To create a Windows installer:

```bash
flutter pub run msix:create
```
The installer will be available in the `build/windows/runner/Release` directory (or wherever the msix package outputs).

## Usage

1. **Select Country Code** - Tap the dropdown to choose your country
2. **Enter Phone Number** - Type the phone number (country code is added automatically)
3. **Add Message (Optional)** - Type a pre-filled message
4. **Click "Open in WhatsApp"** - The app opens WhatsApp (or WhatsApp Web on Desktop) with the chat ready

## Supported Countries

🇮🇳 India (+91) | 🇺🇸 USA (+1) | 🇬🇧 UK (+44) | 🇦🇪 UAE (+971) | 🇸🇦 Saudi Arabia (+966)
🇸🇬 Singapore (+65) | 🇦🇺 Australia (+61) | 🇩🇪 Germany (+49) | 🇫🇷 France (+33) | 🇯🇵 Japan (+81)
🇨🇳 China (+86) | 🇧🇷 Brazil (+55) | 🇿🇦 South Africa (+27) | 🇳🇬 Nigeria (+234) | 🇰🇪 Kenya (+254)

## Dependencies

- `url_launcher` - Opens WhatsApp with the phone number
- `shared_preferences` - Stores recent numbers locally
- `cupertino_icons` - iOS-style icons
- `google_fonts` - Premium typography (Outfit font)
- `msix` - Windows installer generation

## License

This project is open source and available under the MIT License.

---

Made with ❤️ using Flutter
