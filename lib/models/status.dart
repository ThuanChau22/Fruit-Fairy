/// A class that represents a donation status
/// [code]: number represent current main status
/// [subCode]: number represent current sub status
/// [isCharity]: true if status is retrieve from a charity
/// [_description]: description of current status
/// [_message]: inform user about current status with explanation
class Status implements Comparable<Status> {
  final int code;
  final int subCode;
  final bool isCharity;
  String _description = '';
  String _message = '';

  Status(
    this.code,
    this.subCode, {
    this.isCharity = false,
  }) {
    //TODO: Message for charity
    if (isCharity) {
      if (isPennding) {
        _description = 'Pending';
        _message = '';
      }
      if (isInProgress) {
        _description = 'In Progress';
        _message = '';
      }
      if (isDenied) {
        _description = 'Denied';
        _message = '';
      }
      if (isCompleted) {
        _description = 'Completed';
        _message = '';
      }
    } else {
      if (isPennding) {
        _description = 'Pending';
        _message = 'Donation waiting for charity approval';
      }
      if (isInProgress) {
        _description = 'In Progress';
        _message =
            'Donation accepted. The charity will schedule a pickup with you';
      }
      if (isDenied) {
        _description = 'Denied';
        _message = 'Donation declined by selected charities';
      }
      if (isCompleted) {
        _description = 'Completed';
        _message = 'Donation completed';
      }
    }
  }

  /// Return true if donation is waiting
  /// for charity response
  bool get isPennding {
    return code == 0 && subCode == 0;
  }

  /// Return true if donation is in progress
  bool get isInProgress {
    return code == 0 && subCode == 1;
  }

  /// Return true if donation is denied by charity
  bool get isDenied {
    return code == 1 && subCode == 0;
  }

  /// Return true if donation is completed
  bool get isCompleted {
    return code == 1 && subCode == 1;
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
  static Status init() {
    return Status(0, 0);
  }

  @override
  int compareTo(Status other) {
    return this.code - other.code;
  }
}
