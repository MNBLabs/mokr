import '../../core/distribution.dart';
import '../../core/seed_hash.dart';
import '../../core/seeded_rng.dart';
import '../models/mock_user.dart';
import 'text_generator.dart';

/// Generates deterministic [MockUser] instances from a seed string.
///
/// RNG consumption is fixed at exactly 12 draws regardless of output.
/// This is a semver-stability contract — do not alter without a major bump.
final class UserGenerator {
  UserGenerator._();

  /// Generates a [MockUser] from [seed].
  ///
  /// Same seed always produces the same user.
  ///
  /// RNG consumption order (12 draws total):
  /// 1.  firstNameIndex         (TextGenerator.generateFirstName — 1 draw)
  /// 2.  lastNameIndex          (TextGenerator.generateLastName  — 1 draw)
  /// 3.  bioLength              (TextGenerator.generateBio start — 1 draw)
  /// 4–6. bioPhraseIndex[0–2]  (TextGenerator.generateBio       — 3 draws)
  /// 7.  followerTier           (powerLawInt draw 1)
  /// 8.  followerValue          (powerLawInt draw 2)
  /// 9.  followingCount
  /// 10. postCount
  /// 11. isVerifiedRaw          (double, < 0.04 = verified)
  /// 12. joinedAtRaw            (double, exponential dist)
  static MockUser generate(String seed) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    final rng = SeededRng(seed);

    // Draws 1–2: name
    final firstName = TextGenerator.generateFirstName(rng);
    final lastName = TextGenerator.generateLastName(rng);

    // Draws 3–6: bio (1 length draw + 3 phrase draws)
    final bio = TextGenerator.generateBio(rng);

    // Draws 7–8: follower count (power-law, 2 draws)
    final followerCount = powerLawInt(rng, max: 50000000);

    // Draw 9: following count
    final followingCount = rng.nextInt(5000);

    // Draw 10: post count
    final postCount = rng.nextInt(1000);

    // Draw 11: verified status (~4% probability)
    final isVerified = rng.nextDouble() < 0.04;

    // Draw 12: joined date (exponential recency, mean 365d, cap 3650d)
    final joinedAt = recencyDate(rng, meanDays: 365, maxDays: 3650);

    // Derived — no RNG
    final hashHex =
        SeedHash.hash(seed).toRadixString(16).padLeft(8, '0').substring(0, 4);
    final id = 'usr_$hashHex';
    final username = TextGenerator.generateUsername(firstName, lastName);

    return MockUser(
      seed: seed,
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      bio: bio,
      followerCount: followerCount,
      followingCount: followingCount,
      postCount: postCount,
      isVerified: isVerified,
      joinedAt: joinedAt,
    );
  }
}
