import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/styles.dart';
import 'package:sonique/utils/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String pass = '';
  bool _passwordVisible = false;

  Future<void> _loginErrorDialogBuilder(String title, String content) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.w_background,
      appBar: AppBar(
        title: Container(
          height: 20,
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        backgroundColor: AppColors.w_background,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log in', style: AppTextStyles.welcomeTitle),
                Form(
                  key: _formKey,
                  child: Column(
                    spacing: 15,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: AppColors.w_box,
                          filled: true,
                          border: AppBorders.formBorder,
                          focusedBorder: AppBorders.focusedFormBorder,
                        ),
                        style: AppTextStyles.welcomeSmall,
                        validator: (value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return 'E-mail cannot be empty';
                            }
                            if (!EmailValidator.validate(value)) {
                              return 'E-mail not valid';
                            }
                          }
                        },
                        onSaved: (value) {
                          email = value ?? '';
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: !_passwordVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: AppColors.w_box,
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          border: AppBorders.formBorder,
                          focusedBorder: AppBorders.focusedFormBorder,
                        ),
                        style: AppTextStyles.welcomeSmall,
                        validator: (value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            if (value.length < 6) {
                              return 'Password must contain at least 6 characters';
                            }
                          }
                        },
                        onSaved: (value) {
                          pass = value ?? '';
                        },
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Forgot your password?',
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            print('this fool forgot their password lmao');
                          },
                    style: AppTextStyles.welcomeSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: WelcomeButton(
                text: 'Log In',
                inverted: true,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Email $email Password $pass');
                    _formKey.currentState!.save();
                    print('Email $email Password $pass');
                    setState(() {
                      Navigator.pushNamed(context, '/home');
                    });
                  } else {
                    _loginErrorDialogBuilder(
                      'Form Error',
                      'Your form is invalid',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
