import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/styles.dart';
import 'package:sonique/utils/widgets.dart';
import 'package:sonique/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
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
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: AppColors.button,
                          filled: true,
                          border: AppBorders.formBorder,
                          focusedBorder: AppBorders.focusedFormBorder,
                        ),
                        style: AppTextStyles.welcomeSmall,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          return null;
                        },
                        onSaved: (value) => email = value ?? '',
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
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            } else if (value.length < 6) {
                              return 'Password must contain at least 6 characters';
                            }
                            return null;
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
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    _formKey.currentState!.save();

                    try{
                      final user = await AuthService().logIn(email, pass);

                      if(user != null){
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/mainNavigator',
                              (Route<dynamic> route) => false,
                        );
                      }
                    }
                    catch (e) {
                      _loginErrorDialogBuilder(
                          'Login Failed',
                          e.toString().replaceAll('Exception:', '').trim()
                      );
                    }
                  }
                  else {
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
