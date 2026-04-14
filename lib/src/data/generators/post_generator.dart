import '../../core/distribution.dart';
import '../../core/seed_hash.dart';
import '../../core/seeded_rng.dart';
import '../../images/mokr_image_provider.dart';
import '../models/mock_post.dart';
import '../tables/hashtags.dart';
import 'text_generator.dart';
import 'user_generator.dart';

/// Generates deterministic [MockPost] instances from a seed string.
///
/// RNG consumption is fixed at exactly 19 draws regardless of output.
/// This is a semver-stability contract — do not alter without a major bump.
///
/// The author is generated from `'${seed}_author'` using a separate
/// [SeededRng] — it does not consume from the post's RNG.
final class PostGenerator {
  PostGenerator._();

  /// Generates a [MockPost] from [seed].
  ///
  /// Same seed always produces the same post.
  ///
  /// RNG consumption order (19 draws total):
  /// 1.  captionLength          (TextGenerator.generateCaption start — 1 draw)
  /// 2–5. captionPhraseIndex[0–3] (TextGenerator.generateCaption   — 4 draws)
  /// 6.  hasImageRaw            (double, < 0.80 = has image)
  /// 7.  imageCategoryIdx       (always consumed)
  /// 8.  likeU1                 (normalInt draw 1)
  /// 9.  likeU2                 (normalInt draw 2)
  /// 10. commentCount
  /// 11. shareCount
  /// 12. isLikedRaw             (double, < 0.30 = liked)
  /// 13. createdAtRaw           (double, exponential dist)
  /// 14. tagCount               (0–5)
  /// 15–19. tagIndex[0–4]       (always 5 consumed)
  static MockPost generate(String seed) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    final rng = SeededRng(seed);

    // Draws 1–5: caption (1 length draw + 4 phrase draws)
    final caption = TextGenerator.generateCaption(rng);

    // Draw 6: has image (~80% probability)
    final hasImage = rng.nextDouble() < 0.80;

    // Draw 7: image category (always consumed for stable RNG sequence)
    final category =
        MokrCategory.values[rng.nextInt(MokrCategory.values.length)];

    // Draws 8–9: like count (triangle distribution via normalInt)
    final likeCount = normalInt(rng, mean: 5000, stddev: 3500);

    // Draw 10: comment count
    final commentCount = rng.nextInt(500);

    // Draw 11: share count
    final shareCount = rng.nextInt(200);

    // Draw 12: is liked (~30% probability)
    final isLiked = rng.nextDouble() < 0.30;

    // Draw 13: created at (exponential recency, mean 14d, cap 365d)
    final createdAt = recencyDate(rng, meanDays: 14, maxDays: 365);

    // Draw 14: tag count (0–5)
    final tagCount = rng.nextInt(6);

    // Draws 15–19: tag indices — always 5 consumed regardless of tagCount
    final tIdx0 = rng.nextInt(kHashtags.length);
    final tIdx1 = rng.nextInt(kHashtags.length);
    final tIdx2 = rng.nextInt(kHashtags.length);
    final tIdx3 = rng.nextInt(kHashtags.length);
    final tIdx4 = rng.nextInt(kHashtags.length);
    final tags = [
      kHashtags[tIdx0],
      kHashtags[tIdx1],
      kHashtags[tIdx2],
      kHashtags[tIdx3],
      kHashtags[tIdx4],
    ].take(tagCount).toList();

    // Derived — no RNG
    final hashHex =
        SeedHash.hash(seed).toRadixString(16).padLeft(8, '0').substring(0, 4);
    final id = 'pst_$hashHex';

    // Author: separate RNG from derived seed — does not affect post RNG
    final author = UserGenerator.generate('${seed}_author');

    return MockPost(
      seed: seed,
      id: id,
      author: author,
      caption: caption,
      hasImage: hasImage,
      category: category,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      isLiked: isLiked,
      createdAt: createdAt,
      tags: tags,
    );
  }
}
