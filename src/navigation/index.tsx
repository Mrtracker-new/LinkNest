import React from 'react';
import { NavigationContainer, NavigatorScreenParams } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useTheme } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

// Import screens (will create these next)
import HomeScreen from '../screens/HomeScreen';
import LinksScreen from '../screens/LinksScreen';
import NotesScreen from '../screens/NotesScreen';
import DocumentsScreen from '../screens/DocumentsScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AddLinkScreen from '../screens/AddLinkScreen';
import EditLinkScreen from '../screens/EditLinkScreen';
import LinkDetailsScreen from '../screens/LinkDetailsScreen';
import AddNoteScreen from '../screens/AddNoteScreen';
import EditNoteScreen from '../screens/EditNoteScreen';
import NoteDetailsScreen from '../screens/NoteDetailsScreen';
import AddDocumentScreen from '../screens/AddDocumentScreen';
import DocumentDetailsScreen from '../screens/DocumentDetailsScreen';
import CategoriesScreen from '../screens/CategoriesScreen';
import TagsScreen from '../screens/TagsScreen';

// Define navigation types

export type RootStackParamList = {
  Main: NavigatorScreenParams<MainTabParamList>;
  AddLink: undefined;
  EditLink: { id: string };
  LinkDetails: { id: string };
  AddNote: undefined;
  EditNote: { id: string };
  NoteDetails: { id: string };
  AddDocument: undefined;
  DocumentDetails: { id: string };
  Categories: undefined;
  Tags: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Links: { categoryId?: string };
  Notes: { categoryId?: string };
  Documents: { categoryId?: string };
  Settings: undefined;
};

// Create navigators
const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

// Main tab navigator
const MainTabNavigator = () => {
  const theme = useTheme();

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName = '';

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Links') {
            iconName = focused ? 'link-variant' : 'link-variant-outline';
          } else if (route.name === 'Notes') {
            iconName = focused ? 'note-text' : 'note-text-outline';
          } else if (route.name === 'Documents') {
            iconName = focused ? 'file-document' : 'file-document-outline';
          } else if (route.name === 'Settings') {
            iconName = focused ? 'cog' : 'cog-outline';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.outline,
        tabBarStyle: {
          backgroundColor: theme.colors.surface,
          borderTopColor: theme.colors.surfaceVariant,
          elevation: 8,
          height: 60,
          paddingBottom: 8,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
        headerShown: false,
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Links" component={LinksScreen} />
      <Tab.Screen name="Notes" component={NotesScreen} />
      <Tab.Screen name="Documents" component={DocumentsScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
};

// Root stack navigator
const AppNavigator = () => {
  const theme = useTheme();

  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: theme.colors.surface,
        },
        headerTintColor: theme.colors.onSurface,
        headerShadowVisible: false,
        contentStyle: {
          backgroundColor: theme.colors.background,
        },
      }}
    >
        <Stack.Screen
          name="Main"
          component={MainTabNavigator}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="AddLink"
          component={AddLinkScreen}
          options={{ title: 'Add Link' }}
        />
        <Stack.Screen
          name="EditLink"
          component={EditLinkScreen}
          options={{ title: 'Edit Link' }}
        />
        <Stack.Screen
          name="LinkDetails"
          component={LinkDetailsScreen}
          options={{ title: 'Link Details' }}
        />
        <Stack.Screen
          name="AddNote"
          component={AddNoteScreen}
          options={{ title: 'Add Note' }}
        />
        <Stack.Screen
          name="EditNote"
          component={EditNoteScreen}
          options={{ title: 'Edit Note' }}
        />
        <Stack.Screen
          name="NoteDetails"
          component={NoteDetailsScreen}
          options={{ title: 'Note Details' }}
        />
        <Stack.Screen
          name="Categories"
          component={CategoriesScreen}
          options={{ title: 'Categories' }}
        />
        <Stack.Screen
          name="Tags"
          component={TagsScreen}
          options={{ title: 'Tags' }}
        />
        <Stack.Screen
          name="AddDocument"
          component={AddDocumentScreen}
          options={{ title: 'Add Document' }}
        />
        <Stack.Screen
          name="DocumentDetails"
          component={DocumentDetailsScreen}
          options={{ title: 'Document Details' }}
        />
      </Stack.Navigator>
  );
};

export default AppNavigator;