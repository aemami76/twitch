import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twich_clone/resource/firestore_meth.dart';
import 'package:twich_clone/screens/broadcast_screen.dart';

class GoliveScreen extends StatefulWidget {
  const GoliveScreen({super.key});

  @override
  State<GoliveScreen> createState() => _GoliveScreenState();
}

class _GoliveScreenState extends State<GoliveScreen> {
  final controller = TextEditingController();
  late String channelName;
  late String channelTitle;
  XFile? xFile;

  getPic() async {
    var xfile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (xfile == null) {
      return;
    }
    setState(() {
      xFile = xfile;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                onTap: getPic,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  color: Colors.deepPurple,
                  dashPattern: const [10, 10],
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  radius: const Radius.circular(24),
                  child: Container(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height / 4,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.purpleAccent.withOpacity(0.1),
                      ),
                      child: xFile == null
                          ? const Opacity(
                              opacity: 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_in_picture,
                                    size: 80,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Select your Thubnail',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            )
                          : Image.file(
                              File(xFile!.path),
                              fit: BoxFit.fill,
                            )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.purple, width: 2))),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: (xFile == null && controller.text.isEmpty)
                      ? null
                      : () async {
                          channelTitle = controller.text;
                          await FireStoreMeth()
                              .startStream(controller.text, xFile!)
                              .then((value) => channelName = value);
                          if (channelName.isNotEmpty && mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BroadcastScreen(
                                          isBroadcaster: true,
                                          channelName: channelName,
                                          channelTitle: channelTitle,
                                        )));
                          }
                          controller.text = '';
                          setState(() {
                            xFile = null;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Go Live',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
