import React, { useState } from 'react';
import { StyleSheet, View, ScrollView, Alert, Platform, PermissionsAndroid } from 'react-native';
import { Button, Text, useTheme, Chip } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { pick, types, DocumentPickerResponse, isErrorWithCode, errorCodes } from '@react-native-documents/picker';
import RNFS from 'react-native-fs';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { useApp } from '../context/AppContext';
import { RootStackParamList } from '../navigation';

type AddDocumentScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const AddDocumentScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<AddDocumentScreenNavigationProp>();
  const { categories, tags, addDocument } = useApp();
  
  // State
  const [selectedFile, setSelectedFile] = useState<DocumentPickerResponse | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  
  // Request Android permissions
  const requestAndroidPermissions = async (): Promise<boolean> => {
    if (Platform.OS !== 'android') {
      return true;
    }
    
    try {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE,
        {
          title: 'Storage Permission',
          message: 'This app needs access to storage to pick documents.',
          buttonNeutral: 'Ask Me Later',
          buttonNegative: 'Cancel',
          buttonPositive: 'OK',
        }
      );
      
      return granted === PermissionsAndroid.RESULTS.GRANTED;
    } catch (err) {
      console.warn('Permission request error:', err);
      return false;
    }
  };
  
  // Handle document picker
  const handlePickDocument = async () => {
    console.log('DocumentPicker: handlePickDocument called');
    
    // Request permissions on Android
    const hasPermission = await requestAndroidPermissions();
    if (!hasPermission) {
      Alert.alert('Permission Required', 'Storage permission is required to pick documents.');
      return;
    }
    
      console.log('DocumentPicker pick function:', pick);
    console.log('Types object:', types);
    
    try {
      console.log('DocumentPicker: About to call pick()');
      const result = await pick({
        type: [
          types.pdf,
          types.doc,
          types.docx,
          types.xls,
          types.xlsx,
          types.ppt,
          types.pptx,
          types.images,
          types.plainText,
        ],
        allowMultiSelection: false,
        mode: 'import',
      });
      
      console.log('DocumentPicker: Pick result:', result);
      
      if (result && result.length > 0) {
        setSelectedFile(result[0]);
      } else {
        console.log('DocumentPicker: No file selected');
      }
    } catch (err: any) {
      // Check if user cancelled using the proper error checking
      if (isErrorWithCode(err) && err.code === errorCodes.OPERATION_CANCELED) {
        console.log('DocumentPicker: User cancelled the picker');
      } else if (isErrorWithCode(err) && err.code === errorCodes.IN_PROGRESS) {
        console.log('DocumentPicker: Multiple pickers were opened, only the last will be considered');
      } else {
        console.log('DocumentPicker: Error caught:', err);
        console.error('Error picking document:', err);
        Alert.alert('Error', 'Failed to pick document. Please try again.');
      }
    }
  };
  
  // Handle category selection
  const handleCategorySelect = (categoryId: string) => {
    setSelectedCategory(categoryId);
  };
  
  // Handle tag selection
  const handleTagSelect = (tagId: string) => {
    setSelectedTags((prev) =>
      prev.includes(tagId) ? prev.filter((id) => id !== tagId) : [...prev, tagId]
    );
  };
  
  // Get file icon based on type
  const getFileIcon = (type: string | null | undefined) => {
    if (!type) return 'file-box';
    
    const fileType = type.toLowerCase();
    if (fileType.includes('pdf')) return 'file-pdf-box';
    if (fileType.includes('doc') || fileType.includes('word')) return 'file-word-box';
    if (fileType.includes('xls') || fileType.includes('sheet')) return 'file-excel-box';
    if (fileType.includes('ppt') || fileType.includes('presentation')) return 'file-powerpoint-box';
    if (fileType.includes('txt') || fileType.includes('text')) return 'file-document-box';
    if (fileType.includes('jpg') || fileType.includes('jpeg') || fileType.includes('png') || fileType.includes('image')) return 'file-image-box';
    return 'file-box';
  };
  
  // Format file size
  const formatFileSize = (bytes: number | null | undefined) => {
    if (!bytes) return '0 B';
    
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };
  
  // Handle save document
  const handleSaveDocument = async () => {
    if (!selectedFile) {
      Alert.alert('Error', 'Please select a document first.');
      return;
    }
    
    if (!selectedCategory) {
      Alert.alert('Error', 'Please select a category for the document.');
      return;
    }
    
    try {
      setIsLoading(true);
      
      // Create documents directory if it doesn't exist
      const documentsDir = Platform.OS === 'ios' 
        ? `${RNFS.DocumentDirectoryPath}/LinkNestDocuments` 
        : `${RNFS.ExternalDirectoryPath}/LinkNestDocuments`;
      
      const dirExists = await RNFS.exists(documentsDir);
      if (!dirExists) {
        await RNFS.mkdir(documentsDir);
      }
      
        // Generate a unique filename to avoid conflicts
        const fileName = selectedFile.name ? `${Date.now()}_${selectedFile.name}` : `${Date.now()}_document`;
        const fileExt = selectedFile.name ? selectedFile.name.split('.').pop() || '' : '';
        const destPath = `${documentsDir}/${fileName}`;
        
        // Copy the file from cache to app's documents directory
        if (selectedFile.uri) {
          await RNFS.copyFile(selectedFile.uri, destPath);
        
        // Add document to state
        // Keep original MIME type for proper file opening
        const originalMimeType = selectedFile.type || '';
        
        // Create user-friendly display type
        let displayFileType = originalMimeType || fileExt;
        
        // Convert MIME types to more user-friendly formats for display
        if (displayFileType.includes('image/jpeg') || displayFileType.includes('image/jpg')) {
          displayFileType = 'jpg';
        } else if (displayFileType.includes('image/png')) {
          displayFileType = 'png';
        } else if (displayFileType.includes('image/')) {
          displayFileType = displayFileType.replace('image/', '');
        } else if (displayFileType.includes('application/pdf')) {
          displayFileType = 'pdf';
        } else if (displayFileType.includes('application/msword') || displayFileType.includes('application/vnd.openxmlformats-officedocument.wordprocessingml')) {
          displayFileType = 'doc';
        } else if (displayFileType.includes('application/vnd.ms-excel') || displayFileType.includes('application/vnd.openxmlformats-officedocument.spreadsheetml')) {
          displayFileType = 'xls';
        } else if (displayFileType.includes('application/vnd.ms-powerpoint') || displayFileType.includes('application/vnd.openxmlformats-officedocument.presentationml')) {
          displayFileType = 'ppt';
        } else if (displayFileType.includes('text/plain')) {
          displayFileType = 'txt';
        }
        
        await addDocument({
          name: selectedFile.name || `Document_${Date.now()}`,
          uri: destPath,
          type: displayFileType,
          mimeType: originalMimeType, // Store original MIME type
          size: selectedFile.size || 0,
          category: selectedCategory,
          tags: selectedTags,
          isFavorite: false,
        });
        
        
        // Navigate back
        navigation.goBack();
      } else {
        throw new Error('File URI is undefined');
      }
    } catch (error) {
      console.error('Error saving document:', error);
      Alert.alert('Error', 'Failed to save document. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        {/* Document Picker */}
        <View style={[styles.section, { backgroundColor: theme.colors.surface, borderColor: theme.colors.outline + '20' }]}>
          <Text variant="titleMedium" style={[styles.sectionTitle, { color: theme.colors.onSurface }]}>Select Document</Text>
          
          {selectedFile ? (
            <View style={[styles.selectedFileContainer, { backgroundColor: theme.colors.surfaceVariant, borderColor: theme.colors.outline + '20' }]}>
              <Icon
                name={getFileIcon(selectedFile.type ?? undefined)}
                size={40}
                color={theme.colors.primary}
                style={styles.fileIcon}
              />
              <View style={styles.fileInfo}>
                <Text variant="titleSmall" numberOfLines={1} style={{ color: theme.colors.onSurface }}>
                  {selectedFile.name || 'Unnamed Document'}
                </Text>
                <Text variant="bodySmall" style={{ color: theme.colors.onSurfaceVariant }}>
                  {formatFileSize(selectedFile.size ?? undefined)} • {selectedFile.type || 'Unknown'}
                </Text>
              </View>
              <Button
                mode="text"
                onPress={() => setSelectedFile(null)}
                compact
              >
                Change
              </Button>
            </View>
          ) : (
            <Button
              mode="outlined"
              icon="file-upload"
              onPress={handlePickDocument}
              style={styles.pickButton}
            >
              Pick Document
            </Button>
          )}
        </View>
        
        {/* Category Selection */}
        <View style={[styles.section, { backgroundColor: theme.colors.surface, borderColor: theme.colors.outline + '20' }]}>
          <Text variant="titleMedium" style={[styles.sectionTitle, { color: theme.colors.onSurface }]}>Category</Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.categoriesContainer}>
            {categories.map((category) => (
              <Chip
                key={category.id}
                selected={selectedCategory === category.id}
                onPress={() => handleCategorySelect(category.id)}
                style={[styles.categoryChip, { borderColor: category.color }]}
                textStyle={{ color: selectedCategory === category.id ? theme.colors.onPrimary : category.color }}
                showSelectedCheck={false}
                mode={selectedCategory === category.id ? 'flat' : 'outlined'}
                selectedColor={theme.colors.onPrimary}
                avatar={<Icon name={category.icon} size={16} color={selectedCategory === category.id ? theme.colors.onPrimary : category.color} />}
              >
                {category.name}
              </Chip>
            ))}
          </ScrollView>
        </View>
        
        {/* Tags Selection */}
        <View style={[styles.section, { backgroundColor: theme.colors.surface, borderColor: theme.colors.outline + '20' }]}>
          <Text variant="titleMedium" style={[styles.sectionTitle, { color: theme.colors.onSurface }]}>Tags (Optional)</Text>
          <View style={styles.tagsContainer}>
            {tags.map((tag) => (
              <Chip
                key={tag.id}
                selected={selectedTags.includes(tag.id)}
                onPress={() => handleTagSelect(tag.id)}
                style={[styles.tagChip, { borderColor: tag.color }]}
                textStyle={{ color: selectedTags.includes(tag.id) ? theme.colors.onPrimary : tag.color }}
                showSelectedCheck={false}
                mode={selectedTags.includes(tag.id) ? 'flat' : 'outlined'}
                selectedColor={theme.colors.onPrimary}
              >
                {tag.name}
              </Chip>
            ))}
          </View>
        </View>
        
        {/* Save Button */}
        <Button
          mode="contained"
          onPress={handleSaveDocument}
          style={styles.saveButton}
          disabled={!selectedFile || !selectedCategory || isLoading}
          loading={isLoading}
        >
          Save Document
        </Button>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({

  container: {
    flex: 1,
  },
  content: {
    padding: 20,
  },
  section: {
    marginBottom: 28,
    borderRadius: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
    borderWidth: 1,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    letterSpacing: 0.2,
  },
  pickButton: {
    marginTop: 12,
  },
  selectedFileContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginTop: 12,
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.1)',
  },
  fileIcon: {
    marginRight: 16,
  },
  fileInfo: {
    flex: 1,
  },
  categoriesContainer: {
    flexDirection: 'row',
    marginTop: 12,
  },
  categoryChip: {
    marginRight: 10,
    marginBottom: 10,
    height: 36,
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
  saveButton: {
    marginTop: 24,
    marginBottom: 32,
    paddingVertical: 8,
  },
});

export default AddDocumentScreen;