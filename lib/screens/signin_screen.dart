import 'package:flutter/material.dart';
import 'package:twich_clone/model/my_user.dart';
import 'package:twich_clone/resource/auth_meth.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _pController = TextEditingController();
  final _uController = TextEditingController();
  bool isEnabled = false;
  @override
  void dispose() {
    _pController.dispose();
    _uController.dispose();
    super.dispose();
  }

  void changeController() {
    if (_pController.text.isNotEmpty && _uController.text.isNotEmpty) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _uController,
              onChanged: (_) => changeController(),
              decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2))),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _pController,
              onChanged: (_) => changeController(),
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2))),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
                onPressed: !isEnabled
                    ? null
                    : () async {
                        await AuthMeth()
                            .signin(_uController.text, _pController.text);
                        if (mounted && MyUser.instance != null) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign in',
                    style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
    );
  }
}
