import React from 'react';
import { StyleSheet, View, TouchableOpacity } from 'react-native';
import { Card, Text, IconButton, useTheme, Chip } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Document } from '../types';
import { useApp } from '../context/AppContext';

interface DocumentCardProps {
  document: Document;
  onPress: () => void;
}

const DocumentCard: React.FC<DocumentCardProps> = ({ document, onPress }) => {
  const theme = useTheme();
  const { categories, tags, toggleFavoriteDocument } = useApp();
  const styles = createStyles(theme);

  // Find the category for this document
  const category = categories.find((cat) => cat.id === document.category);

  // Find tags for this document
  const documentTags = tags.filter((tag) => document.tags.includes(tag.id));

  const handleFavoriteToggle = () => {
    toggleFavoriteDocument(document.id);
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

  // Format file size
  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  // Get icon based on file type
  const getFileIcon = (type: string) => {
    if (type.includes('pdf')) return 'file-pdf-box';
    if (type.includes('word') || type.includes('doc')) return 'file-word-box';
    if (type.includes('excel') || type.includes('sheet') || type.includes('xls')) return 'file-excel-box';
    if (type.includes('powerpoint') || type.includes('presentation') || type.includes('ppt')) return 'file-powerpoint-box';
    if (type.includes('image')) return 'file-image-box';
    if (type.includes('text')) return 'file-document-box';
    return 'file-box';
  };

  return (
    <Card style={[styles.card, { borderColor: theme.colors.outline + '20' }]} onPress={onPress}>
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
            icon={document.isFavorite ? 'star' : 'star-outline'}
            iconColor={document.isFavorite ? theme.colors.tertiary : theme.colors.outline}
            size={20}
            onPress={handleFavoriteToggle}
            style={styles.favoriteButton}
          />
        </View>
        
        <View style={styles.documentInfo}>
          <View style={[styles.iconContainer, { backgroundColor: theme.colors.surfaceVariant, borderColor: theme.colors.outline + '30' }]}>
            <Icon 
              name={getFileIcon(document.type)} 
              size={24} 
              color={theme.colors.primary} 
            />
          </View>
          <View style={styles.documentDetails}>
            <Text variant="titleMedium" style={[styles.title, { color: theme.colors.onSurface }]} numberOfLines={2}>
              {document.name}
            </Text>
            
            <View style={styles.metaInfo}>
              <Text variant="bodySmall" style={[styles.fileInfo, { color: theme.colors.onSurfaceVariant }]}>
                {formatFileSize(document.size)} • {document.type.split('/')[1]?.toUpperCase() || document.type}
              </Text>
              <Text variant="bodySmall" style={[styles.date, { color: theme.colors.onSurfaceVariant }]}>
                {formatDate(document.createdAt)}
              </Text>
            </View>
          </View>
        </View>
        
        {documentTags.length > 0 && (
          <View style={styles.tagsContainer}>
            {documentTags.slice(0, 2).map((tag) => (
              <Chip 
                key={tag.id} 
                style={[styles.tag, { backgroundColor: `${tag.color}20` }]}
                textStyle={{ color: tag.color }}
                compact
              >
                {tag.name}
              </Chip>
            ))}
            {documentTags.length > 2 && (
              <Chip 
                style={styles.moreTag}
                textStyle={{ color: theme.colors.onSurfaceVariant }}
                compact
              >
                +{documentTags.length - 2}
              </Chip>
            )}
          </View>
        )}
      </Card.Content>
    </Card>
  );
};

const createStyles = (theme: any) => StyleSheet.create({

  card: {
    marginBottom: 16,
    marginHorizontal: 8,
    borderRadius: 16,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    backgroundColor: theme.colors.surface,
    borderWidth: 1,
    borderColor: theme.colors.surfaceVariant,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
  },
  categoryContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: theme.colors.surfaceVariant,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 12,
  },
  categoryIcon: {
    marginRight: 8,
  },
  categoryText: {
    fontWeight: '600',
    fontSize: 12,
    letterSpacing: 0.2,
  },
  favoriteButton: {
    margin: 0,
    marginRight: -8,
  },
  documentInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 14,
  },
  iconContainer: {
    width: 52,
    height: 52,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
    borderWidth: 1,
    borderColor: `${theme.colors.primary}20`,
  },
  documentDetails: {
    flex: 1,
  },
  title: {
    fontWeight: '700',
    marginBottom: 8,
    lineHeight: 22,
    fontSize: 16,
    letterSpacing: 0.1,
    color: theme.colors.onSurface,
  },
  metaInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  fileInfo: {
    color: theme.colors.onSurfaceVariant,
    fontSize: 12,
    fontWeight: '500',
    letterSpacing: 0.2,
  },
  date: {
    color: theme.colors.onSurfaceVariant,
    fontSize: 12,
    fontWeight: '500',
    letterSpacing: 0.2,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 8,
    alignItems: 'center',
  },
  tag: {
    marginRight: 8,
    marginBottom: 6,
    height: 28,
    borderRadius: 14,
    paddingHorizontal: 2,
  },
  moreTag: {
    marginRight: 8,
    marginBottom: 6,
    height: 28,
    backgroundColor: theme.colors.surfaceVariant,
    borderRadius: 14,
    paddingHorizontal: 2,
  },
});

export default DocumentCard;