import 'package:flutter/cupertino.dart';

class Charity extends ChangeNotifier {
  List <int> numbers = [];
  List <String> charityName = [];



  void addNumber(int index){
    numbers.add(index);
  }

  void removeNumber(int index){
    numbers.remove(index);
  }

}