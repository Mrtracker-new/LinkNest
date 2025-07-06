import React, { useState } from 'react';
import { StyleSheet, View, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { TextInput, Button, Chip, HelperText, useTheme, Switch, Text } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useApp } from '../context/AppContext';
import { RootStackParamList } from '../navigation';

type AddNoteScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const AddNoteScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<AddNoteScreenNavigationProp>();
  const { addNote, categories, tags } = useApp();
  
  // Form state
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [categoryId, setCategoryId] = useState<string | null>(null);
  const [selectedTagIds, setSelectedTagIds] = useState<string[]>([]);
  const [isFavorite, setIsFavorite] = useState(false);
  
  // Validation state
  const [titleError, setTitleError] = useState('');
  const [contentError, setContentError] = useState('');
  
  // Handle category selection
  const handleCategorySelect = (id: string) => {
    setCategoryId(id === categoryId ? null : id);
  };
  
  // Handle tag selection
  const handleTagSelect = (id: string) => {
    setSelectedTagIds(prev =>
      prev.includes(id)
        ? prev.filter(tagId => tagId !== id)
        : [...prev, id]
    );
  };
  
  // Validate form
  const validateForm = () => {
    let isValid = true;
    
    // Validate title
    if (!title.trim()) {
      setTitleError('Title is required');
      isValid = false;
    } else {
      setTitleError('');
    }
    
    // Validate content
    if (!content.trim()) {
      setContentError('Content is required');
      isValid = false;
    } else {
      setContentError('');
    }
    
    return isValid;
  };
  
  // Handle save note
  const handleSaveNote = () => {
    if (validateForm()) {
      addNote({
        title: title.trim(),
        content: content.trim(),
        category: categoryId || categories[0]?.id || '', // Changed from categoryId to category
        tags: selectedTagIds, // Changed from tagIds to tags
        isFavorite,
      });
      
      navigation.goBack();
    }
  };
  
  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 64 : 0}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <TextInput
          label="Title"
          value={title}
          onChangeText={setTitle}
          mode="outlined"
          style={styles.input}
          error={!!titleError}
        />
        {titleError ? <HelperText type="error">{titleError}</HelperText> : null}
        
        <TextInput
          label="Content"
          value={content}
          onChangeText={setContent}
          mode="outlined"
          multiline
          numberOfLines={8}
          style={styles.contentInput}
          error={!!contentError}
        />
        {contentError ? <HelperText type="error">{contentError}</HelperText> : null}
        
        <Text variant="titleMedium" style={styles.sectionTitle}>Category</Text>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.categoriesContainer}
        >
          {categories.map(category => (
            <Chip
              key={category.id}
              selected={category.id === categoryId}
              onPress={() => handleCategorySelect(category.id)}
              style={styles.chip}
              showSelectedCheck
              selectedColor={theme.colors.primary}
            >
              {category.name}
            </Chip>
          ))}
        </ScrollView>
        
        <Text variant="titleMedium" style={styles.sectionTitle}>Tags</Text>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.tagsContainer}
        >
          {tags.map(tag => (
            <Chip
              key={tag.id}
              selected={selectedTagIds.includes(tag.id)}
              onPress={() => handleTagSelect(tag.id)}
              style={styles.chip}
              showSelectedCheck
              selectedColor={theme.colors.primary}
            >
              {tag.name}
            </Chip>
          ))}
        </ScrollView>
        
        <View style={styles.favoriteContainer}>
          <Text variant="titleMedium">Add to Favorites</Text>
          <Switch
            value={isFavorite}
            onValueChange={setIsFavorite}
            color={theme.colors.primary}
          />
        </View>
        
        <Button
          mode="contained"
          onPress={handleSaveNote}
          style={styles.saveButton}
        >
          Save Note
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
  },
  input: {
    marginBottom: 8,
  },
  contentInput: {
    marginBottom: 8,
    minHeight: 150,
  },
  sectionTitle: {
    marginTop: 16,
    marginBottom: 8,
  },
  categoriesContainer: {
    flexDirection: 'row',
    flexWrap: 'nowrap',
    paddingVertical: 8,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'nowrap',
    paddingVertical: 8,
  },
  chip: {
    marginRight: 8,
    marginBottom: 8,
  },
  favoriteContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginVertical: 16,
  },
  saveButton: {
    marginTop: 16,
    marginBottom: 32,
  },
});

export default AddNoteScreen;