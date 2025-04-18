import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/styles.dart';
import 'package:sonique/utils/widgets.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupFormKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  String email = '';
  String pass = '';

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
      appBar: myAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sign Up', style: AppTextStyles.welcomeTitle),
                Form(
                  key: _signupFormKey,
                  child: Column(
                    spacing: 15,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: AppColors.button,
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
                        decoration: InputDecoration(
                          labelText: 'Username',
                          fillColor: AppColors.button,
                          filled: true,
                          border: AppBorders.formBorder,
                          focusedBorder: AppBorders.focusedFormBorder,
                        ),
                        style: AppTextStyles.welcomeSmall,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: !_passwordVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: AppColors.button,
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: WelcomeButton(
                text: 'Sign Up',
                inverted: true,
                onPressed: () {
                  if (_signupFormKey.currentState!.validate()) {
                    print('Email $email Password $pass');
                    _signupFormKey.currentState!.save();
                    print('Email $email Password $pass');
                    setState(() {
                      print('signup successful');
                      Navigator.pushNamed(context, '/');
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
