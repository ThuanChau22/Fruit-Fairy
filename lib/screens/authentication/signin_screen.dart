import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/services/credential_service.dart';
import 'package:fruitfairy/services/validation.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

enum AuthMode { SignIn, Reset, Phone, VerifyCode }

class SignInScreen extends StatefulWidget {
  static const String id = 'signin_screen';
  static const String email = 'email';
  static const String password = 'password';
  static const String message = 'message';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _confirmCode = TextEditingController();

  String _isoCode = 'US';
  String _dialCode = '+1';

  String _emailError = '';
  String _passwordError = '';
  String _phoneError = '';
  String _confirmCodeError = '';

  AuthMode _mode = AuthMode.SignIn;
  String _appBarLabel = 'Sign In';
  String _buttonLabel = 'Sign In';

  bool _showSpinner = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  Future<String> Function(String smsCode) _verifyCode;

  void _getCredential() async {
    setState(() => _showSpinner = true);
    Map<String, String> credentials = await CredentialService.get();
    if (credentials.isNotEmpty) {
      setState(() {
        _email.text = credentials[CredentialService.kEmail];
        _password.text = credentials[CredentialService.kPassword];
        _phoneNumber.text = credentials[CredentialService.kPhone];
        _isoCode = credentials[CredentialService.kIsoCode];
        _dialCode = credentials[CredentialService.kDialCode];
        _rememberMe = true;
      });
    }
    setState(() => _showSpinner = false);
  }

  Future<bool> _validate() async {
    String errors = '';
    String email = _email.text.trim();
    String password = _password.text;
    switch (_mode) {
      case AuthMode.Reset:
        errors = _emailError = Validate.checkEmail(email);
        break;

      case AuthMode.Phone:
        errors = _phoneError = await Validate.phoneNumber(
          phoneNumber: _phoneNumber.text.trim(),
          isoCode: _isoCode,
        );
        break;

      case AuthMode.VerifyCode:
        errors = _confirmCodeError = Validate.checkConfirmCode(
          _confirmCode.text.trim(),
        );
        break;

      // Sign In Mode
      default:
        errors = _emailError = Validate.checkEmail(email);
        errors += _passwordError = Validate.checkPassword(password);
        break;
    }
    setState(() {});
    return errors.isEmpty;
  }

  void submit() async {
    if (await _validate()) {
      setState(() => _showSpinner = true);
      switch (_mode) {
        case AuthMode.Reset:
          String notifyMessage = '';
          try {
            FireAuthService auth = context.read<FireAuthService>();
            notifyMessage = await auth.resetPassword(_email.text.trim());
            _buttonLabel = 'Re-send';
          } catch (errorMessage) {
            notifyMessage = errorMessage;
          }
          MessageBar(context, message: notifyMessage).show();
          break;

        case AuthMode.Phone:
          FireAuthService auth = context.read<FireAuthService>();
          String nofifyMessage = await auth.signInWithPhone(
            phoneNumber: '$_dialCode${_phoneNumber.text.trim()}',
            codeSent: (verifyCode) {
              if (verifyCode != null) {
                _verifyCode = verifyCode;
                setState(() {
                  _mode = AuthMode.VerifyCode;
                  _buttonLabel = 'Verify';
                });
              }
            },
            completed: (result) async {
              String errorMessage = await result();
              if (errorMessage.isEmpty) {
                await _signInSuccess();
              } else {
                MessageBar(context, message: errorMessage).show();
              }
            },
            failed: (errorMessage) async {
              MessageBar(context, message: await errorMessage()).show();
            },
          );
          MessageBar(context, message: nofifyMessage).show();
          break;

        case AuthMode.VerifyCode:
          if (_verifyCode != null) {
            String errorMessage = await _verifyCode(_confirmCode.text.trim());
            if (errorMessage.isEmpty) {
              _verifyCode = null;
              await _signInSuccess();
            } else {
              MessageBar(context, message: errorMessage).show();
            }
          }
          break;

        // Sign In Mode
        default:
          try {
            String email = _email.text.trim();
            String password = _password.text;
            FireAuthService auth = context.read<FireAuthService>();
            String notifyMessage = await auth.signIn(
              email: email,
              password: password,
            );
            if (notifyMessage.isEmpty) {
              await _signInSuccess();
            } else {
              MessageBar(context, message: notifyMessage).show();
            }
          } catch (errorMessage) {
            MessageBar(context, message: errorMessage).show();
          }
          break;
      }
      setState(() => _showSpinner = false);
    }
  }

