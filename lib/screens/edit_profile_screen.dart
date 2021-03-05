import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/constant.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/auto_scroll.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

enum Field { Name, Phone, Address, Password }

enum DeleteMode { Input, Loading, Success }

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

  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _confirmCode = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zip = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _deleteConfirm = TextEditingController();

  String _isoCode = 'US', _dialCode = '+1';

  String _firstNameError = '';
  String _lastNameError = '';
  String _phoneError = '';
  String _confirmCodeError = '';
  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';
  String _deleteError = '';

  bool _showSpinner = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _updatedName = false;
  bool _updatedAddress = false;
  bool _updatedPassword = false;
  String _updatePhoneLabel = 'Add';
  bool _newPhoneNumber = false;
  DeleteMode _deleteMode = DeleteMode.Input;
  bool _obscureDeletePassword = true;

  Future<String> Function(String smsCode) _verifyCode;

  BuildContext _scaffoldContext;

  StateSetter setDialogState;

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
      _updatePhoneLabel = 'Remove';
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
        return 'Please check your inputs!';
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
        return 'Please check your inputs!';
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
        updateMessage = 'Profile updated';
      } else {
        updateMessage = 'Profile is up-to-date';
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
    setState(() => _showSpinner = true);
    String phoneNumber = _phoneNumber.text.trim();
    _phoneError = await Validate.phoneNumber(
      phoneNumber: phoneNumber,
      isoCode: _isoCode,
    );
    if (_phoneError.isEmpty) {
      AuthService auth = context.read<AuthService>();
      if (_hasChanges(Field.Phone)) {
        String notifyMessage = await auth.registerPhone(
          phoneNumber: '$_dialCode$phoneNumber',
          update: context.read<Account>().phone.isNotEmpty,
          codeSent: (verifyCode) async {
            if (verifyCode != null) {
              _verifyCode = verifyCode;
            }
          },
          failed: (errorMessage) {
            MessageBar(
              _scaffoldContext,
              message: errorMessage,
            ).show();
          },
        );
        _confirmCode.clear();
        _newPhoneNumber = true;
        _updatePhoneLabel = 'Re-send';
        MessageBar(
          _scaffoldContext,
          message: notifyMessage,
        ).show();
      } else {
        if (await auth.removePhone()) {
          await context.read<FireStoreService>().updatePhoneNumber(
                phoneNumber: '',
              );
          context.read<Account>().setPhoneNumber(phoneNumber: '');
          _phoneNumber.clear();
          _updatePhoneLabel = 'Add';
          MessageBar(
            _scaffoldContext,
            message: 'Phone number removed',
          ).show();
        }
      }
    }
    setState(() => _showSpinner = false);
  }

  void _updatePhoneVerify() async {
    setState(() => _showSpinner = true);
    if (_hasChanges(Field.Phone) && _verifyCode != null) {
      String errorMessage = await _verifyCode(_confirmCode.text.trim());
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
        _phoneNumber.text = phoneNumber;
        _confirmCode.clear();
        _newPhoneNumber = false;
        _updatePhoneLabel = 'Remove';
        errorMessage = 'Phone number updated';
      }
      MessageBar(
        _scaffoldContext,
        message: errorMessage,
      ).show();
    }
    setState(() => _showSpinner = false);
  }

  void _deleteAccount() async {
    String password = _deleteConfirm.text;
    _deleteError = Validate.checkPassword(password);
    if (_deleteError.isEmpty) {
      setDialogState(() => _deleteMode = DeleteMode.Loading);
      try {
        await context.read<AuthService>().deleteAccount(
              email: _email.text.trim(),
              password: password,
            );
        context.read<Account>().clear();
        setDialogState(() => _deleteMode = DeleteMode.Success);
        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
          SignOptionScreen.id,
          (route) => false,
        );
        Navigator.of(context).pushNamed(SignInScreen.id);
      } catch (errorMessage) {
        _deleteError = errorMessage;
        setDialogState(() => _deleteMode = DeleteMode.Input);
      }
    }
    setDialogState(() {});
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
    _phoneNumber.dispose();
    _confirmCode.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _zip.dispose();
    _deleteConfirm.dispose();
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
                      inputFieldSizeBox(),
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
                  String phoneNumber = _phoneNumber.text.trim();
                  _phoneError = await Validate.phoneNumber(
                    phoneNumber: phoneNumber,
                    isoCode: _isoCode,
                  );
                  _updatePhoneLabel =
                      _hasChanges(Field.Phone) || phoneNumber.isEmpty
                          ? 'Add'
                          : 'Remove';
                  _newPhoneNumber = false;
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
                label: _updatePhoneLabel,
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
    return Visibility(
      visible: _newPhoneNumber,
      child: Column(
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
      label: 'Delete this account',
      onTap: () {
        showDeleteDialog();
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Future<void> showDeleteDialog() async {
    Alert(
      context: context,
      title: 'Delete Account',
      style: AlertStyle(
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titleStyle: TextStyle(
          color: kLabelColor,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: kPrimaryColor,
        overlayColor: Colors.black.withOpacity(0.50),
        isOverlayTapDismiss: false,
      ),
      closeIcon: Icon(
        Icons.close_rounded,
        color: kLabelColor,
      ),
      closeFunction: () {
        _deleteMode = DeleteMode.Input;
        _obscureDeletePassword = true;
        _deleteConfirm.clear();
        _deleteError = '';
        Navigator.of(context).pop();
        HapticFeedback.mediumImpact();
      },
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          setDialogState = setState;
          return Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: deleteLayout(),
          );
        },
      ),
      buttons: [],
    ).show();
  }

  Widget deleteLayout() {
    switch (_deleteMode) {
      case DeleteMode.Loading:
        return Container(
          height: 50.0,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAppBarColor),
            ),
          ),
        );
        break;

      case DeleteMode.Success:
        return Container(
          height: 50.0,
          child: Center(
            child: Text(
              'Account deleted',
              style: TextStyle(
                color: kLabelColor,
              ),
            ),
          ),
        );
        break;

      default:
        return Column(
          children: [
            Text(
              'Please confirm your password',
              style: TextStyle(
                color: kLabelColor,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10.0),
            Stack(
              children: [
                InputField(
                  label: 'Password',
                  controller: _deleteConfirm,
                  errorMessage: _deleteError,
                  obscureText: _obscureDeletePassword,
                  onChanged: (value) {
                    setDialogState(() {
                      _deleteError =
                          Validate.checkPassword(_deleteConfirm.text);
                    });
                  },
                ),
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: ObscureIcon(
                    obscure: _obscureDeletePassword,
                    onTap: () {
                      setDialogState(() {
                        _obscureDeletePassword = !_obscureDeletePassword;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: RoundedButton(
                label: 'Delete',
                labelColor: kPrimaryColor,
                backgroundColor: kObjectBackgroundColor,
                onPressed: () {
                  _deleteAccount();
                },
              ),
            ),
          ],
        );
    }
  }
}
