class UserProfile {
  final String name;
  final String email;
  final String memberSince;

  const UserProfile({
    required this.name,
    required this.email,
    required this.memberSince,
  });
}

class ActivitySummary {
  final int imagesScanned;
  final int genuineResults;
  final int suspiciousResults;

  const ActivitySummary({
    required this.imagesScanned,
    required this.genuineResults,
    required this.suspiciousResults,
  });
}

const mockUserProfile = UserProfile(
  name: 'Aarya Parulekar',
  email: 'aarya@example.com',
  memberSince: 'September 2026',
);

const mockActivitySummary = ActivitySummary(
  imagesScanned: 24,
  genuineResults: 18,
  suspiciousResults: 6,
);
