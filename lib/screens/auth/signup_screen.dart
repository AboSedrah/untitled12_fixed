import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen
    extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState
    extends State<SignUpScreen> {
  final _emailController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text
            .trim(),
        password: _passwordController
            .text
            .trim(),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content: Text(
                '✅ تم إنشاء الحساب بنجاح')),
      );

      // يمكنك توجيه المستخدم مباشرةً إلى الصفحة الرئيسية أو شاشة تسجيل الدخول
      Navigator.pushReplacementNamed(
          context, '/login');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message =
            '❌ كلمة المرور ضعيفة.';
      } else if (e.code ==
          'email-already-in-use') {
        message =
            '❌ البريد الإلكتروني مستخدم بالفعل.';
      } else if (e.code ==
          'invalid-email') {
        message =
            '❌ البريد الإلكتروني غير صالح.';
      } else {
        message = '❌ خطأ: ${e.message}';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
            content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              const SizedBox(
                  height: 50),
              TextField(
                controller:
                    _emailController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'البريد الإلكتروني',
                  border:
                      OutlineInputBorder(),
                ),
                keyboardType:
                    TextInputType
                        .emailAddress,
              ),
              const SizedBox(
                  height: 20),
              TextField(
                controller:
                    _passwordController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'كلمة المرور',
                  border:
                      OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(
                  height: 30),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _signUpUser,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white)
                    : const Text(
                        'إنشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
