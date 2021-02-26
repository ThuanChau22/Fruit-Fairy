import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditProfileScreen extends StatefulWidget {
  static const String id = 'edit_profile_screen';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _showSpinner = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Consumer<Account>(
      builder: (context, account, child) {
        _firstNameController.text = account.firstName;
        _lastNameController.text = account.lastName;
        _emailController.text = account.email;
        return Scaffold(
          backgroundColor: kPrimaryColor,
          appBar: AppBar(
            backgroundColor: kAppBarColor,
            title: Text('Edit Profile Page'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kAppBarColor),
              ),
              child: ScrollableLayout(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.06,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Account Information',
                        style: TextStyle(
                          color: kLabelColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      divider(),
                      SizedBox(height: screen.height * 0.01),
                      firstNameInputField(),
                      SizedBox(height: screen.height * 0.01),
                      lastNameInputField(),
                      SizedBox(height: screen.height * 0.01),
                      emailInputField(),
                      SizedBox(height: screen.height * 0.01),
                      phoneInputField(),
                      SizedBox(height: screen.height * 0.01),
                      passwordInputField(),
                      SizedBox(height: screen.height * 0.01),
                      confirmPasswordInputField(),
                      button(),
                      SizedBox(height: screen.height * 0.01),
                      Text(
                        'Address Information',
                        style: TextStyle(
                          color: kLabelColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      divider(),
                      SizedBox(height: screen.height * 0.01),
                      streetInputField(),
                      SizedBox(height: screen.height * 0.01),
                      zipcodeInputField(),
                      SizedBox(height: screen.height * 0.01),
                      stateInputField(),
                      button(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      thickness: 3.0,
      indent: 20.0,
      endIndent: 20.0,
    );
  }

  Widget button() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.15,
      ),
      child: RoundedButton(
        label: 'Update',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {},
      ),
    );
  }

  Widget emailInputField() {
    return InputField(
      label: 'Email',
      controller: _emailController,
      readOnly: true,
      onChanged: (value) {},
    );
  }

  Widget firstNameInputField() {
    return InputField(
      label: 'First Name',
      controller: _firstNameController,
      onChanged: (value) {},
    );
  }

  Widget lastNameInputField() {
    return InputField(
      label: 'Last Name',
      controller: _lastNameController,
      onChanged: (value) {},
    );
  }

  Widget phoneInputField() {
    return InputField(
      label: 'Phone number',
      //controller: _phoneNumberController,
      onChanged: (value) {},
    );
  }

  passwordInputField() {
    return InputField(
      label: 'Password',
      onChanged: (value) {},
    );
  }

  confirmPasswordInputField() {
    return InputField(
      label: 'Confirm Password',
      onChanged: (value) {},
    );
  }

  streetInputField() {
    return InputField(
      label: 'Street',
      //controller: _streetController
      onChanged: (value) {},
    );
  }

  zipcodeInputField() {
    return InputField(
      label: 'Zipcode',
      //controller: _zipcodeController
      onChanged: (value) {},
    );
  }

  stateInputField() {
    return InputField(
      label: 'State',
      //controller: _zipcodeController
      onChanged: (value) {},
    );
  }
}
