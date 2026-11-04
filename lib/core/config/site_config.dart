/// Public web pages the stores and the app link to. The Firebase default
/// domain keeps working after a custom domain is connected.
abstract final class SiteConfig {
  static const origin = 'https://live-jury.web.app';
  static const privacyUrl = '$origin/privacy';
  static const deleteAccountUrl = '$origin/delete-account';
}
