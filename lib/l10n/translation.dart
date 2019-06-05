import 'dart:async';
import 'dart:ui';

import 'package:Medicall/l10n/messages_all.dart';
import 'package:Medicall/components/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Translation {
  static const String TAG = "L10N";
  static const _TranslationDelegate delegate = const _TranslationDelegate();

  static Future<Translation> load(Locale locale) {
    Logger.log(TAG, message: "Loading for locale: $locale");
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return Translation();
    });
  }

  static Translation of(BuildContext context) {
    return Localizations.of<Translation>(context, Translation);
  }

  String get appName => 'Medicall';

  String get space => " ";

  String get privacyPolicyLink => Intl.message(
        'https://gildaswise.com/sosin-privacy-policy',
        name: "privacyPolicyLink",
      );

  String get termsLink => Intl.message(
        'https://gildaswise.com/sosin-eula',
        name: "termsLink",
      );

  String get privacyPolicy => Intl.message(
        "Privacy Policy",
        name: "privacyPolicy",
      );

  String get agreement => Intl.message(
        "When signing in, you agree to our",
        name: "agreement",
      );

  String get agreementAnd => Intl.message(
        "and our",
        name: "agreementAnd",
      );

  String get terms => Intl.message(
        "Terms of Service",
        name: "terms",
      );

  String get signInWithGoogle => Intl.message(
        "Sign in with Google",
        name: "signInWithGoogle",
      );

  String get signInWithEmail => Intl.message(
        "Sign in with e-mail",
        name: "signInWithEmail",
      );

  String get passwordReset => Intl.message(
        "Forgot your password? Touch ",
        name: "passwordReset",
      );

  String get here => Intl.message(
        "Here",
        name: "here",
      );

  String get signIn => Intl.message(
        "Login",
        name: "signIn",
      );

  String get signUp => Intl.message(
        "Sign up",
        name: "signUp",
      );

  String get email => Intl.message(
        "E-mail",
        name: "email",
      );

  String get exampleEmail => Intl.message(
        "example@email.com",
        name: "exampleEmail",
      );

  String get password => Intl.message(
        "Password",
        name: "password",
      );

  String get passwordHelper => Intl.message(
        "Your password must have at least 8 characters",
        name: "passwordHelper",
      );

  String get previous => Intl.message(
        "Previous",
        name: "previous",
      );

  String get next => Intl.message(
        "Next",
        name: "next",
      );

  String get signOut => Intl.message(
        "Sign out",
        name: "signOut",
      );

  String get emptyName => Intl.message(
        "No name",
        name: "emptyName",
      );

  String get sentPasswordReset => Intl.message(
        "Just sent an e-mail containing instructions on how to reset your password!",
        name: "sentPasswordReset",
      );

  String get errorPasswordReset => Intl.message(
        "Couldn't send your password reset e-mail, please try again later or check our e-mail",
        name: "errorPasswordReset",
      );

  String get errorEmailInUse => Intl.message(
        "This e-mail is already being used by another account!",
        name: "errorEmailInUse",
      );

  String get errorVerifyEmail => Intl.message(
        "Couldn't verify your e-mail, please check your connection status!",
        name: "errorVerifyEmail",
      );

  String get errorGoogleProvider => Intl.message(
        "You're already using this e-mail on your Google account, please sign in with that!",
        name: "errorGoogleProvider",
      );

  String get errorInvalidCredentials => Intl.message(
        "Couldn't verify your identity, please check your e-mail and password.",
        name: "errorInvalidCredentials",
      );

  String get errorSignIn => Intl.message(
        "Couldn't sign in, please check your connection status!",
        name: "errorSignIn",
      );

  String get errorOcurred => Intl.message(
        "An unexpected error ocurred, please report this incident.",
        name: "errorOcurred",
      );

  String get errorEmpty => Intl.message(
        "This field can't be empty!",
        name: "errorEmpty",
      );

  String get errorEmailInvalid => Intl.message(
        "This e-mail format is invalid!",
        name: "errorEmailInvalid",
      );

  String get errorPasswordInvalid => Intl.message(
        "Your password should have at least 8 characters!",
        name: "errorPasswordInvalid",
      );
}

class _TranslationDelegate extends LocalizationsDelegate<Translation> {
  const _TranslationDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<Translation> load(Locale locale) => Translation.load(locale);

  @override
  bool shouldReload(_TranslationDelegate old) => false;
}
