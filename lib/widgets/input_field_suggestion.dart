import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/message_bar.dart';

class InputFieldSuggestion<T> extends StatelessWidget {
  final String label;
  final Color labelColor;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final SuggestionsCallback<T> suggestionsCallback;
  final ItemBuilder<T> itemBuilder;
  final WidgetBuilder noItemsFoundBuilder;
  final SuggestionSelectionCallback<T> onSuggestionSelected;

  InputFieldSuggestion({
    this.label,
    this.labelColor = kLabelColor,
    this.controller,
    this.onChanged,
    this.suggestionsCallback,
    this.itemBuilder,
    this.noItemsFoundBuilder,
    this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return TypeAheadField<T>(
      hideOnLoading: true,
      hideSuggestionsOnKeyboardHide: false,
      keepSuggestionsOnLoading: false,
      suggestionsBoxVerticalOffset: 1.0,
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        constraints: BoxConstraints(maxHeight: 175.0),
        hasScrollbar: false,
      ),
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        cursorColor: labelColor,
        onChanged: onChanged,
        onTap: () => MessageBar(context).hide(),
        style: TextStyle(color: labelColor),
        scrollPadding: EdgeInsets.only(
          top: screen.height * 0.05,
          bottom: 200.0,
        ),
        decoration: kTextFieldDecoration.copyWith(
          labelText: label,
          fillColor: kObjectColor.withOpacity(0.2),
        ),
      ),
      suggestionsCallback: suggestionsCallback,
      itemBuilder: itemBuilder,
      noItemsFoundBuilder: noItemsFoundBuilder,
      onSuggestionSelected: onSuggestionSelected,
    );
  }
}
