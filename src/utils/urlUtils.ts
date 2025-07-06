/**
 * URL utility functions for the app
 */

/**
 * Extracts the domain from a URL
 * @param url The URL to extract the domain from
 * @returns The domain name without protocol and www
 */
export const extractDomain = (url: string): string => {
  try {
    // Handle empty or invalid URLs
    if (!url) return '';
    
    // Ensure URL has a protocol
    let processedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      processedUrl = 'https://' + url;
    }
    
    // Parse the URL
    const urlObj = new URL(processedUrl);
    let domain = urlObj.hostname;
    
    // Remove www. if present
    if (domain.startsWith('www.')) {
      domain = domain.substring(4);
    }
    
    return domain;
  } catch (error) {
    // If URL parsing fails, try a simple regex approach
    try {
      const domainMatch = url.match(/^(?:https?:\/\/)?(?:www\.)?([^\/:]+)/i);
      return domainMatch ? domainMatch[1] : url;
    } catch {
      // If all else fails, return the original URL
      return url;
    }
  }
};

/**
 * Formats a URL for display by removing protocol and trailing slashes
 * @param url The URL to format
 * @returns The formatted URL
 */
export const formatUrlForDisplay = (url: string): string => {
  if (!url) return '';
  
  // Remove protocol
  let formatted = url.replace(/^(https?:\/\/)?(www\.)?/i, '');
  
  // Remove trailing slash
  if (formatted.endsWith('/')) {
    formatted = formatted.slice(0, -1);
  }
  
  return formatted;
};

/**
 * Ensures a URL has a protocol
 * @param url The URL to ensure has a protocol
 * @returns The URL with a protocol
 */
export const ensureUrlProtocol = (url: string): string => {
  if (!url) return '';
  
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'https://' + url;
  }
  
  return url;
};