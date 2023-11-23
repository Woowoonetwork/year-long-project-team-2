import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addDocument({
  required String collectionName,
  required String filename,
  required List<String> fieldNames,
  required List<dynamic> fieldValues,
}) async {
  try {
    // Create a reference to the Firestore collection
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collectionName);

    // Create a map with field names and corresponding values
    Map<String, dynamic> data = {};
    for (int i = 0; i < fieldNames.length; i++) {
      data[fieldNames[i]] = fieldValues[i];
    }

    // Add the document to the collection
    await collectionReference.doc(filename).set(data);

    print('Document added successfully!');
  } catch (e) {
    print('Error adding document: $e');
  }
}