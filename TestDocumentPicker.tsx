import React from 'react';
import { View, Button, Alert } from 'react-native';
import { pick, types, isErrorWithCode, errorCodes } from '@react-native-documents/picker';

const TestDocumentPicker: React.FC = () => {
  const pickDocument = async () => {
    try {
      console.log('DocumentPicker pick function:', pick);
      console.log('DocumentPicker types:', types);
      
      const result = await pick({
        type: [types.allFiles],
        allowMultiSelection: false,
      });
      
      console.log('Picked document:', result);
      Alert.alert('Success', `Document picked: ${result[0].name}`);
    } catch (error: any) {
      if (isErrorWithCode(error) && error.code === errorCodes.OPERATION_CANCELED) {
        console.log('User cancelled document picker');
      } else {
        console.error('DocumentPicker error:', error);
        Alert.alert('Error', `Failed to pick document: ${error?.message || 'Unknown error'}`);
      }
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <Button title="Test Document Picker" onPress={pickDocument} />
    </View>
  );
};

export default TestDocumentPicker;
