import React, { useState } from 'react';
import { StyleSheet, View, FlatList, Alert, TouchableOpacity } from 'react-native';
import { List, FAB, useTheme, Dialog, Portal, TextInput, Button, IconButton, Text } from 'react-native-paper';
import { useApp } from '../context/AppContext';
import { Category } from '../types';
import EmptyState from '../components/EmptyState';

const CategoriesScreen = () => {
  const theme = useTheme();
  const { categories, addCategory, updateCategory, deleteCategory, links, notes, documents } = useApp();
  
  // Dialog state
  const [dialogVisible, setDialogVisible] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentCategory, setCurrentCategory] = useState<Category | null>(null);
  const [categoryName, setCategoryName] = useState('');
  const [categoryColor, setCategoryColor] = useState('#6200ee'); // Default color
  const [nameError, setNameError] = useState('');
  
  // Open add category dialog
  const handleAddCategory = () => {
    setIsEditing(false);
    setCurrentCategory(null);
    setCategoryName('');
    setCategoryColor('#6200ee');
    setNameError('');
    setDialogVisible(true);
  };
  
  // Open edit category dialog
  const handleEditCategory = (category: Category) => {
    setIsEditing(true);
    setCurrentCategory(category);
    setCategoryName(category.name);
    setCategoryColor(category.color || '#6200ee');
    setNameError('');
    setDialogVisible(true);
  };
  
  // Handle save category
  const handleSaveCategory = () => {
    // Validate name
    if (!categoryName.trim()) {
      setNameError('Category name is required');
      return;
    }
    
    // Check for duplicate name
    const isDuplicate = categories.some(
      category => 
        category.name.toLowerCase() === categoryName.trim().toLowerCase() && 
        category.id !== currentCategory?.id
    );
    
    if (isDuplicate) {
      setNameError('A category with this name already exists');
      return;
    }
    
    if (isEditing && currentCategory) {
      // Update existing category
      updateCategory(currentCategory.id, {
        name: categoryName.trim(),
        color: categoryColor,
      });
    } else {
      // Add new category
      addCategory({
        name: categoryName.trim(),
        color: categoryColor,
        icon: 'folder', // Adding the required icon property
      });
    }
    
    // Close dialog
    setDialogVisible(false);
  };
  
  // Handle delete category
  const handleDeleteCategory = (category: Category) => {
    // Check if category is in use
    const linksUsingCategory = links.filter(link => link.category === category.id).length;
    const notesUsingCategory = notes.filter(note => note.category === category.id).length;
    const documentsUsingCategory = documents.filter(document => document.category === category.id).length;
    
    const totalUsage = linksUsingCategory + notesUsingCategory + documentsUsingCategory;
    
    if (totalUsage > 0) {
      // Category is in use, show warning
      Alert.alert(
        'Category in Use',
        `This category is used by ${totalUsage} item${totalUsage !== 1 ? 's' : ''}. Deleting it will remove the category from these items.`,
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Delete Anyway',
            style: 'destructive',
            onPress: () => deleteCategory(category.id),
          },
        ]
      );
    } else {
      // Category is not in use, confirm deletion
      Alert.alert(
        'Delete Category',
        'Are you sure you want to delete this category?',
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Delete',
            style: 'destructive',
            onPress: () => deleteCategory(category.id),
          },
        ]
      );
    }
  };
  
  // Render category item
  const renderCategoryItem = ({ item }: { item: Category }) => {
    // Count items using this category
    const linksCount = links.filter(link => link.category === item.id).length;
    const notesCount = notes.filter(note => note.category === item.id).length;
    const documentsCount = documents.filter(document => document.category === item.id).length;
    
    const totalCount = linksCount + notesCount + documentsCount;
    const description = totalCount > 0 
      ? `${totalCount} item${totalCount !== 1 ? 's' : ''} (${linksCount} link${linksCount !== 1 ? 's' : ''}, ${notesCount} note${notesCount !== 1 ? 's' : ''}, ${documentsCount} document${documentsCount !== 1 ? 's' : ''})`
      : 'No items';
    
    return (
      <List.Item
        title={item.name}
        description={description}
        left={(_props) => (
          <View style={[styles.categoryColor, { backgroundColor: item.color || theme.colors.primary }]} />
        )}
        right={(_props) => (
          <View style={styles.actionsContainer}>
            <IconButton
              icon="pencil"
              size={20}
              onPress={() => handleEditCategory(item)}
            />
            <IconButton
              icon="delete"
              size={20}
              iconColor={theme.colors.error}
              onPress={() => handleDeleteCategory(item)}
            />
          </View>
        )}
      />
    );
  };
  
  // Available colors for categories
  const colorOptions = [
    '#6200ee', // Purple
    '#03dac6', // Teal
    '#ff0266', // Pink
    '#ff9e00', // Orange
    '#00c853', // Green
    '#00b0ff', // Blue
    '#d50000', // Red
    '#aa00ff', // Deep Purple
    '#ffab00', // Amber
    '#64dd17', // Light Green
  ];
  
  return (
    <View style={styles.container}>
      {categories.length > 0 ? (
        <FlatList
          data={categories}
          renderItem={renderCategoryItem}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.listContent}
        />
      ) : (
        <EmptyState
          icon="folder"
          title="No Categories"
          message="Tap the + button to add your first category"
          actionLabel="Add Category"
          onAction={handleAddCategory}
        />
      )}
      
      <FAB
        icon="plus"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={handleAddCategory}
      />
      
      <Portal>
        <Dialog visible={dialogVisible} onDismiss={() => setDialogVisible(false)}>
          <Dialog.Title>{isEditing ? 'Edit Category' : 'Add Category'}</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="Category Name"
              value={categoryName}
              onChangeText={text => {
                setCategoryName(text);
                if (text.trim()) setNameError('');
              }}
              mode="outlined"
              style={styles.input}
              error={!!nameError}
            />
            {nameError ? <Text style={styles.errorText}>{nameError}</Text> : null}
            
            <Text variant="titleMedium" style={styles.colorTitle}>Category Color</Text>
            <View style={styles.colorContainer}>
              {colorOptions.map(color => (
                <TouchableColorCircle
                  key={color}
                  color={color}
                  selected={color === categoryColor}
                  onPress={() => setCategoryColor(color)}
                />
              ))}
            </View>
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setDialogVisible(false)}>Cancel</Button>
            <Button onPress={handleSaveCategory}>{isEditing ? 'Update' : 'Add'}</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    </View>
  );
};

