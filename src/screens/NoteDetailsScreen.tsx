import React from 'react';
import { StyleSheet, View, ScrollView, Share, Alert } from 'react-native';
import { Text, Card, Chip, IconButton, useTheme, Divider, Menu } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useApp } from '../context/AppContext';
import { RootStackParamList } from '../navigation';

type NoteDetailsScreenRouteProp = RouteProp<RootStackParamList, 'NoteDetails'>;
type NoteDetailsScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const NoteDetailsScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<NoteDetailsScreenNavigationProp>();
  const route = useRoute<NoteDetailsScreenRouteProp>();
  const { id } = route.params;
  
  const { notes, categories, tags, deleteNote, toggleFavoriteNote } = useApp();
  
  const note = notes.find(n => n.id === id);
  const category = categories.find(c => c.id === note?.category); // Changed from categoryId to category
  const noteTags = tags.filter(t => note?.tags.includes(t.id)); // Changed from tagIds to tags
  
  const [menuVisible, setMenuVisible] = React.useState(false);
  
  if (!note) {
    return (
      <View style={styles.container}>
        <Text variant="headlineMedium">Note not found</Text>
      </View>
    );
  }
  
  // Format date
  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };
  
  // Handle share note
  const handleShareNote = async () => {
    try {
      await Share.share({
        title: note.title,
        message: `${note.title}\n\n${note.content}`,
      });
    } catch (error) {
      console.error('Error sharing note:', error);
    }
  };
  
  // Handle edit note
  const handleEditNote = () => {
    navigation.navigate('EditNote', { id: note.id });
  };
  
  // Handle delete note
  const handleDeleteNote = () => {
    Alert.alert(
      'Delete Note',
      'Are you sure you want to delete this note? This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            deleteNote(note.id);
            navigation.goBack();
          },
        },
      ]
    );
  };
  
  // Handle toggle favorite
  const handleToggleFavorite = () => {
    toggleFavoriteNote(note.id);
  };
  
  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Card style={styles.card}>
          <Card.Content>
            <View style={styles.headerContainer}>
              <Text variant="headlineMedium" style={styles.title}>
                {note.title}
              </Text>
              <IconButton
                icon={note.isFavorite ? 'star' : 'star-outline'}
                iconColor={note.isFavorite ? theme.colors.primary : undefined}
                size={24}
                onPress={handleToggleFavorite}
              />
            </View>
            
            {category && (
              <Chip
                icon="folder"
                style={styles.category}
                textStyle={{ color: theme.colors.onSurface }}
              >
                {category.name}
              </Chip>
            )}
            
            <Divider style={styles.divider} />
            
            <Text variant="bodyLarge" style={styles.content}>
              {note.content}
            </Text>
            
            {noteTags.length > 0 && (
              <View style={styles.tagsContainer}>
                {noteTags.map(tag => (
                  <Chip
                    key={tag.id}
                    icon="tag"
                    style={styles.tag}
                    textStyle={{ color: theme.colors.onSurface }}
                  >
                    {tag.name}
                  </Chip>
                ))}
              </View>
            )}
            
            <Divider style={styles.divider} />
            
            <View style={styles.dateContainer}>
              <Text variant="bodySmall" style={styles.dateText}>
                Created: {formatDate(note.createdAt)}
              </Text>
              {note.updatedAt !== note.createdAt && (
                <Text variant="bodySmall" style={styles.dateText}>
                  Updated: {formatDate(note.updatedAt)}
                </Text>
              )}
            </View>
          </Card.Content>
        </Card>
      </ScrollView>
      
      <View style={styles.actionsContainer}>
        <IconButton
          icon="share-variant"
          size={24}
          onPress={handleShareNote}
        />
        <IconButton
          icon="pencil"
          size={24}
          onPress={handleEditNote}
        />
        <IconButton
          icon="delete"
          size={24}
          iconColor={theme.colors.error}
          onPress={handleDeleteNote}
        />
        <View style={styles.menuContainer}>
          <Menu
            visible={menuVisible}
            onDismiss={() => setMenuVisible(false)}
            anchor={
              <IconButton
                icon="dots-vertical"
                size={24}
                onPress={() => setMenuVisible(true)}
              />
            }
          >
            <Menu.Item
              title="Edit"
              leadingIcon="pencil"
              onPress={() => {
                setMenuVisible(false);
                handleEditNote();
              }}
            />
            <Menu.Item
              title="Share"
              leadingIcon="share-variant"
              onPress={() => {
                setMenuVisible(false);
                handleShareNote();
              }}
            />
            <Menu.Item
              title={note.isFavorite ? "Remove from Favorites" : "Add to Favorites"}
              leadingIcon={note.isFavorite ? "star-off" : "star"}
              onPress={() => {
                setMenuVisible(false);
                handleToggleFavorite();
              }}
            />
            <Divider />
            <Menu.Item
              title="Delete"
              leadingIcon="delete"
              onPress={() => {
                setMenuVisible(false);
                handleDeleteNote();
              }}
              titleStyle={{ color: theme.colors.error }}
            />
          </Menu>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 80, // Extra space for action buttons
  },
  card: {
    marginBottom: 16,
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  title: {
    flex: 1,
    fontWeight: 'bold',
  },
  category: {
    alignSelf: 'flex-start',
    marginBottom: 16,
  },
  divider: {
    marginVertical: 16,
  },
  content: {
    marginBottom: 16,
    lineHeight: 24,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 16,
  },
  tag: {
    marginRight: 8,
    marginBottom: 8,
  },
  dateContainer: {
    marginTop: 8,
  },
  dateText: {
    marginBottom: 4,
    opacity: 0.7,
  },
  actionsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    paddingVertical: 8,
    borderTopWidth: 1,
    borderTopColor: 'rgba(0, 0, 0, 0.1)',
  },
  menuContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default NoteDetailsScreen;