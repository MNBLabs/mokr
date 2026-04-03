# /test — Test Suite

Generate tests in this order. Run after each group before continuing.

---

## `test/core/seed_hash_test.dart`
```
- hash('') returns non-negative int
- hash('a') != hash('b')
- hash('user_0') through hash('user_9999') — all unique (no collisions)
- hash('x') called 100 times — always same value (stability)
- hash handles Unicode: hash('用户_0') is stable
- sig derivation: hash(seed) % 9999 always in [0, 9998]
```

## `test/core/seeded_rng_test.dart`
```
- SeededRng('seed').nextInt(100) is in [0, 100)
- SeededRng('seed').nextIntInRange(5, 10) is in [5, 10)
- SeededRng('seed').nextBool(probability: 0.0) always false
- SeededRng('seed').nextBool(probability: 1.0) always true
- SeededRng('seed').pick(['a','b','c']) same result each time
- Two SeededRng('seed') instances produce identical sequences
```

## `test/core/slot_registry_test.dart`
```
Mock SharedPreferences. Test:
- getOrCreate('x') generates a seed and stores it
- getOrCreate('x') called twice returns same seed
- pin('x') adds x to pinned set
- clearAll() removes unpinned, keeps pinned
- clearPin('x') removes from both map and pinned set
- clearPin('nonexistent') is a no-op
- Reinitialising registry loads persisted state
```

## `test/data/mock_user_test.dart`
```
- Mokr.user('any') returns non-null MockUser
- name is non-empty
- username starts with '@'
- followerCount >= 0
- DETERMINISM: Mokr.user('seed_42') called 1000 times → all identical
- DISTRIBUTION: 1000 different seeds → isVerified true < 10% of the time
- initials matches first chars of name parts
- formattedFollowers: 999→'999', 1000→'1k', 1500→'1.5k', 1000000→'1M'
```

## `test/data/mock_post_test.dart`
```
- Mokr.post('any') returns non-null MockPost
- caption non-empty
- createdAt is in the past
- DETERMINISM: Mokr.post('seed') called 1000 times → all identical
- DISTRIBUTION: 1000 posts → ~80% have images
- relativeTime returns non-empty string
- feedPage('seed', page:0) and feedPage('seed', page:1) return different posts
- feedPage('seed', page:0) called twice returns identical list
```

## `test/images/url_test.dart`
```
- avatarUrl('seed') starts with 'https://'
- avatarUrl('seed', size: 80) contains '80x80'
- avatarUrl('user_0') != avatarUrl('user_1')
- avatarUrl('user_0') == avatarUrl('user_0')  (deterministic)
- imageUrl('seed', category: MokrCategory.technology) contains 'technology'
- No URL contains 'null', 'undefined', or 'NaN'
- Picsum provider: avatarUrl returns picsum.photos URL
```

## `test/widgets/mokr_avatar_test.dart`
```
- MokrAvatar(seed: 'x', size: 48) renders without error
- MokrAvatar(slot: 'y') renders without error
- MokrAvatar() renders without error
- MokrAvatar(seed: 'x', slot: 'y') throws assertion error
- Renders inside Container, ListTile leading, Stack
```

## Run Command
```bash
flutter test --coverage
```
Target: >90% line coverage on `lib/src/core/` and `lib/src/data/`.
