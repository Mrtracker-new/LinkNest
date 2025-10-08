import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import { View, StyleSheet } from 'react-native';
import { Snackbar, useTheme, Text } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

type ToastType = 'success' | 'error' | 'warning' | 'info';

interface ToastConfig {
  message: string;
  type?: ToastType;
  duration?: number;
  action?: {
    label: string;
    onPress: () => void;
  };
}

interface ToastContextType {
  showToast: (config: ToastConfig) => void;
  hideToast: () => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within ToastProvider');
  }
  return context;
};

interface ToastProviderProps {
  children: ReactNode;
}

export const ToastProvider: React.FC<ToastProviderProps> = ({ children }) => {
  const theme = useTheme();
  const [visible, setVisible] = useState(false);
  const [message, setMessage] = useState('');
  const [type, setType] = useState<ToastType>('info');
  const [duration, setDuration] = useState(3000);
  const [action, setAction] = useState<ToastConfig['action']>(undefined);

  const showToast = useCallback((config: ToastConfig) => {
    setMessage(config.message);
    setType(config.type || 'info');
    setDuration(config.duration || 3000);
    setAction(config.action);
    setVisible(true);
  }, []);

  const hideToast = useCallback(() => {
    setVisible(false);
  }, []);

  const getIconName = () => {
    switch (type) {
      case 'success':
        return 'check-circle';
      case 'error':
        return 'alert-circle';
      case 'warning':
        return 'alert';
      case 'info':
      default:
        return 'information';
    }
  };

  const getIconColor = () => {
    switch (type) {
      case 'success':
        return '#4CAF50';
      case 'error':
        return '#F44336';
      case 'warning':
        return '#FF9800';
      case 'info':
      default:
        return theme.colors.primary;
    }
  };

  return (
    <ToastContext.Provider value={{ showToast, hideToast }}>
      {children}
      <Snackbar
        visible={visible}
        onDismiss={hideToast}
        duration={duration}
        action={action}
        style={{
          backgroundColor: theme.colors.surface,
        }}
        theme={{ colors: { surface: theme.colors.surface } }}
      >
        <View style={styles.toastContent}>
          <Icon
            name={getIconName()}
            size={20}
            color={getIconColor()}
            style={{ marginRight: 8 }}
          />
          <Text style={styles.toastText}>{message}</Text>
        </View>
      </Snackbar>
    </ToastContext.Provider>
  );
};

const styles = StyleSheet.create({
  toastContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  toastText: {
    flex: 1,
    fontSize: 14,
  },
});

export default useToast;
