import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { StyleSheet, View, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { useDebounce } from '../utils/debounce';
import { Searchbar, useTheme } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useApp } from '../context/AppContext';
import { Note } from '../types';
import NoteCard from '../components/NoteCard';
import FilterBar from '../components/FilterBar';
import EmptyState from '../components/EmptyState';
import { SkeletonNoteCard } from '../components/SkeletonLoader';
import AnimatedFAB from '../components/AnimatedFAB';
import { RootStackParamList } from '../navigation';

type NotesScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const NotesScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<NotesScreenNavigationProp>();
  const { notes, categories, tags, isLoading } = useApp();
  
  const [searchQuery, setSearchQuery] = useState('');
  const debouncedSearchQuery = useDebounce(searchQuery, 300);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [sortOption, setSortOption] = useState<string>('newest');
  const [refreshing, setRefreshing] = useState(false);

  // Filter and sort notes with useMemo for performance
  const filteredNotes = useMemo(() => {
    let result = [...notes];
    
    // Filter by search query
    if (debouncedSearchQuery) {
      result = result.filter(
        note =>
          note.title.toLowerCase().includes(debouncedSearchQuery.toLowerCase()) ||
          note.content.toLowerCase().includes(debouncedSearchQuery.toLowerCase())
      );
    }
    
    // Filter by category
    if (selectedCategory) {
      result = result.filter(note => note.category === selectedCategory);
    }
    
    // Filter by tags
    if (selectedTags.length > 0) {
      result = result.filter(note =>
        selectedTags.every(tagId => note.tags.includes(tagId))
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
    
    return result;
  }, [notes, debouncedSearchQuery, selectedCategory, selectedTags, sortOption]);

  const handleNotePress = useCallback((noteId: string) => {
    navigation.navigate('NoteDetails', { id: noteId });
  }, [navigation]);

  const handleAddNote = useCallback(() => {
    navigation.navigate('AddNote');
  }, [navigation]);
  
  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
    }, 1000);
  }, []);

  const renderItem = useCallback(({ item }: { item: Note }) => (
    <NoteCard note={item} onPress={() => handleNotePress(item.id)} />
  ), [handleNotePress]);

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
      
      {isLoading ? (
        <View style={styles.listContent}>
          {Array.from({ length: 5 }).map((_, index) => (
            <SkeletonNoteCard key={index} />
          ))}
        </View>
      ) : filteredNotes.length > 0 ? (
        <FlatList
          data={filteredNotes}
          renderItem={renderItem}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              colors={[theme.colors.primary]}
              tintColor={theme.colors.primary}
            />
          }
          removeClippedSubviews={true}
          maxToRenderPerBatch={10}
          updateCellsBatchingPeriod={50}
          initialNumToRender={10}
          windowSize={10}
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
      
      <AnimatedFAB
        icon="plus"
        onPress={handleAddNote}
        color={theme.colors.onPrimary}
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