import React, { createContext, useContext, useEffect, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useColorScheme, Platform } from 'react-native';
import uuid from 'react-native-uuid';
import RNFS from 'react-native-fs';
import { Link, Category, Tag, Note, Document } from '../types';

interface AppContextType {
  // Data
  links: Link[];
  categories: Category[];
  tags: Tag[];
  notes: Note[];
  documents: Document[];
  
  // Link operations
  addLink: (link: Omit<Link, 'id' | 'createdAt' | 'updatedAt'>) => Promise<Link>;
  updateLink: (id: string, link: Partial<Link>) => Promise<Link | null>;
  deleteLink: (id: string) => Promise<boolean>;
  toggleFavoriteLink: (id: string) => Promise<Link | null>;
  
  // Category operations
  addCategory: (category: Omit<Category, 'id' | 'createdAt'>) => Promise<Category>;
  updateCategory: (id: string, category: Partial<Category>) => Promise<Category | null>;
  deleteCategory: (id: string) => Promise<boolean>;
  
  // Tag operations
  addTag: (tag: Omit<Tag, 'id' | 'createdAt'>) => Promise<Tag>;
  updateTag: (id: string, tag: Partial<Tag>) => Promise<Tag | null>;
  deleteTag: (id: string) => Promise<boolean>;
  
  // Note operations
  addNote: (note: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>) => Promise<Note>;
  updateNote: (id: string, note: Partial<Note>) => Promise<Note | null>;
  deleteNote: (id: string) => Promise<boolean>;
  toggleFavoriteNote: (id: string) => Promise<Note | null>;
  
  // Document operations
  addDocument: (document: Omit<Document, 'id' | 'createdAt' | 'updatedAt'>) => Promise<Document>;
  updateDocument: (id: string, document: Partial<Document>) => Promise<Document | null>;
  deleteDocument: (id: string) => Promise<boolean>;
  toggleFavoriteDocument: (id: string) => Promise<Document | null>;
  
  // App operations
  resetAppData: () => Promise<boolean>;
  
