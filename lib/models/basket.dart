import 'dart:collection';
import 'package:flutter/foundation.dart';

class Basket extends ChangeNotifier {
  final List<String> _fruitImages = [
    'images/Peach.png',
    'images/Avocado.png',
    'images/Lemon.png',
    'images/Orange.png',
  ];

  final List<String> _fruitNames = [
    'Peach',
    'Avocado',
    'Lemon',
    'Orange',
  ];

  final List<int> _selectedFruits = [];

  Basket();

  UnmodifiableListView get fruitImages{
    return UnmodifiableListView(_fruitImages);
  }

  UnmodifiableListView get fruitNames{
    return UnmodifiableListView(_fruitNames);
  }

  UnmodifiableListView<int> get selectedFruits {
    return UnmodifiableListView(_selectedFruits);
  }

  void pickFruit(int index){
    _selectedFruits.add(index);
    notifyListeners();
  }

  void remove(int index){
    _selectedFruits.remove(index);
    notifyListeners();
  }


}
