import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, ViewStyle } from 'react-native';
import { useTheme } from 'react-native-paper';

interface SkeletonLoaderProps {
  width?: number | string;
  height?: number | string;
  borderRadius?: number;
  style?: ViewStyle;
}

export const SkeletonLoader: React.FC<SkeletonLoaderProps> = ({ 
  width = '100%', 
  height = 20, 
  borderRadius = 4,
  style 
}) => {
  const theme = useTheme();
  const animatedValue = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(animatedValue, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(animatedValue, {
          toValue: 0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    ).start();
  }, [animatedValue]);

  const opacity = animatedValue.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.7],
  });

  const dimensionStyle: any = {
    width,
    height,
    borderRadius,
    backgroundColor: theme.colors.surfaceVariant,
  };

  return (
    <Animated.View
      style={[
        dimensionStyle,
        { opacity },
        style,
      ]}
    />
  );
};

interface SkeletonCardProps {
  style?: ViewStyle;
}

export const SkeletonCard: React.FC<SkeletonCardProps> = ({ style }) => {
  const theme = useTheme();
  
  return (
    <View style={[styles.card, { backgroundColor: theme.colors.surface }, style]}>
      <SkeletonLoader width={60} height={60} borderRadius={8} style={styles.icon} />
      <View style={styles.content}>
        <SkeletonLoader width="80%" height={20} style={styles.title} />
        <SkeletonLoader width="60%" height={16} style={styles.subtitle} />
        <View style={styles.meta}>
          <SkeletonLoader width={80} height={24} borderRadius={12} />
          <SkeletonLoader width={100} height={14} />
        </View>
      </View>
    </View>
  );
};

interface SkeletonListProps {
  count?: number;
}

export const SkeletonList: React.FC<SkeletonListProps> = ({ count = 5 }) => {
  return (
    <View style={styles.list}>
      {Array.from({ length: count }).map((_, index) => (
        <SkeletonCard key={index} style={styles.listItem} />
      ))}
    </View>
  );
};

export const SkeletonNoteCard: React.FC<SkeletonCardProps> = ({ style }) => {
  const theme = useTheme();
  
  return (
    <View style={[styles.noteCard, { backgroundColor: theme.colors.surface }, style]}>
      <SkeletonLoader width="70%" height={20} style={styles.title} />
      <SkeletonLoader width="100%" height={14} style={styles.subtitle} />
      <SkeletonLoader width="90%" height={14} style={styles.subtitle} />
      <View style={styles.noteMeta}>
        <SkeletonLoader width={80} height={24} borderRadius={12} />
        <SkeletonLoader width={100} height={12} />
      </View>
    </View>
  );
};

export const SkeletonDocumentCard: React.FC<SkeletonCardProps> = ({ style }) => {
  const theme = useTheme();
  
  return (
    <View style={[styles.documentCard, { backgroundColor: theme.colors.surface }, style]}>
      <SkeletonLoader width={40} height={40} borderRadius={8} style={styles.documentIcon} />
      <View style={styles.documentContent}>
        <SkeletonLoader width="75%" height={18} style={styles.title} />
        <SkeletonLoader width="50%" height={14} style={styles.subtitle} />
        <View style={styles.documentMeta}>
          <SkeletonLoader width={80} height={24} borderRadius={12} />
          <SkeletonLoader width={100} height={12} />
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  list: {
    padding: 16,
  },
  listItem: {
    marginBottom: 12,
  },
  card: {
    flexDirection: 'row',
    padding: 16,
    borderRadius: 12,
    elevation: 2,
  },
  icon: {
    marginRight: 12,
  },
  content: {
    flex: 1,
  },
  title: {
    marginBottom: 8,
  },
  subtitle: {
    marginBottom: 8,
  },
  meta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  noteCard: {
    padding: 16,
    borderRadius: 12,
    elevation: 2,
    marginBottom: 12,
  },
  noteMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 12,
  },
  documentCard: {
    flexDirection: 'row',
    padding: 16,
    borderRadius: 8,
    elevation: 1,
    marginBottom: 8,
  },
  documentIcon: {
    marginRight: 12,
  },
  documentContent: {
    flex: 1,
  },
  documentMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 8,
  },
});

export default SkeletonLoader;