  // Loading state
  isLoading: boolean;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

// Storage keys
const LINKS_STORAGE_KEY = '@linknest:links';
const CATEGORIES_STORAGE_KEY = '@linknest:categories';
const TAGS_STORAGE_KEY = '@linknest:tags';
const NOTES_STORAGE_KEY = '@linknest:notes';
const DOCUMENTS_STORAGE_KEY = '@linknest:documents';

// Document storage directory
const DOCUMENTS_DIR = Platform.OS === 'ios' 
  ? `${RNFS.DocumentDirectoryPath}/LinkNestDocuments` 
  : `${RNFS.ExternalDirectoryPath}/LinkNestDocuments`;

// Default categories
const DEFAULT_CATEGORIES: Category[] = [
  {
    id: uuid.v4() as string,
    name: 'Work',
    color: '#4285F4',
    icon: 'briefcase',
    createdAt: Date.now(),
  },
  {
    id: uuid.v4() as string,
    name: 'Personal',
    color: '#EA4335',
    icon: 'person',
    createdAt: Date.now(),
  },
  {
    id: uuid.v4() as string,
    name: 'Education',
    color: '#FBBC05',
    icon: 'school',
    createdAt: Date.now(),
  },
  {
    id: uuid.v4() as string,
    name: 'Entertainment',
    color: '#34A853',
    icon: 'play',
    createdAt: Date.now(),
  },
];

// Default tags
const DEFAULT_TAGS: Tag[] = [
  {
    id: uuid.v4() as string,
    name: 'Important',
    color: '#FF5252',
    createdAt: Date.now(),
  },
  {
    id: uuid.v4() as string,
    name: 'Reference',
    color: '#448AFF',
    createdAt: Date.now(),
  },
  {
    id: uuid.v4() as string,
    name: 'Tutorial',
    color: '#9C27B0',
    createdAt: Date.now(),
  },
];

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // State
  const [links, setLinks] = useState<Link[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [tags, setTags] = useState<Tag[]>([]);
  const [notes, setNotes] = useState<Note[]>([]);
  const [documents, setDocuments] = useState<Document[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Load data from AsyncStorage
  useEffect(() => {
    const loadData = async () => {
      try {
        // Create documents directory if it doesn't exist
        const dirExists = await RNFS.exists(DOCUMENTS_DIR);
        if (!dirExists) {
          await RNFS.mkdir(DOCUMENTS_DIR);
        }
        
        // Load links
        const linksData = await AsyncStorage.getItem(LINKS_STORAGE_KEY);
        if (linksData) {
          setLinks(JSON.parse(linksData));
        }

        // Load or initialize categories
        const categoriesData = await AsyncStorage.getItem(CATEGORIES_STORAGE_KEY);
        if (categoriesData) {
          setCategories(JSON.parse(categoriesData));
        } else {
          // Initialize with default categories
          setCategories(DEFAULT_CATEGORIES);
          await AsyncStorage.setItem(CATEGORIES_STORAGE_KEY, JSON.stringify(DEFAULT_CATEGORIES));
        }

        // Load or initialize tags
        const tagsData = await AsyncStorage.getItem(TAGS_STORAGE_KEY);
        if (tagsData) {
          setTags(JSON.parse(tagsData));
        } else {
          // Initialize with default tags
          setTags(DEFAULT_TAGS);
          await AsyncStorage.setItem(TAGS_STORAGE_KEY, JSON.stringify(DEFAULT_TAGS));
        }

        // Load notes
        const notesData = await AsyncStorage.getItem(NOTES_STORAGE_KEY);
        if (notesData) {
          setNotes(JSON.parse(notesData));
        }
        
        // Load documents
        const documentsData = await AsyncStorage.getItem(DOCUMENTS_STORAGE_KEY);
        if (documentsData) {
          setDocuments(JSON.parse(documentsData));
        }
      } catch (error) {
        console.error('Error loading data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadData();
  }, []);

  // Save data to AsyncStorage whenever it changes
  useEffect(() => {
    const saveLinks = async () => {
      if (!isLoading) {
        await AsyncStorage.setItem(LINKS_STORAGE_KEY, JSON.stringify(links));
      }
    };
    saveLinks();
  }, [links, isLoading]);

  useEffect(() => {
    const saveCategories = async () => {
      if (!isLoading) {
        await AsyncStorage.setItem(CATEGORIES_STORAGE_KEY, JSON.stringify(categories));
      }
    };
    saveCategories();
  }, [categories, isLoading]);

  useEffect(() => {
    const saveTags = async () => {
      if (!isLoading) {
        await AsyncStorage.setItem(TAGS_STORAGE_KEY, JSON.stringify(tags));
      }
    };
    saveTags();
  }, [tags, isLoading]);

  useEffect(() => {
    const saveNotes = async () => {
      if (!isLoading) {
        await AsyncStorage.setItem(NOTES_STORAGE_KEY, JSON.stringify(notes));
      }
    };
    saveNotes();
  }, [notes, isLoading]);
  
  useEffect(() => {
    const saveDocuments = async () => {
      if (!isLoading) {
        await AsyncStorage.setItem(DOCUMENTS_STORAGE_KEY, JSON.stringify(documents));
      }
    };
    saveDocuments();
  }, [documents, isLoading]);



  // Link operations
  const addLink = async (linkData: Omit<Link, 'id' | 'createdAt' | 'updatedAt'>): Promise<Link> => {
    const timestamp = Date.now();
    const newLink: Link = {
      ...linkData,
      id: uuid.v4() as string,
      createdAt: timestamp,
      updatedAt: timestamp,
    };
    
    setLinks((prevLinks) => [...prevLinks, newLink]);
    return newLink;
  };

  const updateLink = async (id: string, linkData: Partial<Link>): Promise<Link | null> => {
    let updatedLink: Link | null = null;
    
    setLinks((prevLinks) => {
      const updatedLinks = prevLinks.map((link) => {
        if (link.id === id) {
          updatedLink = {
            ...link,
            ...linkData,
            updatedAt: Date.now(),
          };
          return updatedLink;
        }
        return link;
      });
      
      return updatedLinks;
    });
    
    return updatedLink;
  };

  const deleteLink = async (id: string): Promise<boolean> => {
    setLinks((prevLinks) => prevLinks.filter((link) => link.id !== id));
    return true;
  };

  const toggleFavoriteLink = async (id: string): Promise<Link | null> => {
    return updateLink(id, { isFavorite: !links.find((link) => link.id === id)?.isFavorite });
  };

  // Category operations
  const addCategory = async (categoryData: Omit<Category, 'id' | 'createdAt'>): Promise<Category> => {
    const newCategory: Category = {
      ...categoryData,
      id: uuid.v4() as string,
      createdAt: Date.now(),
    };
    
    setCategories((prevCategories) => [...prevCategories, newCategory]);
    return newCategory;
  };

  const updateCategory = async (id: string, categoryData: Partial<Category>): Promise<Category | null> => {
    let updatedCategory: Category | null = null;
    
    setCategories((prevCategories) => {
      const updatedCategories = prevCategories.map((category) => {
        if (category.id === id) {
          updatedCategory = {
            ...category,
            ...categoryData,
          };
          return updatedCategory;
        }
        return category;
      });
      
      return updatedCategories;
    });
    
    return updatedCategory;
  };

  const deleteCategory = async (id: string): Promise<boolean> => {
    setCategories((prevCategories) => prevCategories.filter((category) => category.id !== id));
    return true;
  };

  // Tag operations
  const addTag = async (tagData: Omit<Tag, 'id' | 'createdAt'>): Promise<Tag> => {
    const newTag: Tag = {
      ...tagData,
      id: uuid.v4() as string,
      createdAt: Date.now(),
    };
    
    setTags((prevTags) => [...prevTags, newTag]);
    return newTag;
  };

  const updateTag = async (id: string, tagData: Partial<Tag>): Promise<Tag | null> => {
    let updatedTag: Tag | null = null;
    
    setTags((prevTags) => {
      const updatedTags = prevTags.map((tag) => {
        if (tag.id === id) {
          updatedTag = {
            ...tag,
            ...tagData,
          };
          return updatedTag;
        }
        return tag;
      });
      
      return updatedTags;
    });
    
    return updatedTag;
  };

  const deleteTag = async (id: string): Promise<boolean> => {
    setTags((prevTags) => prevTags.filter((tag) => tag.id !== id));
    return true;
  };

  // Note operations
  const addNote = async (noteData: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>): Promise<Note> => {
    const timestamp = Date.now();
    const newNote: Note = {
      ...noteData,
      id: uuid.v4() as string,
      createdAt: timestamp,
      updatedAt: timestamp,
    };
    
    setNotes((prevNotes) => [...prevNotes, newNote]);
    return newNote;
  };

  const updateNote = async (id: string, noteData: Partial<Note>): Promise<Note | null> => {
    let updatedNote: Note | null = null;
    
    setNotes((prevNotes) => {
      const updatedNotes = prevNotes.map((note) => {
        if (note.id === id) {
          updatedNote = {
            ...note,
            ...noteData,
            updatedAt: Date.now(),
          };
          return updatedNote;
        }
        return note;
      });
      
      return updatedNotes;
    });
    
    return updatedNote;
  };

  const deleteNote = async (id: string): Promise<boolean> => {
    setNotes((prevNotes) => prevNotes.filter((note) => note.id !== id));
    return true;
  };

  const toggleFavoriteNote = async (id: string): Promise<Note | null> => {
    return updateNote(id, { isFavorite: !notes.find((note) => note.id === id)?.isFavorite });
  };
  
  // Document operations
  const addDocument = async (documentData: Omit<Document, 'id' | 'createdAt' | 'updatedAt'>): Promise<Document> => {
    const timestamp = Date.now();
    const newDocument: Document = {
      ...documentData,
      id: uuid.v4() as string,
      createdAt: timestamp,
      updatedAt: timestamp,
    };
    
    setDocuments((prevDocuments) => [...prevDocuments, newDocument]);
    return newDocument;
  };

  const updateDocument = async (id: string, documentData: Partial<Document>): Promise<Document | null> => {
    let updatedDocument: Document | null = null;
    
    setDocuments((prevDocuments) => {
      const updatedDocuments = prevDocuments.map((document) => {
        if (document.id === id) {
          updatedDocument = {
            ...document,
            ...documentData,
            updatedAt: Date.now(),
          };
          return updatedDocument;
        }
        return document;
      });
      
      return updatedDocuments;
    });
    
    return updatedDocument;
  };

  const deleteDocument = async (id: string): Promise<boolean> => {
    try {
      // Find the document to get its URI
      const document = documents.find(doc => doc.id === id);
      if (document && document.uri) {
        // Check if the file exists before attempting to delete
        const fileExists = await RNFS.exists(document.uri);
        if (fileExists) {
          await RNFS.unlink(document.uri);
        }
      }
      
      // Remove from state
      setDocuments((prevDocuments) => prevDocuments.filter((doc) => doc.id !== id));
      return true;
    } catch (error) {
      console.error('Error deleting document:', error);
      return false;
    }
  };

  const toggleFavoriteDocument = async (id: string): Promise<Document | null> => {
    return updateDocument(id, { isFavorite: !documents.find((doc) => doc.id === id)?.isFavorite });
  };



  // Reset all app data to defaults
  const resetAppData = async (): Promise<boolean> => {
    try {
      // Reset all state to initial values
      setLinks([]);
      setCategories(DEFAULT_CATEGORIES);
      setTags(DEFAULT_TAGS);
      setNotes([]);
      
      // Delete all document files
      for (const document of documents) {
        if (document.uri) {
          const fileExists = await RNFS.exists(document.uri);
          if (fileExists) {
            await RNFS.unlink(document.uri);
          }
        }
      }
      setDocuments([]);
      
      // Save default categories and tags to AsyncStorage
      await AsyncStorage.setItem(CATEGORIES_STORAGE_KEY, JSON.stringify(DEFAULT_CATEGORIES));
      await AsyncStorage.setItem(TAGS_STORAGE_KEY, JSON.stringify(DEFAULT_TAGS));
      
      // Clear other data
      await AsyncStorage.removeItem(LINKS_STORAGE_KEY);
      await AsyncStorage.removeItem(NOTES_STORAGE_KEY);
      await AsyncStorage.removeItem(DOCUMENTS_STORAGE_KEY);
      
      return true;
    } catch (error) {
      console.error('Error resetting app data:', error);
      return false;
    }
  };

  const value: AppContextType = {
    // Data
    links,
    categories,
    tags,
    notes,
    documents,
    
    // Link operations
    addLink,
    updateLink,
    deleteLink,
    toggleFavoriteLink,
    
    // Category operations
    addCategory,
    updateCategory,
    deleteCategory,
    
    // Tag operations
    addTag,
    updateTag,
    deleteTag,
    
    // Note operations
    addNote,
    updateNote,
    deleteNote,
    toggleFavoriteNote,
    
    // Document operations
    addDocument,
    updateDocument,
    deleteDocument,
    toggleFavoriteDocument,
    
    // App operations
    resetAppData,
    
    // Loading state
    isLoading,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
};

export const useApp = (): AppContextType => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};