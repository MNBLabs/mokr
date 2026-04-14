import '../../core/seeded_rng.dart';
import '../tables/bio_phrases.dart';
import '../tables/caption_phrases.dart';
import '../tables/first_names.dart';
import '../tables/last_names.dart';

/// Deterministic text generation helpers.
///
/// Methods accept a [SeededRng] and consume a fixed, documented number of
/// draws. The consumption count is a semver contract — do not alter without
/// a major version bump.
///
/// These methods are used by both the generators ([UserGenerator],
/// [PostGenerator]) and the [TextNamespace] (Mokr.text.*).
final class TextGenerator {
  TextGenerator._();

  /// Returns a first name. Consumes **1** RNG draw.
  static String generateFirstName(SeededRng rng) => rng.pick(kFirstNames);

  /// Returns a last name. Consumes **1** RNG draw.
  static String generateLastName(SeededRng rng) => rng.pick(kLastNames);

  /// Returns `'FirstName LastName'`. Consumes **2** RNG draws.
  static String generateName(SeededRng rng) {
    final first = generateFirstName(rng);
    final last = generateLastName(rng);
    return '$first $last';
  }

  /// Returns a lowercase username from first and last name.
  /// No RNG draws — purely derived from the supplied strings.
  /// e.g. `'Sofia'`, `'Nakamura'` → `'sofianakamura'`
  static String generateUsername(String firstName, String lastName) =>
      '${firstName.toLowerCase()}${lastName.toLowerCase()}';

  /// Returns `'FirstName[0]LastName[0]'` in uppercase. No RNG draws.
  static String generateInitials(String firstName, String lastName) =>
      '${firstName[0]}${lastName[0]}'.toUpperCase();

  /// Returns a 1–3 sentence bio. Consumes **4** RNG draws:
  /// 1 for length selection + 3 phrase indices (always consumed).
  static String generateBio(SeededRng rng) {
    final length = 1 + rng.nextInt(3); // draw 1: length 1–3
    // draws 2–4: always 3 indices regardless of length
    final p0 = kBioPhrases[rng.nextInt(kBioPhrases.length)];
    final p1 = kBioPhrases[rng.nextInt(kBioPhrases.length)];
    final p2 = kBioPhrases[rng.nextInt(kBioPhrases.length)];
    return [p0, p1, p2].take(length).join(' ');
  }

  /// Returns a 1–4 phrase caption. Consumes **5** RNG draws:
  /// 1 for length selection + 4 phrase indices (always consumed).
  static String generateCaption(SeededRng rng) {
    final length = 1 + rng.nextInt(4); // draw 1: length 1–4
    // draws 2–5: always 4 indices regardless of length
    final p0 = kCaptionPhrases[rng.nextInt(kCaptionPhrases.length)];
    final p1 = kCaptionPhrases[rng.nextInt(kCaptionPhrases.length)];
    final p2 = kCaptionPhrases[rng.nextInt(kCaptionPhrases.length)];
    final p3 = kCaptionPhrases[rng.nextInt(kCaptionPhrases.length)];
    return [p0, p1, p2, p3].take(length).join(' ');
  }

  /// Returns a comment string. Consumes **1** RNG draw.
  /// Reuses caption phrases — suitable for mock comment text.
  static String generateComment(SeededRng rng) =>
      kCaptionPhrases[rng.nextInt(kCaptionPhrases.length)];
}
