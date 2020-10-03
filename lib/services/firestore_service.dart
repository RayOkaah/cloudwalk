import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudwalk/models/user.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');

  Future createUser(AppUser user) async {
    try {
      await _usersCollectionReference.doc(user.id).set(user.toJson());
    } catch (e) {
      return e.message;
    }
  }

  Future getUser(String uid) async {
    try {
      DocumentSnapshot user = await _usersCollectionReference.doc(uid).get();
      final userData = user.data();
      return AppUser.fromData(userData);
    } catch (e) {
      return e.message;
    }
  }
}
