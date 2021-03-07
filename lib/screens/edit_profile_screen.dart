import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/services/address_service.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/services/validation.dart';
import 'package:fruitfairy/widgets/auto_scroll.dart';
import 'package:fruitfairy/widgets/input_field_suggestion.dart';
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
  final TextEditingController _zipCode = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _deleteConfirm = TextEditingController();

  final Uuid uuid = Uuid();

  String _isoCode = 'US';
  String _dialCode = '+1';

  String _firstNameError = '';
  String _lastNameError = '';
  String _phoneError = '';
  String _streetError = '';
  String _cityError = '';
  String _stateError = '';
  String _zipError = '';
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

  String sessionToken;

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
      _zipCode.text = address[kDBAddressZip];
    }
  }

  bool _addressIsFilled() {
    String street = _street.text.trim();
    String city = _city.text.trim();
    String state = _state.text.trim();
    String zip = _zipCode.text.trim();
    bool isFilled = street.isNotEmpty ||
        city.isNotEmpty ||
        state.isNotEmpty ||
        zip.isNotEmpty;
    if (!isFilled) {
      _streetError = _cityError = _stateError = _zipError = '';
    }
    return isFilled;
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
        String zip = _zipCode.text.trim();
        Map<String, String> address = account.address;
        bool insert = address.isEmpty && _addressIsFilled();
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
    } else if (_streetError.isNotEmpty ||
        _cityError.isNotEmpty ||
        _stateError.isNotEmpty ||
        _zipError.isNotEmpty) {
      tag = Field.Address;
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
        label: 'first name',
        name: firstName,
      );
      error += _lastNameError = Validate.name(
        label: 'fast name',
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
      String zip = _zipCode.text.trim();
      String error = '';
      if (_addressIsFilled()) {
        error += _streetError = Validate.checkStreet(street);
        error += _cityError = Validate.checkCity(city);
        error += _stateError = Validate.checkState(state);
        error += _zipError = Validate.zipCode(zip);
      }
      if (error.isEmpty) {
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
      } else {
        return 'Please check your inputs!';
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
          await context.read<FireAuthService>().updatePassword(
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
    MessageBar(context, message: updateMessage).show();
  }

  void _updatePhoneRequest() async {
    setState(() => _showSpinner = true);
    String phoneNumber = _phoneNumber.text.trim();
    _phoneError = await Validate.phoneNumber(
      phoneNumber: phoneNumber,
      isoCode: _isoCode,
    );
    if (_phoneError.isEmpty) {
      FireAuthService auth = context.read<FireAuthService>();
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
              context,
              message: errorMessage,
            ).show();
          },
        );
        _confirmCode.clear();
        _newPhoneNumber = true;
        _updatePhoneLabel = 'Re-send';
        MessageBar(context, message: notifyMessage).show();
      } else {
        if (await auth.removePhone()) {
          await context.read<FireStoreService>().updatePhoneNumber(
                country: _isoCode,
                dialCode: _dialCode,
                phoneNumber: '',
              );
          context.read<Account>().setPhoneNumber(phoneNumber: '');
          _phoneNumber.clear();
          _updatePhoneLabel = 'Add';
          MessageBar(context, message: 'Phone number removed').show();
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
      MessageBar(context, message: errorMessage).show();
    }
    setState(() => _showSpinner = false);
  }

  void _deleteAccount() async {
    String password = _deleteConfirm.text;
    _deleteError = Validate.checkPassword(password);
    if (_deleteError.isEmpty) {
      setDialogState(() => _deleteMode = DeleteMode.Loading);
      try {
        await context.read<FireAuthService>().deleteAccount(
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
    _zipCode.dispose();
    _deleteConfirm.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SafeArea(
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
                  inputFieldSizedBox(),
                  firstNameInputField(),
                  inputFieldSizedBox(),
                  lastNameInputField(),
                  inputFieldSizedBox(),
                  inputGroupSizedBox(),
                  inputGroupLabel(
                    'Mobile Contact',
                    tag: Field.Phone,
                  ),
                  phoneNumberField(),
                  verifyCodeField(),
                  inputFieldSizedBox(),
                  inputGroupSizedBox(),
                  inputGroupLabel(
                    'Address',
                    tag: Field.Address,
                  ),
                  streetInputField(),
                  inputFieldSizedBox(),
                  cityInputField(),
                  inputFieldSizedBox(),
                  stateInputField(),
                  inputFieldSizedBox(),
                  zipInputField(),
                  inputFieldSizedBox(),
                  inputGroupSizedBox(),
                  inputGroupLabel(
                    'Change Password',
                    tag: Field.Password,
                  ),
                  currentPasswordInputField(),
                  inputFieldSizedBox(),
                  newPasswordInputField(),
                  inputFieldSizedBox(),
                  confirmPasswordInputField(),
                  inputFieldSizedBox(),
                  inputGroupSizedBox(),
                  saveButton(),
                  SizedBox(height: screen.height * 0.05),
                  deleteAccountLink(),
                ],
              ),
            ),
          ),
        ),
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

  Widget inputFieldSizedBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.01);
  }

  Widget inputGroupSizedBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.02);
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
      onChanged: (value) {
        setState(() {
          _firstNameError = Validate.name(
            label: 'first name',
            name: _firstName.text.trim(),
          );
        });
      },
    );
  }

  Widget lastNameInputField() {
    return InputField(
      label: 'Last Name',
      controller: _lastName,
      errorMessage: _lastNameError,
      onChanged: (value) {
        setState(() {
          _lastNameError = Validate.name(
            label: 'last name',
            name: _lastName.text.trim(),
          );
        });
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
                  _phoneError = '';
                  if (phoneNumber.isNotEmpty) {
                    _phoneError = await Validate.phoneNumber(
                      phoneNumber: phoneNumber,
                      isoCode: _isoCode,
                    );
                  }
                  _updatePhoneLabel = 'Remove';
                  if (_hasChanges(Field.Phone) || phoneNumber.isEmpty) {
                    _updatePhoneLabel = 'Add';
                  }
                  _newPhoneNumber = false;
                  setState(() {});
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
            vertical: 1.5,
            horizontal: 20.0,
          ),
          child: Text(
            _phoneError.trim(),
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

  Widget streetInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputFieldSuggestion<Map<String, String>>(
          label: 'Street',
          controller: _street,
          suggestionsCallback: (pattern) async {
            if (pattern.isNotEmpty) {
              sessionToken = sessionToken ?? uuid.v4();
              return await AddressService.getSuggestions(
                pattern,
                sessionToken: sessionToken,
              );
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              if (_addressIsFilled()) {
                _streetError = Validate.checkStreet(_street.text.trim());
              }
            });
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(
                suggestion[AddressService.description],
                style: TextStyle(
                  color: kPrimaryColor,
                ),
              ),
            );
          },
          noItemsFoundBuilder: (context) {
            return ListTile(
              title: Text(
                'Address not found!',
                style: TextStyle(
                  color: kPrimaryColor,
                ),
              ),
            );
          },
          onSuggestionSelected: (suggestion) async {
            Map<String, String> address = await AddressService.getDetails(
              suggestion[AddressService.placeId],
              sessionToken: sessionToken,
            );
            if (address.isNotEmpty) {
              _street.text = address[AddressService.street];
              _city.text = address[AddressService.city];
              _state.text = address[AddressService.state];
              _zipCode.text = address[AddressService.zipCode];
            }
            sessionToken = null;
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 1.5,
            horizontal: 20.0,
          ),
          child: Text(
            _streetError.trim(),
            style: TextStyle(
              color: kErrorColor,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget cityInputField() {
    return InputField(
      label: 'City',
      controller: _city,
      errorMessage: _cityError,
      onChanged: (value) {
        setState(() {
          if (_addressIsFilled()) {
            _cityError = Validate.checkCity(_city.text.trim());
          }
        });
      },
    );
  }

  Widget stateInputField() {
    return InputField(
      label: 'State',
      controller: _state,
      errorMessage: _stateError,
      onChanged: (value) {
        setState(() {
          if (_addressIsFilled()) {
            _stateError = Validate.checkState(_state.text.trim());
          }
        });
      },
    );
  }

  Widget zipInputField() {
    return InputField(
      label: 'Zip Code',
      controller: _zipCode,
      errorMessage: _zipError,
      onChanged: (value) {
        setState(() {
          if (_addressIsFilled()) {
            _zipError = Validate.zipCode(_zipCode.text.trim());
          }
        });
      },
    );
  }

  Widget currentPasswordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'Current Password',
          controller: _oldPassword,
          errorMessage: _oldPasswordError,
          obscureText: _obscureOldPassword,
          onChanged: (value) {
            setState(() {
              _oldPasswordError = '';
              if (_newPassword.text.isNotEmpty) {
                _oldPasswordError = Validate.checkPassword(_oldPassword.text);
              }
            });
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

  Widget newPasswordInputField() {
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
              _oldPasswordError = '';
              _newPasswordError = '';
              _confirmPasswordError = '';
              if (newPassword.isNotEmpty) {
                _oldPasswordError = Validate.checkPassword(oldPassword);
                _newPasswordError = Validate.password(newPassword);
                if (confirmPassword.isNotEmpty) {
                  _confirmPasswordError = Validate.confirmPassword(
                    password: newPassword,
                    confirmPassword: confirmPassword,
                  );
                }
              }
            });
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

  Widget confirmPasswordInputField() {
    return InputField(
      label: 'Confirm Password',
      controller: _confirmPassword,
      errorMessage: _confirmPasswordError,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          String newPassword = _newPassword.text;
          _confirmPasswordError = '';
          if (newPassword.isNotEmpty) {
            _confirmPasswordError = Validate.confirmPassword(
              password: newPassword,
              confirmPassword: _confirmPassword.text,
            );
          }
        });
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
        MessageBar(context).hide();
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
        HapticFeedback.mediumImpact();
        _deleteMode = DeleteMode.Input;
        _obscureDeletePassword = true;
        _deleteConfirm.clear();
        _deleteError = '';
        Navigator.of(context).pop();
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
