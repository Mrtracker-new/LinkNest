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

#### Core Functionality
- 🔗 **Link Management**: Save and organize web links with custom titles and descriptions
  - Smart URL validation and auto-formatting
  - YouTube URL special handling
  - Domain extraction for preview
  - Open links in browser with haptic feedback
- 📝 **Note Taking**: Create and manage rich text notes with full editing capabilities
  - Rich text content with formatting
  - Quick search across note content
  - Favorite notes for priority access
- 📁 **Document Storage**: Upload and organize various document types with preview support
  - PDF, Image, Word, Excel support
  - In-app document preview (PDF & images)
  - File sharing functionality
  - File type detection and icons

#### Organization & Discovery
- 🏷️ **Smart Categorization**: Organize resources using customizable categories and tags
  - Color-coded categories with custom icons
  - Multi-tag support per resource
  - Category filtering from home screen
- ⭐ **Favorites System**: Mark important resources for quick access
- 🔍 **Powerful Search**: Full-text search across all your resources
  - Real-time search with debouncing
  - Search across titles, URLs, descriptions, and content
  - Filter status display
- 🎯 **Advanced Filtering**: Filter by categories, tags, and favorites
  - Multi-criteria filtering
  - Sort by newest, oldest, alphabetical, or favorites
  - Active filter badges

#### User Experience
- 🌙 **Dark Mode Support**: Beautiful dark theme for comfortable viewing
  - System theme detection
  - Manual theme toggle
  - Consistent theming across all components
- 📱 **Cross-Platform**: Native performance on both iOS and Android
- 🎨 **Material Design 3**: Modern UI following Google's latest design guidelines
- ✨ **Smooth Animations**: 60fps native animations for all interactions
  - Animated FAB with breathing effect
  - Animated buttons with press feedback
  - Optimized icon rendering
  - Skeleton loaders for perceived performance
- 📳 **Haptic Feedback**: Tactile feedback on all interactions
- 🔄 **Pull-to-Refresh**: Refresh content with native gestures
- 🎯 **Toast Notifications**: Non-intrusive feedback for user actions
- 📊 **Empty States**: Helpful guidance when no content exists
- 🔐 **Error Boundaries**: Graceful error handling with recovery options

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
| **React Native Haptic Feedback** | Haptic vibrations | 2.3.3 |
| **React Native Document Picker** | File selection | 10.1.3 |
| **React Native File Viewer** | Document preview | 2.1.5 |
| **React Native Share** | Share functionality | 12.1.0 |
| **React Native FS** | File system access | 2.20.0 |

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
│   │   ├── AnimatedButton.tsx      # Animated button with press feedback
│   │   ├── AnimatedCard.tsx        # Animated card component
│   │   ├── AnimatedFAB.tsx         # Floating action button with animations
│   │   ├── DocumentCard.tsx        # Document display card
│   │   ├── EmptyState.tsx          # Empty state component
│   │   ├── ErrorBoundary.tsx       # Error boundary for crash handling
│   │   ├── FilterBar.tsx           # Advanced filtering UI
│   │   ├── LinkCard.tsx            # Link display card
│   │   ├── NoteCard.tsx            # Note display card
│   │   ├── OptimizedIcon.tsx       # Memoized icon component
│   │   ├── SkeletonLoader.tsx      # Loading skeletons
│   │   └── Toast.tsx               # Toast notification system
│   ├── context/             # React Context providers
│   │   ├── AppContext.tsx          # App state and data management
│   │   └── ThemeContext.tsx        # Theme switching logic
│   ├── hooks/               # Custom React hooks
│   │   └── useHaptic.ts            # Haptic feedback hook
│   ├── navigation/          # Navigation configuration
│   │   └── index.tsx               # Stack & tab navigation
│   ├── screens/             # App screens
│   │   ├── AddDocumentScreen.tsx   # Document upload
│   │   ├── AddLinkScreen.tsx       # Add new link
│   │   ├── AddNoteScreen.tsx       # Create note
│   │   ├── CategoriesScreen.tsx    # Manage categories
│   │   ├── DocumentDetailsScreen.tsx # Document viewer
│   │   ├── DocumentsScreen.tsx     # Documents list
│   │   ├── EditLinkScreen.tsx      # Edit link
│   │   ├── EditNoteScreen.tsx      # Edit note
│   │   ├── HomeScreen.tsx          # Dashboard
│   │   ├── LinkDetailsScreen.tsx   # Link details
│   │   ├── LinksScreen.tsx         # Links list
│   │   ├── NoteDetailsScreen.tsx   # Note viewer
│   │   ├── NotesScreen.tsx         # Notes list
│   │   ├── SettingsScreen.tsx      # App settings
│   │   └── TagsScreen.tsx          # Manage tags
│   ├── types/               # TypeScript type definitions
│   │   └── index.ts                # App-wide types
│   └── utils/               # Utility functions
│       ├── debounce.ts             # Debounce utility
│       ├── UrlOpener.ts            # URL handling
│       └── urlUtils.ts             # URL validation
├── android/                 # Android-specific code
├── ios/                     # iOS-specific code
├── App.tsx                  # Main app component
├── package.json             # Dependencies and scripts
└── Documentation/           # Project documentation
    ├── BUGFIX_TEXT_RENDERING.md
    ├── DEPLOYMENT_GUIDE.md
    ├── PERFORMANCE_IMPROVEMENTS.md
    └── PRODUCTION_READINESS.md
