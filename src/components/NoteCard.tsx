import React from 'react';
import { StyleSheet, View, TouchableOpacity } from 'react-native';
import { Card, Text, IconButton, useTheme, Chip } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Note } from '../types';
import { useApp } from '../context/AppContext';

interface NoteCardProps {
  note: Note;
  onPress: () => void;
}

const NoteCard: React.FC<NoteCardProps> = ({ note, onPress }) => {
  const theme = useTheme();
  const { categories, tags, toggleFavoriteNote } = useApp();
  const styles = createStyles(theme);

  // Find the category for this note
  const category = categories.find((cat) => cat.id === note.category);

  // Find tags for this note
  const noteTags = tags.filter((tag) => note.tags.includes(tag.id));

  const handleFavoriteToggle = () => {
    toggleFavoriteNote(note.id);
  };

  // Format date
  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  return (
    <Card style={styles.card} onPress={onPress}>
      <Card.Content>
        <View style={styles.header}>
          {category && (
            <View style={styles.categoryContainer}>
              <Icon 
                name={category.icon} 
                size={16} 
                color={category.color} 
                style={styles.categoryIcon} 
              />
              <Text 
                variant="labelMedium" 
                style={[styles.categoryText, { color: category.color }]}
              >
                {category.name}
              </Text>
            </View>
          )}
          <IconButton
            icon={note.isFavorite ? 'star' : 'star-outline'}
            iconColor={note.isFavorite ? theme.colors.tertiary : theme.colors.outline}
            size={20}
            onPress={handleFavoriteToggle}
            style={styles.favoriteButton}
          />
        </View>
        
        <Text variant="titleMedium" style={styles.title} numberOfLines={2}>
          {note.title}
        </Text>
        
        <Text variant="bodyMedium" style={styles.content} numberOfLines={3}>
          {note.content}
        </Text>
        
        <View style={styles.footer}>
          <Text variant="bodySmall" style={styles.date}>
            {formatDate(note.updatedAt)}
          </Text>
          
          {noteTags.length > 0 && (
            <View style={styles.tagsContainer}>
              {noteTags.slice(0, 2).map((tag) => (
                <Chip 
                  key={tag.id} 
                  style={[styles.tag, { backgroundColor: `${tag.color}20` }]}
                  textStyle={{ color: tag.color }}
                  compact
                >
                  {tag.name}
                </Chip>
              ))}
              {noteTags.length > 2 && (
                <Chip 
                  style={styles.moreTag}
                  textStyle={{ color: theme.colors.onSurfaceVariant }}
                  compact
                >
                  +{noteTags.length - 2}
                </Chip>
              )}
            </View>
          )}
        </View>
      </Card.Content>
    </Card>
  );
};

const createStyles = (theme: any) => StyleSheet.create({
  card: {
    marginBottom: 16,
    marginHorizontal: 4,
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
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  categoryContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.surfaceVariant,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  categoryIcon: {
    marginRight: 6,
  },
  categoryText: {
    fontWeight: '500',
    fontSize: 12,
  },
  favoriteButton: {
    margin: 0,
    marginRight: -12,
  },
  title: {
    fontWeight: '700',
    marginBottom: 12,
    lineHeight: 24,
    fontSize: 16,
  },
  content: {
    marginBottom: 16,
    lineHeight: 20,
    opacity: 0.8,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginTop: 4,
  },
  date: {
    opacity: 0.6,
    fontSize: 12,
    fontWeight: '500',
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
  },
  tag: {
    marginLeft: 6,
    height: 26,
    borderRadius: 13,
  },
  moreTag: {
    marginLeft: 6,
    height: 26,
    backgroundColor: theme.colors.surfaceVariant,
    borderRadius: 13,
  },
});

export default NoteCard;