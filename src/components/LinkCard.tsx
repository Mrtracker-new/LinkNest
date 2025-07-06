import React, { memo } from 'react';
import { StyleSheet, View, Linking, TouchableOpacity } from 'react-native';
import { Surface, Text, IconButton, Chip, useTheme, TouchableRipple } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Link } from '../types';
import { useApp } from '../context/AppContext';
import { extractDomain } from '../utils/urlUtils.ts';

interface LinkCardProps {
  link: Link;
  onPress: () => void;
}

const LinkCard: React.FC<LinkCardProps> = memo(({ link, onPress }) => {
  const theme = useTheme();
  const { categories, tags, toggleFavoriteLink } = useApp();
  const styles = createStyles(theme);

  // Find the category for this link
  const category = categories.find((cat) => cat.id === link.category);

  // Find tags for this link
  const linkTags = tags.filter((tag) => link.tags.includes(tag.id));

  // Extract domain from URL for display
  const domain = extractDomain(link.url);

  const handleFavoriteToggle = (e: any) => {
    e.stopPropagation();
    toggleFavoriteLink(link.id);
  };
  
  // Handle opening the link directly
  const handleOpenLink = (e: any) => {
    e.stopPropagation();
    const url = link.url.startsWith('http') ? link.url : `https://${link.url}`;
    Linking.openURL(url).catch(err => console.error('Error opening URL:', err));
  };

  return (
    <Surface style={styles.cardSurface} elevation={2}>
      <TouchableRipple onPress={onPress} style={styles.ripple} borderless>
        <View style={styles.cardContent}>
          <View style={styles.header}>
            {category && (
              <View style={[styles.categoryContainer, { backgroundColor: `${category.color}15` }]}>
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
            <View style={styles.actionButtons}>
              <IconButton
                icon="open-in-new"
                iconColor={theme.colors.primary}
                size={18}
                onPress={handleOpenLink}
                style={styles.actionButton}
              />
              <IconButton
                icon={link.isFavorite ? 'star' : 'star-outline'}
                iconColor={link.isFavorite ? theme.colors.tertiary : theme.colors.outline}
                size={20}
                onPress={handleFavoriteToggle}
                style={styles.favoriteButton}
              />
            </View>
          </View>
          
          <Text variant="titleMedium" style={styles.title} numberOfLines={2}>
            {link.title}
          </Text>
          
          <View style={styles.urlContainer}>
            <Icon name="link-variant" size={14} color={theme.colors.primary} style={styles.urlIcon} />
            <Text variant="bodySmall" style={styles.url} numberOfLines={1}>
              {domain}
            </Text>
          </View>
          
          {link.description && (
            <Text variant="bodyMedium" style={styles.description} numberOfLines={2}>
              {link.description}
            </Text>
          )}
          
          {linkTags.length > 0 && (
            <View style={styles.tagsContainer}>
              {linkTags.slice(0, 3).map((tag) => (
                <Chip 
                  key={tag.id} 
                  style={[styles.tag, { backgroundColor: `${tag.color}30` }]}
                  textStyle={{ color: tag.color, fontWeight: '600', fontSize: 12, lineHeight: 16 }}
                  compact
                >
                  {tag.name}
                </Chip>
              ))}
              {linkTags.length > 3 && (
                <Chip 
                  style={styles.moreTag}
                  textStyle={{ color: theme.colors.onSurfaceVariant, fontSize: 12, lineHeight: 16 }}
                  compact
                >
                  +{linkTags.length - 3}
                </Chip>
              )}
            </View>
          )}
          
          <View style={styles.dateContainer}>
            <Icon name="clock-outline" size={12} color={theme.colors.onSurfaceVariant} style={styles.dateIcon} />
            <Text variant="labelSmall" style={styles.dateText}>
              {new Date(link.updatedAt).toLocaleDateString()}
            </Text>
          </View>
        </View>
      </TouchableRipple>
    </Surface>
  );
});

const createStyles = (theme: any) => StyleSheet.create({
  cardSurface: {
    marginBottom: 16,
    marginHorizontal: 8,
    borderRadius: 16,
    overflow: 'hidden',
    backgroundColor: theme.colors.surface,
  },
  ripple: {
    borderRadius: 16,
  },
  cardContent: {
    padding: 16,
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
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 12,
    maxWidth: '70%',
  },
  categoryIcon: {
    marginRight: 6,
  },
  categoryText: {
    fontWeight: '600',
    fontSize: 12,
  },
  actionButtons: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionButton: {
    margin: 0,
    marginRight: -4,
  },
  favoriteButton: {
    margin: 0,
    marginRight: -8,
  },
  title: {
    fontWeight: '700',
    marginBottom: 10,
    lineHeight: 22,
    fontSize: 16,
  },
  urlContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  urlIcon: {
    marginRight: 6,
  },
  url: {
    opacity: 0.7,
    fontSize: 13,
    color: theme.colors.primary,
  },
  description: {
    marginBottom: 16,
    lineHeight: 20,
    opacity: 0.8,
    fontSize: 14,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 4,
    marginBottom: 12,
    alignItems: 'center',
  },
  tag: {
    marginRight: 6,
    marginBottom: 4,
    height: 28,
    borderRadius: 14,
    paddingHorizontal: 8,
    justifyContent: 'center',
  },
  moreTag: {
    marginRight: 6,
    marginBottom: 4,
    height: 28,
    backgroundColor: theme.colors.surfaceVariant,
    borderRadius: 14,
    paddingHorizontal: 8,
    justifyContent: 'center',
  },
  dateContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  dateIcon: {
    marginRight: 4,
  },
  dateText: {
    color: theme.colors.onSurfaceVariant,
    fontSize: 11,
  },
});

export default LinkCard;
