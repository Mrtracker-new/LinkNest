import React, { useState } from 'react';
import { StyleSheet, View, ScrollView, Alert, Linking } from 'react-native';
import { List, Switch, Divider, Button, Dialog, Portal, Text, useTheme } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { RootStackParamList } from '../navigation';
import { useApp, AppProvider } from '../context/AppContext';
import { useThemeContext } from '../context/ThemeContext';

type SettingsScreenNavigationProp = NativeStackNavigationProp<RootStackParamList>;

const SettingsScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation<SettingsScreenNavigationProp>();
  const { links, notes, documents, isLoading, resetAppData } = useApp();
  
  // Get theme context
  const { isDarkMode, toggleDarkMode } = useThemeContext();
  
  // Settings state
  const [notificationsEnabled, setNotificationsEnabled] = useState(false);
  const [confirmDeleteDialogVisible, setConfirmDeleteDialogVisible] = useState(false);
  const [aboutDialogVisible, setAboutDialogVisible] = useState(false);

  // Handle dark mode toggle
  const handleDarkModeToggle = () => {
    toggleDarkMode();
  };

  // Handle notifications toggle
  const handleNotificationsToggle = () => {
    setNotificationsEnabled(!notificationsEnabled);
    // In a real app, you would update notification settings here
  };

  // Handle clear all data
  const handleClearAllData = () => {
    setConfirmDeleteDialogVisible(true);
  };

  // Confirm clear all data
  const confirmClearAllData = async () => {
    try {
      // Use the resetAppData function from AppContext
      const success = await resetAppData();
      
      // Close dialog
      setConfirmDeleteDialogVisible(false);
      
      if (success) {
        // Show success message
        Alert.alert(
          'Success',
          'All data has been reset to defaults.',
          [{ 
            text: 'OK',
            onPress: () => {
              // Reset navigation stack to Main navigator
              navigation.reset({
                index: 0,
                routes: [{ name: 'Main' }],
              });
            }
          }]
        );
      } else {
        Alert.alert('Error', 'Failed to reset data. Please try again.');
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to reset data. Please try again.');
      console.error('Error resetting data:', error);
    }
  };

  // Handle rate app
  const handleRateApp = () => {
    // In a real app, you would open the app store page
    Linking.openURL('https://play.google.com/store');
  };

  // Handle send feedback
  const handleSendFeedback = () => {
    // In a real app, you would open an email client
    Linking.openURL('mailto:support@linknest.app');
  };

  // Calculate storage usage
  const calculateStorageUsage = () => {
    const linksCount = links.length;
    const notesCount = notes.length;
    const documentsCount = documents.length;
    const totalItems = linksCount + notesCount + documentsCount;
    
    return {
      linksCount,
      notesCount,
      documentsCount,
      totalItems,
    };
  };

  const { linksCount, notesCount, documentsCount, totalItems } = calculateStorageUsage();

  return (
    <View style={styles.container}>
      <ScrollView>
        <List.Section>
          <List.Subheader>Appearance</List.Subheader>
          <List.Item
            title="Dark Mode"
            description="Enable dark mode for the app"
            left={(props) => <List.Icon {...props} icon="theme-light-dark" />}
            right={() => (
              <Switch
                value={isDarkMode}
                onValueChange={handleDarkModeToggle}
                color={theme.colors.primary}
              />
            )}
          />
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>Notifications</List.Subheader>
          <List.Item
            title="Enable Notifications"
            description="Receive notifications for reminders and updates"
            left={(props) => <List.Icon {...props} icon="bell" />}
            right={() => (
              <Switch
                value={notificationsEnabled}
                onValueChange={handleNotificationsToggle}
                color={theme.colors.primary}
              />
            )}
          />
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>Data Management</List.Subheader>
          <List.Item
            title="Categories"
            description="Manage your categories"
            left={(props) => <List.Icon {...props} icon="folder" />}
            onPress={() => navigation.navigate('Categories')}
          />
          <List.Item
            title="Tags"
            description="Manage your tags"
            left={(props) => <List.Icon {...props} icon="tag" />}
            onPress={() => navigation.navigate('Tags')}
          />
          <List.Item
            title="Storage Usage"
            description={`${totalItems} items (${linksCount} links, ${notesCount} notes, ${documentsCount} documents)`}
            left={(props) => <List.Icon {...props} icon="database" />}
          />
          <List.Item
            title="Clear All Data"
            description="Delete all your data from this device"
            left={(props) => <List.Icon {...props} icon="delete" color={theme.colors.error} />}
            onPress={handleClearAllData}
            titleStyle={{ color: theme.colors.error }}
            descriptionStyle={{ color: theme.colors.error }}
          />
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>About</List.Subheader>
          <List.Item
            title="About LinkNest"
            description="Learn more about the app"
            left={(props) => <List.Icon {...props} icon="information" />}
            onPress={() => setAboutDialogVisible(true)}
          />
          <List.Item
            title="Rate App"
            description="Rate us on the Play Store"
            left={(props) => <List.Icon {...props} icon="star" />}
            onPress={handleRateApp}
          />
          <List.Item
            title="Send Feedback"
            description="Help us improve the app"
            left={(props) => <List.Icon {...props} icon="email" />}
            onPress={handleSendFeedback}
          />
          <List.Item
            title="Version"
            description="1.0.0"
            left={(props) => <List.Icon {...props} icon="cellphone-information" />}
          />
        </List.Section>
      </ScrollView>

      {/* Confirm Delete Dialog */}
      <Portal>
        <Dialog
          visible={confirmDeleteDialogVisible}
          onDismiss={() => setConfirmDeleteDialogVisible(false)}
        >
          <Dialog.Title>Clear All Data</Dialog.Title>
          <Dialog.Content>
            <Text variant="bodyMedium">
              Are you sure you want to clear all data? This action cannot be undone and will delete all your links, notes, files, categories, and tags.
            </Text>
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setConfirmDeleteDialogVisible(false)}>Cancel</Button>
            <Button onPress={confirmClearAllData} textColor={theme.colors.error}>Clear All Data</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>

      {/* About Dialog */}
      <Portal>
        <Dialog
          visible={aboutDialogVisible}
          onDismiss={() => setAboutDialogVisible(false)}
        >
          <Dialog.Title>About LinkNest</Dialog.Title>
          <Dialog.Content>
            <Text variant="bodyMedium" style={styles.aboutText}>
              LinkNest is a powerful link organizer app that helps you store and organize your links, notes, and files locally on your device.
            </Text>
            <Text variant="bodyMedium" style={styles.aboutText}>
              Features:
            </Text>
            <Text variant="bodyMedium" style={styles.aboutListItem}>
              • Store links with titles, descriptions, and categories
            </Text>
            <Text variant="bodyMedium" style={styles.aboutListItem}>
              • Organize with customizable categories and tags
            </Text>
            <Text variant="bodyMedium" style={styles.aboutListItem}>
              • Take notes and store documents locally
            </Text>
            <Text variant="bodyMedium" style={styles.aboutListItem}>
              • Organize documents with categories and tags
            </Text>
            <Text variant="bodyMedium" style={styles.aboutListItem}>
              • No cloud account required - all data stays on your device
            </Text>
            <Text variant="bodyMedium" style={styles.aboutText}>
              Developed with ❤️ by Rolan Lobo
            </Text>
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setAboutDialogVisible(false)}>Close</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  aboutText: {
    marginBottom: 12,
  },
  aboutListItem: {
    marginBottom: 8,
    marginLeft: 8,
  },
});

export default SettingsScreen;