  Future<void> _signInSuccess() async {
    await CredentialService.detele();
    if (_rememberMe) {
      await CredentialService.store(
        email: _email.text.trim(),
        password: _password.text,
        phoneNumber: _phoneNumber.text.trim(),
        isoCode: _isoCode,
        dialCode: _dialCode,
      );
    }
    String uid = context.read<FireAuthService>().user.uid;
    context.read<FireStoreService>().uid(uid);
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.id,
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<String, Object> args = ModalRoute.of(context).settings.arguments;
      if (args != null) {
        _rememberMe = false;
        _email.text = args[SignInScreen.email];
        _password.text = args[SignInScreen.password];
        MessageBar(context, message: args[SignInScreen.message]).show();
      } else {
        _getCredential();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _phoneNumber.dispose();
    _confirmCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        MessageBar(context).hide();
        return true;
      },
      child: GestureWrapper(
        child: Scaffold(
          appBar: AppBar(title: Text(_appBarLabel)),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
              ),
              child: ScrollableLayout(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.03,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      fairyLogo(),
                      SizedBox(height: screen.height * 0.03),
                      layoutMode(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget fairyLogo() {
    return Hero(
      tag: FruitFairyLogo.id,
      child: FruitFairyLogo(
        fontSize: 30,
        radius: 65,
      ),
    );
  }

  Widget layoutMode() {
    Size screen = MediaQuery.of(context).size;
    switch (_mode) {
      case AuthMode.Reset:
        return Column(
          children: [
            instructionLabel('Enter email for password reset:'),
            SizedBox(height: screen.height * 0.02),
            emailInputField(),
            SizedBox(height: screen.height * 0.02),
            submitButton(context),
            SizedBox(height: screen.height * 0.05),
            signInEmailLink(context),
          ],
        );
        break;

      case AuthMode.Phone:
        return Column(
          children: [
            instructionLabel('Enter phone number to sign in:'),
            SizedBox(height: screen.height * 0.02),
            phoneNumberField(),
            SizedBox(height: screen.height * 0.02),
            submitButton(context),
            SizedBox(height: screen.height * 0.05),
            signInEmailLink(context),
          ],
        );
        break;

      case AuthMode.VerifyCode:
        return Column(
          children: [
            instructionLabel('Enter verification code:'),
            SizedBox(height: screen.height * 0.02),
            verifyCodeField(),
            SizedBox(height: screen.height * 0.02),
            submitButton(context),
            SizedBox(height: screen.height * 0.05),
            resendCodeLink(context),
          ],
        );
        break;

      // Sign In Mode
      default:
        return Column(
          children: [
            emailInputField(),
            SizedBox(height: screen.height * 0.01),
            passwordInputField(),
            rememberMe(),
            SizedBox(height: screen.height * 0.02),
            submitButton(context),
            SizedBox(height: screen.height * 0.03),
            forgotPasswordLink(context),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screen.height * 0.015),
              child: Divider(color: kLabelColor, thickness: 2.0),
            ),
            signInPhoneLink(context),
          ],
        );
        break;
    }
  }

  Widget instructionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: kLabelColor,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget emailInputField() {
    return InputField(
      label: 'Email',
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      errorMessage: _emailError,
      onChanged: (value) {
        setState(() {
          _emailError = Validate.checkEmail(_email.text.trim());
        });
      },
    );
  }

  Widget passwordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'Password',
          controller: _password,
          keyboardType: TextInputType.visiblePassword,
          errorMessage: _passwordError,
          obscureText: _obscurePassword,
          onChanged: (value) {
            setState(() {
              _passwordError = Validate.checkPassword(_password.text);
            });
          },
        ),
        Positioned(
          top: 12.0,
          right: 12.0,
          child: ObscureIcon(
            obscure: _obscurePassword,
            onTap: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget phoneNumberField() {
    return InputField(
      label: 'Phone Number',
      controller: _phoneNumber,
      prefixText: _dialCode,
      errorMessage: _phoneError,
      onChanged: (value) async {
        _phoneError = await Validate.phoneNumber(
          phoneNumber: _phoneNumber.text.trim(),
          isoCode: _isoCode,
        );
        setState(() {});
      },
    );
  }

  Widget verifyCodeField() {
    return InputField(
      label: '6-Digit Code',
      controller: _confirmCode,
      errorMessage: _confirmCodeError,
    );
  }

  Widget rememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: Theme(
            data: ThemeData(
              unselectedWidgetColor: kLabelColor,
            ),
            child: Checkbox(
              value: _rememberMe,
              activeColor: kLabelColor,
              checkColor: kPrimaryColor,
              onChanged: (bool value) {
                HapticFeedback.mediumImpact();
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
        ),
        Text(
          'Remember me',
          style: TextStyle(
            color: kLabelColor,
            fontSize: 16,
          ),
        )
      ],
    );
  }

  Widget submitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.15,
      ),
      child: RoundedButton(
        label: _buttonLabel,
        onPressed: () {
          submit();
        },
      ),
    );
  }

  Widget signInEmailLink(BuildContext context) {
    return LabelLink(
      label: 'Back to Sign In',
      onTap: () {
        setState(() {
          _mode = AuthMode.SignIn;
          _appBarLabel = 'Sign In';
          _buttonLabel = 'Sign In';
        });
      },
    );
  }

  Widget forgotPasswordLink(BuildContext context) {
    return LabelLink(
      label: 'Forgot Password?',
      onTap: () {
        setState(() {
          _mode = AuthMode.Reset;
          _appBarLabel = 'Reset Password';
          _buttonLabel = 'Send';
        });
      },
    );
  }

  Widget signInPhoneLink(BuildContext context) {
    return LabelLink(
      label: 'Sign in with phone number',
      onTap: () {
        setState(() {
          _mode = AuthMode.Phone;
          _appBarLabel = 'Sign In with Phone Number';
          _buttonLabel = 'Continue';
        });
      },
    );
  }

  Widget resendCodeLink(BuildContext context) {
    return LabelLink(
      label: 'Re-send Verification Code',
      onTap: () {
        setState(() {
          _mode = AuthMode.Phone;
          _buttonLabel = 'Continue';
          _confirmCode.clear();
        });
      },
    );
  }
}
