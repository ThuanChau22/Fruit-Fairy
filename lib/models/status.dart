/// A class that represents a donation status
/// [code]: number represent current status
/// [isDenied]: true if a charity denies the donation
/// [_description]: status description based on [code]
/// [_message]: inform donor about current status with explanation
/// [kPending]: After a donation is requested
/// [kInProgress]: After a donation is accepted
/// [kCompleted]: After a donation is marked as completed or denied
class Status implements Comparable<Status> {
  static const int kPending = 0;
  static const int kInProgress = 1;
  static const int kCompleted = 2;

  final int code;
  final bool isDenied;
  String _description = '';
  String _message = '';

  Status(
    this.code, {
    this.isDenied = false,
  }) {
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
      case kCompleted:
        _description = 'Completed';
        _message = 'Donation completed';
        if (isDenied) {
          _description = 'Denied';
          _message = 'Donation declined by selected charities';
        }
        break;
    }
  }

  /// Return a copy of [_description]
  String get description {
    return _description;
  }

  /// Return a copy of [_message]
  String get message {
    return _message;
  }

  /// Return initial status code
  static int init() {
    return kPending;
  }

  @override
  int compareTo(Status other) {
    return this.code - other.code;
  }
}
