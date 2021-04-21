class Status implements Comparable<Status> {
  static const int kPending = 0;
  static const int kInProgress = 10;
  static const int kDenied = 11;
  static const int kCompleted = 20;

  final int code;
  String _description = '';
  String _message = '';

  Status(this.code) {
    switch (code) {
      case kPending:
        _description = 'Pending';
        _message = 'Donation waiting for charity approval';
        break;
      case kInProgress:
        _description = 'In Progress';
        _message =
            'Donation accepted. The charity will schedule a pickup with you';
        break;
      case kDenied:
        _description = 'Denied';
        _message = 'Donation declined by selected charities';
        break;
      case kCompleted:
        _description = 'Completed';
        _message = 'Donation completed';
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

  @override
  int compareTo(Status other) {
    return this.code - other.code;
  }
}
