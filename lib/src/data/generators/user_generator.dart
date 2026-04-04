import '../../core/distribution.dart';
import '../../core/seed_hash.dart';
import '../../core/seeded_rng.dart';
import '../../images/provider_registry.dart';
import '../../mokr_enums.dart';
import '../models/mock_user.dart';
import '../tables/bio_phrases.dart';
import '../tables/first_names.dart';
import '../tables/last_names.dart';

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
  /// 1. firstNameIndex
  /// 2. lastNameIndex
  /// 3. bioLength (1–3)
  /// 4. bioPhraseIndex[0] — always consumed
  /// 5. bioPhraseIndex[1] — always consumed
  /// 6. bioPhraseIndex[2] — always consumed
  /// 7. followerTier (double, for power-law)
  /// 8. followerValue (double, within tier)
  /// 9. followingCount
  /// 10. postCount
  /// 11. isVerifiedRaw (double, < 0.04 = verified)
  /// 12. joinedAtRaw (double, for exponential dist)
  static MockUser generate(String seed) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    final rng = SeededRng(seed);

    // Draws 1–2: name
    final firstName = kFirstNames[rng.nextInt(kFirstNames.length)];
    final lastName = kLastNames[rng.nextInt(kLastNames.length)];
    final name = '$firstName $lastName';

    // Draw 3: bio length
    final bioLength = 1 + rng.nextInt(3); // 1, 2, or 3

    // Draws 4–6: bio phrase indices — always 3 draws regardless of bioLength
    final bioPhraseIdx0 = rng.nextInt(kBioPhrases.length);
    final bioPhraseIdx1 = rng.nextInt(kBioPhrases.length);
    final bioPhraseIdx2 = rng.nextInt(kBioPhrases.length);
    final bio = [
      kBioPhrases[bioPhraseIdx0],
      kBioPhrases[bioPhraseIdx1],
      kBioPhrases[bioPhraseIdx2],
    ].take(bioLength).join(' ');

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

    // Derived (no RNG)
    final hashHex =
        SeedHash.hash(seed).toRadixString(16).padLeft(8, '0').substring(0, 4);
    final id = 'usr_$hashHex';
    final username = '@${name.toLowerCase().replaceAll(' ', '.')}';
    final avatarUrl = activeImageProvider.avatarUrl(seed, MokrCategory.face);

    return MockUser(
      seed: seed,
      id: id,
      name: name,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
      followerCount: followerCount,
      followingCount: followingCount,
      postCount: postCount,
      isVerified: isVerified,
      joinedAt: joinedAt,
    );
  }
}
