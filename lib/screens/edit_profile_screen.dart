import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/auto_scroll.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

enum Field {
  Name,
  Address,
  Password,
  Phone,
}

class EditProfileScreen extends StatefulWidget {
  static const String id = 'edit_profile_screen';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AutoScroll<Field> _scroller = AutoScroll(
    elements: {
      Field.Name: 0,
      Field.Phone: 1,
      Field.Address: 2,
      Field.Password: 3,
    },
  );

  bool _showSpinner = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _updatedName = false;
  bool _updatedAddress = false;
  bool _updatedPassword = false;
  String _updatePhoneRequestLabel = 'Send';
  bool _hasPhoneNumber = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();

  TextEditingController _street = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _zip = TextEditingController();

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  String _isoCode = 'US', _dialCode = '+1';
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _confirmCode = TextEditingController();

  String _firstNameError = '';
  String _lastNameError = '';
  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';
  String _phoneError = '';
  String _confirmCodeError = '';

  Future<String> Function(String smsCode) verifyCode;

  BuildContext _scaffoldContext;

  void _getAccountInfo() {
    Account account = context.read<Account>();
    _email.text = account.email;
    _firstName.text = account.firstName;
    _lastName.text = account.lastName;
    Map<String, String> phone = account.phone;
    if (phone.isNotEmpty) {
      _isoCode = phone[kDBPhoneCountry];
      _dialCode = phone[kDBPhoneDialCode];
      _phoneNumber.text = phone[kDBPhoneNumber];
      _hasPhoneNumber = true;
    }
    Map<String, String> address = account.address;
    if (address.isNotEmpty) {
      _street.text = address[kDBAddressStreet];
      _city.text = address[kDBAddressCity];
      _state.text = address[kDBAddressState];
      _zip.text = address[kDBAddressZip];
    }
  }

  bool _hasChanges(Field field) {
    Account account = context.read<Account>();
    switch (field) {
      case Field.Name:
        bool hasChange = _firstName.text.trim() != account.firstName;
        hasChange = hasChange || _lastName.text.trim() != account.lastName;
        return hasChange;
        break;

      case Field.Address:
        String street = _street.text.trim();
        String city = _city.text.trim();
        String state = _state.text.trim();
        String zip = _zip.text.trim();
        Map<String, String> address = account.address;
        bool insert = address.isEmpty &&
            (street.isNotEmpty ||
                city.isNotEmpty ||
                state.isNotEmpty ||
                zip.isNotEmpty);
        bool update = address.isNotEmpty &&
            (street != address[kDBAddressStreet] ||
                city != address[kDBAddressCity] ||
                state != address[kDBAddressState] ||
                zip != address[kDBAddressZip]);
        return insert || update;
        break;

      case Field.Password:
        return _newPassword.text.isNotEmpty;
        break;

      case Field.Phone:
        String phoneNumber = _phoneNumber.text.trim();
        Map<String, String> phone = account.phone;
        bool insert = phone.isEmpty && (phoneNumber.isNotEmpty);
        bool update = phone.isNotEmpty &&
            (phoneNumber != phone[kDBPhoneNumber] ||
                _isoCode != phone[kDBPhoneCountry]);
        return insert || update;
        break;
    }
    return false;
  }

  void _scrollToError() async {
    Field tag;
    if (_firstNameError.isNotEmpty || _lastNameError.isNotEmpty) {
      tag = Field.Name;
    } else if (_oldPasswordError.isNotEmpty ||
        _newPasswordError.isNotEmpty ||
        _confirmPasswordError.isNotEmpty) {
      tag = Field.Password;
    }
    _scroller.scroll(tag);
  }

  Future<String> _updateName() async {
    if (_hasChanges(Field.Name)) {
      String firstName = _firstName.text.trim();
      String lastName = _lastName.text.trim();
      String error = _firstNameError = Validate.name(
        label: 'First Name',
        name: firstName,
      );
      error += _lastNameError = Validate.name(
        label: 'Last Name',
        name: lastName,
      );
      if (error.isEmpty) {
        try {
          await context.read<FireStoreService>().updateUserName(
                firstName: firstName,
                lastName: lastName,
              );
          Account account = context.read<Account>();
          account.setFirstName(firstName);
          account.setLastName(lastName);
          _updatedName = true;
        } catch (errorMessage) {
          return errorMessage;
        }
      } else {
        return 'Please check your input';
      }
    }
    return '';
  }

