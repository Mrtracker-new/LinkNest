import { NativeModules, Platform, Linking } from 'react-native';

const { UrlOpener } = NativeModules;

interface UrlOpenerInterface {
  openUrl(url: string): Promise<string>;
}

// Create a JavaScript wrapper for the native module with improved error handling
const UrlOpenerModule: UrlOpenerInterface = {
  openUrl: async (url: string): Promise<string> => {
    console.log('UrlOpener.ts received URL:', url);
    
    try {
      // Safety check for null or undefined URL
      if (!url) {
        console.error('UrlOpener received null or undefined URL');
        return Promise.reject('Invalid URL: URL is null or undefined');
      }

      // Check if the native module is available
      if (!UrlOpener && Platform.OS === 'android') {
        console.error('UrlOpener native module is not available');
        // Fall back to Linking API if native module is not available
        console.log('Falling back to Linking API');
        return fallbackToLinking(url);
      }
      
      // Clean and validate the URL
      let cleanUrl = url.trim();
      
      // Ensure the URL has a scheme
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://' + cleanUrl;
      }
      
      // Basic URL validation
      try {
        new URL(cleanUrl);
      } catch (urlError) {
        console.error('Invalid URL format:', cleanUrl);
        return Promise.reject(`Invalid URL format: ${cleanUrl}`);
      }
      
      console.log('Cleaned URL:', cleanUrl);
      
      // Call the native module to open the URL
      if (Platform.OS === 'android') {
        if (UrlOpener) {
          console.log('Calling Android native module with URL:', cleanUrl);
          try {
            return UrlOpener.openUrl(cleanUrl);
          } catch (nativeError) {
            console.error('Error in native module, falling back to Linking:', nativeError);
            return fallbackToLinking(cleanUrl);
          }
        } else {
          return fallbackToLinking(cleanUrl);
        }
      } else {
        // iOS implementation - use Linking API directly
        return fallbackToLinking(cleanUrl);
      }
      
    } catch (error) {
      console.error('Error in UrlOpener.ts:', error);
      // Try to use Linking as a last resort
      try {
        return fallbackToLinking(url);
      } catch (linkingError) {
        return Promise.reject(error instanceof Error ? error.message : String(error));
      }
    }
  },
};

// Helper function to use React Native's Linking API as a fallback
async function fallbackToLinking(url: string): Promise<string> {
  try {
    // Ensure URL has a scheme
    let urlToOpen = url.trim();
    if (!urlToOpen.startsWith('http://') && !urlToOpen.startsWith('https://')) {
      urlToOpen = 'https://' + urlToOpen;
    }
    
    console.log('Using Linking.openURL fallback with:', urlToOpen);
    await Linking.openURL(urlToOpen);
    return Promise.resolve('URL opened successfully with Linking API');
  } catch (error) {
    console.error('Error in Linking fallback:', error);
    return Promise.reject(`Failed to open URL with Linking API: ${error instanceof Error ? error.message : String(error)}`);
  }
}

export default UrlOpenerModule;