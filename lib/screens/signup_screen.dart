import 'package:flutter/material.dart';
import 'package:twich_clone/resource/auth_meth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pController = TextEditingController();
  final _uController = TextEditingController();
  final _eController = TextEditingController();
  bool isEnabled = false;

  @override
  void dispose() {
    _pController.dispose();
    _uController.dispose();
    _eController.dispose();
    super.dispose();
  }

  void changeController() {
    if (_pController.text.isNotEmpty &&
        _uController.text.isNotEmpty &&
        _eController.text.isNotEmpty) {
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
        title: const Text('Sign up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _eController,
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
              controller: _uController,
              onChanged: (_) => changeController(),
              decoration: const InputDecoration(
                  labelText: 'Username',
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
                onPressed: isEnabled
                    ? () async {
                        await AuthMeth().signup(_uController.text,
                            _eController.text, _pController.text);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign up',
                    style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
    );
  }
}
