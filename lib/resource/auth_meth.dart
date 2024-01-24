import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twich_clone/model/my_user.dart';

class AuthMeth {
  Future<void> setInstance() async {
    if (FirebaseAuth.instance.currentUser != null) {
      var uid = FirebaseAuth.instance.currentUser!.uid;
      var snap =
          await FirebaseFirestore.instance.collection('tusers').doc(uid).get();
      var map = snap.data()!;
      MyUser.instance = MyUser(
          email: map['email'], username: map['username'], uid: map['uid']);
    }
  }

  Future<void> signup(String username, String email, String password) async {
    try {
      var cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      var uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('tusers').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
      });

      await signin(email, password);
    } catch (e) {
      print(e);
    }
  }

  Future<void> signin(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await setInstance();
    } catch (e) {
      print(e);
    }
  }
}
