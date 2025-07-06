import React, { useState, memo } from 'react';
import { StyleSheet, View, ScrollView, Animated } from 'react-native';
import { Chip, IconButton, Menu, Divider, useTheme, Text, Badge, Surface } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Category, Tag } from '../types';
import { useApp } from '../context/AppContext';

interface FilterBarProps {
  selectedCategory: string | null;
  setSelectedCategory: (categoryId: string | null) => void;
  selectedTags: string[];
  setSelectedTags: (tags: string[]) => void;
  sortBy: 'newest' | 'oldest' | 'alphabetical' | 'favorites';
  setSortBy: (sortBy: 'newest' | 'oldest' | 'alphabetical' | 'favorites') => void;
}

const FilterBar: React.FC<FilterBarProps> = memo(({ 
  selectedCategory,
  setSelectedCategory,
  selectedTags,
  setSelectedTags,
  sortBy,
  setSortBy,
}) => {
  const theme = useTheme();
  const { categories, tags } = useApp();
  const [sortMenuVisible, setSortMenuVisible] = useState(false);
  const [categoryMenuVisible, setCategoryMenuVisible] = useState(false);
  const [tagsMenuVisible, setTagsMenuVisible] = useState(false);
  const styles = createStyles(theme);
  
  // Count active filters
  const activeFilterCount = (selectedCategory ? 1 : 0) + selectedTags.length;

  const handleCategoryPress = (categoryId: string) => {
    if (selectedCategory === categoryId) {
      setSelectedCategory(null);
    } else {
      setSelectedCategory(categoryId);
    }
  };

  const handleTagPress = (tagId: string) => {
    if (selectedTags.includes(tagId)) {
      setSelectedTags(selectedTags.filter((id) => id !== tagId));
    } else {
      setSelectedTags([...selectedTags, tagId]);
    }
  };

  const handleSortPress = (sort: 'newest' | 'oldest' | 'alphabetical' | 'favorites') => {
    setSortBy(sort);
    setSortMenuVisible(false);
  };

  const getSortIcon = () => {
    switch (sortBy) {
      case 'newest':
        return 'clock-outline';
      case 'oldest':
        return 'clock-time-eight-outline';
      case 'alphabetical':
        return 'sort-alphabetical-ascending';
      case 'favorites':
        return 'star-outline';
      default:
        return 'sort';
    }
  };

  return (
    <Surface style={styles.container} elevation={1}>
      <View style={styles.filterSection}>
        <View style={styles.filterHeader}>
          <Text variant="labelLarge" style={styles.filterTitle}>Filters</Text>
          {activeFilterCount > 0 && (
            <Badge size={22} style={styles.filterBadge}>{activeFilterCount}</Badge>
          )}
        </View>
        
        <View style={styles.filterButtons}>
          <Chip
            mode="outlined"
            selected={selectedCategory !== null || selectedTags.length > 0}
            onPress={() => {
              setSelectedCategory(null);
              setSelectedTags([]);
            }}
            style={styles.clearChip}
            icon="filter-remove-outline"
          >
            Clear All
          </Chip>
          
          <View style={styles.filterButtonsRight}>
            <Menu
              visible={categoryMenuVisible}
              onDismiss={() => setCategoryMenuVisible(false)}
              anchor={
                <Chip
                  mode="outlined"
                  onPress={() => setCategoryMenuVisible(true)}
                  style={styles.menuChip}
                  icon={selectedCategory ? 'check-circle' : 'shape-outline'}
                  selectedColor={selectedCategory ? theme.colors.primary : undefined}
                  selected={selectedCategory !== null}
                >
                  {selectedCategory 
                    ? categories.find(c => c.id === selectedCategory)?.name 
                    : 'Category'}
                </Chip>
              }
            >
              <Menu.Item
                leadingIcon="close-circle-outline"
                onPress={() => {
                  setSelectedCategory(null);
                  setCategoryMenuVisible(false);
                }}
                title="All Categories"
              />
              <Divider />
              {categories.map((category) => (
                <Menu.Item
                  key={category.id}
                  leadingIcon={({size, color}) => (
                    <Icon name={category.icon} size={size} color={category.color} />
                  )}
                  onPress={() => {
                    handleCategoryPress(category.id);
                    setCategoryMenuVisible(false);
                  }}
                  title={category.name}
                  trailingIcon={selectedCategory === category.id ? 'check' : undefined}
                />
              ))}
            </Menu>
            
            <Menu
              visible={tagsMenuVisible}
              onDismiss={() => setTagsMenuVisible(false)}
              anchor={
                <Chip
                  mode="outlined"
                  onPress={() => setTagsMenuVisible(true)}
                  style={styles.menuChip}
                  icon={selectedTags.length > 0 ? 'check-circle' : 'tag-outline'}
                  selectedColor={selectedTags.length > 0 ? theme.colors.primary : undefined}
                  selected={selectedTags.length > 0}
                >
                  {selectedTags.length > 0 
                    ? `${selectedTags.length} Tag${selectedTags.length > 1 ? 's' : ''}` 
                    : 'Tags'}
                </Chip>
              }
            >
              <Menu.Item
                leadingIcon="close-circle-outline"
                onPress={() => {
                  setSelectedTags([]);
                  setTagsMenuVisible(false);
                }}
                title="Clear Tags"
              />
              <Divider />
              {tags.map((tag) => (
                <Menu.Item
                  key={tag.id}
                  leadingIcon={({size}) => (
                    <View style={[styles.tagDot, {backgroundColor: tag.color}]} />
                  )}
                  onPress={() => {
                    handleTagPress(tag.id);
                    setTagsMenuVisible(false);
                  }}
                  title={tag.name}
                  trailingIcon={selectedTags.includes(tag.id) ? 'check' : undefined}
                />
              ))}
            </Menu>
            
            <Menu
              visible={sortMenuVisible}
              onDismiss={() => setSortMenuVisible(false)}
              anchor={
                <Chip
                  mode="outlined"
                  onPress={() => setSortMenuVisible(true)}
                  style={styles.menuChip}
                  icon={getSortIcon()}
                >
                  Sort
                </Chip>
              }
            >
              <Menu.Item
                leadingIcon="clock-outline"
                onPress={() => handleSortPress('newest')}
                title="Newest First"
                trailingIcon={sortBy === 'newest' ? 'check' : undefined}
              />
              <Menu.Item
                leadingIcon="clock-time-eight-outline"
                onPress={() => handleSortPress('oldest')}
                title="Oldest First"
                trailingIcon={sortBy === 'oldest' ? 'check' : undefined}
              />
              <Menu.Item
                leadingIcon="sort-alphabetical-ascending"
                onPress={() => handleSortPress('alphabetical')}
                title="Alphabetical"
                trailingIcon={sortBy === 'alphabetical' ? 'check' : undefined}
              />
              <Menu.Item
                leadingIcon="star-outline"
                onPress={() => handleSortPress('favorites')}
                title="Favorites First"
                trailingIcon={sortBy === 'favorites' ? 'check' : undefined}
              />
            </Menu>
          </View>
        </View>
        
        {(selectedCategory || selectedTags.length > 0) && (
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.activeFiltersContainer}
          >
            {selectedCategory && (
              <Chip
                mode="flat"
                onClose={() => setSelectedCategory(null)}
                style={styles.activeFilterChip}
                avatar={
                  <Icon 
                    name={categories.find(c => c.id === selectedCategory)?.icon || 'shape-outline'} 
                    size={16} 
                    color={categories.find(c => c.id === selectedCategory)?.color} 
                  />
                }
              >
                {categories.find(c => c.id === selectedCategory)?.name}
              </Chip>
            )}
            
            {selectedTags.map(tagId => {
              const tag = tags.find(t => t.id === tagId);
              if (!tag) return null;
              return (
                <Chip
                  key={tag.id}
                  mode="flat"
                  onClose={() => handleTagPress(tag.id)}
                  style={[styles.activeFilterChip, {backgroundColor: `${tag.color}20`}]}
                  selectedColor={tag.color}
                >
                  {tag.name}
                </Chip>
              );
            })}
          </ScrollView>
        )}
      </View>
    </Surface>
  );
});

const createStyles = (theme: any) => StyleSheet.create({
  container: {
    backgroundColor: theme.colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.outline + '10',
  },
  filterSection: {
    padding: 12,
  },
  filterHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  filterTitle: {
    fontWeight: '600',
    color: theme.colors.onSurfaceVariant,
  },
  filterBadge: {
    marginLeft: 8,
    backgroundColor: theme.colors.primary,
  },
  filterButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  filterButtonsRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  clearChip: {
    height: 36,
    borderRadius: 18,
  },
  menuChip: {
    height: 36,
    borderRadius: 18,
    marginLeft: 8,
  },
  activeFiltersContainer: {
    paddingVertical: 8,
    paddingRight: 8,
  },
  activeFilterChip: {
    marginRight: 8,
    height: 32,
    borderRadius: 16,
  },
  tagDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
});

export default FilterBar;