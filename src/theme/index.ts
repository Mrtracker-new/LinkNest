import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';
import { DefaultTheme as NavigationLightTheme, DarkTheme as NavigationDarkTheme } from '@react-navigation/native';

// Modern custom colors with better contrast and vibrancy
const customColors = {
  primary: '#7C3AED',        // Vibrant purple
  primaryContainer: '#F3E8FF', // Light purple container
  secondary: '#10B981',       // Modern emerald green
  secondaryContainer: '#D1FAE5', // Light green container
  tertiary: '#F59E0B',        // Warm amber
  tertiaryContainer: '#FEF3C7', // Light amber container
  surface: '#FFFFFF',
  surfaceVariant: '#F9FAFB',  // Slightly gray
  background: '#F8FAFC',      // Soft background
  error: '#EF4444',
  errorContainer: '#FEE2E2',
  onPrimary: '#FFFFFF',
  onPrimaryContainer: '#4C1D95',
  onSecondary: '#FFFFFF',
  onSecondaryContainer: '#064E3B',
  onTertiary: '#FFFFFF',
  onTertiaryContainer: '#78350F',
  onSurface: '#1F2937',
  onSurfaceVariant: '#6B7280',
  onBackground: '#1F2937',
  onError: '#FFFFFF',
  onErrorContainer: '#7F1D1D',
  outline: '#9CA3AF',
  shadow: '#000000',
  inverseSurface: '#1F2937',
  inverseOnSurface: '#F9FAFB',
  inversePrimary: '#A78BFA',
  // Additional gradient colors
  gradientStart: '#7C3AED',
  gradientEnd: '#A78BFA',
  cardShadow: 'rgba(124, 58, 237, 0.1)',
};

// Modern custom dark colors with OLED-friendly blacks
const customDarkColors = {
  primary: '#A78BFA',         // Lighter purple for dark mode
  primaryContainer: '#5B21B6', // Deep purple container
  secondary: '#34D399',       // Bright emerald for dark
  secondaryContainer: '#065F46', // Dark green container
  tertiary: '#FBBF24',        // Bright amber
  tertiaryContainer: '#92400E', // Dark amber container
  surface: '#1E293B',         // Slate surface
  surfaceVariant: '#334155',  // Lighter slate
  background: '#0F172A',      // Deep slate background
  error: '#F87171',
  errorContainer: '#991B1B',
  onPrimary: '#4C1D95',
  onPrimaryContainer: '#DDD6FE',
  onSecondary: '#064E3B',
  onSecondaryContainer: '#A7F3D0',
  onTertiary: '#78350F',
  onTertiaryContainer: '#FDE68A',
  onSurface: '#F1F5F9',
  onSurfaceVariant: '#CBD5E1',
  onBackground: '#F1F5F9',
  onError: '#FFFFFF',
  onErrorContainer: '#FCA5A5',
  outline: '#64748B',
  shadow: '#000000',
  inverseSurface: '#F1F5F9',
  inverseOnSurface: '#1E293B',
  inversePrimary: '#7C3AED',
  // Additional gradient colors
  gradientStart: '#7C3AED',
  gradientEnd: '#A78BFA',
  cardShadow: 'rgba(167, 139, 250, 0.15)',
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