// Touchable color circle component
interface TouchableColorCircleProps {
  color: string;
  selected: boolean;
  onPress: () => void;
}

const TouchableColorCircle = ({ color, selected, onPress }: TouchableColorCircleProps) => {
  return (
    <View style={[styles.colorCircleContainer, selected && styles.selectedColorContainer]}>
      <IconButton
        icon="circle"
        size={24}
        iconColor={color}
        style={styles.colorCircle}
        onPress={onPress}
      />
      {selected && <View style={styles.selectedIndicator} />}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  listContent: {
    paddingBottom: 80, // Extra padding for FAB
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
  input: {
    marginBottom: 8,
  },
  errorText: {
    color: 'red',
    fontSize: 12,
    marginBottom: 8,
  },
  colorTitle: {
    marginTop: 16,
    marginBottom: 8,
  },
  colorContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'flex-start',
    marginTop: 8,
  },
  colorCircleContainer: {
    position: 'relative',
    margin: 4,
  },
  colorCircle: {
    margin: 0,
  },
  selectedColorContainer: {
    borderRadius: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.1)',
  },
  selectedIndicator: {
    position: 'absolute',
    bottom: 0,
    left: '50%',
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'black',
    transform: [{ translateX: -2 }],
  },
  categoryColor: {
    width: 24,
    height: 24,
    borderRadius: 12,
    marginLeft: 8,
    marginVertical: 8,
  },
  actionsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
});

export default CategoriesScreen;