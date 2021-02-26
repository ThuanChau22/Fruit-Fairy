import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/store_credential.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/phone_input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

enum AuthMode { SignIn, Reset, Phone, VerifyCode }

class SignInScreen extends StatefulWidget {
  static const String id = 'signin_screen';
  static const String credentialObject = 'credential';
  static const String email = 'email';
  static const String password = 'password';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthMode _mode = AuthMode.SignIn;
  String appBarLabel = 'Sign In';
  String buttonLabel = 'Sign In';

  bool _showSpinner = false;
  bool _obscureText = true;
  bool _rememberMe = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _email = '';
  String _password = '';
  String _phone = '';
  String _dialCode = '';
  String _isoCode = 'US';
  String _confirmCode = '';

  String _emailError = '';
  String _passwordError = '';
  String _phoneError = '';
  String _confirmCodeError = '';

  Future<String> Function(String smsCode) verifyCode;

  BuildContext _scaffoldContext;

  void _getCredential() async {
    setState(() => _showSpinner = true);
    Map<String, String> credentials = await StoreCredential.get();
    if (credentials.isNotEmpty) {
      setState(() {
        _emailController.text = credentials[StoreCredential.email];
        _email = _emailController.text;
        _passwordController.text = credentials[StoreCredential.password];
        _password = _passwordController.text;
        _rememberMe = true;
      });
    }
    setState(() => _showSpinner = false);
  }

  Future<bool> _validate() async {
    String errors = '';
    switch (_mode) {
      case AuthMode.Reset:
        errors = _emailError = Validate.checkEmail(_email);
        break;

      case AuthMode.Phone:
        errors = _phoneError = await Validate.validatePhoneNumber(
          phoneNumber: _phone,
          isoCode: _isoCode,
        );
        break;

      case AuthMode.VerifyCode:
        errors = _confirmCodeError = Validate.checkConfirmCode(_confirmCode);
        break;

      // Sign In Mode
      default:
        errors = _emailError = Validate.checkEmail(_email);
        errors += _passwordError = Validate.checkPassword(_password);
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
          try {
            final AuthService auth = context.read<AuthService>();
            auth.resetPassword(_email);
            buttonLabel = 'Re-send';
            MessageBar(
              _scaffoldContext,
              message: 'Reset password email sent',
            ).show();
          } catch (e) {
            print(e);
          }
          break;

        case AuthMode.Phone:
          final AuthService auth = context.read<AuthService>();
          await auth.signInWithPhone(
            phoneNumber: '$_dialCode$_phone',
            completed: (String errorMessage) {
              if (errorMessage.isEmpty) {
                _signInSuccess();
              } else {
                MessageBar(
                  _scaffoldContext,
                  message: errorMessage,
                ).show();
              }
            },
            codeSent: (Future<String> Function(String smsCode) verifyFunction) {
              if (verifyFunction != null) {
                verifyCode = verifyFunction;
                setState(() {
                  _mode = AuthMode.VerifyCode;
                  buttonLabel = 'Verify';
                });
              }
            },
            failed: (String errorMessage) {
              MessageBar(
                _scaffoldContext,
                message: errorMessage,
              ).show();
            },
          );
          // TODO: After continue
          MessageBar(
            _scaffoldContext,
            message: 'Doing something...',
          ).show();
          break;

        case AuthMode.VerifyCode:
          String errorMessage = await verifyCode(_confirmCode);
          if (errorMessage.isEmpty) {
            _signInSuccess();
          } else {
            //TODO: Error message from code sent
            MessageBar(
              _scaffoldContext,
              message: errorMessage,
            ).show();
          }
          break;

        // Sign In Mode
        default:
          try {
            final AuthService auth = context.read<AuthService>();
            bool signedIn = await auth.signIn(
              email: _email,
              password: _password,
            );
            if (signedIn) {
              await StoreCredential.detele();
              if (_rememberMe) {
                await StoreCredential.store(
                  email: _email,
                  password: _password,
                );
              }
              _signInSuccess();
            } else {
              _showConfirmEmailMessage();
            }
          } catch (errorMessage) {
            MessageBar(
              _scaffoldContext,
              message: errorMessage,
            ).show();
          }
          break;
      }
      setState(() => _showSpinner = false);
    }
  }

  void _signInSuccess() async {
    FireStoreService fireStoreService = context.read<FireStoreService>();
    fireStoreService.uid = context.read<AuthService>().user.uid;
    context.read<Account>().fromMap(await fireStoreService.getUserData());
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.id,
      (route) => false,
    );
  }

  void _showConfirmEmailMessage() {
    MessageBar(
      _scaffoldContext,
      message: 'Please check your email for a verification link',
    ).show();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<String, Object> args = ModalRoute.of(context).settings.arguments;
      if (args != null) {
        UserCredential user = args[SignInScreen.credentialObject];
        if (user != null && user.additionalUserInfo.isNewUser) {
          _emailController.text = args[SignInScreen.email];
          _email = _emailController.text;
          _passwordController.text = args[SignInScreen.password];
          _password = _passwordController.text;
          _rememberMe = false;
          _showConfirmEmailMessage();
        }
      } else {
        _getCredential();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text(appBarLabel),
        centerTitle: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;
          return SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kAppBarColor),
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
          );
        },
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
            SizedBox(height: screen.height * 0.03),
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
            SizedBox(height: screen.height * 0.03),
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
            SizedBox(height: screen.height * 0.03),
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
            SizedBox(height: screen.height * 0.02),
            emailInputField(),
            SizedBox(height: screen.height * 0.01),
            passwordInputField(),
            optionTile(),
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
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      errorMessage: _emailError,
      onChanged: (value) {
        setState(() {
          _email = value.trim();
          _emailError = Validate.checkEmail(_email);
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget passwordInputField() {
    return InputField(
      label: 'Password',
      controller: _passwordController,
      obscureText: _obscureText,
      errorMessage: _passwordError,
      onChanged: (value) {
        setState(() {
          _password = value;
          _passwordError = Validate.checkPassword(_password);
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget phoneNumberField() {
    return PhoneInputField(
      initialPhoneNumber: _phone,
      initialSelection: _isoCode,
      errorMessage: _phoneError,
      showDropdownIcon: false,
      onPhoneNumberChanged: (phoneNumber, intlNumber, isoCode) async {
        _phone = phoneNumber;
        _isoCode = isoCode;
        _dialCode = intlNumber.substring(0, intlNumber.indexOf(phoneNumber));
        _phoneError = await Validate.validatePhoneNumber(
          phoneNumber: _phone,
          isoCode: _isoCode,
        );
        setState(() {});
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget verifyCodeField() {
    return InputField(
      label: '6-Digit Code',
      keyboardType: TextInputType.number,
      errorMessage: _confirmCodeError,
      onChanged: (value) {
        setState(() {
          _confirmCode = value;
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget optionTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        rememberMe(),
        passwordVisibility(),
      ],
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
                setState(() {
                  _rememberMe = value;
                });
                HapticFeedback.mediumImpact();
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

  Widget passwordVisibility() {
    return Padding(
      padding: EdgeInsets.only(right: 15.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
          HapticFeedback.mediumImpact();
        },
        child: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: kLabelColor,
        ),
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.15,
      ),
      child: RoundedButton(
        label: buttonLabel,
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
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
          appBarLabel = 'Sign In';
          buttonLabel = 'Sign In';
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
          appBarLabel = 'Reset Password';
          buttonLabel = 'Send';
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
          appBarLabel = 'Sign In with Phone Number';
          buttonLabel = 'Continue';
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
          buttonLabel = 'Continue';
        });
      },
    );
  }
}
