import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/Models/ServiceModels/Message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUserStream() {
    return _firestore.collection('user').snapshots();
  }

  Future<void> sendMessage(String receiverID, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String conversationID = ids.join('_');

    await _firestore
        .collection("conversations")
        .doc(conversationID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String conversationID = ids.join('_');

    return _firestore
        .collection("conversations")
        .doc(conversationID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
  getReceiverData(String receiverID) {
    return _firestore.collection('user').doc(receiverID).get();
  }
}
