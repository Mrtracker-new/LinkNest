import React, { useState, useEffect } from 'react';
import { StyleSheet, View, ScrollView, Share, Alert, Linking, Platform, StatusBar, ToastAndroid } from 'react-native';
import UrlOpener from '../utils/UrlOpener';
import { Text, Card, Button, IconButton, Menu, Divider, useTheme, Chip, Surface, Banner, ActivityIndicator } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp, useFocusEffect } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { RootStackParamList } from '../navigation';
import { useApp } from '../context/AppContext';
import { extractDomain, ensureUrlProtocol } from '../utils/urlUtils.ts';

// Helper function to clean and process YouTube URLs
const processYoutubeUrl = (url: string, description?: string): string => {
  // Clean the URL - ensure there are no line breaks or extra spaces
  let cleanUrl = url.trim().replace(/\s+/g, '');
  
  // Ensure URL has a scheme
  if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://') && cleanUrl.length > 0) {
    cleanUrl = `https://${cleanUrl}`;
    console.log('Added https:// scheme to URL:', cleanUrl);
  }
  
  // Special handling for YouTube URLs
  if (cleanUrl.includes('youtu.be') || cleanUrl.includes('youtube.com')) {
    const youtubeBaseRegex = /^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/?$/i;
    
    if (youtubeBaseRegex.test(cleanUrl) && description) {
      // Try different patterns to extract YouTube video ID from description
      let videoId = null;
      
      // Pattern 1: /videoID or /videoID?parameters
      const pathMatch = description.match(/[\/]([a-zA-Z0-9_-]{11})(\?|$)/);
      if (pathMatch && pathMatch[1]) {
        videoId = pathMatch[1];
      }
      
      // Pattern 2: v=videoID in the description
      if (!videoId) {
        const vParamMatch = description.match(/[?&]v=([a-zA-Z0-9_-]{11})(&|$)/);
        if (vParamMatch && vParamMatch[1]) {
          videoId = vParamMatch[1];
        }
      }
      
      // Pattern 3: Just the video ID by itself
      if (!videoId) {
        const standaloneMatch = description.match(/^\s*([a-zA-Z0-9_-]{11})\s*$/);
        if (standaloneMatch && standaloneMatch[1]) {
          videoId = standaloneMatch[1];
        }
      }
      
      if (videoId) {
        // Combine the base URL with the video ID
        return `https://youtu.be/${videoId}`;
      }
    }
  }
  
  return cleanUrl;
};

type LinkDetailsScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;
type LinkDetailsScreenRouteProp = RouteProp<RootStackParamList, 'LinkDetails'>;

const LinkDetailsScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<LinkDetailsScreenNavigationProp>();
  const route = useRoute<LinkDetailsScreenRouteProp>();
  const { links, categories, tags, deleteLink, toggleFavoriteLink } = useApp();
  const [menuVisible, setMenuVisible] = useState(false);
  const [loading, setLoading] = useState(false);
  const [bannerVisible, setBannerVisible] = useState(false);
  const [bannerMessage, setBannerMessage] = useState('');
  const styles = createStyles(theme);
  
  // Set up the navigation header on focus
  useFocusEffect(
    React.useCallback(() => {
      StatusBar.setBackgroundColor(theme.colors.surface);
      StatusBar.setBarStyle(theme.dark ? 'light-content' : 'dark-content');
      
      return () => {
        // Clean up when screen loses focus
      };
    }, [theme])
  );

  // Get link ID from route params
  const { id } = route.params;

  // Find link by ID
  const link = links.find((link) => link.id === id);

  // Find category and tags
  const category = categories.find((cat) => cat.id === link?.category);
  const linkTags = tags.filter((tag) => link?.tags.includes(tag.id));

  // Format date
  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  // Handle open link
  const handleOpenLink = async () => {
    if (!link) return;

    try {
      setLoading(true);
      
      // Process the URL using the helper function
      const cleanUrl = ensureUrlProtocol(processYoutubeUrl(link.url, link.description));
      
      // Show domain in toast on Android
      if (Platform.OS === 'android') {
        ToastAndroid.show(`Opening ${extractDomain(cleanUrl)}...`, ToastAndroid.SHORT);
      }
      
      // Detect file type from URL
      const isFile = /\.(pdf|doc|docx|xls|xlsx|ppt|pptx|txt|jpg|jpeg|png|gif|mp3|mp4|mov|zip|rar)$/i.test(cleanUrl);
      
      // Check if the URL is supported
      let supported = false;
      try {
        supported = await Linking.canOpenURL(cleanUrl);
      } catch (canOpenError) {
        console.error('Error checking if URL can be opened:', canOpenError);
        // Continue with the flow even if canOpenURL fails
      }

      if (isFile) {
        // For file URLs, show options to open with appropriate apps
        Alert.alert(
          'Open File',
          'How would you like to open this file?',
          [
            { 
              text: 'Open in Browser', 
              onPress: () => {
                Linking.openURL(cleanUrl).catch(err => {
                  console.error('Error opening URL in browser:', err);
                  setBannerMessage(`Could not open in browser: ${err}`);
                  setBannerVisible(true);
                });
              }
            },
            { 
              text: 'Open with Default App', 
              onPress: () => {
                Linking.openURL(cleanUrl).catch(err => {
                  console.error('Error opening URL with default app:', err);
                  setBannerMessage(`Could not open with default app: ${err}`);
                  setBannerVisible(true);
                });
              }
            },
            { 
              text: 'Cancel', 
              style: 'cancel' 
            },
          ]
        );
      } else {
        // For all other URLs, use our custom UrlOpener module on Android
        // or fall back to Linking on iOS
        if (Platform.OS === 'android') {
          try {
            await UrlOpener.openUrl(cleanUrl);
          } catch (err) {
            console.error('Error opening URL with UrlOpener:', err);
            // Try fallback to regular Linking
            try {
              await Linking.openURL(cleanUrl);
            } catch (linkingErr) {
              setBannerMessage(`Could not open URL: ${err}`);
              setBannerVisible(true);
            }
          }
        } else {
          // For iOS or if UrlOpener fails, fall back to the default behavior
          if (supported) {
            // For regular URLs that are supported, open directly
            await Linking.openURL(cleanUrl);
          } else {
            // For URLs that might not be supported, try to open anyway but with a warning
            Alert.alert(
              'Warning',
              `The URL may not be supported by your device, but we'll try to open it: ${cleanUrl}`,
              [
                {
                  text: 'Continue',
                  onPress: () => {
                    Linking.openURL(cleanUrl).catch(err => {
                      console.error('Error opening URL after warning:', err);
                      setBannerMessage(`Could not open URL: ${err}`);
                      setBannerVisible(true);
                    });
                  }
                },
                {
                  text: 'Cancel',
                  style: 'cancel'
                }
              ]
            );
          }
        }
      }
    } catch (error) {
      console.error('Error in handleOpenLink:', error);
      setBannerMessage(`An error occurred: ${error}`);
      setBannerVisible(true);
    } finally {
      setLoading(false);
    }
  };

  // Handle share link
  const handleShareLink = async () => {
    if (!link) return;
    try {
      // Process the URL using the helper function
      const cleanUrl = processYoutubeUrl(link.url, link.description);
      
      await Share.share({
        message: `Check out this link: ${link.title}\n${cleanUrl}`,
        url: cleanUrl,
      });
    } catch (error) {
      Alert.alert('Error', `An error occurred: ${error}`);
    }
  };

  // Handle edit link
  const handleEditLink = () => {
    navigation.navigate('EditLink', { id });
  };

  // Handle delete link
  const handleDeleteLink = () => {
    Alert.alert(
      'Delete Link',
      'Are you sure you want to delete this link? This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            await deleteLink(id);
            navigation.goBack();
          },
        },
      ]
    );
  };

  // Handle toggle favorite
  const handleToggleFavorite = async () => {
    if (!link) return;
    await toggleFavoriteLink(id);
  };

  // If link not found
  if (!link) {
    return (
      <View style={styles.container}>
        <Text>Link not found</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={theme.colors.surface} barStyle={theme.dark ? 'light-content' : 'dark-content'} />
      
      {/* Error Banner */}
      <Banner
        visible={bannerVisible}
        actions={[
          {
            label: 'Dismiss',
            onPress: () => setBannerVisible(false),
          },
        ]}
        icon={({size}) => (
          <Icon name="alert-circle" size={size} color={theme.colors.error} />
        )}
      >
        {bannerMessage}
      </Banner>
      
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {loading && (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={theme.colors.primary} />
          </View>
        )}
        
        <Surface style={styles.card} elevation={1}>
          <View style={styles.cardContent}>
            <View style={styles.header}>
              {category && (
                <Chip
                  mode="flat"
                  style={[styles.categoryChip, { backgroundColor: `${category.color}15` }]}
                  textStyle={{ color: category.color }}
                  icon={() => (
                    <Icon name={category.icon} size={16} color={category.color} />
                  )}
                >
                  {category.name}
                </Chip>
              )}
              <IconButton
                icon={link.isFavorite ? 'star' : 'star-outline'}
                iconColor={link.isFavorite ? theme.colors.tertiary : theme.colors.outline}
                size={24}
                onPress={handleToggleFavorite}
              />
            </View>

            <Text variant="headlineSmall" style={styles.title}>
              {link.title}
            </Text>

            <View style={styles.urlContainer}>
              <Icon name="link-variant" size={18} color={theme.colors.primary} style={styles.urlIcon} />
              <Text variant="bodyMedium" style={styles.url} onPress={handleOpenLink} numberOfLines={1}>
                {extractDomain(processYoutubeUrl(link.url, link.description))}
              </Text>
              <Text variant="bodySmall" style={styles.fullUrl} numberOfLines={1}>
                {processYoutubeUrl(link.url, link.description)}
              </Text>
            </View>

            {link.description && (
              <Text variant="bodyMedium" style={styles.description}>
                {link.description}
              </Text>
            )}

            <Divider style={styles.divider} />

            <View style={styles.metaContainer}>
              <Text variant="labelMedium" style={styles.metaLabel}>
                Added on
              </Text>
              <Text variant="bodyMedium" style={styles.metaValue}>
                {formatDate(link.createdAt)}
              </Text>
            </View>

            {link.createdAt !== link.updatedAt && (
              <View style={styles.metaContainer}>
                <Text variant="labelMedium" style={styles.metaLabel}>
                  Last updated
                </Text>
                <Text variant="bodyMedium" style={styles.metaValue}>
                  {formatDate(link.updatedAt)}
                </Text>
              </View>
            )}

            {linkTags.length > 0 && (
              <View style={styles.tagsContainer}>
                <Text variant="labelMedium" style={styles.tagsLabel}>
                  Tags
                </Text>
                <View style={styles.tagsList}>
                  {linkTags.map((tag) => (
                    <Chip
                      key={tag.id}
                      style={[styles.tagChip, { backgroundColor: `${tag.color}20` }]}
                      textStyle={{ color: tag.color }}
                    >
                      {tag.name}
                    </Chip>
                  ))}
                </View>
              </View>
            )}
          </View>
        </Surface>

        <Surface style={styles.actionsContainer} elevation={0}>
          <Button
            mode="contained"
            icon="open-in-new"
            onPress={handleOpenLink}
            style={[styles.actionButton, styles.primaryButton]}
            contentStyle={styles.actionButtonContent}
            loading={loading}
          >
            Open Link
          </Button>

          <View style={styles.actionButtonsRow}>
            <Button
              mode="outlined"
              icon="share-variant"
              onPress={handleShareLink}
              style={[styles.actionButton, styles.secondaryButton]}
              contentStyle={styles.actionButtonContent}
            >
              Share
            </Button>

            <Button
              mode="outlined"
              icon="pencil"
              onPress={handleEditLink}
              style={[styles.actionButton, styles.secondaryButton]}
              contentStyle={styles.actionButtonContent}
            >
              Edit
            </Button>
          </View>
          
          <Button
            mode="text"
            icon="delete"
            onPress={handleDeleteLink}
            style={styles.deleteButton}
            textColor={theme.colors.error}
            contentStyle={styles.actionButtonContent}
          >
            Delete Link
          </Button>
        </Surface>
      </ScrollView>

      <Menu
        visible={menuVisible}
        onDismiss={() => setMenuVisible(false)}
        anchor={<View />}
      >
        <Menu.Item
          leadingIcon="pencil"
          onPress={() => {
            setMenuVisible(false);
            handleEditLink();
          }}
          title="Edit"
        />
        <Menu.Item
          leadingIcon="delete"
          onPress={() => {
            setMenuVisible(false);
            handleDeleteLink();
          }}
          title="Delete"
          titleStyle={{ color: theme.colors.error }}
        />
      </Menu>
    </View>
  );
};

