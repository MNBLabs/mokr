import '../core/seeded_rng.dart';
import '../data/generators/text_generator.dart';

/// `Mokr.text` — deterministic string generation.
///
/// All methods are synchronous and deterministic: same seed → same string,
/// always and everywhere. No disk. No init dependency.
///
/// Results match the corresponding fields on [MockUser] / [MockPost] for
/// the same seed — so you can feed your own widgets directly without needing
/// the full model:
///
/// ```dart
/// MyProfileHeader(
///   name:   Mokr.text.name('u1'),    // == Mokr.user('u1').name
///   handle: Mokr.text.handle('u1'),  // == Mokr.user('u1').handle
///   bio:    Mokr.text.bio('u1'),     // == Mokr.user('u1').bio
/// )
/// ```
final class MokrText {
  const MokrText();

  /// Full display name, e.g. `'Jordan Rivera'`.
  /// Matches [MockUser.name] for the same seed. Consumes 2 RNG draws.
  String name(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return TextGenerator.generateName(SeededRng(seed));
  }

  /// Given name only, e.g. `'Jordan'`.
  /// Matches [MockUser.firstName] for the same seed. Consumes 1 RNG draw.
  String firstName(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return TextGenerator.generateFirstName(SeededRng(seed));
  }

  /// Family name only, e.g. `'Rivera'`.
  /// Matches [MockUser.lastName] for the same seed. Consumes 2 RNG draws
  /// (first name draw is consumed to preserve the sequence).
  String lastName(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    final rng = SeededRng(seed);
    TextGenerator.generateFirstName(rng); // draw 1 — must be consumed
    return TextGenerator.generateLastName(rng); // draw 2
  }

  /// Lowercase username without `@`, e.g. `'jordanrivera'`.
  /// Matches [MockUser.username] for the same seed.
  String username(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    final rng = SeededRng(seed);
    final first = TextGenerator.generateFirstName(rng);
    final last = TextGenerator.generateLastName(rng);
    return TextGenerator.generateUsername(first, last);
  }

  /// `@`-prefixed handle, e.g. `'@jordanrivera'`.
  /// Matches [MockUser.handle] for the same seed.
  String handle(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return '@${username(seed)}';
  }

  /// 1–3 sentence bio.
  /// Matches [MockUser.bio] for the same seed.
  String bio(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    final rng = SeededRng(seed);
    // Consume draws 1–2 to align with UserGenerator's sequence.
    TextGenerator.generateFirstName(rng);
    TextGenerator.generateLastName(rng);
    return TextGenerator.generateBio(rng); // draws 3–6
  }

  /// 1–4 phrase caption.
  /// Matches [MockPost.caption] for the same seed.
  String caption(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return TextGenerator.generateCaption(SeededRng(seed));
  }

  /// A single comment phrase.
  String comment(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return TextGenerator.generateComment(SeededRng(seed));
  }

  /// Two-letter initials, e.g. `'JR'`.
  /// Matches [MockUser.initials] for the same seed.
  String initials(String seed) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    final rng = SeededRng(seed);
    final first = TextGenerator.generateFirstName(rng);
    final last = TextGenerator.generateLastName(rng);
    return TextGenerator.generateInitials(first, last);
  }
}