```

## 🎨 Features in Detail

### Theme System
- **Light & Dark Modes**: Automatic system detection with manual override
- **Material Design 3**: Modern color schemes and typography
- **Consistent Styling**: Unified design language across all components
- **Dynamic Theming**: Real-time theme switching without restart

### Data Management
- **Local Storage**: Secure local data persistence with AsyncStorage
- **Type Safety**: Full TypeScript support for robust development
- **State Management**: Context API for efficient state handling
- **Data Integrity**: Automatic data validation and error recovery
- **Default Data**: Pre-configured categories and tags for quick start

### User Experience Enhancements
- **Smooth Animations**: Native performance with React Native Reanimated (60fps)
  - Breathing FAB animation
  - Button press animations
  - Scroll-based animations
- **Haptic Feedback**: Vibration feedback for all user actions
  - Light haptics for selections
  - Medium haptics for saves
  - Heavy haptics for errors
  - Success haptics for completions
- **Loading States**: Skeleton loaders for improved perceived performance
- **Empty States**: Helpful guidance with actionable CTAs
- **Error Handling**: ErrorBoundary with user-friendly error messages
- **Toast Notifications**: Non-intrusive feedback system
- **Pull-to-Refresh**: Native refresh gesture support
- **Gesture Support**: Intuitive touch interactions
- **Search & Filter**: Fast and responsive content discovery with debouncing
- **Responsive Design**: Optimized for various screen sizes

### Performance Optimizations
- **Memoization**: React.memo for frequently rendered components
- **useMemo & useCallback**: Optimized re-renders
- **OptimizedIcon**: Memoized icon component reduces re-renders
- **FlatList Optimization**: Proper windowing and virtualization
- **Debounced Search**: Reduced API calls and re-renders
- **Native Driver**: All animations use native driver for 60fps

## 🧪 Development

### Available Scripts

```bash
# Start Metro server
npm start

# Start with cache reset
npm run reset-cache

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run tests
npm test

# TypeScript type check
npm run type-check

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Clean cache
npm run clean

# Clean Android build
npm run clean:android

# Clean iOS build
npm run clean:ios
```

### Code Quality & Best Practices
- **ESLint**: Code linting with React Native configuration
- **Prettier**: Automatic code formatting
- **TypeScript**: Strict type checking enabled
- **Jest**: Unit testing framework
- **Error Boundaries**: Graceful error handling
- **Type Safety**: Zero `any` types in production code
- **Performance**: Optimized with memoization and lazy loading
- **Accessibility**: Accessible components and navigation

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
- Read [PRODUCTION_READINESS.md](PRODUCTION_READINESS.md) for deployment info
- Check [BUGFIX_TEXT_RENDERING.md](BUGFIX_TEXT_RENDERING.md) for common fixes
- Contact the development team

### Known Issues & Solutions
- **Text Rendering Errors**: All fixed in v1.0.0 (see BUGFIX_TEXT_RENDERING.md)
- **TypeScript Errors**: All resolved with proper type definitions
- **Performance**: Optimized with memoization (see PERFORMANCE_IMPROVEMENTS.md)

## 🚀 Production Ready

LinkNest v1.0.0 is production-ready with:
- ✅ Full TypeScript type safety
- ✅ Comprehensive error handling
- ✅ Performance optimizations
- ✅ Material Design 3 UI
- ✅ Cross-platform compatibility
- ✅ Extensive documentation

See [PRODUCTION_READINESS.md](PRODUCTION_READINESS.md) for deployment guide.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright © 2025 Rolan Lobo. All rights reserved.

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
