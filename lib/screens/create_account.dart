import 'package:flutter/material.dart';
import 'package:fruitfairy/widgets/roundedbutton.dart';

class CreateAccount extends StatelessWidget {
  static const String id = 'create_account';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF05e5c),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Account'),
        backgroundColor: Color(0xFFF05e5c),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
           // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoundedButton(
                label: 'Donor',
                color: Colors.white,
                //ToDo: redirect to other screen
                onPressed: null,
              ),
              SizedBox(height: 24.0,),
              RoundedButton(
                label: 'Charity',
                color: Colors.white,
                //ToDo: missing pressing function
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
