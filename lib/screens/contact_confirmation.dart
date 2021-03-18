import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/services/address_service.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/services/session_token.dart';
import 'package:fruitfairy/services/validation.dart';
import 'package:fruitfairy/widgets/auto_scroll.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field_suggestion.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'charity_selection_screen.dart';

enum Field { Phone, Address }

class ContactConfirmationScreen extends StatefulWidget {
  static const String id = 'contact_confirmation_screen';

  @override
  _ContactConfirmation createState() => _ContactConfirmation();
}

class _ContactConfirmation extends State<ContactConfirmationScreen> {
  final AutoScroll<Field> _scroller = AutoScroll(
    elements: {
      Field.Phone: 0,
      Field.Address: 1,
    },
  );

  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _confirmCode = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zipCode = TextEditingController();

  final SessionToken sessionToken = SessionToken();

  String _isoCode = 'US';
  String _dialCode = '+1';

  String _phoneError = '';
  String _streetError = '';
  String _cityError = '';
  String _stateError = '';
  String _zipError = '';

  bool _showSpinner = false;
  bool _needVerifyPhone = false;
  String _updatePhoneLabel = 'Add';


  Future<String> Function(String smsCode) _verifyCode;


  void _fillInputFields() {
    Account account = context.read<Account>();
    Map<String, String> phone = account.phone;
    if (phone.isNotEmpty) {
      _isoCode = phone[FireStoreService.kPhoneCountry];
      _dialCode = phone[FireStoreService.kPhoneDialCode];
      _phoneNumber.text = phone[FireStoreService.kPhoneNumber];
      _updatePhoneLabel = 'Remove';
    } else {
      _isoCode = 'US';
      _dialCode = '+1';
      _phoneNumber.clear();
      _updatePhoneLabel = 'Add';
    }
    Map<String, String> address = account.address;
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
    setState(() {});
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
      bool insert = phone.isEmpty && (phoneNumber.isNotEmpty);
      bool update = phone.isNotEmpty &&
          (phoneNumber != phone[FireStoreService.kPhoneNumber] ||
              _isoCode != phone[FireStoreService.kPhoneCountry]);
      if (insert || update) {
        String notifyMessage = await auth.registerPhone(
          phoneNumber: '$_dialCode$phoneNumber',
          update: account.phone.isNotEmpty,
          codeSent: (verifyCode) async {
            if (verifyCode != null) {
              _verifyCode = verifyCode;
            }
          },
          failed: (errorMessage) {
            MessageBar(context, message: errorMessage).show();
          },
        );
        _confirmCode.clear();
        _needVerifyPhone = true;
        _updatePhoneLabel = 'Re-send';
        MessageBar(context, message: notifyMessage).show();
      } else {
        if (await auth.removePhone()) {
          await context.read<FireStoreService>().updatePhoneNumber(
            country: _isoCode,
            dialCode: _dialCode,
            phoneNumber: '',
          );
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
    if (_verifyCode != null) {
      String errorMessage = await _verifyCode(_confirmCode.text.trim());
      if (errorMessage.isEmpty) {
        String phoneNumber = _phoneNumber.text.trim();
        await context.read<FireStoreService>().updatePhoneNumber(
          country: _isoCode,
          dialCode: _dialCode,
          phoneNumber: phoneNumber,
        );
        _phoneNumber.text = phoneNumber;
        _confirmCode.clear();
        _needVerifyPhone = false;
        _updatePhoneLabel = 'Remove';
        _verifyCode = null;
        errorMessage = 'Phone number updated';
      }
      MessageBar(context, message: errorMessage).show();
    }
    setState(() => _showSpinner = false);
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


  @override
  void initState() {
    super.initState();
    _fillInputFields();
  }

  @override
  void dispose() {
    super.dispose();
    _scroller.controller.dispose();
    _phoneNumber.dispose();
    _confirmCode.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _zipCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return GestureWrapper(
      child: Scaffold(
        appBar: AppBar(title: Text('Contact Confirmation')),
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
                      'Phone Number',
                      tag: Field.Phone,
                    ),
                    phoneNumberField(),
                    verifyCodeField(),
                    inputGroupSizedBox(),
                    nextButton(),
                    SizedBox(height: screen.height * 0.05),
                    //deleteAccountLink(),
                  ],
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
                  _needVerifyPhone = false;
                  _updatePhoneLabel = 'Remove';
                  Map<String, String> phone = context.read<Account>().phone;
                  bool insert = phone.isEmpty && (phoneNumber.isNotEmpty);
                  bool update = phone.isNotEmpty &&
                      (phoneNumber != phone[FireStoreService.kPhoneNumber] ||
                          _isoCode != phone[FireStoreService.kPhoneCountry]);
                  if (insert || update || phoneNumber.isEmpty) {
                    _updatePhoneLabel = 'Add';
                  }
                  setState(() {});
                },
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: RoundedButton(
                label: _updatePhoneLabel,
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
      visible: _needVerifyPhone,
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
              return await AddressService.getSuggestions(
                pattern,
                sessionToken: sessionToken.getToken(),
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
                suggestion[AddressService.kDescription],
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
              suggestion[AddressService.kPlaceId],
              sessionToken: sessionToken.getToken(),
            );
            if (address.isNotEmpty) {
              _street.text = address[AddressService.kStreet];
              _city.text = address[AddressService.kCity];
              _state.text = address[AddressService.kState];
              _zipCode.text = address[AddressService.kZipCode];
              sessionToken.clear();
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

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.15,
      ),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          //_updateProfile();
          Navigator.of(context).pushNamed(CharitySelectionScreen.id);
        },
      ),
    );
  }
}
