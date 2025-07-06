import React, { useState, useEffect } from 'react';
import { StyleSheet, View, ScrollView, Alert, Linking, Platform, Modal } from 'react-native';
import { Text, Button, Chip, Divider, IconButton, Menu, useTheme, ActivityIndicator } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import RNFS from 'react-native-fs';
import FileViewer from 'react-native-file-viewer';
import Share from 'react-native-share';
import ImageView from 'react-native-image-viewing';
import Pdf from 'react-native-pdf';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { useApp } from '../context/AppContext';
import { RootStackParamList } from '../navigation';
import { Document } from '../types';
// Import the required dependency for react-native-pdf
import ReactNativeBlobUtil from 'react-native-blob-util';

type DocumentDetailsRouteProp = RouteProp<RootStackParamList, 'DocumentDetails'>;
type DocumentDetailsNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const DocumentDetailsScreen = () => {
  const theme = useTheme();
  const route = useRoute<DocumentDetailsRouteProp>();
  const navigation = useNavigation<DocumentDetailsNavigationProp>();
  const { documents, categories, tags, deleteDocument, toggleFavoriteDocument } = useApp();
  
  // State
  const [document, setDocument] = useState<Document | null>(null);
  const [menuVisible, setMenuVisible] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [imageViewVisible, setImageViewVisible] = useState(false);
const [isPdfViewerVisible, setIsPdfViewerVisible] = useState(false);
const [pdfUri, setPdfUri] = useState('');
const styles = createStyles(theme);
  
  // Get document ID from route params
  const { id } = route.params;
  
  // Find document by ID
  useEffect(() => {
    const doc = documents.find((d) => d.id === id);
    if (doc) {
      setDocument(doc);
    } else {
      // Document not found, navigate back
      Alert.alert('Error', 'Document not found.');
      navigation.goBack();
    }
  }, [id, documents, navigation]);
  
  // Get category and tags
  const category = document ? categories.find((c) => c.id === document.category) : null;
  const documentTags = document
    ? tags.filter((tag) => document.tags.includes(tag.id))
    : [];
  
  // Get file icon based on type
  const getFileIcon = (type: string, mimeType?: string) => {
    // Check mimeType first if available, then fall back to type
    const checkType = mimeType || type;
    const fileType = checkType.toLowerCase();
    
    if (fileType.includes('pdf')) return 'file-pdf-box';
    if (fileType.includes('doc') || fileType.includes('word')) return 'file-word-box';
    if (fileType.includes('xls') || fileType.includes('sheet')) return 'file-excel-box';
    if (fileType.includes('ppt') || fileType.includes('presentation')) return 'file-powerpoint-box';
    if (fileType.includes('txt') || fileType.includes('text')) return 'file-document-box';
    if (fileType.includes('jpg') || fileType.includes('jpeg') || fileType.includes('png') || fileType.includes('image')) return 'file-image-box';
    return 'file-box';
  };
  
  // Format file size
  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };
  
  // Format date
  const formatDate = (timestamp: number) => {
    return new Date(timestamp).toLocaleString();
  };
  
  // Handle share document
  const handleShareDocument = async () => {
    if (!document) return;
    
    try {
      setIsLoading(true);
      
      // Check if file exists
      const exists = await RNFS.exists(document.uri);
      if (!exists) {
        Alert.alert('Error', 'File does not exist and cannot be shared.');
        return;
      }
      
      // Prepare share options
      const shareOptions = {
        title: `Share ${document.name}`,
        message: `Sharing document: ${document.name}`,
        url: `file://${document.uri}`,
        type: document.mimeType || 'application/octet-stream',
        filename: document.name,
        saveToFiles: true,
      };
      
      const result = await Share.open(shareOptions);
      console.log('Share result:', result);
    } catch (error) {
      console.error('Error sharing document:', error);
      if (error.message !== 'User did not share') {
        Alert.alert('Error', 'Failed to share document. Please try again.');
      }
    } finally {
      setIsLoading(false);
    }
  };
  
  // Handle open document
  const handleOpenDocument = async () => {
    if (!document) return;
    
    try {
      setIsLoading(true);
      
      // Check if file exists
      const exists = await RNFS.exists(document.uri);
      if (!exists) {
        throw new Error('File does not exist');
      }
      
// Get file extension for additional type checking
const fileExtension = document.name.split('.').pop()?.toLowerCase() || '';
const isImage = document.mimeType?.startsWith('image/') || 
               ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(fileExtension);
const isPdf = document.mimeType?.includes('pdf') || fileExtension === 'pdf';

// For images, use built-in viewer as primary option
if (isImage) {
  // Directly use built-in image viewer for reliability
  setImageViewVisible(true);
  return;
}

// For PDFs, use internal PDF viewer
if (isPdf) {
  try {
    // Ensure the PDF URI is properly formatted
    const pdfPath = document.uri.startsWith('file://') ? document.uri : `file://${document.uri}`;
    setPdfUri(pdfPath);
    setIsPdfViewerVisible(true);
  } catch (error) {
    console.error('Error setting up PDF viewer:', error);
    Alert.alert('Error', 'Failed to open PDF viewer. Please try again.');
  }
  return;
}

// Strategy 1: Try FileViewer with comprehensive options
try {
        await FileViewer.open(document.uri, {
          showOpenWithDialog: true,
          showAppsSuggestions: true,
          displayName: document.name,
        });
        return;
      } catch (fileViewerError) {
        console.log('FileViewer failed for non-image file:', fileViewerError);
        
        // Strategy 2: Create temp file with proper extension for better file type detection
        try {
          const tempDir = Platform.OS === 'ios' 
            ? RNFS.TemporaryDirectoryPath 
            : RNFS.ExternalCachesDirectoryPath || RNFS.CachesDirectoryPath;
          
          // Ensure proper file extension based on MIME type
          let properExtension = fileExtension;
          if (document.mimeType) {
            const mimeType = document.mimeType.toLowerCase();
            if (mimeType.includes('pdf')) {
              properExtension = 'pdf';
            } else if (mimeType.includes('video/mp4')) {
              properExtension = 'mp4';
            } else if (mimeType.includes('video/')) {
              properExtension = mimeType.split('/')[1] || fileExtension;
            } else if (mimeType.includes('audio/')) {
              properExtension = mimeType.split('/')[1] || fileExtension;
            } else if (mimeType.includes('text/plain')) {
              properExtension = 'txt';
            } else if (mimeType.includes('application/msword')) {
              properExtension = 'doc';
            } else if (mimeType.includes('application/vnd.openxmlformats-officedocument.wordprocessingml')) {
              properExtension = 'docx';
            } else if (mimeType.includes('application/vnd.ms-excel')) {
              properExtension = 'xls';
            } else if (mimeType.includes('application/vnd.openxmlformats-officedocument.spreadsheetml')) {
              properExtension = 'xlsx';
            } else if (mimeType.includes('application/vnd.ms-powerpoint')) {
              properExtension = 'ppt';
            } else if (mimeType.includes('application/vnd.openxmlformats-officedocument.presentationml')) {
              properExtension = 'pptx';
            }
          }
          
          const tempFileName = `view_${Date.now()}.${properExtension}`;
          const tempFilePath = `${tempDir}/${tempFileName}`;
          
          await RNFS.copyFile(document.uri, tempFilePath);
          
          await FileViewer.open(tempFilePath, {
            showOpenWithDialog: true,
            showAppsSuggestions: true,
            displayName: document.name,
          });
          
          // Clean up temp file after delay
          setTimeout(() => {
            RNFS.exists(tempFilePath).then(exists => {
              if (exists) {
                RNFS.unlink(tempFilePath).catch(err => 
                  console.log('Failed to clean up temp file:', err)
                );
              }
            });
          }, 15000);
          
          return;
        } catch (tempError) {
          console.log('Temp file strategy failed:', tempError);
        }
        
        // Strategy 3: Try Linking API for specific file types
        try {
          const fileUri = `file://${document.uri}`;
          const canOpen = await Linking.canOpenURL(fileUri);
          if (canOpen) {
            await Linking.openURL(fileUri);
            return;
          }
        } catch (linkingError) {
          console.log('Linking failed:', linkingError);
        }
        
        // If all strategies fail, show user-friendly options instead of auto-sharing
        throw fileViewerError;
      }
      
    } catch (error) {
      console.error('Error opening document:', error);
      
      // Determine file type for better error messaging
      const fileExtension = document.name.split('.').pop()?.toLowerCase() || '';
      const isImageFile = document.mimeType?.startsWith('image/') || 
                         ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(fileExtension);
      const isPDF = document.mimeType?.includes('pdf') || fileExtension === 'pdf';
      const isVideo = document.mimeType?.startsWith('video/') || 
                     ['mp4', 'avi', 'mov', 'mkv', 'wmv', '3gp'].includes(fileExtension);
      const isAudio = document.mimeType?.startsWith('audio/') || 
                     ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg'].includes(fileExtension);
      const isDocument = document.mimeType?.includes('word') || document.mimeType?.includes('excel') || 
                        document.mimeType?.includes('powerpoint') || 
                        ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(fileExtension);
      
      let title = 'Cannot Open File';
      let message = '';
      let buttons = [];
      
      if (error.message && error.message.includes('No app associated')) {
        if (isImageFile) {
          title = 'No Image Viewer Available';
          message = 'Your device does not have an app installed that can view images.';
          buttons = [
            {
              text: 'Install Gallery App',
              onPress: () => {
                Linking.openURL('market://search?q=gallery%20photo%20viewer')
                  .catch(() => {
                    Linking.openURL('https://play.google.com/store/search?q=gallery%20photo%20viewer');
                  });
              }
            },
            {
              text: 'Share File',
              onPress: () => handleShareDocument()
            },
            { text: 'OK', style: 'cancel' }
          ];
        } else if (isPDF) {
          title = 'No PDF Viewer Available';
          message = 'Your device does not have an app installed that can view PDF files.';
          buttons = [
            {
              text: 'Install PDF Reader',
              onPress: () => {
                Linking.openURL('market://search?q=pdf%20reader%20viewer')
                  .catch(() => {
                    Linking.openURL('https://play.google.com/store/search?q=pdf%20reader%20viewer');
                  });
              }
            },
            {
              text: 'Share File',
              onPress: () => handleShareDocument()
            },
            { text: 'OK', style: 'cancel' }
          ];
        } else if (isVideo) {
          title = 'No Video Player Available';
          message = 'Your device does not have an app installed that can play video files.';
          buttons = [
            {
              text: 'Install Video Player',
              onPress: () => {
                Linking.openURL('market://search?q=video%20player%20media')
                  .catch(() => {
                    Linking.openURL('https://play.google.com/store/search?q=video%20player%20media');
                  });
              }
            },
            {
              text: 'Share File',
              onPress: () => handleShareDocument()
            },
            { text: 'OK', style: 'cancel' }
          ];
        } else if (isAudio) {
          title = 'No Audio Player Available';
          message = 'Your device does not have an app installed that can play audio files.';
          buttons = [
            {
              text: 'Install Music Player',
              onPress: () => {
                Linking.openURL('market://search?q=music%20player%20audio')
                  .catch(() => {
                    Linking.openURL('https://play.google.com/store/search?q=music%20player%20audio');
                  });
              }
            },
            {
              text: 'Share File',
              onPress: () => handleShareDocument()
            },
            { text: 'OK', style: 'cancel' }
          ];
        } else if (isDocument) {
          title = 'No Office App Available';
          message = 'Your device does not have an app installed that can view office documents.';
          buttons = [
            {
              text: 'Install Office App',
              onPress: () => {
                Linking.openURL('market://search?q=microsoft%20office%20documents')
                  .catch(() => {
                    Linking.openURL('https://play.google.com/store/search?q=microsoft%20office%20documents');
                  });
              }
            },
            {
              text: 'Share File',
              onPress: () => handleShareDocument()
            },
            { text: 'OK', style: 'cancel' }
          ];
        } else {
          title = 'No Compatible App';
          message = `No app is available to open .${fileExtension} files.\n\nYou can try sharing the file to find compatible apps.`;
          buttons = [
            {
              text: 'Search App Store',
              onPress: () => {
                Linking.openURL(`market://search?q=${fileExtension}%20file%20viewer`)
                  .catch(() => {
                    Linking.openURL(`https://play.google.com/store/search?q=${fileExtension}%20file%20viewer`);
                  });
              }
            },
            {
              text: 'Share File',
              onPress: () => handleShareDocument()
            },
            { text: 'OK', style: 'cancel' }
          ];
        }
      } else if (error.message && error.message.includes('File does not exist')) {
        message = 'The file no longer exists. It may have been moved or deleted.';
        buttons = [{ text: 'OK', style: 'default' }];
      } else {
        message = 'Unable to open the file. This could be due to:\n\n• File corruption\n• Missing compatible app\n• Insufficient permissions\n\nTry sharing the file to access it through other apps.';
        buttons = [
          {
            text: 'Share File',
            onPress: () => handleShareDocument()
          },
          { text: 'OK', style: 'cancel' }
        ];
      }
      
      Alert.alert(title, message, buttons);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Handle toggle favorite
  const handleToggleFavorite = async () => {
    if (!document) return;
    
    try {
      await toggleFavoriteDocument(document.id);
    } catch (error) {
      console.error('Error toggling favorite:', error);
      Alert.alert('Error', 'Failed to update favorite status.');
    }
  };
  
  // Handle delete document
  const handleDeleteDocument = async () => {
    if (!document) return;
    
    Alert.alert(
      'Delete Document',
      'Are you sure you want to delete this document? This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              setIsLoading(true);
              const success = await deleteDocument(document.id);
              if (success) {
                navigation.goBack();
              } else {
                throw new Error('Failed to delete document');
              }
            } catch (error) {
              console.error('Error deleting document:', error);
              Alert.alert('Error', 'Failed to delete document.');
              setIsLoading(false);
            }
          },
        },
      ]
    );
  };
  
  // Handle menu toggle
  const toggleMenu = () => setMenuVisible(!menuVisible);
  
  if (!document) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }
  
  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <ScrollView contentContainerStyle={styles.content}>
        {/* Document Header */}
        <View style={styles.header}>
          <Icon
            name={getFileIcon(document.type, document.mimeType)}
            size={60}
            color={theme.colors.primary}
            style={styles.fileIcon}
          />
          <Text variant="headlineSmall" style={[styles.fileName, { color: theme.colors.onBackground }]}>{document.name}</Text>
        </View>
        
        {/* Document Actions */}
        <View style={styles.actions}>
          <Button
            mode="contained"
            icon={(() => {
              const fileExtension = document.name.split('.').pop()?.toLowerCase() || '';
              const isImage = document.mimeType?.startsWith('image/') || ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(fileExtension);
              const isPDF = document.mimeType?.includes('pdf') || fileExtension === 'pdf';
              const isVideo = document.mimeType?.startsWith('video/') || ['mp4', 'avi', 'mov', 'mkv', 'wmv', '3gp'].includes(fileExtension);
              const isAudio = document.mimeType?.startsWith('audio/') || ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg'].includes(fileExtension);
              const isDocument = document.mimeType?.includes('word') || document.mimeType?.includes('excel') || document.mimeType?.includes('powerpoint') || ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(fileExtension);
              
              if (isImage) return 'image';
              if (isPDF) return 'file-pdf-box';
              if (isVideo) return 'play';
              if (isAudio) return 'music';
              if (isDocument) return 'file-document';
              return 'file-eye';
            })()}
            onPress={handleOpenDocument}
            style={styles.openButton}
            loading={isLoading}
            disabled={isLoading}
          >
            {(() => {
              const fileExtension = document.name.split('.').pop()?.toLowerCase() || '';
              const isImage = document.mimeType?.startsWith('image/') || ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(fileExtension);
              const isPDF = document.mimeType?.includes('pdf') || fileExtension === 'pdf';
              const isVideo = document.mimeType?.startsWith('video/') || ['mp4', 'avi', 'mov', 'mkv', 'wmv', '3gp'].includes(fileExtension);
              const isAudio = document.mimeType?.startsWith('audio/') || ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg'].includes(fileExtension);
              const isDocument = document.mimeType?.includes('word') || document.mimeType?.includes('excel') || document.mimeType?.includes('powerpoint') || ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(fileExtension);
              
              if (isImage) return 'View Image';
              if (isPDF) return 'View PDF';
              if (isVideo) return 'Play Video';
              if (isAudio) return 'Play Audio';
              if (isDocument) return 'Open Document';
              return 'Open File';
            })()}
          </Button>
          
          <IconButton
            icon="share-variant"
            size={24}
            onPress={handleShareDocument}
            style={styles.shareButton}
            iconColor={theme.colors.onSurface}
            disabled={isLoading}
          />
          
          <IconButton
            icon={document.isFavorite ? 'star' : 'star-outline'}
            size={24}
            onPress={handleToggleFavorite}
            style={styles.favoriteButton}
            iconColor={document.isFavorite ? theme.colors.primary : theme.colors.onSurface}
          />
          
          <Menu
            visible={menuVisible}
            onDismiss={toggleMenu}
            anchor={<IconButton icon="dots-vertical" size={24} onPress={toggleMenu} />}
          >
            <Menu.Item
              leadingIcon="delete"
              onPress={() => {
                toggleMenu();
                handleDeleteDocument();
              }}
              title="Delete"
              titleStyle={{ color: theme.colors.error }}
            />
          </Menu>
        </View>
        
        <Divider style={[styles.divider, { backgroundColor: theme.colors.outline + '30' }]} />
        
        {/* Document Info */}
        <View style={[styles.infoSection, { backgroundColor: theme.colors.surfaceVariant, borderColor: theme.colors.outline + '20' }]}>
          <Text variant="titleMedium" style={[styles.sectionTitle, { color: theme.colors.onSurfaceVariant }]}>File Information</Text>
          
          <View style={[styles.infoRow, { borderBottomColor: theme.colors.outline + '30' }]}>
            <Text variant="bodyMedium" style={[styles.infoLabel, { color: theme.colors.onSurfaceVariant }]}>Type:</Text>
            <Text variant="bodyMedium" style={{ color: theme.colors.onSurfaceVariant }}>
              {document.type.toUpperCase()}
              {document.mimeType && document.mimeType !== document.type && (
                <Text style={{ fontSize: 12, opacity: 0.7 }}> ({document.mimeType})</Text>
              )}
            </Text>
          </View>
          
          <View style={[styles.infoRow, { borderBottomColor: theme.colors.outline + '30' }]}>
            <Text variant="bodyMedium" style={[styles.infoLabel, { color: theme.colors.onSurfaceVariant }]}>Size:</Text>
            <Text variant="bodyMedium" style={{ color: theme.colors.onSurfaceVariant }}>{formatFileSize(document.size)}</Text>
          </View>
          
          <View style={[styles.infoRow, { borderBottomColor: theme.colors.outline + '30' }]}>
            <Text variant="bodyMedium" style={[styles.infoLabel, { color: theme.colors.onSurfaceVariant }]}>Added:</Text>
            <Text variant="bodyMedium" style={{ color: theme.colors.onSurfaceVariant }}>{formatDate(document.createdAt)}</Text>
          </View>
          
          <View style={[styles.infoRow, { borderBottomColor: theme.colors.outline + '30' }]}>
            <Text variant="bodyMedium" style={[styles.infoLabel, { color: theme.colors.onSurfaceVariant }]}>Modified:</Text>
            <Text variant="bodyMedium" style={{ color: theme.colors.onSurfaceVariant }}>{formatDate(document.updatedAt)}</Text>
          </View>
        </View>
        
        <Divider style={[styles.divider, { backgroundColor: theme.colors.outline + '30' }]} />
        
        {/* Category */}
        <View style={[styles.infoSection, { backgroundColor: theme.colors.surfaceVariant, borderColor: theme.colors.outline + '20' }]}>
          <Text variant="titleMedium" style={[styles.sectionTitle, { color: theme.colors.onSurfaceVariant }]}>Category</Text>
          
          {category && (
            <Chip
              mode="outlined"
              style={[styles.categoryChip, { borderColor: category.color }]}
              textStyle={{ color: category.color }}
              icon={() => <Icon name={category.icon} size={16} color={category.color} />}
            >
              {category.name}
            </Chip>
          )}
        </View>
        
        {/* Tags */}
        {documentTags.length > 0 && (
          <>
            <Divider style={[styles.divider, { backgroundColor: theme.colors.outline + '30' }]} />
            
            <View style={[styles.infoSection, { backgroundColor: theme.colors.surfaceVariant, borderColor: theme.colors.outline + '20' }]}>
              <Text variant="titleMedium" style={[styles.sectionTitle, { color: theme.colors.onSurfaceVariant }]}>Tags</Text>
              
              <View style={styles.tagsContainer}>
                {documentTags.map((tag) => (
                  <Chip
                    key={tag.id}
                    mode="outlined"
                    style={[styles.tagChip, { borderColor: tag.color }]}
                    textStyle={{ color: tag.color }}
                  >
                    {tag.name}
                  </Chip>
                ))}
              </View>
            </View>
          </>
        )}
      </ScrollView>
      
      {/* Built-in Image Viewer */}
      <ImageView
        images={[{ uri: `file://${document?.uri || ''}` }]}
        imageIndex={0}
        visible={imageViewVisible}
        onRequestClose={() => setImageViewVisible(false)}
        HeaderComponent={() => (
          <View style={{ padding: 20, backgroundColor: 'rgba(0,0,0,0.8)' }}>
            <Text style={{ color: 'white', fontSize: 16, textAlign: 'center' }}>
              {document?.name || ''}
            </Text>
          </View>
        )}
        FooterComponent={() => (
          <View style={{ padding: 20, backgroundColor: 'rgba(0,0,0,0.8)', alignItems: 'center' }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-around', marginBottom: 10, width: '100%' }}>
              <Button
                mode="outlined"
                onPress={async () => {
                  setImageViewVisible(false);
                  try {
                    if (document) {
                      await FileViewer.open(document.uri, {
                        showOpenWithDialog: true,
                        showAppsSuggestions: true,
                        displayName: document.name,
                      });
                    }
                  } catch (error) {
                    Alert.alert(
                      'No External App Available',
                      'No external image viewer app is installed. You can install one from the app store or share this image to view it in other apps.',
                      [
                        {
                          text: 'Install App',
                          onPress: () => {
                            Linking.openURL('market://search?q=gallery%20photo%20viewer')
                              .catch(() => {
                                Linking.openURL('https://play.google.com/store/search?q=gallery%20photo%20viewer');
                              });
                          }
                        },
                        { text: 'OK', style: 'cancel' }
                      ]
                    );
                  }
                }}
                textColor="white"
                icon="open-in-app"
                compact
              >
                Open in App
              </Button>
              <Button
                mode="outlined"
                onPress={() => {
                  setImageViewVisible(false);
                  handleShareDocument();
                }}
                textColor="white"
                icon="share"
                compact
              >
                Share
              </Button>
            </View>
            <Button
              mode="text"
              onPress={() => setImageViewVisible(false)}
              textColor="white"
            >
              Close
            </Button>
          </View>
        )}
      />
      
      {/* PDF Viewer Modal */}
      {isPdfViewerVisible && (
        <Modal visible={isPdfViewerVisible} onDismiss={() => setIsPdfViewerVisible(false)}>
          <View style={{ flex: 1, backgroundColor: 'black' }}>
            <Pdf
              source={{ uri: pdfUri }}
              onLoadComplete={(numberOfPages) => {
                console.log(`number of pages: ${numberOfPages}`);
              }}
              onPageChanged={(page, numberOfPages) => {
                console.log(`current page: ${page}`);
              }}
              onError={(error) => {
                console.log(error);
                Alert.alert('Error', 'Failed to load PDF file.');
              }}
              style={{ flex: 1 }}
            />
            <View style={{ 
              position: 'absolute', 
              top: 50, 
              right: 20, 
              zIndex: 1000 
            }}>
              <Button 
                mode="contained" 
                onPress={() => setIsPdfViewerVisible(false)}
                icon="close"
                buttonColor="rgba(0,0,0,0.7)"
                textColor="white"
              >
                Close
              </Button>
            </View>
          </View>
        </Modal>
      )}
    </View>
  );
};

