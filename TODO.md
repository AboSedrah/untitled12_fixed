# TODO - Remaining Tasks

## High Priority (Blocking Build)

### 1. Fix Azkar Const Constructor Issue
**Status:** ⚠️ BLOCKING - Prevents build

**Files to fix:**
- lib/widgets/zikr_card.dart (add const to Zikr class)
- lib/screens/azkar/zikr_sabah.dart
- lib/screens/azkar/zikr_masaa.dart
- lib/screens/azkar/zikr_noum.dart
- lib/screens/azkar/zikr_salah.dart
- lib/screens/azkar/quran_duas_screen.dart (add const to Dua class)

**Solution:** Add const constructor to Zikr and Dua model classes

## Medium Priority (Code Quality)

### 2. Deprecation Warnings
- Replace withOpacity() with withValues() (~50+ occurrences)
- Update ConcatenatingAudioSource usage (deprecated)
- Fix Radio widget deprecations

### 3. Code Style
- Add missing type annotations
- Remove print() statements in production code
- Fix file naming (convertNumberToAr.dart → convert_number_to_ar.dart)

## Low Priority (Optional)

### 4. Qibla Accuracy
- Verify sensor calibration logic
- Test Qibla direction calculation accuracy
- Add compass calibration UI

### 5. Quran Module
- Test all Quran screens
- Verify audio playback
- Test bookmark functionality (if still needed after cleanup)

## Future Enhancements

### 6. Performance
- Optimize heavy builds
- Add const constructors where possible
- Profile app performance

### 7. Dependencies
- Remove unused dependencies from pubspec.yaml
- Update to latest stable versions

## Notes
- All external nabd code has been removed
- App uses local screens in lib/screens/
- Quran integration via modules/quran works correctly
