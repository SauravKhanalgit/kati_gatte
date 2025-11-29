# Kati Gatte

A Flutter desktop application that displays the current Nepali date in your system tray (menu bar).

## Features

- 📅 Shows current Nepali date in the system tray
- 🔄 Refresh date functionality
- 🎨 Clean and minimal interface
- 💻 Cross-platform support (macOS, Windows, Linux)

## Dependencies

- `flutter` - Flutter SDK
- `system_tray` - System tray integration
- `nepali_date_picker` - Nepali calendar support

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd Kati_Gatte
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d macos  # For macOS
flutter run -d windows  # For Windows
flutter run -d linux  # For Linux
```

## Building

To build the application for your platform:

### macOS
```bash
flutter build macos
```

### Windows
```bash
flutter build windows
```

### Linux
```bash
flutter build linux
```

## Project Structure

```
lib/
  ├── main.dart          # Main application entry point
assets/
  ├── logo.png           # Application logo
  └── tray_icon.png      # System tray icon
```

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