const createStyles = (theme: any) => StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 28,
  },
  fileIcon: {
    marginBottom: 16,
  },
  fileName: {
    textAlign: 'center',
    letterSpacing: 0.2,
    lineHeight: 28,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
  },
  openButton: {
    flex: 1,
    borderRadius: 12,
    paddingVertical: 6,
  },
  shareButton: {
    marginLeft: 8,
  },
  favoriteButton: {
    marginLeft: 8,
  },
  divider: {
    marginVertical: 20,
  },
  infoSection: {
    marginBottom: 20,
    borderRadius: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 4,
    borderWidth: 1,
  },
  sectionTitle: {
    marginBottom: 16,
    fontSize: 18,
    fontWeight: 'bold',
    letterSpacing: 0.2,
  },
  infoRow: {
    flexDirection: 'row',
    marginBottom: 10,
    paddingVertical: 6,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0,0,0,0.1)',
  },
  infoLabel: {
    width: 80,
    fontWeight: 'bold',
    fontSize: 15,
    letterSpacing: 0.1,
  },
  categoryChip: {
    alignSelf: 'flex-start',
    height: 32,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 12,
  },
  tagChip: {
    marginRight: 10,
    marginBottom: 10,
    height: 32,
  },
});

export default DocumentDetailsScreen;
