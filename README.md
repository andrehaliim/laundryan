# Laundryan

> **Status**: Active Development
> **Version**: 0.1.0
> **Framework**: Flutter
> **Language**: Dart
> **Architecture**: MVVM (Model-View-ViewModel) with Riverpod

Laundryan is a modern, feature-rich laundry management application built with Flutter. It is designed to streamline the process of tracking laundry cycles, managing wardrobes, and monitoring laundry activities with an intuitive user interface and robust state management.

## 📋 Table of Contents

- [Key Features](#-key-features)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Installation](#-installation)
- [Running the App](#-running-the-app)
- [File Overview](#-file-overview)
- [Contribution Guidelines](#-contribution-guidelines)
- [License](#-license)

## 🌟 Key Features

### 🎨 Modern UI/UX
- **Material 3 Design**: Built with Flutter's latest Material Design components for a premium look and feel.
- **Responsive Layout**: Adapts seamlessly to different screen sizes.
- **Polished Animations**: Smooth transitions and micro-interactions enhance the user experience.

### 👕 Wardrobe Management
- **Item Cataloging**: Organize your clothing with detailed categorization (tops, bottoms, outerwear, etc.).
- **Photo Integration**: Add images to each clothing item for easy identification.
- **Metadata Tracking**: Keep track of item details such as material, color, and acquisition date.

### 🧺 Laundry Management
- **Cycle Tracking**: Monitor laundry cycles from washing to folding.
- **Activity Logging**: Maintain a history of all laundry activities.
- **Order Management**: Create and manage laundry orders with tracking.

### 🧠 State Management
- **Riverpod**: Robust, compile-safe state management using Riverpod.
- **MVVM Architecture**: Clean separation of concerns between UI, business logic, and data.
- **Provider System**: Efficient state updates and dependency injection.

## 🛠️ Technology Stack

| Category | Technology | Version |
|----------|------------|---------|
| **Framework** | Flutter | 3.38.3 |
| **Language** | Dart | 3.10.1 |
| **State Management** | Riverpod | 2.6.2 |
| **Routing** | GoRouter | 15.0.1 |
| **Design System** | Material 3 | - |
| **Build System** | Flutter CLI | - |
| **Environment** | FVM | 3.4.0 |

## 📂 Project Structure

```
laundryan/
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── lib/                  # Dart source code
│   ├── core/             # Core functionality
│   │   ├── providers/    # Riverpod providers
│   │   ├── router/       # App router configuration
│   │   └── theme/        # Theme and color definitions
│   ├── models/           # Data models
│   │   ├── clothing_item.dart
│   │   ├── laundry_activity.dart
│   │   ├── laundry_order.dart
│   │   └── user.dart
│   ├── screens/          # UI screens
│   │   ├── main_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── wardrobe_screen.dart
│   │   └── sessions_screen.dart
│   ├── services/         # API and service integrations
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets
├── test/                 # Unit and widget tests
├── pubspec.yaml          # Project dependencies
└── README.md             # Project documentation
```

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your development machine:

- **Flutter SDK**: Version 3.38.3 or higher
- **Dart SDK**: Version 3.10.1 or higher
- **Android Studio / VS Code**: With Flutter and Dart extensions
- **FVM (Flutter Version Management)**: Recommended for managing Flutter versions

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/andrehaliim/laundryan.git
   cd laundryan
   ```

2. **Set up Flutter version (using FVM)**:
   ```bash
   fvm use
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

## 🏃‍♂️ Running the App

### Debug Mode

To run the app in debug mode with hot-reload support:

```bash
flutter run
```

### Release Mode

To build and run the app in release mode:

```bash
flutter run --release
```

### Available Commands

```bash
# Build Android APK
flutter build apk

# Build iOS App
flutter build ios

# Clean build artifacts
flutter clean

# Run tests
flutter test
```

## 📋 File Overview

### Core Files

| File | Description |
|------|-------------|
| `lib/main.dart` | Application entry point and root widget |
| `lib/core/theme/app_theme.dart` | Material 3 theme configuration |
| `lib/core/router/app_router.dart` | GoRouter configuration |
| `lib/core/providers/app_info_provider.dart` | App information provider |

### Screens

| File | Description |
|------|-------------|
| `lib/screens/splash_screen.dart` | Initial splash screen displayed on app launch |
| `lib/screens/onboarding_screen.dart` | Onboarding flow for new users |
| `lib/screens/main_screen.dart` | Main application screen with bottom navigation |
| `lib/screens/wardrobe_screen.dart` | Wardrobe management screen |
| `lib/screens/sessions_screen.dart` | Laundry sessions tracking screen |

### Models

| File | Description |
|------|-------------|
| `lib/models/clothing_item.dart` | Represents a clothing item in the wardrobe |
| `lib/models/laundry_order.dart` | Represents a laundry order |
| `lib/models/laundry_activity.dart` | Represents a laundry activity log |
| `lib/models/user.dart` | Represents user information |

## 📝 Code Style

- **Format**: Code should follow Dart's standard formatting conventions
- **Linters**: Run `flutter analyze` to check for linting issues
- **Comments**: Use English for all code comments and documentation
- **Naming**: PascalCase for classes, camelCase for variables and functions

## 🤝 Contribution Guidelines

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. Create a **feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. Open a **Pull Request**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
