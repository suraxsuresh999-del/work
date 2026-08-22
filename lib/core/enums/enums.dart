/// User types in WorkSphere
enum UserType {
  rolePending('role_pending', 'Role Pending'),
  freelancer('freelancer', 'Freelancer'),
  client('client', 'Client'),
  admin('admin', 'Admin');

  const UserType(this.value, this.label);

  final String value;
  final String label;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UserType.rolePending,
    );
  }
}

/// Server-controlled progress through the required marketplace onboarding.
enum OnboardingStatus {
  rolePending('role_pending'),
  profilePending('profile_pending'),
  active('active');

  const OnboardingStatus(this.value);

  final String value;

  static OnboardingStatus fromString(String value) {
    return OnboardingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OnboardingStatus.rolePending,
    );
  }
}

/// Verification status for user identity
enum VerificationStatus {
  unverified('unverified', 'Not Verified'),
  pending('pending', 'Pending Review'),
  approved('approved', 'Verified'),
  rejected('rejected', 'Rejected'),
  reuploadRequired('reupload_required', 'Re-upload Required');

  const VerificationStatus(this.value, this.label);

  final String value;
  final String label;

  bool get isVerified => this == VerificationStatus.approved;
  bool get isPending => this == VerificationStatus.pending;
  bool get isRejected => this == VerificationStatus.rejected;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VerificationStatus.unverified,
    );
  }
}

/// Job status lifecycle
enum JobStatus {
  draft('draft', 'Draft'),
  open('open', 'Open'),
  paused('paused', 'Paused'),
  inProgress('in_progress', 'In Progress'),
  closed('closed', 'Closed'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const JobStatus(this.value, this.label);

  final String value;
  final String label;

  bool get isActive => this == JobStatus.open || this == JobStatus.inProgress;
  bool get isEditable => this == JobStatus.draft || this == JobStatus.open;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => JobStatus.draft,
    );
  }
}

/// Application status for job applications
enum ApplicationStatus {
  pending('pending', 'Pending'),
  shortlisted('shortlisted', 'Shortlisted'),
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected'),
  withdrawn('withdrawn', 'Withdrawn');

  const ApplicationStatus(this.value, this.label);

  final String value;
  final String label;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ApplicationStatus.pending,
    );
  }
}

/// Payment status
enum PaymentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded'),
  cancelled('cancelled', 'Cancelled');

  const PaymentStatus(this.value, this.label);

  final String value;
  final String label;

  bool get isSuccessful => this == PaymentStatus.completed;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Project status
enum ProjectStatus {
  pending('pending', 'Pending'),
  active('active', 'Active'),
  onHold('on_hold', 'On Hold'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  disputed('disputed', 'Disputed');

  const ProjectStatus(this.value, this.label);

  final String value;
  final String label;

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProjectStatus.pending,
    );
  }
}

/// Milestone status
enum MilestoneStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  submitted('submitted', 'Submitted'),
  approved('approved', 'Approved'),
  revisionRequired('revision_required', 'Revision Required'),
  completed('completed', 'Completed');

  const MilestoneStatus(this.value, this.label);

  final String value;
  final String label;

  static MilestoneStatus fromString(String value) {
    return MilestoneStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MilestoneStatus.pending,
    );
  }
}

/// Message type in chat
enum MessageType {
  text('text'),
  image('image'),
  document('document'),
  voiceNote('voice_note'),
  system('system');

  const MessageType(this.value);

  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }
}

/// Government ID types for verification
enum GovernmentIdType {
  aadhaar('aadhaar', 'Aadhaar Card'),
  drivingLicence('driving_licence', 'Driving Licence'),
  passport('passport', 'Passport'),
  voterId('voter_id', 'Voter ID'),
  businessProof('business_proof', 'Business Proof');

  const GovernmentIdType(this.value, this.label);

  final String value;
  final String label;

  static GovernmentIdType fromString(String value) {
    return GovernmentIdType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GovernmentIdType.aadhaar,
    );
  }
}

/// Availability status
enum AvailabilityStatus {
  available('available', 'Available'),
  partiallyAvailable('partially_available', 'Partially Available'),
  unavailable('unavailable', 'Unavailable');

  const AvailabilityStatus(this.value, this.label);

  final String value;
  final String label;

  static AvailabilityStatus fromString(String value) {
    return AvailabilityStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AvailabilityStatus.available,
    );
  }
}

/// Transaction type
enum TransactionType {
  credit('credit', 'Credit'),
  debit('debit', 'Debit'),
  withdrawal('withdrawal', 'Withdrawal'),
  refund('refund', 'Refund');

  const TransactionType(this.value, this.label);

  final String value;
  final String label;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.credit,
    );
  }
}

/// Notification type
enum NotificationType {
  jobPosted('job_posted'),
  applicationReceived('application_received'),
  applicationAccepted('application_accepted'),
  applicationRejected('application_rejected'),
  message('message'),
  payment('payment'),
  milestoneUpdate('milestone_update'),
  review('review'),
  verification('verification'),
  system('system');

  const NotificationType(this.value);

  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}
