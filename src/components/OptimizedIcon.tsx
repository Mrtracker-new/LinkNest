import React, { memo } from 'react';
import { StyleProp, ViewStyle } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

interface OptimizedIconProps {
  name: string;
  size?: number;
  color?: string;
  style?: any;
}

/**
 * Optimized Icon component that memoizes to prevent unnecessary re-renders
 * Uses react-native-vector-icons MaterialCommunityIcons
 */
const OptimizedIcon: React.FC<OptimizedIconProps> = memo(
  ({ name, size = 24, color = '#000', style }) => {
    return <Icon name={name} size={size} color={color} style={style} />;
  },
  (prevProps, nextProps) => {
    // Custom comparison function for memo
    return (
      prevProps.name === nextProps.name &&
      prevProps.size === nextProps.size &&
      prevProps.color === nextProps.color &&
      prevProps.style === nextProps.style
    );
  }
);

OptimizedIcon.displayName = 'OptimizedIcon';

export default OptimizedIcon;
