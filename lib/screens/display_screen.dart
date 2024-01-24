import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as ago;
import 'package:twich_clone/model/my_stream.dart';
import 'package:twich_clone/screens/broadcast_screen.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Streams',
        ),
        backgroundColor: Colors.purple[200],
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('lives')
                .orderBy('started', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (!snapshot.hasData || snapshot.data!.size == 0) {
                return const Center(
                  child: Text(
                    'Nothing Available!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) {
                      MyStream post =
                          MyStream.fromMap(snapshot.data!.docs[index].data());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BroadcastScreen(
                                  isBroadcaster: false,
                                  channelName: post.channel,
                                  channelTitle: post.title,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height / 5,
                              width: MediaQuery.sizeOf(context).width,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width / 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          post.url,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          post.username,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        Text('viewers: ${post.viewers}'),
                                        Text(
                                            'started at ${ago.format(post.started.toDate())}'),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              }
            }),
      ),
    ));
  }
}
