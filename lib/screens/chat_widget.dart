import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as ago;

import '../model/my_user.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({required this.channelName, super.key});
  final String channelName;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final controller = TextEditingController();
  final user = MyUser.instance!;

  sendMessage(String text) async {
    try {
      if (text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('lives')
            .doc(widget.channelName)
            .collection('comments')
            .doc(DateTime.now().toString())
            .set({
          'date': DateTime.now(),
          'text': text,
          'username': user.username
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('lives')
                    .doc(widget.channelName)
                    .collection('comments')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data!.size,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(8),
                            elevation: 5,
                            child: ListTile(
                              trailing: Text(ago.format(((snapshot
                                      .data!.docs[index]['date']) as Timestamp)
                                  .toDate())),
                              title: Text(
                                snapshot.data!.docs[index]['username'] + ' :',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue[900]),
                              ),
                              subtitle: Text(
                                  '  ${snapshot.data!.docs[index]['text']}'),
                            ),
                          );
                        });
                  }
                }),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: 'share your message',
                      disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple, width: 2)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple, width: 2))),
                ),
              ),
              SizedBox(
                  width: 80,
                  child: TextButton(
                      onPressed: () async {
                        await sendMessage(controller.text);
                        controller.text = '';
                      },
                      child: const Text(
                        'Share',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.purpleAccent),
                      ))),
            ],
          ),
        ),
      ],
    );
  }
}
