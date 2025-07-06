import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';
import { DefaultTheme as NavigationLightTheme, DarkTheme as NavigationDarkTheme } from '@react-navigation/native';
import { customLightTheme, customDarkTheme, navigationLightTheme, navigationDarkTheme } from '../theme';

type ThemeMode = 'light' | 'dark' | 'system';

interface ThemeContextType {
  themeMode: ThemeMode;
  isDarkMode: boolean;
  theme: typeof MD3LightTheme | typeof MD3DarkTheme;
  navigationTheme: typeof NavigationLightTheme | typeof NavigationDarkTheme;
  setThemeMode: (mode: ThemeMode) => void;
  toggleDarkMode: () => void;
}

// Define the props that will be passed to children function
interface ThemeProps {
  isDarkMode: boolean;
  theme: typeof MD3LightTheme | typeof MD3DarkTheme;
  navigationTheme: typeof NavigationLightTheme | typeof NavigationDarkTheme;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Storage key for theme preference
const THEME_STORAGE_KEY = '@linknest:theme';

export const ThemeProvider: React.FC<{ children: ReactNode | ((props: ThemeProps) => ReactNode) }> = ({ children }) => {
  const systemColorScheme = useColorScheme();
  const [themeMode, setThemeModeState] = useState<ThemeMode>('system');
  
  // Determine if dark mode is active based on theme mode and system preference
  const isDarkMode = themeMode === 'system' 
    ? systemColorScheme === 'dark' 
    : themeMode === 'dark';

  // Load saved theme preference on mount
  useEffect(() => {
    const loadThemePreference = async () => {
      try {
        const savedTheme = await AsyncStorage.getItem(THEME_STORAGE_KEY);
        if (savedTheme) {
          setThemeModeState(savedTheme as ThemeMode);
        }
      } catch (error) {
        console.error('Failed to load theme preference:', error);
      }
    };

    loadThemePreference();
  }, []);

  // Save theme preference when it changes
  const setThemeMode = async (mode: ThemeMode) => {
    try {
      await AsyncStorage.setItem(THEME_STORAGE_KEY, mode);
      setThemeModeState(mode);
    } catch (error) {
      console.error('Failed to save theme preference:', error);
    }
  };

  // Toggle between light and dark mode
  const toggleDarkMode = () => {
    const newMode = isDarkMode ? 'light' : 'dark';
    setThemeMode(newMode);
  };

  // Get the appropriate themes based on dark mode state
  const theme = isDarkMode ? customDarkTheme : customLightTheme;
  const navigationTheme = isDarkMode ? navigationDarkTheme : navigationLightTheme;

  // If children is a function, pass the theme props to it
  if (typeof children === 'function') {
    return (
      <ThemeContext.Provider
        value={{
          themeMode,
          isDarkMode,
          theme,
          navigationTheme,
          setThemeMode,
          toggleDarkMode,
        }}
      >
        {children({ isDarkMode, theme, navigationTheme } as ThemeProps)}
      </ThemeContext.Provider>
    );
  }

  // Otherwise, just render the children
  return (
    <ThemeContext.Provider
      value={{
        themeMode,
        isDarkMode,
        theme,
        navigationTheme,
        setThemeMode,
        toggleDarkMode,
      }}
    >
      {children}
    </ThemeContext.Provider>
  );
};

export const useThemeContext = () => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useThemeContext must be used within a ThemeProvider');
  }
  return context;
};