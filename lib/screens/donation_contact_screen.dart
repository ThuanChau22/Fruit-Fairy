import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/screens/charity_selection_screen.dart';
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

enum Field { Address, Phone }

class DonationContactScreen extends StatefulWidget {
  static const String id = 'donation_contact_screen';

  @override
  _ContactConfirmation createState() => _ContactConfirmation();
}

class _ContactConfirmation extends State<DonationContactScreen> {
  final AutoScroll<Field> _scroller = AutoScroll(
    elements: {
      Field.Address: 0,
      Field.Phone: 1,
    },
  );

  final TextEditingController _street = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zipCode = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _confirmCode = TextEditingController();

  final Set<Field> _updated = {};

  final SessionToken sessionToken = SessionToken();

  String _isoCode = 'US';
  String _dialCode = '+1';

  String _streetError = '';
  String _cityError = '';
  String _stateError = '';
  String _zipError = '';
  String _phoneError = '';

  bool _showSpinner = false;

  String _phoneButtonLabel = 'Add';
  bool _showVerifyPhone = false;
  bool _phoneVerified = false;

  StreamSubscription<DocumentSnapshot> _subscription;

  Future<String> Function(String smsCode) _verifyCode;

  void _fillInputFields() {
    if (_updated.isEmpty) {
      fillAddress();
      fillPhone();
    } else {
      if (_updated.contains(Field.Address)) {
        fillAddress();
      }
      if (_updated.contains(Field.Phone)) {
        fillPhone();
      }
    }
    setState(() {});
  }

