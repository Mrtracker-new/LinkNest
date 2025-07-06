import React, { useState, useEffect } from 'react';
import { StyleSheet, View, ScrollView, RefreshControl } from 'react-native';
import { Text, FAB, useTheme, Searchbar, Card, Divider, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { RootStackParamList } from '../navigation';
import { useApp } from '../context/AppContext';
import LinkCard from '../components/LinkCard';
import NoteCard from '../components/NoteCard';
import DocumentCard from '../components/DocumentCard';
import EmptyState from '../components/EmptyState';
import { Link, Note, Document, Resource } from '../types';

type HomeScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const HomeScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const { links, notes, documents, categories, isLoading } = useApp();
  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const styles = createStyles(theme);

  // Get recent items
  const recentLinks = [...links]
    .sort((a, b) => b.updatedAt - a.updatedAt)
    .slice(0, 3);

  const recentNotes = [...notes]
    .sort((a, b) => b.updatedAt - a.updatedAt)
    .slice(0, 3);
    
  const recentDocuments = [...documents]
    .sort((a, b) => b.updatedAt - a.updatedAt)
    .slice(0, 3);

  // Get favorite items
  const favoriteLinks = links.filter((link) => link.isFavorite).slice(0, 3);
  const favoriteNotes = notes.filter((note) => note.isFavorite).slice(0, 3);
  const favoriteDocuments = documents.filter((doc) => doc.isFavorite).slice(0, 3);

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

  // Navigate to details screens
  const navigateToLinkDetails = (id: string) => {
    navigation.navigate('LinkDetails', { id });
  };

  const navigateToNoteDetails = (id: string) => {
    navigation.navigate('NoteDetails', { id });
  };
  
  const navigateToDocumentDetails = (id: string) => {
    navigation.navigate('DocumentDetails', { id });
  };

  // Navigate to list screens
  const navigateToLinks = () => {
    navigation.navigate('Main', { screen: 'Links', params: { } });
  };

  const navigateToNotes = () => {
    navigation.navigate('Main', { screen: 'Notes', params: { } });
  };
  
  const navigateToDocuments = () => {
    navigation.navigate('Main', { screen: 'Documents', params: { } });
  };
  
  // Render section header with title and optional "See All" button
  const renderSectionHeader = (title: string, onSeeAllPress?: () => void) => (
    <View style={styles.sectionHeader}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {onSeeAllPress && (
        <Button 
          mode="text" 
          onPress={onSeeAllPress} 
          labelStyle={styles.seeAllButton}
          style={styles.seeAllButtonContainer}
        >
          See All
        </Button>
      )}
    </View>
  );

  // Show empty state if no data
  if (!isLoading && links.length === 0 && notes.length === 0 && documents.length === 0) {
    return (
      <View style={styles.container}>
        <EmptyState
          icon="link-variant-plus"
          title="Welcome to LinkNest!"
          message="Start organizing your links, notes, and files by adding your first resource."
          actionLabel="Add Link"
          onAction={() => navigation.navigate('AddLink')}
        />
        <FAB
          icon="plus"
          style={[styles.fab, { backgroundColor: theme.colors.primary }]}
          onPress={() => navigation.navigate('AddLink')}
          color={theme.colors.onPrimary}
        />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.titleContainer}>
          <Icon name="link-variant" size={28} color={theme.colors.primary} style={styles.titleIcon} />
          <Text variant="headlineMedium" style={styles.title}>
            LinkNest
          </Text>
        </View>
        <Searchbar
          placeholder="Search"
          onChangeText={handleSearch}
          value={searchQuery}
          style={styles.searchBar}
          iconColor={theme.colors.primary}
        />
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {/* Favorites Section */}
        {(favoriteLinks.length > 0 || favoriteNotes.length > 0 || favoriteDocuments.length > 0) && (
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <View style={styles.sectionTitleContainer}>
                <Icon name="star" size={24} color={theme.colors.tertiary} style={styles.sectionIcon} />
                <Text variant="titleLarge" style={styles.sectionTitle}>
                  Favorites
                </Text>
              </View>
            </View>

            {favoriteLinks.map((link) => (
              <LinkCard
                key={link.id}
                link={link}
                onPress={() => navigateToLinkDetails(link.id)}
              />
            ))}

            {favoriteNotes.map((note) => (
              <NoteCard
                key={note.id}
                note={note}
                onPress={() => navigateToNoteDetails(note.id)}
              />
            ))}
            
            {favoriteDocuments.map((document) => (
              <DocumentCard
                key={document.id}
                document={document}
                onPress={() => navigateToDocumentDetails(document.id)}
              />
            ))}
          </View>
        )}

        {/* Recent Links Section */}
        {recentLinks.length > 0 && (
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <View style={styles.sectionTitleContainer}>
                <Icon name="link-variant" size={24} color={theme.colors.primary} style={styles.sectionIcon} />
                <Text variant="titleLarge" style={styles.sectionTitle}>
                  Recent Links
                </Text>
              </View>
              <Text
                variant="labelLarge"
                style={[styles.viewAll, { color: theme.colors.primary }]}
                onPress={navigateToLinks}
              >
                View All
              </Text>
            </View>

            {recentLinks.map((link) => (
              <LinkCard
                key={link.id}
                link={link}
                onPress={() => navigateToLinkDetails(link.id)}
              />
            ))}
          </View>
        )}

        {/* Recent Notes Section */}
        {recentNotes.length > 0 && (
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <View style={styles.sectionTitleContainer}>
                <Icon name="note-text" size={24} color={theme.colors.primary} style={styles.sectionIcon} />
                <Text variant="titleLarge" style={styles.sectionTitle}>
                  Recent Notes
                </Text>
              </View>
              <Text
                variant="labelLarge"
                style={[styles.viewAll, { color: theme.colors.primary }]}
                onPress={navigateToNotes}
              >
                View All
              </Text>
            </View>

            {recentNotes.map((note) => (
              <NoteCard
                key={note.id}
                note={note}
                onPress={() => navigateToNoteDetails(note.id)}
              />
            ))}
          </View>
        )}
        
        {/* Recent Documents Section */}
        {recentDocuments.length > 0 && (
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <View style={styles.sectionTitleContainer}>
                <Icon name="file-document" size={24} color={theme.colors.primary} style={styles.sectionIcon} />
                <Text variant="titleLarge" style={styles.sectionTitle}>
                  Recent Documents
                </Text>
              </View>
              <Text
                variant="labelLarge"
                style={[styles.viewAll, { color: theme.colors.primary }]}
                onPress={navigateToDocuments}
              >
                View All
              </Text>
            </View>

            {recentDocuments.map((document) => (
              <DocumentCard
                key={document.id}
                document={document}
                onPress={() => navigateToDocumentDetails(document.id)}
              />
            ))}
          </View>
        )}

        {/* Categories Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <View style={styles.sectionTitleContainer}>
              <Icon name="shape" size={24} color={theme.colors.primary} style={styles.sectionIcon} />
              <Text variant="titleLarge" style={styles.sectionTitle}>
                Categories
              </Text>
            </View>
            <Text
              variant="labelLarge"
              style={[styles.viewAll, { color: theme.colors.primary }]}
              onPress={() => navigation.navigate('Categories')}
            >
              Manage
            </Text>
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.categoriesContainer}
          >
            {categories.map((category) => (
              <Card
                key={category.id}
                style={[styles.categoryCard, { borderLeftColor: category.color, borderColor: theme.colors.outline + '20' }]}
                onPress={() => {
                  navigation.navigate('Main', { 
                    screen: 'Links',
                    params: { categoryId: category.id }
                  });
                }}
              >
                <Card.Content style={styles.categoryCardContent}>
                  <View style={[styles.categoryIconContainer, { backgroundColor: `${category.color}20` }]}>
                    <Icon name={category.icon} size={24} color={category.color} />
                  </View>
                  <Text variant="titleMedium" style={styles.categoryName}>
                    {category.name}
                  </Text>
                  <Text variant="bodySmall" style={[styles.categoryCount, { color: theme.colors.onSurfaceVariant }]}>
                    {links.filter((link) => link.category === category.id).length} links, 
                    {notes.filter((note) => note.category === category.id).length} notes, 
                    {documents.filter((doc) => doc.category === category.id).length} docs
                  </Text>
                </Card.Content>
              </Card>
            ))}
          </ScrollView>
        </View>
      </ScrollView>

      <FAB
        icon="plus"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={() => navigation.navigate('AddLink')}
        color={theme.colors.onPrimary}
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
    padding: 20,
    paddingTop: 32,
    backgroundColor: theme.colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.outline + '20',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  titleIcon: {
    marginRight: 12,
  },
  title: {
    fontWeight: '800',
    fontSize: 24,
    letterSpacing: -0.5,
  },
  searchBar: {
    elevation: 0,
    borderRadius: 12,
    height: 52,
    backgroundColor: theme.colors.surfaceVariant,
    borderWidth: 1,
    borderColor: theme.colors.outline + '20',
  },
  scrollContent: {
    paddingBottom: 100,
    paddingTop: 8,
  },
  section: {
    marginBottom: 32,
    paddingHorizontal: 16,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingHorizontal: 4,
  },
  sectionTitleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  sectionIcon: {
    marginRight: 10,
  },
  sectionTitle: {
    fontWeight: '700',
    fontSize: 18,
    letterSpacing: -0.3,
  },
  viewAll: {
    fontWeight: '600',
    fontSize: 14,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 16,
    backgroundColor: theme.colors.primaryContainer,
  },
  categoriesContainer: {
    paddingRight: 16,
    paddingVertical: 8,
  },
  categoryCard: {
    width: 150,
    marginRight: 16,
    borderLeftWidth: 4,
    borderRadius: 16,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    backgroundColor: theme.colors.surface,
    borderWidth: 1,
    borderColor: theme.colors.outline + '20',
  },
  categoryCardContent: {
    padding: 16,
  },
  categoryIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  categoryName: {
    fontWeight: '600',
    marginBottom: 6,
    fontSize: 14,
    lineHeight: 20,
  },
  categoryCount: {
    color: theme.colors.onSurfaceVariant,
    fontSize: 12,
    fontWeight: '500',
  },
  fab: {
    position: 'absolute',
    margin: 20,
    right: 0,
    bottom: 0,
    borderRadius: 28,
    elevation: 6,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 3,
    },
    shadowOpacity: 0.2,
    shadowRadius: 5,
  },
  seeAllButton: {
    fontSize: 14,
    fontWeight: '500',
  },
  seeAllButtonContainer: {
    marginRight: -8,
  },
});

export default HomeScreen;