import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/screens/profile_screen.dart';
import 'package:fruitfairy/services/map_service.dart';
import 'package:fruitfairy/services/session_token.dart';
import 'package:fruitfairy/services/validation.dart';
import 'package:fruitfairy/widgets/auto_scroll.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/input_field_suggestion.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:fruitfairy/constant.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CharityProfileScreen extends StatefulWidget {
  static const String id = 'charity_profile_screen';

  @override
  _CharityProfileScreenState createState() => _CharityProfileScreenState();
}

class _CharityProfileScreenState extends State<CharityProfileScreen> {
  bool _showSpinner = false;

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

  //final Set<Field> _updated = {};

  final SessionToken sessionToken = SessionToken();

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

  String _phoneButtonLabel = 'Add';
  bool _showVerifyPhone = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  DeleteMode _deleteMode = DeleteMode.Input;
  bool _obscureDeletePassword = true;

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
          appBar: AppBar(title: Text('Profile')),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
              ),
              child: ScrollableLayout(
                //controller: _scroller.controller,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.03,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    children: [
                      inputGroupLabel(
                        'Account',
                        //tag: Field.Name,
                      ),
                      emailInputField(),
                      einInputField(),
                      inputFieldSizedBox(),
                      inputGroupLabel(
                        'Address',
                        // tag: Field.Address,
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
                        //   tag: Field.Phone,
                      ),
                      phoneNumberField(),
                      verifyCodeField(),
                      inputFieldSizedBox(),
                      inputGroupLabel(
                        'Change Password',
                        //   tag: Field.Password,
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
    );
  }

  Widget inputGroupLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
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
    );
  }

  Widget emailInputField() {
    return InputField(
      label: 'Email',
      labelColor: kLabelColor.withOpacity(0.5),
      //controller: _email,
      readOnly: true,
    );
  }

  Widget inputFieldSizedBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.01);
  }

  Widget einInputField() {
    return InputField(
      label: 'EIN',
      //controller: _firstName,
      //errorMessage: _firstNameError,
      onChanged: (value) {
        setState(() {
          //_firstNameError = Validate.name(
          //label: 'first name',
          //name: _firstName.text.trim(),
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
          //controller: _street,
          suggestionsCallback: (pattern) async {
            if (pattern.isNotEmpty) {
              return await MapService.getAddressSuggestions(
                pattern,
                //sessionToken: sessionToken.getToken(),
              );
            }
            return null;
          },
          // onChanged: (value) {
          //   setState(() {
          //     if (_addressIsFilled()) {
          //       _streetError = Validate.checkStreet(_street.text.trim());
          //     }
          //   });
          // },
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
            Map<String, String> address = await MapService.getAddressDetails(
              suggestion[MapService.kPlaceId],
              //sessionToken: sessionToken.getToken(),
            );
            // if (address.isNotEmpty) {
            //   setState(() {
            //     _street.text = address[AddressService.kStreet];
            //     _city.text = address[AddressService.kCity];
            //     _state.text = address[AddressService.kState];
            //     _zipCode.text = address[AddressService.kZipCode];
            //     _streetError = Validate.checkStreet(_street.text.trim());
            //     _cityError = Validate.checkCity(_city.text.trim());
            //     _stateError = Validate.checkState(_state.text.trim());
            //     _zipError = Validate.zipCode(_zipCode.text.trim());
            //   });
            //   sessionToken.clear();
            // }
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
          // if (_addressIsFilled()) {
          //   _cityError = Validate.checkCity(_city.text.trim());
          // }
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
          // if (_addressIsFilled()) {
          //   _stateError = Validate.checkState(_state.text.trim());
          // }
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
          // if (_addressIsFilled()) {
          //   _zipError = Validate.zipCode(_zipCode.text.trim());
          // }
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
                // onChanged: (value) async {
                //   String phoneNumber = _phoneNumber.text.trim();
                //   _phoneError = '';
                //   // if (phoneNumber.isNotEmpty) {
                //   //   _phoneError = await Validate.phoneNumber(
                //   //     phoneNumber: phoneNumber,
                //   //     isoCode: _isoCode,
                //   //   );
                //   // }
                //   _showVerifyPhone = false;
                //   _phoneButtonLabel = 'Remove';
                //   Map<String, String> phone = context.read<Account>().phone;
                //   bool insert = phone.isEmpty && phoneNumber.isNotEmpty;
                //   bool update = phone.isNotEmpty &&
                //       (phoneNumber != phone[FireStoreService.kPhoneNumber] ||
                //           _isoCode != phone[FireStoreService.kPhoneCountry]);
                //   if (insert || update || phoneNumber.isEmpty) {
                //     _phoneButtonLabel = 'Add';
                //   }
                //   setState(() {});
                // },
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: RoundedButton(
                label: _phoneButtonLabel,
                // onPressed: () {
                //   _updatePhoneRequest();
                // },
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
      //visible: _showVerifyPhone,
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
                    //_updatePhoneVerify();
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
          //_updateProfile();
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
          //_setDialogState = setState;
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
              valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
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
                  // onChanged: (value) {
                  //   _setDialogState(() {
                  //     _deleteError =
                  //         Validate.checkPassword(_deleteConfirm.text);
                  //   });
                  // },
                ),
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: ObscureIcon(
                    obscure: _obscureDeletePassword,
                    // onTap: () {
                    //   _setDialogState(() {
                    //     _obscureDeletePassword = !_obscureDeletePassword;
                    //   });
                    // },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: RoundedButton(
                label: 'Delete',
                // onPressed: () {
                //   _deleteAccount();
                // },
              ),
            ),
          ],
        );
    }
  }
}
