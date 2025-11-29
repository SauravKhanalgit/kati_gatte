# Kati Gatte 📅

<div align="center">

**A Beautiful & Powerful Nepali Calendar System Tray Application**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

*Keep track of Nepali dates right from your system tray!*

</div>

---

## ✨ Features

### 🎯 Core Features
- **📅 Live Date Display** - Shows current Nepali (BS) and English (AD) dates in system tray
- **🔄 Auto-Refresh** - Automatically updates at midnight
- **📋 Quick Copy** - Copy dates to clipboard with one click
- **🎨 Beautiful UI** - Modern, gradient-based Material 3 design
- **🌓 Dark Mode** - Automatic system theme support

### 🚀 Advanced Features
- **🗓️ Full Calendar View** - Interactive date picker with holiday markers
- **� Date Converter** - Convert between BS and AD dates seamlessly
- **🎉 Holiday Tracking** - Nepali public holidays highlighted
- **📱 Responsive Design** - Works perfectly on any screen size
- **⚡ Quick Actions** - Access common tasks from system tray menu

### 🎨 UI/UX Highlights
- **Gradient Headers** - Eye-catching gradient backgrounds
- **Info Cards** - Quick glance at month, day, and year
- **Action Chips** - Quick access to common dates
- **Smooth Animations** - Polished Material Design transitions
- **Toast Notifications** - Instant feedback for all actions

---

## 📸 Screenshots

> System Tray Menu with both BS & AD dates, copy options, and quick actions

> Full Calendar View with holiday markers and gradient design

> Date Converter with bidirectional conversion (BS ↔ AD)

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- Platform-specific requirements:
  - macOS: Xcode Command Line Tools
  - Windows: Visual Studio 2022
  - Linux: GTK 3.0 development files

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/SauravKhanalgit/kati_gatte.git
cd kati_gatte
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the application:**
```bash
# For macOS
flutter run -d macos

# For Windows
flutter run -d windows

# For Linux
flutter run -d linux
```

---

## 🏗️ Building for Production

### macOS
```bash
flutter build macos --release
```
The app will be in `build/macos/Build/Products/Release/kati_gatte.app`

### Windows
```bash
flutter build windows --release
```
The app will be in `build/windows/runner/Release/`

### Linux
```bash
flutter build linux --release
```
The app will be in `build/linux/x64/release/bundle/`

---

## 📋 System Tray Menu

The app provides a comprehensive system tray menu:

- **📅 Current Day** - Shows day of the week
- **BS Date** - Nepali calendar date
- **AD Date** - English calendar date
- **📋 Copy Options**:
  - Copy Nepali Date
  - Copy AD Date  
  - Copy Both Dates
- **🗓️ Open Full Calendar** - Interactive calendar view
- **🔄 Date Converter** - BS ↔ AD conversion tool
- **🔄 Refresh Date** - Manual refresh option
- **ℹ️ About** - App information
- **❌ Quit** - Exit the application

---

## 🎯 Features in Detail

### 1. Full Calendar View
- Interactive date picker with Nepali calendar
- Beautiful gradient header showing selected date
- Holiday markers with celebration icons
- Info cards for Month, Day, and Year
- Quick copy buttons for both BS and AD dates
- "Go to Today" button in app bar

### 2. Date Converter
- Bidirectional conversion (BS ↔ AD)
- Segmented button for direction selection
- Visual conversion flow with arrows
- Quick action chips for common dates
- One-click copy to clipboard
- Beautiful color-coded result display

### 3. Auto-Refresh System
- Checks time every minute
- Automatically refreshes at midnight
- Updates system tray display
- No manual intervention needed

### 4. Public Holidays (BS 2081)
- नयाँ वर्ष (New Year)
- लोकतन्त्र दिवस (Democracy Day)
- महिला दिवस (Women's Day)
- संविधान दिवस (Constitution Day)
- दशैं (Dashain)
- तिहार (Tihar)
- *More holidays can be easily added*

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **UI**: Material 3 Design
- **Packages**:
  - `system_tray` - System tray integration
  - `nepali_date_picker` - Nepali calendar support
  - `flutter/services` - Clipboard functionality

---

## 📁 Project Structure

```
kati_gatte/
├── lib/
│   └── main.dart              # Main application logic
├── assets/
│   ├── logo.png               # Application logo
│   └── tray_icon.png          # System tray icon
├── android/                   # Android platform files
├── ios/                       # iOS platform files
├── macos/                     # macOS platform files
├── windows/                   # Windows platform files
├── linux/                     # Linux platform files
├── pubspec.yaml               # Dependencies
└── README.md                  # This file
```

---

## 🎨 Customization

### Adding More Holidays

Edit the `holidays` map in `_CalendarScreenState`:

```dart
final Map<String, String> holidays = {
  '2081-01-01': 'नयाँ वर्ष (New Year)',
  '2081-XX-XX': 'Your Holiday Name',
  // Add more holidays here
};
```

### Changing Date Format

Modify the date format in `initSystemTray()`:

```dart
String nepaliDate = NepaliDateFormat("yyyy MMMM dd").format(now);
```

Available format patterns:
- `yyyy` - Full year (e.g., 2081)
- `MMMM` - Full month name
- `MMM` - Short month name
- `dd` - Day with leading zero
- `EEEE` - Full day name

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Ideas for Contribution
- [ ] Add more Nepali public holidays
- [ ] Implement reminder system
- [ ] Add widget for desktop
- [ ] Support for different Nepali date formats
- [ ] Multi-language support (Nepali/English toggle)
- [ ] Export calendar to PDF/Image
- [ ] Monthly calendar grid view

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Saurav Khanal**
- GitHub: [@SauravKhanalgit](https://github.com/SauravKhanalgit)

---

## 🙏 Acknowledgments

- **nepali_date_picker** package for Nepali calendar support
- **system_tray** package for system tray integration
- Flutter community for amazing tools and support

---

## 📧 Support

If you have any questions or run into issues, please:
- Open an issue on GitHub
- Star ⭐ the repository if you find it useful!

---

<div align="center">

**Made with ❤️ in Nepal 🇳🇵**

*Keeping Nepali culture alive, one date at a time!*

</div>
