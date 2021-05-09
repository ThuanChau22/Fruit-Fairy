import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/charities.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/services/map_service.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firemessaging_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/services/session_token.dart';
import 'package:fruitfairy/services/validation.dart';
import 'package:fruitfairy/widgets/auto_scroll.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field_suggestion.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

enum Field { Name, Phone, Address, Password }
enum DeleteMode { Input, Loading, Success }

class ProfileDonorScreen extends StatefulWidget {
  static const String id = 'profile_donor_screen';

  @override
  _ProfileDonorScreenState createState() => _ProfileDonorScreenState();
}

class _ProfileDonorScreenState extends State<ProfileDonorScreen> {
  final AutoScroll<Field> _scroller = AutoScroll(
    elements: {
      Field.Name: 0,
      Field.Address: 1,
      Field.Phone: 2,
      Field.Password: 3,
    },
  );

  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zipCode = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _confirmCode = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _deleteConfirm = TextEditingController();

  final Set<Field> _updated = {};

  final SessionToken _sessionToken = SessionToken();

  String _isoCode = 'US';
  String _dialCode = '+1';

  String _firstNameError = '';
  String _lastNameError = '';
  String _streetError = '';
  String _cityError = '';
  String _stateError = '';
  String _zipError = '';
  String _phoneError = '';
  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';
  String _deleteError = '';

  bool _showSpinner = false;

  String _phoneButtonLabel = 'Add';
  bool _showVerifyPhone = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  DeleteMode _deleteMode = DeleteMode.Input;
  bool _obscureDeletePassword = true;

  Future<String> Function(String smsCode) _verifyCode;

  StateSetter _setDialogState;

  void _updateInputFields() {
    _fillEmail();
    if (_updated.isEmpty) {
      _fillName();
      _fillAddress();
      _fillPhone();
    }
    if (_updated.contains(Field.Name)) {
      _fillName();
    }
    if (_updated.contains(Field.Address)) {
      _fillAddress();
    }
    if (_updated.contains(Field.Phone)) {
      _fillPhone();
    }
    setState(() {});
  }

  void _fillEmail() {
    _email.text = context.read<Account>().email;
  }

  void _fillName() {
    Account account = context.read<Account>();
    _firstName.text = account.firstName;
    _lastName.text = account.lastName;
  }

  void _fillAddress() {
    Map<String, String> address = context.read<Account>().address;
    if (address.isNotEmpty) {
      _street.text = address[FireStoreService.kAddressStreet];
      _city.text = address[FireStoreService.kAddressCity];
      _state.text = address[FireStoreService.kAddressState];
      _zipCode.text = address[FireStoreService.kAddressZip];
    } else {
      _street.clear();
      _city.clear();
      _state.clear();
      _zipCode.clear();
    }
  }

