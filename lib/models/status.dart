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
    if (isPennding) {
      _description = 'Pending';
      _message = 'Donation is waiting for charity approval';
    }
    if (isInProgress) {
      _description = 'In Progress';
      _message =
          'Donation accepted. The charity will schedule a pickup with you';
    }
    if (isDeclined) {
      _description = 'Declined';
      _message = 'Donation declined by selected charities';
    }
    if (isCompleted) {
      _description = 'Completed';
      _message = 'Donation picked up by charity';
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
  bool get isDeclined {
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

  /// Return initial status
  static Status init() {
    return Status(0, 0);
  }

  /// Return accepted status
  static Status accept() {
    return Status(0, 1, isCharity: true);
  }

  /// Return declined status
  static Status declined() {
    return Status(1, 0, isCharity: true);
  }

  /// Return completed status
  static Status completed() {
    return Status(1, 1, isCharity: true);
  }

  @override
  int compareTo(Status other) {
    return this.code - other.code;
  }
}