  void fillAddress() {
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

  void fillPhone() {
    Map<String, String> phone = context.read<Account>().phone;
    if (phone.isNotEmpty) {
      _isoCode = phone[FireStoreService.kPhoneCountry];
      _dialCode = phone[FireStoreService.kPhoneDialCode];
      _phoneNumber.text = phone[FireStoreService.kPhoneNumber];
      _phoneVerified = true;
    } else {
      _isoCode = 'US';
      _dialCode = '+1';
      _phoneNumber.clear();
      _phoneButtonLabel = 'Add';
      _phoneVerified = false;
    }
  }

  void confirm() async {
    setState(() => _showSpinner = true);
    String addressError = await _updateAddress();
    _phoneError = await Validate.phoneNumber(
      phoneNumber: _phoneNumber.text.trim(),
      isoCode: _isoCode,
    );
    if (addressError.isEmpty && _phoneError.isEmpty && _phoneVerified) {
      context.read<Donation>().setContactInfo(
            street: _street.text.trim(),
            city: _city.text.trim(),
            state: _state.text.trim(),
            zip: _zipCode.text.trim(),
            country: _isoCode,
            dialCode: _dialCode,
            phoneNumber: _phoneNumber.text.trim(),
          );
      Navigator.of(context).pushNamed(CharitySelectionScreen.id);
    } else {
      _scrollToError();
      String errorMessage = '';
      if (addressError.isNotEmpty) {
        errorMessage = addressError;
      } else if (_phoneError.isNotEmpty) {
        errorMessage = 'Please check your inputs!';
      } else if (!_phoneVerified) {
        errorMessage = 'Please verify your phone number!';
      }
      MessageBar(context, message: errorMessage).show();
    }
    setState(() => _showSpinner = false);
  }

  Future<String> _updateAddress() async {
    String street = _street.text.trim();
    String city = _city.text.trim();
    String state = _state.text.trim();
    String zip = _zipCode.text.trim();
    Map<String, String> address = context.read<Account>().address;
    bool insert = address.isEmpty;
    bool update = address.isNotEmpty &&
        (street != address[FireStoreService.kAddressStreet] ||
            city != address[FireStoreService.kAddressCity] ||
            state != address[FireStoreService.kAddressState] ||
            zip != address[FireStoreService.kAddressZip]);
    if (insert || update) {
      String error = _streetError = Validate.checkStreet(street);
      error += _cityError = Validate.checkCity(city);
      error += _stateError = Validate.checkState(state);
      error += _zipError = Validate.zipCode(zip);
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
          return errorMessage;
        } finally {
          _updated.remove(Field.Address);
        }
      } else {
        return 'Please check your inputs!';
      }
    }
    return '';
  }

  void _verifyPhoneRequest() async {
    setState(() => _showSpinner = true);
    String phoneNumber = _phoneNumber.text.trim();
    _phoneError = await Validate.phoneNumber(
      phoneNumber: phoneNumber,
      isoCode: _isoCode,
    );
    if (_phoneError.isEmpty) {
      FireAuthService auth = context.read<FireAuthService>();
      if (isNewPhone(phoneNumber)) {
        String notifyMessage = await auth.registerPhone(
          phoneNumber: '$_dialCode$phoneNumber',
          codeSent: (verifyCode) async {
            _verifyCode = verifyCode;
          },
          completed: (result) async {
            setState(() => _showSpinner = true);
            String errorMessage = await result();
            if (errorMessage.isEmpty) {
              errorMessage = await updatePhoneNumber();
            }
            if (errorMessage.isNotEmpty) {
              MessageBar(context, message: errorMessage).show();
            }
            setState(() => _showSpinner = false);
          },
          failed: (errorMessage) async {
            MessageBar(context, message: await errorMessage()).show();
          },
        );
        _confirmCode.clear();
        _showVerifyPhone = true;
        _phoneButtonLabel = 'Re-send';
        MessageBar(context, message: notifyMessage).show();
      }
    }
    setState(() => _showSpinner = false);
  }

  bool isNewPhone(String phoneNumber) {
    Account account = context.read<Account>();
    Map<String, String> phone = account.phone;
    bool insert = phone.isEmpty;
    bool update = phone.isNotEmpty &&
        (phoneNumber != phone[FireStoreService.kPhoneNumber] ||
            _isoCode != phone[FireStoreService.kPhoneCountry]);
    return insert || update;
  }

  void _verifyPhoneConfirm() async {
    setState(() => _showSpinner = true);
    if (_verifyCode != null) {
      String errorMessage = await _verifyCode(_confirmCode.text.trim());
      if (errorMessage.isEmpty) {
        errorMessage = await updatePhoneNumber();
      }
      if (errorMessage.isNotEmpty) {
        MessageBar(context, message: errorMessage).show();
      }
    }
    setState(() => _showSpinner = false);
  }

  Future<String> updatePhoneNumber() async {
    try {
      _updated.add(Field.Phone);
      String phoneNumber = _phoneNumber.text.trim();
      await context.read<FireStoreService>().updatePhoneNumber(
            country: _isoCode,
            dialCode: _dialCode,
            phoneNumber: phoneNumber,
          );
      _phoneNumber.text = phoneNumber;
      _confirmCode.clear();
      _showVerifyPhone = false;
      _phoneVerified = true;
      _verifyCode = null;
    } catch (errorMessage) {
      return errorMessage;
    } finally {
      _updated.remove(Field.Phone);
    }
    return '';
  }

  void _scrollToError() async {
    Field tag;
    if (_streetError.isNotEmpty ||
        _cityError.isNotEmpty ||
        _stateError.isNotEmpty ||
        _zipError.isNotEmpty) {
      tag = Field.Address;
    } else if (_phoneError.isNotEmpty || !_phoneVerified) {
      tag = Field.Phone;
    }
    _scroller.scroll(tag);
  }

  @override
  void initState() {
    super.initState();
    fillAddress();
    fillPhone();
    _subscription = context.read<FireStoreService>().userStream((userData) {
      _fillInputFields();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scroller.controller.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _zipCode.dispose();
    _phoneNumber.dispose();
    _confirmCode.dispose();
    _subscription.cancel();
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
          appBar: AppBar(title: Text('Donation')),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.width * 0.05,
                ),
                child: Column(
                  children: [
                    titleLabel(),
                    contactInfo(),
                    buttonSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget titleLabel() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.03,
        bottom: screen.height * 0.02,
      ),
      child: Text(
        'Contact Infomation',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
        ),
      ),
    );
  }

  Widget contactInfo() {
    List<Widget> widgets = [
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
      inputGroupLabel(
        'Phone Number',
        tag: Field.Phone,
      ),
      phoneNumberField(),
      verifyCodeField(),
    ];
    Size screen = MediaQuery.of(context).size;
    return Expanded(
      child: ListView.builder(
        controller: _scroller.controller,
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.1,
            ),
            child: widgets[index],
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
            SizedBox(height: screen.height * 0.01),
          ],
        ),
      ),
    );
  }

  Widget inputFieldSizedBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.01);
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
              _streetError = Validate.checkStreet(_street.text.trim());
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
              setState(() {
                _street.text = address[AddressService.kStreet];
                _city.text = address[AddressService.kCity];
                _state.text = address[AddressService.kState];
                _zipCode.text = address[AddressService.kZipCode];
                String street = _street.text.trim();
                String city = _city.text.trim();
                String state = _state.text.trim();
                String zipCode = _zipCode.text.trim();
                _streetError = Validate.checkStreet(street);
                _cityError = Validate.checkCity(city);
                _stateError = Validate.checkState(state);
                _zipError = Validate.zipCode(zipCode);
              });
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
          _cityError = Validate.checkCity(_city.text.trim());
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
          _stateError = Validate.checkState(_state.text.trim());
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
          _zipError = Validate.zipCode(_zipCode.text.trim());
        });
      },
    );
  }

  Widget phoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
                  _showVerifyPhone = false;
                  _phoneVerified = true;
                  if (isNewPhone(phoneNumber)) {
                    _phoneButtonLabel = 'Add';
                    _phoneVerified = false;
                  }
                  setState(() {});
                },
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: _phoneVerified
                  ? Material(
                      elevation: 2.0,
                      color: kObjectColor,
                      borderRadius: BorderRadius.circular(30.0),
                      child: SizedBox(
                        height: 48.0,
                        child: Center(
                          child: Text(
                            'Verified',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : RoundedButton(
                      label: _phoneButtonLabel,
                      onPressed: () {
                        _verifyPhoneRequest();
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
                    _verifyPhoneConfirm();
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

  Widget buttonSection() {
    EdgeInsets view = MediaQuery.of(context).viewInsets;
    return Visibility(
      visible: view.bottom == 0.0,
      child: Column(
        children: [
          divider(),
          nextButton(),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 5.0,
      thickness: 3.0,
    );
  }

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
        horizontal: screen.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          confirm();
        },
      ),
    );
  }
}
