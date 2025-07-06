import React, { useState } from 'react';
import { StyleSheet, View, FlatList, Alert } from 'react-native';
import { List, FAB, useTheme, Dialog, Portal, TextInput, Button, IconButton, Text } from 'react-native-paper';
import { useApp } from '../context/AppContext';
import { Tag } from '../types';
import EmptyState from '../components/EmptyState';

const TagsScreen = () => {
  const theme = useTheme();
  const { tags, addTag, updateTag, deleteTag, links, notes, files } = useApp();
  
  // Dialog state
  const [dialogVisible, setDialogVisible] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentTag, setCurrentTag] = useState<Tag | null>(null);
  const [tagName, setTagName] = useState('');
  const [nameError, setNameError] = useState('');
  
  // Open add tag dialog
  const handleAddTag = () => {
    setIsEditing(false);
    setCurrentTag(null);
    setTagName('');
    setNameError('');
    setDialogVisible(true);
  };
  
  // Open edit tag dialog
  const handleEditTag = (tag: Tag) => {
    setIsEditing(true);
    setCurrentTag(tag);
    setTagName(tag.name);
    setNameError('');
    setDialogVisible(true);
  };
  
  // Handle save tag
  const handleSaveTag = () => {
    // Validate name
    if (!tagName.trim()) {
      setNameError('Tag name is required');
      return;
    }
    
    // Check for duplicate name
    const isDuplicate = tags.some(
      tag => 
        tag.name.toLowerCase() === tagName.trim().toLowerCase() && 
        tag.id !== currentTag?.id
    );
    
    if (isDuplicate) {
      setNameError('A tag with this name already exists');
      return;
    }
    
    if (isEditing && currentTag) {
      // Update existing tag
      updateTag(currentTag.id, {
        name: tagName.trim(),
        color: currentTag.color, // Preserve the existing color
      });
    } else {
      // Add new tag
      addTag({
        name: tagName.trim(),
        color: '#' + Math.floor(Math.random()*16777215).toString(16), // Generate a random color
      });
    }
    
    // Close dialog
    setDialogVisible(false);
  };
  
  // Handle delete tag
  const handleDeleteTag = (tag: Tag) => {
    // Check if tag is in use
    const linksUsingTag = links.filter(link => link.tags.includes(tag.id)).length;
    const notesUsingTag = notes.filter(note => note.tags.includes(tag.id)).length;
    const filesUsingTag = files.filter(file => file.tags.includes(tag.id)).length;
    
    const totalUsage = linksUsingTag + notesUsingTag + filesUsingTag;
    
    if (totalUsage > 0) {
      // Tag is in use, show warning
      Alert.alert(
        'Tag in Use',
        `This tag is used by ${totalUsage} item${totalUsage !== 1 ? 's' : ''}. Deleting it will remove the tag from these items.`,
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Delete Anyway',
            style: 'destructive',
            onPress: () => deleteTag(tag.id),
          },
        ]
      );
    } else {
      // Tag is not in use, confirm deletion
      Alert.alert(
        'Delete Tag',
        'Are you sure you want to delete this tag?',
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Delete',
            style: 'destructive',
            onPress: () => deleteTag(tag.id),
          },
        ]
      );
    }
  };
  
  // Render tag item
  const renderTagItem = ({ item }: { item: Tag }) => {
    // Count items using this tag
    const linksCount = links.filter(link => link.tags.includes(item.id)).length;
    const notesCount = notes.filter(note => note.tags.includes(item.id)).length;
    const filesCount = files.filter(file => file.tags.includes(item.id)).length;
    
    const totalCount = linksCount + notesCount + filesCount;
    const description = totalCount > 0 
      ? `${totalCount} item${totalCount !== 1 ? 's' : ''} (${linksCount} link${linksCount !== 1 ? 's' : ''}, ${notesCount} note${notesCount !== 1 ? 's' : ''}, ${filesCount} file${filesCount !== 1 ? 's' : ''})`
      : 'No items';
    
    return (
      <List.Item
        title={item.name}
        description={description}
        left={props => <List.Icon {...props} icon="tag" />}
        right={props => (
          <View style={styles.actionsContainer}>
            <IconButton
              icon="pencil"
              size={20}
              onPress={() => handleEditTag(item)}
            />
            <IconButton
              icon="delete"
              size={20}
              iconColor={theme.colors.error}
              onPress={() => handleDeleteTag(item)}
            />
          </View>
        )}
      />
    );
  };
  
  return (
    <View style={styles.container}>
      {tags.length > 0 ? (
        <FlatList
          data={tags}
          renderItem={renderTagItem}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.listContent}
        />
      ) : (
        <EmptyState
          icon="tag"
          title="No Tags"
          message="Tap the + button to add your first tag"
          actionLabel="Add Tag"
          onAction={handleAddTag}
        />
      )}
      
      <FAB
        icon="plus"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={handleAddTag}
      />
      
      <Portal>
        <Dialog visible={dialogVisible} onDismiss={() => setDialogVisible(false)}>
          <Dialog.Title>{isEditing ? 'Edit Tag' : 'Add Tag'}</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="Tag Name"
              value={tagName}
              onChangeText={text => {
                setTagName(text);
                if (text.trim()) setNameError('');
              }}
              mode="outlined"
              style={styles.input}
              error={!!nameError}
            />
            {nameError ? <Text style={styles.errorText}>{nameError}</Text> : null}
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setDialogVisible(false)}>Cancel</Button>
            <Button onPress={handleSaveTag}>{isEditing ? 'Update' : 'Add'}</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
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
  actionsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
});

export default TagsScreen;