const createStyles = (theme: any) => StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 32,
  },
  loadingContainer: {
    padding: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  card: {
    borderRadius: 16,
    marginBottom: 16,
    overflow: 'hidden',
  },
  cardContent: {
    padding: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  categoryChip: {
    height: 32,
    paddingHorizontal: 2,
  },
  title: {
    fontWeight: '700',
    marginBottom: 12,
    lineHeight: 28,
  },
  urlContainer: {
    marginBottom: 16,
  },
  urlIcon: {
    marginRight: 8,
    marginBottom: 4,
  },
  url: {
    color: theme.colors.primary,
    fontWeight: '500',
    marginBottom: 4,
  },
  fullUrl: {
    color: theme.colors.onSurfaceVariant,
    opacity: 0.7,
  },
  description: {
    marginBottom: 16,
    lineHeight: 22,
  },
  divider: {
    marginVertical: 16,
  },
  metaContainer: {
    marginBottom: 12,
  },
  metaLabel: {
    color: theme.colors.onSurfaceVariant,
    marginBottom: 4,
  },
  metaValue: {
    fontWeight: '500',
  },
  tagsContainer: {
    marginTop: 16,
  },
  tagsLabel: {
    color: theme.colors.onSurfaceVariant,
    marginBottom: 8,
  },
  tagsList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  tagChip: {
    marginRight: 8,
    marginBottom: 8,
  },
  actionsContainer: {
    padding: 16,
    borderRadius: 16,
    backgroundColor: theme.colors.surface,
  },
  actionButtonsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  actionButton: {
    marginBottom: 12,
  },
  primaryButton: {
    marginBottom: 16,
    borderRadius: 8,
  },
  secondaryButton: {
    width: '48%',
    borderRadius: 8,
  },
  deleteButton: {
    marginTop: 8,
  },
  actionButtonContent: {
    height: 48,
  },
});

export default LinkDetailsScreen;