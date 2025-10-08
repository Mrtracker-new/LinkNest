import React, { useState } from 'react';
import { StyleSheet, View, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { TextInput, useTheme, HelperText, Chip, Text, IconButton, Menu, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation';
import { useApp } from '../context/AppContext';
import { useHaptic } from '../hooks/useHaptic';
import { useToast } from '../components/Toast';
import AnimatedButton from '../components/AnimatedButton';
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
    const pathMatch = cleanDescription.match(/[/]([a-zA-Z0-9_-]{11})(\?|$)/);
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
        .replace(/[/]([a-zA-Z0-9_-]{11})(\?|$)/, '')
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
  const haptic = useHaptic();
  const toast = useToast();

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
    const urlPattern = /^(https?:\/\/)?(www\.)?([-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b)([-a-zA-Z0-9()@:%_+.~#?&//=]*)?$/;
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
      haptic.error();
      return;
    }

    // Process the URL and description using the helper function
    const { url: formattedUrl, description: cleanedDescription } = processYoutubeUrl(url, description);

    // Add link
    try {
      haptic.medium();
      await addLink({
        url: formattedUrl,
        title,
        description: cleanedDescription,
        category: category || categories[0]?.id || '',
        tags: selectedTags,
        isFavorite,
      });

      haptic.success();
      toast.showToast({
        message: 'Link added successfully!',
        type: 'success',
        duration: 2000,
      });
      // Navigate back
      navigation.goBack();
    } catch (error) {
      haptic.error();
      toast.showToast({
        message: 'Failed to add link. Please try again.',
        type: 'error',
        duration: 3000,
      });
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
          outlineStyle={{ borderRadius: 16, borderWidth: 2 }}
          contentStyle={{ paddingLeft: 8 }}
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
          outlineStyle={{ borderRadius: 16, borderWidth: 2 }}
          contentStyle={{ paddingLeft: 8 }}
        />
        {!!titleError && <HelperText type="error">{titleError}</HelperText>}

        <TextInput
          label="Description (optional)"
          value={description}
          onChangeText={setDescription}
          mode="outlined"
          multiline
          numberOfLines={4}
          style={[styles.input, { minHeight: 100 }]}
          left={<TextInput.Icon icon="text" />}
          outlineStyle={{ borderRadius: 16, borderWidth: 2 }}
          contentStyle={{ paddingLeft: 8 }}
        />

        <View style={styles.sectionTitle}>
          <Text variant="titleMedium">Category</Text>
        </View>

        <Menu
          visible={categoryMenuVisible}
          onDismiss={() => setCategoryMenuVisible(false)}
          anchor={
            <Button
              mode="outlined"
              onPress={() => setCategoryMenuVisible(!categoryMenuVisible)}
              style={styles.categoryChip}
              contentStyle={styles.categoryButtonContent}
              icon={selectedCategory ? selectedCategory.icon : 'folder'}
            >
              {selectedCategory ? selectedCategory.name : 'Select Category'}
            </Button>
          }
        >
          {categories.map((cat) => (
            <Menu.Item
              key={cat.id}
              leadingIcon={({ size }) => (
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

        <AnimatedButton
          mode="contained"
          onPress={handleSubmit}
          style={styles.submitButton}
          labelStyle={styles.submitButtonLabel}
        >
          Save Link
        </AnimatedButton>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  input: {
    marginBottom: 20,
    backgroundColor: '#FFFFFF',
  },
  sectionTitle: {
    marginTop: 16,
    marginBottom: 16,
  },
  categoryChip: {
    marginBottom: 20,
    height: 52,
    borderRadius: 16,
    borderWidth: 2,
  },
  categoryButtonContent: {
    flexDirection: 'row-reverse',
    justifyContent: 'space-between',
    paddingHorizontal: 8,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 20,
    gap: 8,
  },
  tagChip: {
    marginRight: 8,
    marginBottom: 8,
    height: 36,
    borderRadius: 18,
    elevation: 2,
  },
  addTagChip: {
    marginRight: 8,
    marginBottom: 8,
    height: 36,
    borderRadius: 18,
    elevation: 1,
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
    marginVertical: 12,
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    elevation: 2,
  },
  submitButton: {
    marginTop: 24,
    borderRadius: 16,
    height: 56,
    justifyContent: 'center',
    elevation: 4,
    shadowColor: '#7C3AED',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  submitButtonLabel: {
    fontSize: 17,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
});

export default AddLinkScreen;