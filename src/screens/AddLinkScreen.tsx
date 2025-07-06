import React, { useState, useRef } from 'react';
import { StyleSheet, View, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { TextInput, Button, useTheme, HelperText, Chip, Text, IconButton, Menu } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation';
import { useApp } from '../context/AppContext';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

// Helper function to process YouTube URLs
const processYoutubeUrl = (url: string, description?: string): { url: string, description: string } => {
  // Clean the URL - ensure there are no line breaks or extra spaces
  let cleanUrl = url.trim().replace(/\s+/g, '');
  let cleanDescription = description || '';
  
  // Ensure URL has a scheme
  if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://') && cleanUrl.length > 0) {
    cleanUrl = `https://${cleanUrl}`;
    console.log('Added https:// scheme to URL:', cleanUrl);
  }
  
  // Special handling for YouTube URLs
  const youtubeBaseRegex = /^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/?$/i;
  
  if (youtubeBaseRegex.test(cleanUrl) && cleanDescription) {
    // Try different patterns to extract YouTube video ID from description
    let videoId = null;
    
    // Pattern 1: /videoID or /videoID?parameters
    const pathMatch = cleanDescription.match(/[\/]([a-zA-Z0-9_-]{11})(\?|$)/);
    if (pathMatch && pathMatch[1]) {
      videoId = pathMatch[1];
    }
    
    // Pattern 2: v=videoID in the description
    if (!videoId) {
      const vParamMatch = cleanDescription.match(/[?&]v=([a-zA-Z0-9_-]{11})(&|$)/);
      if (vParamMatch && vParamMatch[1]) {
        videoId = vParamMatch[1];
      }
    }
    
    // Pattern 3: Just the video ID by itself
    if (!videoId) {
      const standaloneMatch = cleanDescription.match(/^\s*([a-zA-Z0-9_-]{11})\s*$/);
      if (standaloneMatch && standaloneMatch[1]) {
        videoId = standaloneMatch[1];
      }
    }
    
    if (videoId) {
      // Combine the base URL with the video ID
      cleanUrl = `https://youtu.be/${videoId}`;
      // Remove the video ID from the description to avoid duplication
      cleanDescription = cleanDescription
        .replace(/[\/]([a-zA-Z0-9_-]{11})(\?|$)/, '')
        .replace(/[?&]v=([a-zA-Z0-9_-]{11})(&|$)/, '')
        .replace(/^\s*([a-zA-Z0-9_-]{11})\s*$/, '')
        .trim();
    }
  }
  
  // Ensure URL has protocol
  if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
    cleanUrl = `https://${cleanUrl}`;
  }
  
  return { url: cleanUrl, description: cleanDescription };
};

type AddLinkScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const AddLinkScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<AddLinkScreenNavigationProp>();
  const { addLink, categories, tags } = useApp();

  // Form state
  const [url, setUrl] = useState('');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('');
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [isFavorite, setIsFavorite] = useState(false);

  // Validation state
  const [urlError, setUrlError] = useState('');
  const [titleError, setTitleError] = useState('');

  // Menu state
  const [categoryMenuVisible, setCategoryMenuVisible] = useState(false);
  const [tagsMenuVisible, setTagsMenuVisible] = useState(false);
  
  // Refs for menu anchors
  const tagMenuAnchorRef = useRef(null);

  // Handle URL validation
  const validateUrl = (text: string) => {
    setUrl(text);
    if (!text) {
      setUrlError('URL is required');
      return false;
    }

    // Clean the input
    const cleanText = text.trim();
    
    // Special case for YouTube URLs
    if (cleanText.match(/^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/?$/i)) {
      // This is a YouTube base URL without a video ID
      // We'll allow it and handle the video ID from description later
      setUrlError('');
      return true;
    }

    // Enhanced URL validation
    const urlPattern = /^(https?:\/\/)?(www\.)?([-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b)([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?$/;
    if (!urlPattern.test(cleanText)) {
      setUrlError('Please enter a valid URL');
      return false;
    }

    setUrlError('');
    return true;
  };

  // Handle title validation
  const validateTitle = (text: string) => {
    setTitle(text);
    if (!text) {
      setTitleError('Title is required');
      return false;
    }

    setTitleError('');
    return true;
  };

  // Handle category selection
  const handleCategorySelect = (categoryId: string) => {
    setCategory(categoryId);
    setCategoryMenuVisible(false);
  };

  // Handle tag selection
  const handleTagToggle = (tagId: string) => {
    if (selectedTags.includes(tagId)) {
      setSelectedTags(selectedTags.filter((id) => id !== tagId));
    } else {
      setSelectedTags([...selectedTags, tagId]);
    }
  };

  // Handle form submission
  const handleSubmit = async () => {
    // Validate form
    const isUrlValid = validateUrl(url);
    const isTitleValid = validateTitle(title);

    if (!isUrlValid || !isTitleValid) {
      return;
    }

    // Process the URL and description using the helper function
    const { url: formattedUrl, description: cleanedDescription } = processYoutubeUrl(url, description);
    
    // Update the description state if it was changed
    if (description !== cleanedDescription) {
      setDescription(cleanedDescription);
    }

    // Add link
    try {
      await addLink({
        url: formattedUrl,
        title,
        description,
        category: category || categories[0]?.id || '',
        tags: selectedTags,
        isFavorite,
      });

      // Navigate back
      navigation.goBack();
    } catch (error) {
      console.error('Error adding link:', error);
    }
  };

  // Get selected category
  const selectedCategory = categories.find((cat) => cat.id === category) || categories[0];

  // Get selected tags objects
  const selectedTagObjects = tags.filter((tag) => selectedTags.includes(tag.id));

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 64 : 0}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <TextInput
          label="URL"
          value={url}
          onChangeText={(text) => validateUrl(text)}
          mode="outlined"
          autoCapitalize="none"
          keyboardType="url"
          style={styles.input}
          error={!!urlError}
          left={<TextInput.Icon icon="link-variant" />}
        />
        {!!urlError && <HelperText type="error">{urlError}</HelperText>}

        <TextInput
          label="Title"
          value={title}
          onChangeText={(text) => validateTitle(text)}
          mode="outlined"
          style={styles.input}
          error={!!titleError}
          left={<TextInput.Icon icon="format-title" />}
        />
        {!!titleError && <HelperText type="error">{titleError}</HelperText>}

        <TextInput
          label="Description (optional)"
          value={description}
          onChangeText={setDescription}
          mode="outlined"
          multiline
          numberOfLines={3}
          style={styles.input}
          left={<TextInput.Icon icon="text" />}
        />

        <View style={styles.sectionTitle}>
          <Text variant="titleMedium">Category</Text>
        </View>

        <Menu
          visible={categoryMenuVisible}
          onDismiss={() => setCategoryMenuVisible(false)}
          anchor={
            <Chip
              mode="outlined"
              onPress={() => setCategoryMenuVisible(true)}
              style={styles.categoryChip}
              avatar={
                selectedCategory ? (
                  <Icon name={selectedCategory.icon} size={20} color={selectedCategory.color} />
                ) : undefined
              }
            >
              {selectedCategory ? selectedCategory.name : 'Select Category'}
            </Chip>
          }
        >
          {categories.map((cat) => (
            <Menu.Item
              key={cat.id}
              leadingIcon={({ size, color }) => (
                <Icon name={cat.icon} size={size} color={cat.color} />
              )}
              onPress={() => handleCategorySelect(cat.id)}
              title={cat.name}
            />
          ))}
        </Menu>

        <View style={styles.sectionTitle}>
          <Text variant="titleMedium">Tags</Text>
        </View>

        <View style={styles.tagsContainer}>
          {selectedTagObjects.map((tag) => (
            <Chip
              key={tag.id}
              mode="outlined"
              onClose={() => handleTagToggle(tag.id)}
              style={[styles.tagChip, { backgroundColor: `${tag.color}20` }]}
              textStyle={{ color: tag.color }}
            >
              {tag.name}
            </Chip>
          ))}

          <Menu
            visible={tagsMenuVisible}
            onDismiss={() => setTagsMenuVisible(false)}
            anchor={
              <Chip
                mode="outlined"
                icon="plus"
                onPress={() => setTagsMenuVisible(true)}
                style={styles.addTagChip}
                textStyle={{ color: theme.colors.primary }}
                elevated={true}
              >
                Add Tag
              </Chip>
            }
            style={styles.tagsMenu}
            contentStyle={{ maxHeight: 300 }}
          >
          {tags.map((tag) => (
            <Menu.Item
              key={tag.id}
              leadingIcon={({ size }) => (
                <View
                  style={[styles.tagDot, { backgroundColor: tag.color }]}
                />
              )}
              onPress={() => {
                handleTagToggle(tag.id);
                // Keep the menu open to allow selecting multiple tags
              }}
              title={tag.name}
              titleStyle={{ color: selectedTags.includes(tag.id) ? theme.colors.primary : undefined }}
              trailingIcon={selectedTags.includes(tag.id) ? 'check' : undefined}
            />
          ))}
          <Menu.Item
            title="Done"
            leadingIcon="check-circle"
            onPress={() => setTagsMenuVisible(false)}
          />
          </Menu>
        </View>

        <View style={styles.favoriteContainer}>
          <Text variant="titleMedium">Add to Favorites</Text>
          <IconButton
            icon={isFavorite ? 'star' : 'star-outline'}
            iconColor={isFavorite ? theme.colors.tertiary : theme.colors.outline}
            size={24}
            onPress={() => setIsFavorite(!isFavorite)}
          />
        </View>

        <Button
          mode="contained"
          onPress={handleSubmit}
          style={styles.submitButton}
          labelStyle={styles.submitButtonLabel}
        >
          Save Link
        </Button>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 32,
  },
  input: {
    marginBottom: 16,
  },
  sectionTitle: {
    marginTop: 8,
    marginBottom: 12,
  },
  categoryChip: {
    marginBottom: 16,
    height: 40,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 16,
  },
  tagChip: {
    marginRight: 8,
    marginBottom: 8,
  },
  addTagChip: {
    marginRight: 8,
    marginBottom: 8,
  },
  tagsMenu: {
    marginTop: 40,
    width: '80%',
    maxWidth: 300,
  },
  tagMenuAnchor: {
    position: 'absolute',
    top: -20,
    left: 0,
    right: 0,
  },
  tagDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  favoriteContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginVertical: 8,
  },
  submitButton: {
    marginTop: 16,
    borderRadius: 8,
    height: 50,
    justifyContent: 'center',
  },
  submitButtonLabel: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default AddLinkScreen;