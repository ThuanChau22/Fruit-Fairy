import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/phone_input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

enum Field {
  FirstName,
  LastName,
  Phone,
  OldPassword,
  NewPassword,
  ConfirmPassword,
}

class EditProfileScreen extends StatefulWidget {
  static const String id = 'edit_profile_screen';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AutoScrollController _scrollController = AutoScrollController();
  final Map<Field, int> fields = {
    Field.FirstName: 0,
    Field.LastName: 1,
    Field.Phone: 2,
    Field.OldPassword: 3,
    Field.NewPassword: 4,
    Field.ConfirmPassword: 5,
  };
  bool _showSpinner = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  TextEditingController _email = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();

  String _phone = '';
  String _isoCode = 'US';
  String _dialCode = '';

  TextEditingController _street = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _zip = TextEditingController();

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  String _firstNameError = '';
  String _lastNameError = '';
  String _phoneError = '';
  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';

  BuildContext _scaffoldContext;

  void _getAccountInfo() {
    Account account = context.read<Account>();
    _email.text = account.email;
    _firstName.text = account.firstName;
    _lastName.text = account.lastName;
    Map<String, String> phone = account.phone;
    if (phone.isNotEmpty) {
      _phone = phone[kDBPhoneNumber];
      _isoCode = phone[kDBPhoneCountry];
    }
    Map<String, String> address = account.address;
    if (address.isNotEmpty) {
      _street.text = address[kDBAddressStreet];
      _city.text = address[kDBAddressCity];
      _state.text = address[kDBAddressState];
      _zip.text = address[kDBAddressZip];
    }
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
    if (errorMessage.isEmpty) {
      MessageBar(
        _scaffoldContext,
        message: 'Profile Updated',
      ).show();
    } else {
      if (errorMessage == 'invalid') {
        _scrollToError();
      } else {
        MessageBar(
          _scaffoldContext,
          message: errorMessage,
        ).show();
      }
    }

    setState(() => _showSpinner = false);
  }

  Future<String> _updateName() async {
    String firstName = _firstName.text.trim();
    String lastName = _lastName.text.trim();
    Account account = context.read<Account>();
    if (firstName != account.firstName || lastName != account.lastName) {
      String error = _firstNameError = Validate.name(
        label: 'First Name',
        name: firstName.trim(),
      );
      error += _lastNameError = Validate.name(
        label: 'Last Name',
        name: lastName.trim(),
      );
      if (error.isEmpty) {
        try {
          await context.read<FireStoreService>().updateUserName(
                firstName: firstName,
                lastName: lastName,
              );
          account.setFirstName(firstName);
          account.setLastName(lastName);
        } catch (errorMessage) {
          return errorMessage;
        }
      } else {
        return 'invalid';
      }
    }
    return '';
  }

  Future<String> _updatePhone() async {}

  Future<String> _updateAddress() async {
    String street = _street.text.trim();
    String city = _city.text.trim();
    String state = _state.text.trim();
    String zip = _zip.text.trim();
    Account account = context.read<Account>();
    Map<String, String> address = account.address;
    if ((address.isNotEmpty &&
            (street != address[kDBAddressStreet] ||
                city != address[kDBAddressCity] ||
                state != address[kDBAddressState] ||
                zip != address[kDBAddressZip])) ||
        (address.isEmpty &&
            (street.isNotEmpty ||
                city.isNotEmpty ||
                state.isNotEmpty ||
                zip.isNotEmpty))) {
      try {
        await context.read<FireStoreService>().updateUserAddress(
              street: street,
              city: city,
              state: state,
              zip: zip,
            );
        account.setAddress(
          street: street,
          city: city,
          state: state,
          zip: zip,
        );
      } catch (errorMessage) {
        return errorMessage;
      }
    }
    return '';
  }

  Future<String> _updatePassword() async {
    String oldPassword = _oldPassword.text;
    String newPassword = _newPassword.text;
    String confirmPassword = _confirmPassword.text;
    if (newPassword.isNotEmpty) {
      String error = _oldPasswordError = Validate.checkPassword(oldPassword);
      error += _newPasswordError = Validate.password(newPassword);
      error += _confirmPasswordError = Validate.confirmPassword(
        password: newPassword,
        confirmPassword: confirmPassword,
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
        } catch (errorMessage) {
          return errorMessage;
        }
      } else {
        return 'invalid';
      }
    }
    return '';
  }

  void _scrollToError() async {
    int scrollIndex;
    if (_firstNameError.isNotEmpty) {
      scrollIndex = fields[Field.FirstName];
    } else if (_lastNameError.isNotEmpty) {
      scrollIndex = fields[Field.LastName];
    } else if (_phoneError.isNotEmpty) {
      scrollIndex = fields[Field.Phone];
    } else if (_oldPasswordError.isNotEmpty) {
      scrollIndex = fields[Field.OldPassword];
    } else if (_newPasswordError.isNotEmpty) {
      scrollIndex = fields[Field.NewPassword];
    } else if (_confirmPasswordError.isNotEmpty) {
      scrollIndex = fields[Field.ConfirmPassword];
    }
    await _scrollController.scrollToIndex(scrollIndex,
        duration: Duration(seconds: 1),
        preferPosition: AutoScrollPosition.middle);
  }

  @override
  void initState() {
    super.initState();
    _getAccountInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.03,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    children: [
                      inputGroupLabel('Account Information'),
                      emailInputField(),
                      inputFieldSizeBox(),
                      firstNameInputField(),
                      inputFieldSizeBox(),
                      lastNameInputField(),
                      inputFieldSizeBox(),
                      inputGroupLabel('Mobile Contact'),
                      phoneNumberField(),
                      inputFieldSizeBox(),
                      inputGroupLabel('Address'),
                      streetInputField(),
                      inputFieldSizeBox(),
                      cityInputField(),
                      inputFieldSizeBox(),
                      stateInputField(),
                      inputFieldSizeBox(),
                      zipInputField(),
                      inputFieldSizeBox(),
                      inputGroupLabel('Change Password'),
                      currentPasswordInputField(),
                      inputFieldSizeBox(),
                      newPasswordInputField(),
                      inputFieldSizeBox(),
                      confirmPasswordInputField(),
                      inputFieldSizeBox(),
                      inputFieldSizeBox(),
                      saveButton(),
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

  Widget inputGroupLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
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
    return scrollWapper(
      index: Field.FirstName,
      child: InputField(
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
      ),
    );
  }

  Widget lastNameInputField() {
    return scrollWapper(
      index: Field.LastName,
      child: InputField(
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
      ),
    );
  }

  Widget phoneNumberField() {
    return scrollWapper(
      index: Field.Phone,
      child: PhoneInputField(
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
    return scrollWapper(
      index: Field.OldPassword,
      child: Stack(
        children: [
          InputField(
            label: 'Current Password',
            controller: _oldPassword,
            errorMessage: _oldPasswordError,
            obscureText: _obscureCurrentPassword,
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
              obscure: _obscureCurrentPassword,
              onTap: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  newPasswordInputField() {
    return scrollWapper(
      index: Field.NewPassword,
      child: Stack(
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
      ),
    );
  }

  confirmPasswordInputField() {
    return scrollWapper(
      index: Field.ConfirmPassword,
      child: InputField(
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
      ),
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

  Widget scrollWapper({Field index, Widget child}) {
    return AutoScrollTag(
      index: fields[index],
      key: ValueKey(index),
      controller: _scrollController,
      child: child,
    );
  }
}
