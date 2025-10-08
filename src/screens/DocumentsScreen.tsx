import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { StyleSheet, View, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Searchbar, Chip, Text, useTheme, Divider } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { useApp } from '../context/AppContext';
import { RootStackParamList } from '../navigation';
import { Document } from '../types';
import EmptyState from '../components/EmptyState';
import FilterBar from '../components/FilterBar';
import { SkeletonDocumentCard } from '../components/SkeletonLoader';
import AnimatedFAB from '../components/AnimatedFAB';

type DocumentsScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const DocumentsScreen = ({ route }: any) => {
  const theme = useTheme();
  const navigation = useNavigation<DocumentsScreenNavigationProp>();
  const { documents, categories, isLoading } = useApp();
  
  // State
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [sortBy, setSortBy] = useState<'newest' | 'oldest' | 'alphabetical' | 'favorites'>('newest');
  const [filteredDocuments, setFilteredDocuments] = useState<Document[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  
  // Filter documents based on search, category, tags, and sort
  useEffect(() => {
    let filtered = [...documents];
    
    // Filter by search query
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        (doc) => doc.name.toLowerCase().includes(query) || doc.type.toLowerCase().includes(query)
      );
    }
    
    // Filter by category
    if (selectedCategory) {
      filtered = filtered.filter((doc) => doc.category === selectedCategory);
    }
    
    // Filter by tags
    if (selectedTags.length > 0) {
      filtered = filtered.filter((doc) =>
        selectedTags.every((tagId) => doc.tags.includes(tagId))
      );
    }
    
    // Sort documents
    switch (sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.updatedAt - a.updatedAt);
        break;
      case 'oldest':
        filtered.sort((a, b) => a.updatedAt - b.updatedAt);
        break;
      case 'alphabetical':
        filtered.sort((a, b) => a.name.localeCompare(b.name));
        break;
      case 'favorites':
        filtered.sort((a, b) => {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.updatedAt - a.updatedAt;
        });
        break;
      default:
        filtered.sort((a, b) => b.updatedAt - a.updatedAt);
    }
    
    setFilteredDocuments(filtered);
  }, [documents, searchQuery, selectedCategory, selectedTags, sortBy]);
  
  // Handle search
  const handleSearch = useCallback((query: string) => {
    setSearchQuery(query);
  }, []);
  
  // Handle refresh
  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
    }, 1000);
  }, []);
  
  // Handle add document
  const handleAddDocument = useCallback(() => {
    navigation.navigate('AddDocument');
  }, [navigation]);
  
  // Handle document press
  const handleDocumentPress = useCallback((id: string) => {
    navigation.navigate('DocumentDetails', { id });
  }, [navigation]);
  
  // Get file icon based on type - memoized
  const getFileIcon = useMemo(() => (type: string) => {
    const fileType = type.toLowerCase();
    if (fileType.includes('pdf')) return 'file-pdf-box';
    if (fileType.includes('doc') || fileType.includes('word')) return 'file-word-box';
    if (fileType.includes('xls') || fileType.includes('sheet')) return 'file-excel-box';
    if (fileType.includes('ppt') || fileType.includes('presentation')) return 'file-powerpoint-box';
    if (fileType.includes('txt') || fileType.includes('text')) return 'file-document-box';
    if (fileType.includes('jpg') || fileType.includes('jpeg') || fileType.includes('png') || fileType.includes('image')) return 'file-image-box';
    return 'file-box';
  }, []);
  
  // Format file size - memoized
  const formatFileSize = useMemo(() => (bytes: number) => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }, []);
  
  // Render document item with useCallback
  const renderDocumentItem = useCallback(({ item }: { item: Document }) => {
    const category = categories.find((cat) => cat.id === item.category);
    
    return (
      <TouchableOpacity
        style={[styles.documentCard, { backgroundColor: theme.colors.surface, borderColor: theme.colors.outline + '20' }]}
        onPress={() => handleDocumentPress(item.id)}
      >
        <View style={styles.documentIconContainer}>
          <Icon
            name={getFileIcon(item.type)}
            size={40}
            color={theme.colors.primary}
          />
        </View>
        <View style={styles.documentContent}>
          <View style={styles.documentHeader}>
            <Text variant="titleMedium" numberOfLines={1} style={styles.documentTitle}>
              {item.name}
            </Text>
            {item.isFavorite && (
              <Icon name="star" size={18} color={theme.colors.primary} style={styles.favoriteIcon} />
            )}
          </View>
          <Text variant="bodySmall" style={{ color: theme.colors.outline }}>
            {formatFileSize(item.size)} • {item.type.toUpperCase()}
          </Text>
          <View style={styles.documentMeta}>
            {category && (
              <Chip
                mode="outlined"
                style={[styles.categoryChip, { borderColor: category.color }]}
                textStyle={{ color: category.color, fontSize: 12 }}
                compact
              >
                {category.name}
              </Chip>
            )}
            <Text variant="bodySmall" style={{ color: theme.colors.outline }}>
              {new Date(item.updatedAt).toLocaleDateString()}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  }, [categories, theme, getFileIcon, formatFileSize, handleDocumentPress]);
  
  return (
    <View style={styles.container}>
      <Searchbar
        placeholder="Search documents"
        onChangeText={handleSearch}
        value={searchQuery}
        style={styles.searchBar}
        iconColor={theme.colors.primary}
      />
      
      <FilterBar
        selectedCategory={selectedCategory}
        setSelectedCategory={setSelectedCategory}
        selectedTags={selectedTags}
        setSelectedTags={setSelectedTags}
        sortBy={sortBy}
        setSortBy={setSortBy}
      />
      
      {isLoading ? (
        <View style={styles.listContent}>
          {Array.from({ length: 5 }).map((_, index) => (
            <SkeletonDocumentCard key={index} />
          ))}
        </View>
      ) : filteredDocuments.length === 0 ? (
        <EmptyState
          icon="file-document-outline"
          title="No documents yet"
          message="Add your first document by tapping the + button below."
        />
      ) : (
        <FlatList
          data={filteredDocuments}
          renderItem={renderDocumentItem}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          ItemSeparatorComponent={() => <Divider style={styles.divider} />}
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
      )}
      
      <AnimatedFAB
        icon="plus"
        onPress={handleAddDocument}
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
    margin: 12,
    elevation: 3,
    borderRadius: 8,
  },
  listContent: {
    paddingBottom: 80,
  },
  documentCard: {
    flexDirection: 'row',
    padding: 16,
    marginHorizontal: 12,
    marginVertical: 6,
    borderRadius: 12,
    elevation: 1,
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.1)',
  },
  documentIconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
    width: 52,
  },
  documentContent: {
    flex: 1,
    justifyContent: 'center',
  },
  documentHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  documentTitle: {
    flex: 1,
    marginRight: 6,
    fontWeight: '500',
  },
  favoriteIcon: {
    marginLeft: 6,
  },
  documentMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  categoryChip: {
    height: 24,
  },
  divider: {
    marginVertical: 6,
    marginHorizontal: 12,
  },
  fab: {
    position: 'absolute',
    margin: 20,
    right: 0,
    bottom: 0,
    borderRadius: 28,
    elevation: 4,
  },
});

export default DocumentsScreen;