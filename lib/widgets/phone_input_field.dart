import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:international_phone_input/international_phone_input.dart';

import 'package:fruitfairy/utils/constant.dart';

class PhoneInputField extends StatefulWidget {
  final String initialPhoneNumber;
  final String initialSelection;
  final String errorMessage;
  final bool showCountryCodes;
  final bool showCountryFlags;
  final bool showDropdownIcon;
  final List<String> enabledCountries;
  final void Function(String phoneNumber, String internationalizedPhoneNumber,
      String isoCode) onPhoneNumberChanged;
  final GestureTapCallback onTap;

  PhoneInputField({
    this.initialPhoneNumber,
    this.initialSelection,
    this.errorMessage,
    this.showCountryCodes = true,
    this.showCountryFlags = true,
    this.showDropdownIcon = true,
    this.enabledCountries = const [],
    this.onPhoneNumberChanged,
    this.onTap,
  });
  @override
  _PhoneInputFieldState createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  Country selectedCountry;
  List<Country> countryList = [];

  final phoneTextController = TextEditingController();

  Future<List<Country>> _fetchCountryData() async {
    String jsonObj = await DefaultAssetBundle.of(context)
        .loadString('packages/international_phone_input/assets/countries.json');
    List<dynamic> jsonList = json.decode(jsonObj);

    List<Country> countries = List<Country>.generate(jsonList.length, (index) {
      Map<String, String> elem = Map<String, String>.from(jsonList[index]);
      if (widget.enabledCountries.isEmpty) {
        return Country(
            name: elem['en_short_name'],
            code: elem['alpha_2_code'],
            dialCode: elem['dial_code'],
            flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png');
      } else if (widget.enabledCountries.contains(elem['alpha_2_code']) ||
          widget.enabledCountries.contains(elem['dial_code'])) {
        return Country(
            name: elem['en_short_name'],
            code: elem['alpha_2_code'],
            dialCode: elem['dial_code'],
            flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png');
      } else {
        return null;
      }
    });
    countries.removeWhere((value) => value == null);
    return countries;
  }

  void _setSelectedCountry() async {
    List<Country> countries = await _fetchCountryData();
    Country preSelectedItem;
    if (widget.initialSelection != null) {
      preSelectedItem = countries.firstWhere(
          (e) =>
              (e.code.toUpperCase() == widget.initialSelection.toUpperCase()) ||
              (e.dialCode == widget.initialSelection.toString()),
          orElse: () => countries[0]);
    } else {
      preSelectedItem = countries[0];
    }
    setState(() {
      countryList = countries;
      selectedCountry = preSelectedItem;
    });
  }

  void _validatePhoneNumber() async {
    String phoneNumber = phoneTextController.text;
    String isoCode = selectedCountry.code;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      bool isValid = await PhoneService.parsePhoneNumber(phoneNumber, isoCode);
      if (isValid) {
        String intlNumber = await PhoneService.getNormalizedPhoneNumber(
            phoneNumber, selectedCountry.code);
        widget.onPhoneNumberChanged(phoneNumber, intlNumber, isoCode);
      } else {
        widget.onPhoneNumberChanged('', '', isoCode);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _setSelectedCountry();
    phoneTextController.text = widget.initialPhoneNumber;
  }

  @override
  void dispose() {
    super.dispose();
    phoneTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              dropdownButton(),
              textInputField(),
            ],
          ),
          errorText(),
        ],
      ),
    );
  }

  Widget dropdownButton() {
    return DropdownButtonHideUnderline(
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: DropdownButton<Country>(
          value: selectedCountry,
          icon: Padding(
            padding: EdgeInsets.only(bottom: 6.0),
            child: Icon(Icons.arrow_drop_down, color: kLabelColor),
          ),
          iconSize: widget.showDropdownIcon ? 24.0 : 0.0,
          dropdownColor: kLabelColor.withOpacity(0.5),
          onChanged: (Country newValue) {
            setState(() {
              selectedCountry = newValue;
            });
            _validatePhoneNumber();
            HapticFeedback.mediumImpact();
          },
          onTap: () {
            HapticFeedback.mediumImpact();
          },
          items: countryList.map<DropdownMenuItem<Country>>((Country value) {
            return DropdownMenuItem<Country>(
              value: value,
              child: Container(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.showCountryFlags) ...[
                      Image.asset(
                        value.flagUri,
                        width: 32.0,
                        package: 'international_phone_input',
                      )
                    ],
                    if (widget.showCountryCodes) ...[
                      SizedBox(width: 4),
                      Text(
                        value.dialCode,
                        style: TextStyle(
                          color: kLabelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget textInputField() {
    return Flexible(
      child: TextField(
        cursorColor: kLabelColor,
        style: TextStyle(
          color: kLabelColor,
        ),
        keyboardType: TextInputType.phone,
        controller: phoneTextController,
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: TextStyle(
            color: kLabelColor,
            fontSize: 18.0,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          filled: true,
          fillColor: kObjectBackgroundColor.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kLabelColor, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kLabelColor, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kErrorColor, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kErrorColor, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
        ),
        onChanged: (value) {
          _validatePhoneNumber();
        },
        onTap: widget.onTap,
      ),
    );
  }

  Widget errorText() {
    return Text(
      widget.errorMessage,
      style: TextStyle(
        color: kErrorColor,
        fontSize: 16.0,
      ),
    );
  }
}
