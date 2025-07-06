import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';
import { DefaultTheme as NavigationLightTheme, DarkTheme as NavigationDarkTheme } from '@react-navigation/native';

// Custom colors
const customColors = {
  primary: '#6200EE',
  primaryContainer: '#E8DEF8',
  secondary: '#03DAC6',
  secondaryContainer: '#CEFAF5',
  tertiary: '#FF6B9D',
  tertiaryContainer: '#FFE8EE',
  surface: '#FFFFFF',
  surfaceVariant: '#F7F7F7',
  background: '#FAFAFA',
  error: '#D32F2F',
  errorContainer: '#FFEBEE',
  onPrimary: '#FFFFFF',
  onPrimaryContainer: '#21005E',
  onSecondary: '#000000',
  onSecondaryContainer: '#00413D',
  onTertiary: '#FFFFFF',
  onTertiaryContainer: '#31111D',
  onSurface: '#1A1A1A',
  onSurfaceVariant: '#5A5A5A',
  onBackground: '#1A1A1A',
  onError: '#FFFFFF',
  onErrorContainer: '#410E0B',
  outline: '#8E8E93',
  shadow: '#000000',
  inverseSurface: '#313033',
  inverseOnSurface: '#F4EFF4',
  inversePrimary: '#D0BCFF',
};

// Custom dark colors
const customDarkColors = {
  primary: '#D0BCFF',
  primaryContainer: '#4F378B',
  secondary: '#A4F0E8',
  secondaryContainer: '#004D47',
  tertiary: '#FFB3C1',
  tertiaryContainer: '#5D2A37',
  surface: '#1F1F1F',
  surfaceVariant: '#2B2B2B',
  background: '#141414',
  error: '#FF8A95',
  errorContainer: '#8C1D18',
  onPrimary: '#381E72',
  onPrimaryContainer: '#EADDFF',
  onSecondary: '#003A37',
  onSecondaryContainer: '#A4F0E8',
  onTertiary: '#492532',
  onTertiaryContainer: '#FFB3C1',
  onSurface: '#E8E8E8',
  onSurfaceVariant: '#C5C5C5',
  onBackground: '#E8E8E8',
  onError: '#FFFFFF',
  onErrorContainer: '#FFB4AB',
  outline: '#8F8F8F',
  shadow: '#000000',
  inverseSurface: '#E6E1E5',
  inverseOnSurface: '#313033',
  inversePrimary: '#6200EE',
};

// Create navigation-compatible font structure
const createNavigationFonts = () => ({
  regular: { fontFamily: 'System', fontWeight: 'normal' as const },
  medium: { fontFamily: 'System', fontWeight: '500' as const },
  bold: { fontFamily: 'System', fontWeight: 'bold' as const },
  heavy: { fontFamily: 'System', fontWeight: '900' as const },
});

// Create Paper-compatible font structure (MD3 typography)
const createPaperFonts = () => {
  // Use the default MD3 font configuration as a base
  const defaultFonts = MD3LightTheme.fonts;
  return defaultFonts;
};

// Create custom light theme for Paper
const PaperLightTheme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    ...customColors,
  },
  fonts: createPaperFonts(),
};

// Create custom dark theme for Paper
const PaperDarkTheme = {
  ...MD3DarkTheme,
  colors: {
    ...MD3DarkTheme.colors,
    ...customDarkColors,
  },
  fonts: createPaperFonts(),
};

// Create custom light theme for Navigation
const NavigationLightCustomTheme = {
  ...NavigationLightTheme,
  colors: {
    ...NavigationLightTheme.colors,
    ...customColors,
    // Ensure all required navigation colors are present
    primary: customColors.primary,
    background: customColors.background,
    card: customColors.surface,
    text: customColors.onSurface,
    border: customColors.outline,
    notification: customColors.error,
  },
  fonts: createNavigationFonts(),
};

// Create custom dark theme for Navigation
const NavigationDarkCustomTheme = {
  ...NavigationDarkTheme,
  colors: {
    ...NavigationDarkTheme.colors,
    ...customDarkColors,
    // Ensure all required navigation colors are present
    primary: customDarkColors.primary,
    background: customDarkColors.background,
    card: customDarkColors.surface,
    text: customDarkColors.onSurface,
    border: customDarkColors.outline,
    notification: customDarkColors.error,
  },
  fonts: createNavigationFonts(),
};

// Export themes for different providers
export const lightTheme = PaperLightTheme;
export const darkTheme = PaperDarkTheme;
export const navigationLightTheme = NavigationLightCustomTheme;
export const navigationDarkTheme = NavigationDarkCustomTheme;

// Export themes with names used in ThemeContext
export const customLightTheme = PaperLightTheme;
export const customDarkTheme = PaperDarkTheme;

// Combined themes for use with both Paper and Navigation
export const CombinedLightTheme = {
  ...PaperLightTheme,
  ...NavigationLightCustomTheme,
  colors: {
    ...PaperLightTheme.colors,
    ...NavigationLightCustomTheme.colors,
  },
  // Keep Paper's fonts for PaperProvider
  fonts: PaperLightTheme.fonts,
};

export const CombinedDarkTheme = {
  ...PaperDarkTheme,
  ...NavigationDarkCustomTheme,
  colors: {
    ...PaperDarkTheme.colors,
    ...NavigationDarkCustomTheme.colors,
  },
  // Keep Paper's fonts for PaperProvider
  fonts: PaperDarkTheme.fonts,
};

// For backward compatibility
export const CustomLightTheme = PaperLightTheme;
export const CustomDarkTheme = PaperDarkTheme;