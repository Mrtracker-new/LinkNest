import React, { useRef } from 'react';
import { Animated, Pressable, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import { Button, useTheme } from 'react-native-paper';

interface AnimatedButtonProps {
  mode?: 'text' | 'outlined' | 'contained' | 'elevated' | 'contained-tonal';
  onPress: () => void;
  children: string;
  icon?: string;
  disabled?: boolean;
  loading?: boolean;
  style?: ViewStyle;
  labelStyle?: TextStyle;
  contentStyle?: ViewStyle;
}

const AnimatedButton: React.FC<AnimatedButtonProps> = ({
  mode = 'contained',
  onPress,
  children,
  icon,
  disabled = false,
  loading = false,
  style,
  labelStyle,
  contentStyle,
}) => {
  const theme = useTheme();
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const opacityAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: 0.96,
        useNativeDriver: true,
        tension: 300,
        friction: 10,
      }),
      Animated.timing(opacityAnim, {
        toValue: 0.8,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const handlePressOut = () => {
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: 1,
        useNativeDriver: true,
        tension: 300,
        friction: 10,
      }),
      Animated.timing(opacityAnim, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();
  };

  return (
    <Pressable
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      onPress={onPress}
      disabled={disabled || loading}
    >
      <Animated.View
        style={[
          {
            transform: [{ scale: scaleAnim }],
            opacity: opacityAnim,
          },
        ]}
      >
        <Button
          mode={mode}
          onPress={() => {}}
          icon={icon}
          disabled={disabled}
          loading={loading}
          style={style}
          labelStyle={labelStyle}
          contentStyle={contentStyle}
        >
          {children}
        </Button>
      </Animated.View>
    </Pressable>
  );
};

export default AnimatedButton;
