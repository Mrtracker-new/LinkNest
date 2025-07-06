import React, { useState, useEffect } from 'react';
import { StyleSheet, View, ScrollView, KeyboardAvoidingView, Platform, Alert } from 'react-native';
import { TextInput, Button, useTheme, HelperText, Chip, Text, IconButton, Menu } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation';
import { useApp } from '../context/AppContext';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

type EditLinkScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;
type EditLinkScreenRouteProp = RouteProp<RootStackParamList, 'EditLink'>;

const EditLinkScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<EditLinkScreenNavigationProp>();
  const route = useRoute<EditLinkScreenRouteProp>();
  const { links, updateLink, categories, tags } = useApp();

  // Get link ID from route params
  const { id } = route.params;

  // Find link by ID
  const link = links.find((link) => link.id === id);

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

  // Initialize form with link data
  useEffect(() => {
    if (link) {
      setUrl(link.url);
      setTitle(link.title);
      setDescription(link.description || '');
      setCategory(link.category);
      setSelectedTags(link.tags);
      setIsFavorite(link.isFavorite);
    }
  }, [link]);

  // If link not found
  if (!link) {
    return (
      <View style={styles.container}>
        <Text>Link not found</Text>
      </View>
    );
  }

  // Handle URL validation
  const validateUrl = (text: string) => {
    setUrl(text);
    if (!text) {
      setUrlError('URL is required');
      return false;
    }

    // Simple URL validation
    const urlPattern = /^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w- ./?%&=]*)?$/;
    if (!urlPattern.test(text)) {
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

    // Ensure URL has protocol
    let formattedUrl = url;
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = `https://${formattedUrl}`;
    }

    // Update link
    try {
      await updateLink(id, {
        url: formattedUrl,
        title,
        description,
        category,
        tags: selectedTags,
        isFavorite,
      });

      // Navigate back
      navigation.goBack();
    } catch (error) {
      Alert.alert('Error', 'Failed to update link. Please try again.');
      console.error('Error updating link:', error);
    }
  };

  // Get selected category
  const selectedCategory = categories.find((cat) => cat.id === category);

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
        </View>

        <Menu
          visible={tagsMenuVisible}
          onDismiss={() => setTagsMenuVisible(false)}
          anchor={<View style={styles.tagMenuAnchor} />}
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
          Update Link
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

export default EditLinkScreen;