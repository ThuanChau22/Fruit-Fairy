import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:fruitfairy/constant.dart';

// Modified widget from international_phone_input package
class InternationalPhoneInput extends StatefulWidget {
  final void Function(
    String phoneNumber,
    String internationalizedPhoneNumber,
    String isoCode,
  ) onPhoneNumberChange;
  final String initialPhoneNumber;
  final String initialSelection;
  final List<String> enabledCountries;
  final bool showCountryCodes;
  final bool showCountryFlags;
  final bool showDropdownIcon;

  InternationalPhoneInput({
    this.onPhoneNumberChange,
    this.initialPhoneNumber,
    this.initialSelection,
    this.enabledCountries = const [],
    this.showCountryCodes = true,
    this.showCountryFlags = true,
    this.showDropdownIcon = true,
  });

  static Future<String> internationalizeNumber(String number, String iso) {
    return PhoneService.getNormalizedPhoneNumber(number, iso);
  }

  @override
  _InternationalPhoneInputState createState() =>
      _InternationalPhoneInputState();
}

class _InternationalPhoneInputState extends State<InternationalPhoneInput> {
  Country selectedItem;
  List<Country> itemList = [];

  bool hasError = false;
  String errorText;
  bool showCountryCodes;
  bool showCountryFlags;
  bool showDropdownIcon;
  Widget dropdownIcon;
  InputBorder border;

  _InternationalPhoneInputState();

  final phoneTextController = TextEditingController();

  @override
  void initState() {
    errorText = 'Please enter a valid phone number';
    showCountryCodes = widget.showCountryCodes;
    showCountryFlags = widget.showCountryFlags;
    showDropdownIcon = widget.showDropdownIcon;

    phoneTextController.addListener(_validatePhoneNumber);
    phoneTextController.text = widget.initialPhoneNumber;

    _fetchCountryData().then((list) {
      Country preSelectedItem;

      if (widget.initialSelection != null) {
        preSelectedItem = list.firstWhere(
            (e) =>
                (e.code.toUpperCase() ==
                    widget.initialSelection.toUpperCase()) ||
                (e.dialCode == widget.initialSelection.toString()),
            orElse: () => list[0]);
      } else {
        preSelectedItem = list[0];
      }

      setState(() {
        itemList = list;
        selectedItem = preSelectedItem;
      });
    });

    super.initState();
  }

  _validatePhoneNumber() {
    String phoneText = phoneTextController.text;
    if (phoneText != null && phoneText.isNotEmpty) {
      PhoneService.parsePhoneNumber(phoneText, selectedItem.code)
          .then((isValid) {
        setState(() {
          hasError = !isValid;
        });

        if (widget.onPhoneNumberChange != null) {
          if (isValid) {
            PhoneService.getNormalizedPhoneNumber(phoneText, selectedItem.code)
                .then((number) {
              widget.onPhoneNumberChange(phoneText, number, selectedItem.code);
            });
          } else {
            widget.onPhoneNumberChange('', '', selectedItem.code);
          }
        }
      });
    }
  }

  Future<List<Country>> _fetchCountryData() async {
    var list = await DefaultAssetBundle.of(context)
        .loadString('packages/international_phone_input/assets/countries.json');
    List<dynamic> jsonList = json.decode(list);

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextField(
            cursorColor: kLabelColor,
            style: TextStyle(color: kLabelColor),
            keyboardType: TextInputType.phone,
            controller: phoneTextController,
            decoration: InputDecoration(
              labelText: 'Phone Numbder',
              labelStyle: TextStyle(
                color: kLabelColor,
                fontSize: 18.0,
              ),
              errorText: hasError ? errorText : null,
              errorStyle: TextStyle(
                color: kErrorColor,
                fontSize: 16.0,
              ),
              helperText: '',
              prefix: dropdownBox(),
              filled: true,
              fillColor: kObjectBackgroundColor.withOpacity(0.2),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
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
          ),
        )
      ],
    );
  }

  Container dropdownBox() {
    return Container(
      constraints: BoxConstraints(maxHeight: 25.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Country>(
          value: selectedItem,
          icon: Icon(Icons.arrow_drop_down, color: kLabelColor),
          iconSize: showDropdownIcon ? 24.0 : 0.0,
          dropdownColor: kLabelColor.withOpacity(0.2),
          onChanged: (Country newValue) {
            setState(() {
              selectedItem = newValue;
            });
            _validatePhoneNumber();
          },
          items: itemList.map<DropdownMenuItem<Country>>((Country value) {
            return DropdownMenuItem<Country>(
              value: value,
              child: Container(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    if (showCountryFlags) ...[
                      Image.asset(
                        value.flagUri,
                        width: 32.0,
                        package: 'international_phone_input',
                      )
                    ],
                    if (showCountryCodes) ...[
                      SizedBox(width: 4),
                      Text(
                        value.dialCode,
                        textAlign: TextAlign.end,
                        style: TextStyle(color: kLabelColor),
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
}
