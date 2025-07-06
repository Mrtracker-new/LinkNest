import React, { useState, useEffect } from 'react';
import { StyleSheet, View, FlatList, TouchableOpacity } from 'react-native';
import { Searchbar, FAB, useTheme } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useApp } from '../context/AppContext';
import { Note } from '../types';
import NoteCard from '../components/NoteCard';
import FilterBar from '../components/FilterBar';
import EmptyState from '../components/EmptyState';
import { RootStackParamList } from '../navigation';

type NotesScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const NotesScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<NotesScreenNavigationProp>();
  const { notes, categories, tags } = useApp();
  
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredNotes, setFilteredNotes] = useState<Note[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [sortOption, setSortOption] = useState<string>('newest');

  // Filter and sort notes based on search query, category, tags, and sort option
  useEffect(() => {
    let result = [...notes];
    
    // Filter by search query
    if (searchQuery) {
      result = result.filter(
        note =>
          note.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    
    // Filter by category
    if (selectedCategory) {
      result = result.filter(note => note.category === selectedCategory); // Changed from categoryId to category
    }
    
    // Filter by tags
    if (selectedTags.length > 0) {
      result = result.filter(note =>
        selectedTags.every(tagId => note.tags.includes(tagId)) // Changed from tagIds to tags
      );
    }
    
    // Sort notes
    switch (sortOption) {
      case 'newest':
        result.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        break;
      case 'oldest':
        result.sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
        break;
      case 'alphabetical':
        result.sort((a, b) => a.title.localeCompare(b.title));
        break;
      case 'favorites':
        result.sort((a, b) => (a.isFavorite === b.isFavorite ? 0 : a.isFavorite ? -1 : 1));
        break;
      default:
        break;
    }
    
    setFilteredNotes(result);
  }, [notes, searchQuery, selectedCategory, selectedTags, sortOption]);

  const handleNotePress = (noteId: string) => {
    navigation.navigate('NoteDetails', { id: noteId });
  };

  const handleAddNote = () => {
    navigation.navigate('AddNote');
  };

  const renderItem = ({ item }: { item: Note }) => (
    <NoteCard note={item} onPress={() => handleNotePress(item.id)} />
  );

  return (
    <View style={styles.container}>
      <Searchbar
        placeholder="Search notes..."
        onChangeText={setSearchQuery}
        value={searchQuery}
        style={styles.searchBar}
      />
      
      <FilterBar
        selectedCategory={selectedCategory}
        setSelectedCategory={setSelectedCategory}
        selectedTags={selectedTags}
        setSelectedTags={setSelectedTags}
        sortBy={sortOption as 'newest' | 'oldest' | 'alphabetical' | 'favorites'}
        setSortBy={setSortOption as (sortBy: 'newest' | 'oldest' | 'alphabetical' | 'favorites') => void}
      />
      
      {filteredNotes.length > 0 ? (
        <FlatList
          data={filteredNotes}
          renderItem={renderItem}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.listContent}
        />
      ) : (
        <EmptyState
          icon="note-text"
          title="No Notes Found"
          message={searchQuery || selectedCategory || selectedTags.length > 0 
            ? "Try adjusting your filters or search query" 
            : "Tap the + button to add your first note"}
          actionLabel={searchQuery || selectedCategory || selectedTags.length > 0 
            ? undefined 
            : "Add Note"}
          onAction={searchQuery || selectedCategory || selectedTags.length > 0 
            ? undefined 
            : handleAddNote}
        />
      )}
      
      <FAB
        icon="plus"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={handleAddNote}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  searchBar: {
    margin: 16,
    elevation: 4,
  },
  listContent: {
    padding: 16,
    paddingBottom: 80, // Extra padding for FAB
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
});

export default NotesScreen;