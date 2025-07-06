/**
 * Type declarations for urlUtils module
 */

/**
 * Extracts the domain from a URL
 * @param url The URL to extract the domain from
 * @returns The domain name without protocol and www
 */
export declare function extractDomain(url: string): string;

/**
 * Formats a URL for display by removing protocol and trailing slashes
 * @param url The URL to format
 * @returns The formatted URL
 */
export declare function formatUrlForDisplay(url: string): string;

/**
 * Ensures a URL has a protocol
 * @param url The URL to ensure has a protocol
 * @returns The URL with a protocol
 */
export declare function ensureUrlProtocol(url: string): string;