import 'dart:async';
import 'package:uuid/uuid.dart';

/// A class that represents a session token
/// [_uuid]: a unique String generator used to create session token
/// [_timer]: a timer to keep the session alive within certain time
/// [_sessionToken]: current session token
class SessionToken {
  final Uuid _uuid = Uuid();
  Timer _timer;
  String _sessionToken;

  /// Return a copy of [_sessionToken]
  /// starts [_timer] and generates a new [_sessionToken]
  /// if it is not initialized or previously terminated
  String getToken() {
    if (_sessionToken == null) {
      _sessionToken = _uuid.v4();
      _timer = Timer(Duration(seconds: 60), () => clear());
    }
    return _sessionToken;
  }

  /// Terminate current session token and stop timer
  void clear() {
    _sessionToken = null;
    if (_timer.isActive) {
      _timer.cancel();
    }
  }
}
