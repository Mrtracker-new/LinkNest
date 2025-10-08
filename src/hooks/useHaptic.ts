import ReactNativeHapticFeedback from 'react-native-haptic-feedback';
import { Platform } from 'react-native';

const hapticOptions = {
  enableVibrateFallback: true,
  ignoreAndroidSystemSettings: false,
};

export const useHaptic = () => {
  const triggerLight = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactLight', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('impactLight', hapticOptions);
    }
  };

  const triggerMedium = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactMedium', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('impactMedium', hapticOptions);
    }
  };

  const triggerHeavy = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('impactHeavy', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('impactHeavy', hapticOptions);
    }
  };

  const triggerSuccess = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationSuccess', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('notificationSuccess', hapticOptions);
    }
  };

  const triggerWarning = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationWarning', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('notificationWarning', hapticOptions);
    }
  };

  const triggerError = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('notificationError', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('notificationError', hapticOptions);
    }
  };

  const triggerSelection = () => {
    if (Platform.OS === 'ios') {
      ReactNativeHapticFeedback.trigger('selection', hapticOptions);
    } else {
      ReactNativeHapticFeedback.trigger('clockTick', hapticOptions);
    }
  };

  return {
    light: triggerLight,
    medium: triggerMedium,
    heavy: triggerHeavy,
    success: triggerSuccess,
    warning: triggerWarning,
    error: triggerError,
    selection: triggerSelection,
  };
};

export default useHaptic;
