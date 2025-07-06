# 📚 LinkNest - Your Ultimate Resource Organizer

<div align="center">
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen.svg" alt="Version" />
  <img src="https://img.shields.io/badge/React%20Native-0.80.1-blue.svg" alt="React Native Version" />
  <img src="https://img.shields.io/badge/TypeScript-5.0.4-blue.svg" alt="TypeScript Version" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
  <img src="https://img.shields.io/badge/Year-2025-orange.svg" alt="Year" />
</div>

<div align="center">
  <p><em>A powerful and intuitive mobile app for organizing your links, notes, and files</em></p>
</div>

---

## 🚀 Overview

LinkNest is a comprehensive React Native application designed to help you manage your digital resources efficiently. Whether you're a student, professional, or researcher, LinkNest provides a centralized platform to organize your links, notes, and files with an elegant and user-friendly interface.

### ✨ Key Features

- 🔗 **Link Management**: Save and organize web links with custom titles and descriptions
- 📝 **Note Taking**: Create and manage rich text notes with full editing capabilities
- 📁 **Document Storage**: Upload and organize various document types with preview support
- 🏷️ **Smart Categorization**: Organize resources using customizable categories and tags
- ⭐ **Favorites System**: Mark important resources for quick access
- 🔍 **Powerful Search**: Full-text search across all your resources
- 🎯 **Advanced Filtering**: Filter by categories, tags, and favorites
- 🌙 **Dark Mode Support**: Beautiful dark theme for comfortable viewing
- 📱 **Cross-Platform**: Native performance on both iOS and Android
- 🎨 **Material Design 3**: Modern UI following Google's latest design guidelines

## 🛠️ Tech Stack

| Technology | Purpose | Version |
|------------|---------|----------|
| **React Native** | Mobile app framework | 0.80.1 |
| **TypeScript** | Type safety | 5.0.4 |
| **React Navigation** | Navigation system | 7.x |
| **React Native Paper** | UI components & theming | 5.14.5 |
| **AsyncStorage** | Local data persistence | 2.2.0 |
| **React Native Vector Icons** | Icon library | 10.2.0 |
| **React Native Gesture Handler** | Gesture management | 2.27.1 |
| **React Native Reanimated** | Smooth animations | 3.18.0 |

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (>= 18.0.0)
- **React Native CLI** (19.0.0)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development - macOS only)
- **Git**

> **Note**: Complete the [React Native Environment Setup](https://reactnative.dev/docs/environment-setup) guide before proceeding.

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Mrtracker-new/LinkNest.git
cd LinkNest
```

### 2. Install Dependencies
```bash
npm install
```

### 3. iOS Setup (macOS only)
```bash
cd ios && pod install && cd ..
```

### 4. Start Metro Server
```bash
npm start
```

### 5. Run the App

#### For Android:
```bash
npm run android
```

#### For iOS:
```bash
npm run ios
```

## 📱 Usage Guide

### Getting Started
1. **Home Screen**: Overview of your recent and favorite resources
2. **Add Resources**: Tap the floating action button (+) to add links, notes, or documents
3. **Categories**: Organize resources into custom categories
4. **Tags**: Apply multiple tags for granular organization
5. **Search**: Use the search bar to find specific resources
6. **Filters**: Apply category and tag filters for focused browsing

### Managing Resources

#### Adding a Link
1. Tap the "+" button
2. Select "Add Link"
3. Enter URL, title, and description
4. Choose category and add tags
5. Save your link

#### Creating a Note
1. Tap the "+" button
2. Select "Add Note"
3. Enter title and content
4. Organize with categories and tags
5. Save your note

#### Uploading Documents
1. Tap the "+" button
2. Select "Add Document"
3. Choose document from device
4. Add metadata and organize
5. Save your document

## 📂 Project Structure

```
LinkNest/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── DocumentCard.tsx
│   │   ├── EmptyState.tsx
│   │   ├── FilterBar.tsx
│   │   ├── LinkCard.tsx
│   │   └── NoteCard.tsx
│   ├── context/             # React Context providers
│   │   ├── AppContext.tsx
│   │   └── ThemeContext.tsx
│   ├── navigation/          # Navigation configuration
│   │   └── index.tsx
│   ├── screens/             # App screens
│   │   ├── AddDocumentScreen.tsx
│   │   ├── AddLinkScreen.tsx
│   │   ├── AddNoteScreen.tsx
│   │   ├── CategoriesScreen.tsx
│   │   ├── DocumentsScreen.tsx
│   │   ├── HomeScreen.tsx
│   │   ├── LinksScreen.tsx
│   │   ├── NotesScreen.tsx
│   │   ├── SettingsScreen.tsx
│   │   └── TagsScreen.tsx
│   ├── theme/               # Theme configuration
│   │   └── index.ts
│   ├── types/               # TypeScript type definitions
│   │   └── index.ts
│   └── utils/               # Utility functions
│       ├── UrlOpener.ts
│       ├── urlUtils.ts
│       └── urlUtils.d.ts
├── android/                 # Android-specific code
├── ios/                     # iOS-specific code
├── App.tsx                  # Main app component
└── package.json             # Dependencies and scripts
```

## 🎨 Features in Detail

### Theme System
- **Light & Dark Modes**: Automatic system detection with manual override
- **Material Design 3**: Modern color schemes and typography
- **Consistent Styling**: Unified design language across all components

### Data Management
- **Local Storage**: Secure local data persistence with AsyncStorage
- **Type Safety**: Full TypeScript support for robust development
- **State Management**: Context API for efficient state handling

### User Experience
- **Smooth Animations**: Native performance with React Native Reanimated
- **Gesture Support**: Intuitive touch interactions
- **Search & Filter**: Fast and responsive content discovery
- **Responsive Design**: Optimized for various screen sizes

## 🧪 Development

### Available Scripts

```bash
# Start Metro server
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run tests
npm test

# Lint code
npm run lint
```

### Code Quality
- **ESLint**: Code linting with React Native configuration
- **Prettier**: Automatic code formatting
- **TypeScript**: Static type checking
- **Jest**: Unit testing framework

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow TypeScript best practices
- Maintain consistent code formatting
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

## 🐛 Troubleshooting

### Common Issues

#### Metro bundler issues
```bash
npx react-native start --reset-cache
```

#### Android build issues
```bash
cd android && ./gradlew clean && cd ..
npm run android
```

#### iOS build issues
```bash
cd ios && rm -rf Pods/ && pod install && cd ..
npm run ios
```

### Getting Help
- Check [React Native Troubleshooting](https://reactnative.dev/docs/troubleshooting)
- Review [GitHub Issues](https://github.com/Mrtracker-new/LinkNest/issues)
- Contact the development team

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- React Native team for the amazing framework
- React Native Paper for beautiful UI components
- Material Design team for design guidelines
- Open source community for continuous inspiration

---

## 👨‍💻 Author

**Rolan Lobo**
- 💻 Full Stack Developer
- 📱 React Native Enthusiast

---

<div align="center">
  <p>Made with ❤️ by <strong>Rolan Lobo</strong></p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
