import React, { useState, useEffect, useCallback } from 'react';
import { StyleSheet, View, FlatList, RefreshControl, StatusBar, Animated } from 'react-native';
import { Text, FAB, useTheme, Searchbar, ActivityIndicator, Banner } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp, useFocusEffect } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation';
import { useApp } from '../context/AppContext';
import LinkCard from '../components/LinkCard';
import FilterBar from '../components/FilterBar';
import EmptyState from '../components/EmptyState';
import { Link } from '../types';

type LinksScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;
type LinksScreenRouteProp = RouteProp<{ Links: { categoryId?: string } }, 'Links'>;

const LinksScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<LinksScreenNavigationProp>();
  const route = useRoute<LinksScreenRouteProp>();
  const { links, isLoading } = useApp();
  
  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(
    route.params?.categoryId || null
  );
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [sortBy, setSortBy] = useState<'newest' | 'oldest' | 'alphabetical' | 'favorites'>('newest');
  const [showBanner, setShowBanner] = useState(false);
  const [bannerMessage, setBannerMessage] = useState('');
  const [isSearchFocused, setIsSearchFocused] = useState(false);
  const scrollY = new Animated.Value(0);
  const styles = createStyles(theme);
  
  // Reset filters when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      // Update category from route params if provided
      if (route.params?.categoryId) {
        setSelectedCategory(route.params.categoryId);
      }
      return () => {};
    }, [route.params?.categoryId])
  );

  // Filter and sort links
  const filteredLinks = links.filter((link) => {
    // Filter by search query
    const matchesSearch =
      searchQuery === '' ||
      link.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      link.url.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (link.description && link.description.toLowerCase().includes(searchQuery.toLowerCase()));

    // Filter by category
    const matchesCategory = selectedCategory === null || link.category === selectedCategory;

    // Filter by tags
    const matchesTags =
      selectedTags.length === 0 ||
      selectedTags.some((tagId) => link.tags.includes(tagId));

    return matchesSearch && matchesCategory && matchesTags;
  });

  // Sort links
  const sortedLinks = [...filteredLinks].sort((a, b) => {
    switch (sortBy) {
      case 'newest':
        return b.updatedAt - a.updatedAt;
      case 'oldest':
        return a.updatedAt - b.updatedAt;
      case 'alphabetical':
        return a.title.localeCompare(b.title);
      case 'favorites':
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return b.updatedAt - a.updatedAt;
      default:
        return 0;
    }
  });

  // Handle search
  const handleSearch = (query: string) => {
    setSearchQuery(query);
  };

  // Handle refresh
  const onRefresh = () => {
    setRefreshing(true);
    // In a real app, you might fetch new data here
    setTimeout(() => {
      setRefreshing(false);
    }, 1000);
  };

  // Navigate to link details
  const navigateToLinkDetails = (id: string) => {
    navigation.navigate('LinkDetails', { id });
  };

  // Render link item
  const renderLinkItem = ({ item }: { item: Link }) => (
    <LinkCard link={item} onPress={() => navigateToLinkDetails(item.id)} />
  );

  // Calculate header opacity based on scroll position
  const headerOpacity = scrollY.interpolate({
    inputRange: [0, 50],
    outputRange: [1, 0.9],
    extrapolate: 'clamp',
  });

  // Calculate search bar elevation based on focus and scroll
  const searchBarElevation = isSearchFocused ? 4 : scrollY.interpolate({
    inputRange: [0, 30],
    outputRange: [0, 3],
    extrapolate: 'clamp',
  });

  // Handle clear filters
  const handleClearFilters = () => {
    setSearchQuery('');
    setSelectedCategory(null);
    setSelectedTags([]);
    setSortBy('newest');
    setBannerMessage('All filters cleared');
    setShowBanner(true);
    setTimeout(() => setShowBanner(false), 3000);
  };

  // Handle add link
  const handleAddLink = () => {
    navigation.navigate('AddLink');
  };

  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={theme.colors.background} barStyle="dark-content" />
      
      {/* Notification Banner */}
      <Banner
        visible={showBanner}
        actions={[
          { label: 'Dismiss', onPress: () => setShowBanner(false) }
        ]}
        icon="information"
        style={styles.banner}
      >
        {bannerMessage}
      </Banner>

      {/* Animated Header */}
      <Animated.View style={[styles.header, { opacity: headerOpacity, backgroundColor: theme.colors.background }]}>
        <Searchbar
          placeholder="Search links by title, URL or description"
          onChangeText={handleSearch}
          value={searchQuery}
          style={[styles.searchBar, { elevation: isSearchFocused ? 4 : 0 }]}
          iconColor={theme.colors.primary}
          onFocus={() => setIsSearchFocused(true)}
          onBlur={() => setIsSearchFocused(false)}
          clearButtonMode="while-editing"
        />
      </Animated.View>

      <FilterBar
        selectedCategory={selectedCategory}
        setSelectedCategory={setSelectedCategory}
        selectedTags={selectedTags}
        setSelectedTags={setSelectedTags}
        sortBy={sortBy}
        setSortBy={setSortBy}
      />

      {/* Filter Status Bar */}
      {(searchQuery || selectedCategory || selectedTags.length > 0) && (
        <View style={styles.filterStatusBar}>
          <Text variant="bodySmall" style={styles.filterStatusText}>
            {sortedLinks.length} {sortedLinks.length === 1 ? 'result' : 'results'} found
          </Text>
          <Text 
            variant="bodySmall" 
            style={styles.clearFiltersText}
            onPress={handleClearFilters}
          >
            Clear filters
          </Text>
        </View>
      )}

      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
          <Text style={styles.loadingText}>Loading links...</Text>
        </View>
      ) : sortedLinks.length === 0 ? (
        <EmptyState
          icon="link-variant-off"
          title="No Links Found"
          message={
            searchQuery || selectedCategory || selectedTags.length > 0
              ? "No links match your current filters. Try adjusting your search or filters."
              : "You haven't added any links yet. Tap the + button to add your first link."
          }
          actionLabel={searchQuery || selectedCategory || selectedTags.length > 0 ? "Clear Filters" : "Add Link"}
          onAction={searchQuery || selectedCategory || selectedTags.length > 0 ? handleClearFilters : handleAddLink}
        />
      ) : (
        <FlatList
          data={sortedLinks}
          renderItem={renderLinkItem}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl 
              refreshing={refreshing} 
              onRefresh={onRefresh} 
              colors={[theme.colors.primary]}
              tintColor={theme.colors.primary}
            />
          }
          onScroll={Animated.event(
            [{ nativeEvent: { contentOffset: { y: scrollY } } }],
            { useNativeDriver: false }
          )}
          showsVerticalScrollIndicator={false}
          initialNumToRender={10}
          maxToRenderPerBatch={10}
          windowSize={10}
        />
      )}

      <FAB
        icon="plus"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={handleAddLink}
        color={theme.colors.onPrimary}
        animated={true}
      />
    </View>
  );
};

const createStyles = (theme: any) => StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  header: {
    padding: 16,
    paddingTop: 16,
    zIndex: 10,
    borderBottomWidth: 0,
  },
  searchBar: {
    borderRadius: 12,
    height: 50,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  banner: {
    marginBottom: 0,
    elevation: 4,
  },
  filterStatusBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: theme.colors.surfaceVariant + '40',
  },
  filterStatusText: {
    color: theme.colors.onSurfaceVariant,
  },
  clearFiltersText: {
    color: theme.colors.primary,
    fontWeight: '600',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    marginTop: 16,
    color: theme.colors.onSurfaceVariant,
    fontSize: 16,
  },
  listContent: {
    padding: 16,
    paddingTop: 8,
    paddingBottom: 80,
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
    borderRadius: 28,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
});

export default LinksScreen;