  Future<String> _updateAddress() async {
    if (_hasChanges(Field.Address)) {
      String street = _street.text.trim();
      String city = _city.text.trim();
      String state = _state.text.trim();
      String zip = _zip.text.trim();
      try {
        await context.read<FireStoreService>().updateUserAddress(
              street: street,
              city: city,
              state: state,
              zip: zip,
            );
        context.read<Account>().setAddress(
              street: street,
              city: city,
              state: state,
              zip: zip,
            );
        _updatedAddress = true;
      } catch (errorMessage) {
        return errorMessage;
      }
    }
    return '';
  }

  Future<String> _updatePassword() async {
    if (_hasChanges(Field.Password)) {
      String oldPassword = _oldPassword.text;
      String newPassword = _newPassword.text;
      String error = _oldPasswordError = Validate.checkPassword(oldPassword);
      error += _newPasswordError = Validate.password(newPassword);
      error += _confirmPasswordError = Validate.confirmPassword(
        password: newPassword,
        confirmPassword: _confirmPassword.text,
      );
      if (error.isEmpty) {
        try {
          await context.read<AuthService>().updatePassword(
                email: _email.text.trim(),
                oldPassword: oldPassword,
                newPassword: newPassword,
              );
          _oldPassword.clear();
          _newPassword.clear();
          _confirmPassword.clear();
          _updatedPassword = true;
        } catch (errorMessage) {
          return errorMessage;
        }
      } else {
        return 'Please check your input';
      }
    }
    return '';
  }

  void _updateProfile() async {
    setState(() => _showSpinner = true);
    String errorMessage = await _updateName();
    if (errorMessage.isEmpty) {
      errorMessage = await _updateAddress();
    }
    if (errorMessage.isEmpty) {
      errorMessage = await _updatePassword();
    }
    String updateMessage;
    if (errorMessage.isEmpty) {
      if (_updatedName || _updatedAddress || _updatedPassword) {
        _updatedName = _updatedAddress = _updatedPassword = false;
        updateMessage = 'Profile Updated';
      } else {
        updateMessage = 'Profile is Up-to-date';
      }
      _getAccountInfo();
    } else {
      _scrollToError();
      updateMessage = errorMessage;
    }
    setState(() => _showSpinner = false);
    MessageBar(
      _scaffoldContext,
      message: updateMessage,
    ).show();
  }

  void _updatePhoneRequest() async {
    if (_hasChanges(Field.Phone)) {
      String phoneNumber = _phoneNumber.text.trim();
      _phoneError = await Validate.phoneNumber(
        phoneNumber: phoneNumber,
        isoCode: _isoCode,
      );
      if (_phoneError.isEmpty) {
        AuthService auth = context.read<AuthService>();
        auth.registerPhone(
          phoneNumber: '$_dialCode$phoneNumber',
          update: context.read<Account>().phone.isNotEmpty,
          codeSent:
              (Future<String> Function(String smsCode) verifyFunction) async {
            if (verifyFunction != null) {
              verifyCode = verifyFunction;
            }
          },
          failed: (errorMessage) {
            MessageBar(
              _scaffoldContext,
              message: errorMessage,
            ).show();
          },
        );
        //TODO: Notify message
        MessageBar(
          _scaffoldContext,
          message: 'Sending...',
        ).show();
        _confirmCode.clear();
        _updatePhoneRequestLabel = 'Re-send';
      }
    } else {
      MessageBar(
        _scaffoldContext,
        message: 'Phone Number Already Registered',
      ).show();
    }
    setState(() {});
  }

