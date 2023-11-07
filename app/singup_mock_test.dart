import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  test('Firestore add and read data', () async {
    // Create a fake instance of Firestore
    final instance = FakeFirebaseFirestore();

    // Use the fake Firestore instance in place of the real one
    FirebaseFirestore.instanceFor(app: instance);

    // Add data to Firestore
    await FirebaseFirestore.instance.collection('items').add({
      'name': 'Test Item',
      'quantity': 5,
    });

    // Retrieve the data from Firestore
    final snapshot = await FirebaseFirestore.instance.collection('items').get();

    // Verify that the data was added and can be read
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first['name'], 'Test Item');
    expect(snapshot.docs.first['quantity'], 5);
  });
}
