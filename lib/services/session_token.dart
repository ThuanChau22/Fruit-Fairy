import 'dart:async';
import 'package:uuid/uuid.dart';

class SessionToken {
  final Uuid _uuid = Uuid();
  Timer _timer;
  String _sessionToken;

  String getToken() {
    if (_sessionToken == null) {
      _sessionToken = _uuid.v4();
      _timer = Timer(Duration(seconds: 60), () => clear());
    }
    return _sessionToken;
  }

  void clear() {
    _sessionToken = null;
    if (_timer.isActive) {
      _timer.cancel();
    }
  }
}
