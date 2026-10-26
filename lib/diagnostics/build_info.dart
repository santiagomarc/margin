/// Build identity, passed in by CI with --dart-define.
abstract final class BuildInfo {
  static const build = String.fromEnvironment(
    'MARGIN_BUILD',
    defaultValue: 'dev',
  );
  static const commit = String.fromEnvironment('MARGIN_COMMIT');

  static String get label =>
      commit.length >= 7 ? '$build (${commit.substring(0, 7)})' : build;
}