  void _updatePhoneVerify() async {
    if (_hasChanges(Field.Phone) && verifyCode != null) {
      String errorMessage = await verifyCode(_confirmCode.text.trim());
      if (errorMessage.isEmpty) {
        String phoneNumber = _phoneNumber.text.trim();
        await context.read<FireStoreService>().updatePhoneNumber(
              country: _isoCode,
              dialCode: _dialCode,
              phoneNumber: phoneNumber,
            );
        context.read<Account>().setPhoneNumber(
              country: _isoCode,
              dialCode: _dialCode,
              phoneNumber: phoneNumber,
            );
        _confirmCode.clear();
        _hasPhoneNumber = true;
        _updatePhoneRequestLabel = 'Send';
        errorMessage = 'Phone Number Updated';
      }
      MessageBar(
        _scaffoldContext,
        message: errorMessage,
      ).show();
    }
    setState(() {});
  }

  void _removePhone() async {
    AuthService auth = context.read<AuthService>();
    if (auth.user.phoneNumber.isNotEmpty) {
      auth.removePhone().then((removed) async {
        if (removed) {
          await context.read<FireStoreService>().updatePhoneNumber(
                phoneNumber: '',
              );
          context.read<Account>().setPhoneNumber(phoneNumber: '');
          _phoneNumber.clear();
          _hasPhoneNumber = false;
          MessageBar(
            _scaffoldContext,
            message: 'Phone Number Removed',
          ).show();
        }
        setState(() {});
      });
      MessageBar(
        _scaffoldContext,
        message: 'Removing Phone Number',
      ).show();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAccountInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _scroller.controller.dispose();
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _zip.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Edit Profile'),
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
                controller: _scroller.controller,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.03,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    children: [
                      inputGroupLabel(
                        'Account',
                        tag: Field.Name,
                      ),
                      emailInputField(),
                      inputFieldSizeBox(),
                      firstNameInputField(),
                      inputFieldSizeBox(),
                      lastNameInputField(),
                      inputFieldSizeBox(),
                      inputGroupLabel(
                        'Mobile Contact',
                        tag: Field.Phone,
                      ),
                      phoneNumberField(),
                      verifyCodeField(),
                      removePhoneLink(),
                      inputGroupLabel(
                        'Address',
                        tag: Field.Address,
                      ),
                      streetInputField(),
                      inputFieldSizeBox(),
                      cityInputField(),
                      inputFieldSizeBox(),
                      stateInputField(),
                      inputFieldSizeBox(),
                      zipInputField(),
                      inputFieldSizeBox(),
                      inputGroupLabel(
                        'Change Password',
                        tag: Field.Password,
                      ),
                      currentPasswordInputField(),
                      inputFieldSizeBox(),
                      newPasswordInputField(),
                      inputFieldSizeBox(),
                      confirmPasswordInputField(),
                      inputFieldSizeBox(),
                      saveButton(),
                      SizedBox(height: screen.height * 0.05),
                      deleteAccountLink(),
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

  Widget inputGroupLabel(String label, {Field tag}) {
    Size screen = MediaQuery.of(context).size;
    return _scroller.wrap(
      tag: tag,
      child: Padding(
        padding: EdgeInsets.only(
          left: screen.width * 0.05,
          right: screen.width * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                color: kLabelColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: kLabelColor,
              height: 2.0,
              thickness: 2.0,
            ),
            SizedBox(height: screen.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget inputFieldSizeBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.01);
  }

  Widget emailInputField() {
    return InputField(
      label: 'Email',
      labelColor: kLabelColor.withOpacity(0.5),
      controller: _email,
      readOnly: true,
    );
  }

  Widget firstNameInputField() {
    return InputField(
      label: 'First Name',
      controller: _firstName,
      errorMessage: _firstNameError,
      maxLength: 20,
      onChanged: (value) {
        setState(() {
          _firstNameError = Validate.name(
            label: 'First Name',
            name: _firstName.text.trim(),
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget lastNameInputField() {
    return InputField(
      label: 'Last Name',
      controller: _lastName,
      errorMessage: _lastNameError,
      maxLength: 20,
      onChanged: (value) {
        setState(() {
          _lastNameError = Validate.name(
            label: 'Last Name',
            name: _lastName.text.trim(),
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget phoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: InputField(
                label: 'Phone Number',
                controller: _phoneNumber,
                prefixText: _dialCode,
                helperText: null,
                onChanged: (value) async {
                  _phoneError = await Validate.phoneNumber(
                    phoneNumber: _phoneNumber.text.trim(),
                    isoCode: _isoCode,
                  );
                  setState(() {});
                },
                onTap: () {
                  MessageBar(_scaffoldContext).hide();
                },
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: RoundedButton(
                label: _updatePhoneRequestLabel,
                labelColor: kPrimaryColor,
                onPressed: () {
                  _updatePhoneRequest();
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 20.0,
          ),
          child: Text(
            _phoneError,
            style: TextStyle(
              color: kErrorColor,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget verifyCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: InputField(
                label: '6-Digit Code',
                controller: _confirmCode,
                errorMessage: _confirmCodeError,
                onTap: () {
                  MessageBar(_scaffoldContext).hide();
                },
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: RoundedButton(
                label: 'Verify',
                labelColor: kPrimaryColor,
                onPressed: () {
                  _updatePhoneVerify();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget removePhoneLink() {
    Size screen = MediaQuery.of(context).size;
    return Visibility(
      visible: _hasPhoneNumber,
      child: Column(
        children: [
          LabelLink(
            label: 'Remove phone number',
            onTap: () {
              _removePhone();
            },
          ),
          SizedBox(height: screen.height * 0.03),
        ],
      ),
    );
  }

  streetInputField() {
    return InputField(
      label: 'Street',
      controller: _street,
      onChanged: (value) {},
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  cityInputField() {
    return InputField(
      label: 'City',
      controller: _city,
      onChanged: (value) {},
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  stateInputField() {
    return InputField(
      label: 'State',
      controller: _state,
      onChanged: (value) {},
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  zipInputField() {
    return InputField(
      label: 'Zip Code',
      controller: _zip,
      onChanged: (value) {},
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  currentPasswordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'Current Password',
          controller: _oldPassword,
          errorMessage: _oldPasswordError,
          obscureText: _obscureOldPassword,
          onChanged: (value) {
            setState(() {
              if (_newPassword.text.isNotEmpty) {
                _oldPasswordError = Validate.checkPassword(_oldPassword.text);
              } else {
                _oldPasswordError = '';
              }
            });
          },
          onTap: () {
            MessageBar(_scaffoldContext).hide();
          },
        ),
        Positioned(
          top: 12.0,
          right: 12.0,
          child: ObscureIcon(
            obscure: _obscureOldPassword,
            onTap: () {
              setState(() {
                _obscureOldPassword = !_obscureOldPassword;
              });
            },
          ),
        ),
      ],
    );
  }

  newPasswordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'New Password',
          controller: _newPassword,
          errorMessage: _newPasswordError,
          obscureText: _obscureNewPassword,
          onChanged: (value) {
            setState(() {
              String oldPassword = _oldPassword.text;
              String newPassword = _newPassword.text;
              String confirmPassword = _confirmPassword.text;
              if (newPassword.isNotEmpty) {
                _oldPasswordError = Validate.checkPassword(oldPassword);
                _newPasswordError = Validate.password(newPassword);
                if (confirmPassword.isNotEmpty) {
                  _confirmPasswordError = Validate.confirmPassword(
                    password: newPassword,
                    confirmPassword: confirmPassword,
                  );
                }
              } else {
                _oldPasswordError = '';
                _newPasswordError = '';
                _confirmPasswordError = '';
              }
            });
          },
          onTap: () {
            MessageBar(_scaffoldContext).hide();
          },
        ),
        Positioned(
          top: 12.0,
          right: 12.0,
          child: ObscureIcon(
            obscure: _obscureNewPassword,
            onTap: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
        ),
      ],
    );
  }

  confirmPasswordInputField() {
    return InputField(
      label: 'Confirm Password',
      controller: _confirmPassword,
      errorMessage: _confirmPasswordError,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          String newPassword = _newPassword.text;
          if (newPassword.isNotEmpty) {
            _confirmPasswordError = Validate.confirmPassword(
              password: newPassword,
              confirmPassword: _confirmPassword.text,
            );
          } else {
            _confirmPasswordError = '';
          }
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget saveButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.15,
      ),
      child: RoundedButton(
        label: 'Save',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          _updateProfile();
        },
      ),
    );
  }

  Widget deleteAccountLink() {
    return LabelLink(
      label: 'I want to delete this account',
      onTap: () {},
    );
  }
}
