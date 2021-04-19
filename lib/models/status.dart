class Status {
  static const int kPending = 0;
  static const int kInProgress = 10;
  static const int kDenied = 11;
  static const int kCompleted = 20;

  final int code;
  String _description;
  String _message;

  Status(this.code) {
    //TODO: Add messages for donor's donation details
    switch (code) {
      case kPending:
        _description = 'Pending';
        _message = '';
        break;
      case kInProgress:
        _description = 'In Progress';
        _message = '';
        break;
      case kDenied:
        _description = 'Denied';
        _message = '';
        break;
      case kCompleted:
        _description = 'Completed';
        _message = '';
        break;
    }
  }

  String get description {
    return _description;
  }

  String get message {
    return _message;
  }

  static int init() {
    return kPending;
  }
}
