import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen
    extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _emailController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
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
                '✅ تم تسجيل الدخول بنجاح')),
      );
      Navigator.pushReplacementNamed(
          context, '/');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message =
            '❌ لا يوجد مستخدم بهذا البريد';
      } else if (e.code ==
          'wrong-password') {
        message =
            '❌ كلمة المرور غير صحيحة';
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
        title:
            const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              const SizedBox(
                  height: 50),
              TextFormField(
                controller:
                    _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                ),
                keyboardType:
                    TextInputType
                        .emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => (v==null || v.trim().isEmpty) ? 'أدخل البريد الإلكتروني' : null,
              ),
              const SizedBox(
                  height: 20),
              TextFormField(
                controller:
                    _passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (_formKey.currentState?.validate() ?? false) {
                    _loginUser();
                  }
                },
                validator: (v) => (v==null || v.trim().isEmpty) ? 'أدخل كلمة المرور' : null,
              ),
              const SizedBox(
                  height: 30),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _loginUser();
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white)
                    : const Text(
                        'تسجيل الدخول'),
              ),
              const SizedBox(
                  height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Text(
                      'ليس لديك حساب؟'),
                  TextButton(
                    onPressed: () {
                      Navigator
                          .pushNamed(
                              context,
                              '/signup');
                    },
                    child: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                          color: Colors
                              .blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
