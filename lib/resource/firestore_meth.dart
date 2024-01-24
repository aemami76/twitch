import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twich_clone/model/my_user.dart';

class FireStoreMeth {
  final MyUser _user = MyUser.instance!;

  Future<String> _uploadToStorage(XFile xFile) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('live-thumbnail')
          .child(_user.uid);
      TaskSnapshot snap = await ref.putFile(File(xFile.path));
      String url = await snap.ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  Future<String> startStream(String title, XFile xFile) async {
    String channelName = '';
    try {
      bool streamExisted = (await FirebaseFirestore.instance
              .collection('lives')
              .doc(_user.uid)
              .get())
          .exists;
      if (title.isNotEmpty && !streamExisted) {
        String url = await _uploadToStorage(xFile);
        channelName = _user.uid;
        await FirebaseFirestore.instance
            .collection('lives')
            .doc(_user.uid)
            .set({
          'title': title,
          'channel': channelName,
          'username': _user.username,
          'url': url,
          'viewers': 0,
          'started': DateTime.now()
        });
      }
    } catch (e) {
      print(e.toString());
    }
    return channelName;
  }

  Future<void> endLiveStream() async {
    try {
      await FirebaseFirestore.instance
          .collection('lives')
          .doc(_user.uid)
          .delete();

      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('lives')
          .doc(_user.uid)
          .collection('comments')
          .get();
      for (QueryDocumentSnapshot doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateViewCount(String channelId, bool isIncrease) async {
    try {
      await FirebaseFirestore.instance
          .collection('lives')
          .doc(channelId)
          .update({
        'viewers': FieldValue.increment(isIncrease ? 1 : -1),
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