  void _fillPhone() {
    Map<String, String> phone = context.read<Account>().phone;
    if (phone.isNotEmpty) {
      _isoCode = phone[FireStoreService.kPhoneCountry];
      _dialCode = phone[FireStoreService.kPhoneDialCode];
      _phoneNumber.text = phone[FireStoreService.kPhoneNumber];
      _phoneButtonLabel = 'Remove';
    } else {
      _isoCode = 'US';
      _dialCode = '+1';
      _phoneNumber.clear();
      _phoneButtonLabel = 'Add';
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
    String notifyMessage;
    if (errorMessage.isEmpty) {
      notifyMessage = 'Profile is up-to-date';
      if (_updated.isNotEmpty) {
        notifyMessage = 'Profile updated';
        _updated.clear();
      }
    } else {
      _scrollToError();
      notifyMessage = errorMessage;
    }
    setState(() => _showSpinner = false);
    MessageBar(context, message: notifyMessage).show();
  }

  Future<String> _updateName() async {
    String firstName = _firstName.text.trim();
    String lastName = _lastName.text.trim();
    Account account = context.read<Account>();
    if (firstName != account.firstName || lastName != account.lastName) {
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
          _updated.add(Field.Name);
          await context.read<FireStoreService>().updateDonorName(
                firstName: firstName,
                lastName: lastName,
              );
        } catch (errorMessage) {
          _updated.remove(Field.Name);
          return errorMessage;
        }
      } else {
        return 'Please check your inputs!';
      }
    }
    return '';
  }

  Future<String> _updateAddress() async {
    String street = _street.text.trim();
    String city = _city.text.trim();
    String state = _state.text.trim();
    String zip = _zipCode.text.trim();
    Account account = context.read<Account>();
    Map<String, String> address = account.address;
    bool isFilled = _addressIsFilled();
    bool insert = address.isEmpty && isFilled;
    bool update = address.isNotEmpty &&
        (street != address[FireStoreService.kAddressStreet] ||
            city != address[FireStoreService.kAddressCity] ||
            state != address[FireStoreService.kAddressState] ||
            zip != address[FireStoreService.kAddressZip]);
    if (insert || update) {
      String error = '';
      if (isFilled) {
        error += _streetError = Validate.checkStreet(street);
        error += _cityError = Validate.checkCity(city);
        error += _stateError = Validate.checkState(state);
        error += _zipError = Validate.zipCode(zip);
      }
      if (error.isEmpty) {
        try {
          _updated.add(Field.Address);
          await context.read<FireStoreService>().updateUserAddress(
                street: street,
                city: city,
                state: state,
                zip: zip,
              );
        } catch (errorMessage) {
          _updated.remove(Field.Address);
          return errorMessage;
        }
      } else {
        return 'Please check your inputs!';
      }
    }
    return '';
  }

  bool _addressIsFilled() {
    bool isFilled = _street.text.trim().isNotEmpty ||
        _city.text.trim().isNotEmpty ||
        _state.text.trim().isNotEmpty ||
        _zipCode.text.trim().isNotEmpty;
    if (!isFilled) {
      _streetError = _cityError = _stateError = _zipError = '';
    }
    return isFilled;
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
          _updated.add(Field.Password);
          await context.read<FireAuthService>().updatePassword(
                email: _email.text.trim(),
                oldPassword: oldPassword,
                newPassword: newPassword,
              );
          _oldPassword.clear();
          _newPassword.clear();
          _confirmPassword.clear();
        } catch (errorMessage) {
          _updated.remove(Field.Password);
          return errorMessage;
        }
      } else {
        return 'Please check your inputs!';
      }
    }
    return '';
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
      Account account = context.read<Account>();
      Map<String, String> phone = account.phone;
      bool insert = phone.isEmpty && phoneNumber.isNotEmpty;
      bool update = phone.isNotEmpty &&
          (phoneNumber != phone[FireStoreService.kPhoneNumber] ||
              _isoCode != phone[FireStoreService.kPhoneCountry]);
      String notifyMessage = '';
      if (insert || update) {
        notifyMessage = await auth.registerPhone(
          country: _isoCode,
          dialCode: _dialCode,
          phoneNumber: phoneNumber,
          codeSent: (verifyCode) async {
            _verifyCode = verifyCode;
          },
          completed: (register) async {
            setState(() => _showSpinner = true);
            _updated.add(Field.Phone);
            String errorMessage = await register();
            _updated.remove(Field.Phone);
            if (errorMessage.isEmpty) {
              _confirmCode.clear();
              _verifyCode = null;
              _showVerifyPhone = false;
              _phoneButtonLabel = 'Remove';
              errorMessage = 'Phone number updated';
            }
            MessageBar(context, message: errorMessage).show();
            setState(() => _showSpinner = false);
          },
          failed: (errorMessage) async {
            MessageBar(context, message: await errorMessage()).show();
          },
        );
        _confirmCode.clear();
        _showVerifyPhone = true;
        _phoneButtonLabel = 'Re-send';
      } else {
        notifyMessage = await _deletePhoneNumber();
      }
      MessageBar(context, message: notifyMessage).show();
    }
    setState(() => _showSpinner = false);
  }

  void _updatePhoneVerify() async {
    if (_verifyCode != null) {
      setState(() => _showSpinner = true);
      _updated.add(Field.Phone);
      String errorMessage = await _verifyCode(_confirmCode.text.trim());
      _updated.remove(Field.Phone);
      if (errorMessage.isEmpty) {
        _confirmCode.clear();
        _verifyCode = null;
        _showVerifyPhone = false;
        _phoneButtonLabel = 'Remove';
        errorMessage = 'Phone number updated';
      }
      MessageBar(context, message: errorMessage).show();
      setState(() => _showSpinner = false);
    }
  }

  Future<String> _deletePhoneNumber() async {
    String notifyMessage = 'Phone number removed';
    try {
      _updated.add(Field.Phone);
      await context.read<FireAuthService>().removePhone(
            country: _isoCode,
            dialCode: _dialCode,
            phoneNumber: '',
          );
      _phoneNumber.clear();
      _phoneButtonLabel = 'Add';
    } catch (errorMessage) {
      notifyMessage = errorMessage;
    } finally {
      _updated.remove(Field.Phone);
    }
    return notifyMessage;
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

  void _deleteAccount() async {
    String password = _deleteConfirm.text;
    _deleteError = Validate.checkPassword(password);
    if (_deleteError.isEmpty) {
      _setDialogState(() => _deleteMode = DeleteMode.Loading);
      try {
        await context.read<FireAuthService>().deleteAccount(
              email: _email.text.trim(),
              password: password,
            );
        context.read<Account>().clear();
        context.read<Donation>().clear();
        context.read<Produce>().clear();
        context.read<Charities>().clear();
        FireStoreService fireStore = context.read<FireStoreService>();
        await context.read<FireMessagingService>().clear(fireStore);
        fireStore.clear();
        _setDialogState(() => _deleteMode = DeleteMode.Success);
        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.of(context).pushNamedAndRemoveUntil(
          SignOptionScreen.id,
          (route) => false,
        );
        Navigator.of(context).pushNamed(SignInScreen.id);
      } catch (errorMessage) {
        _deleteError = errorMessage;
        _setDialogState(() => _deleteMode = DeleteMode.Input);
      }
    }
    _setDialogState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fillEmail();
    _fillName();
    _fillAddress();
    _fillPhone();
    FireStoreService fireStore = context.read<FireStoreService>();
    fireStore.accountStream(context.read<Account>(), onComplete: () {
      if (mounted) {
        _updateInputFields();
      }
    });
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
    return WillPopScope(
      onWillPop: () async {
        MessageBar(context).hide();
        context.read<Account>().cancelLastSubscription();
        return true;
      },
      child: GestureWrapper(
        child: Scaffold(
          appBar: AppBar(title: Text('Profile')),
          body: SafeArea(
            child: Container(
              decoration: kGradientBackground,
              child: ModalProgressHUD(
                inAsyncCall: _showSpinner,
                progressIndicator: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(kAccentColor),
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
                        inputGroupLabel(
                          'Phone Number',
                          tag: Field.Phone,
                        ),
                        phoneNumberField(),
                        verifyCodeField(),
                        inputFieldSizedBox(),
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
                        saveButton(),
                        SizedBox(height: screen.height * 0.05),
                        deleteAccountLink(),
                      ],
                    ),
                  ),
                ),
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
          bottom: screen.height * 0.01,
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
          ],
        ),
      ),
    );
  }

  Widget inputFieldSizedBox() {
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

  Widget streetInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputFieldSuggestion<Map<String, String>>(
          label: 'Street',
          controller: _street,
          suggestionsCallback: (pattern) async {
            if (pattern.isNotEmpty) {
              return await MapService.addressSuggestions(
                pattern,
                sessionToken: _sessionToken.getToken(),
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
                suggestion[MapService.kDescription],
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
            Map<String, String> address = await MapService.addressDetails(
              suggestion[MapService.kPlaceId],
              sessionToken: _sessionToken.getToken(),
            );
            if (address.isNotEmpty) {
              setState(() {
                _street.text = address[MapService.kStreet];
                _city.text = address[MapService.kCity];
                _state.text = address[MapService.kState];
                _zipCode.text = address[MapService.kZipCode];
                _streetError = Validate.checkStreet(_street.text.trim());
                _cityError = Validate.checkCity(_city.text.trim());
                _stateError = Validate.checkState(_state.text.trim());
                _zipError = Validate.zipCode(_zipCode.text.trim());
              });
              _sessionToken.clear();
            }
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
                  _showVerifyPhone = false;
                  _phoneButtonLabel = 'Remove';
                  Map<String, String> phone = context.read<Account>().phone;
                  bool insert = phone.isEmpty && phoneNumber.isNotEmpty;
                  bool update = phone.isNotEmpty &&
                      (phoneNumber != phone[FireStoreService.kPhoneNumber] ||
                          _isoCode != phone[FireStoreService.kPhoneCountry]);
                  if (insert || update || phoneNumber.isEmpty) {
                    _phoneButtonLabel = 'Add';
                  }
                  setState(() {});
                },
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: RoundedButton(
                label: _phoneButtonLabel,
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
      visible: _showVerifyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InputField(
                  label: '6-Digit Code',
                  controller: _confirmCode,
                  helperText: null,
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                flex: 2,
                child: RoundedButton(
                  label: 'Verify',
                  onPressed: () {
                    _updatePhoneVerify();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget currentPasswordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'Current Password',
          controller: _oldPassword,
          keyboardType: TextInputType.visiblePassword,
          errorMessage: _oldPasswordError,
          obscureText: _obscureOldPassword,
          suffixWidget: SizedBox(width: 20.0),
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
          keyboardType: TextInputType.visiblePassword,
          errorMessage: _newPasswordError,
          obscureText: _obscureNewPassword,
          suffixWidget: SizedBox(width: 20.0),
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
        MessageBar(context).hide();
        showDeleteDialog();
      },
    );
  }

  void showDeleteDialog() {
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
        isButtonVisible: false,
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
          _setDialogState = setState;
          return Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: deleteLayout(),
          );
        },
      ),
    ).show();
  }

  Widget deleteLayout() {
    switch (_deleteMode) {
      case DeleteMode.Loading:
        return Container(
          height: 50.0,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAccentColor),
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
                    _setDialogState(() {
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
                      _setDialogState(() {
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
