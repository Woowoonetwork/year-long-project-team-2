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
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  getReceiverData(String receiverID) {
    return _firestore.collection('user').doc(receiverID).get();
  }

  Future<void> reactToMessage(
      String conversationID, String messageID, String reaction) async {
    final String currentUserID = _auth.currentUser!.uid;

    DocumentReference messageRef = _firestore
        .collection("conversations")
        .doc(conversationID)
        .collection("messages")
        .doc(messageID);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(messageRef);

      Map<String, dynamic> reactions =
          (snapshot.data() as Map<String, dynamic>).containsKey('reactions')
              ? (snapshot.get('reactions') as Map<String, dynamic>)
              : {};
      reactions[currentUserID] = reaction;
      transaction.update(messageRef, {'reactions': reactions});
    });
  }
  

  Stream<Map<String, dynamic>?> streamReactions(
      String conversationID, String messageID) {
    return _firestore
        .collection("conversations")
        .doc(conversationID)
        .collection("messages")
        .doc(messageID)
        .snapshots()
        .map((snapshot) =>
            (snapshot.data()?['reactions'] as Map<String, dynamic>?));
  }

  Future<Map<String, dynamic>?> getReactions(
      String conversationID, String messageID) async {
    DocumentSnapshot messageDoc = await _firestore
        .collection("conversations")
        .doc(conversationID)
        .collection("messages")
        .doc(messageID)
        .get();

    return (messageDoc.data() as Map<String, dynamic>?)?['reactions']
        as Map<String, dynamic>?;
  }
}
