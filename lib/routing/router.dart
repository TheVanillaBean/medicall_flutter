import 'dart:io';

import 'package:Medicall/components/drawer_menu/about_us.dart';
import 'package:Medicall/components/drawer_menu/contact_us.dart';
import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/screens/Shared/Login/login.dart';
import 'package:Medicall/screens/Shared/visit_information/consult_photos.dart';
import 'package:Medicall/screens/Shared/visit_information/review_visit_information.dart';
import 'package:Medicall/screens/patient_flow/account/patient_account.dart';
import 'package:Medicall/screens/patient_flow/account/payment_detail/payment_detail.dart';
import 'package:Medicall/screens/patient_flow/account/payment_detail/summary_payment.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_screen.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_view_model.dart';
import 'package:Medicall/screens/patient_flow/account/update_photo_id.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/drivers_license/photo_id.dart';
import 'package:Medicall/screens/patient_flow/patient_prescriptions/patient_prescriptions.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info.dart';
import 'package:Medicall/screens/patient_flow/previous_visits/previous_visits.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/questions_screen.dart';
import 'package:Medicall/screens/patient_flow/registration/registration.dart';
import 'package:Medicall/screens/patient_flow/select_provider/provider_detail.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/cosmetic_symptoms.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptom_detail.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptoms.dart';
import 'package:Medicall/screens/patient_flow/update_medical_history/view_medical_history.dart';
import 'package:Medicall/screens/patient_flow/video_notes_from_provider/video_notes_from_provider.dart';
import 'package:Medicall/screens/patient_flow/visit_confirmed/confirm_consult.dart';
import 'package:Medicall/screens/patient_flow/visit_details/card_select.dart';
import 'package:Medicall/screens/patient_flow/visit_details/prescription_checkout.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_details_overview.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_doc_note.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_education.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_non_prescriptions.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_prescriptions.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_treatment_recommendations.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment.dart';
import 'package:Medicall/screens/patient_flow/zip_code_verify/zip_code_verify.dart';
import 'package:Medicall/screens/provider_flow/account/provider_account.dart';
import 'package:Medicall/screens/provider_flow/account/select_services/select_services.dart';
import 'package:Medicall/screens/provider_flow/account/stripe_connect/stripe_connect.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_screen.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard.dart';
import 'package:Medicall/screens/provider_flow/provider_visits/provider_visits.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_registration.dart';
import 'package:Medicall/screens/provider_flow/review_medical_history/review_medical_history.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/complete_visit/complete_visit.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/immediate_care/immediate_medical_care.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/prescription_details/prescription_details.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_help.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_help_other.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_office.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_patient_conduct.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_patient_satisfaction.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_poor_info.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/edit_note/edit_note_section.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reclassify_visit/reclassify_visit.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/view_patient_id.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/view_patient_info.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_overview.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review.dart';
import 'package:Medicall/screens/shared/chat/chat_screen.dart';
import 'package:Medicall/screens/shared/consent/index.dart';
import 'package:Medicall/screens/shared/password_reset/password_reset.dart';
import 'package:Medicall/screens/shared/privacy/index.dart';
import 'package:Medicall/screens/shared/terms/index.dart';
import 'package:Medicall/screens/shared/video_player/video_player.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class Routes {
  static const login = '/login';
  static const phoneAuth = '/phone-auth';
  static const registrationType = '/registration-type';
  static const welcome = '/welcome';
  static const startVisit = '/start-visit';
  static const zipCodeVerify = '/zip-code-verify';
  static const registration = '/registration';
  static const providerRegistration = '/provider-registration';
  static const updateProviderInfo = '/update-provider-info';
  static const reset_password = '/reset-password';
  static const photoID = '/photo-ID';
  static const personalInfo = '/personal-information';
  static const confirmConsult = '/confirm-consult';
  static const patientDashboard = '/patient-dashboard';
  static const providerDashboard = '/provider-dashboard';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const consent = '/consent';
  static const malpractice = '/malpractice';
  static const symptoms = '/symptoms';
  static const cosmeticSymptoms = '/cosmetic-symptoms';
  static const symptomDetail = '/symptoms-detail';
  static const questions = '/questions';
  static const selectProvider = '/select-provider';
  static const providerDetail = '/provider-detail';
  static const consultReview = '/consult-review';
  static const makePayment = '/make-payment';
  static const paymentSummary = '/payment-summary';
  static const history = '/history';
  static const historyDetail = '/history-detail';
  static const patientAccount = '/patient-account';
  static const updatePatientInfo = '/update-patient-info';
  static const updatePatientID = '/update-patient-id';
  static const providerAccount = '/provider-account';
  static const paymentDetail = '/payment-detail';
  static const stripeConnect = '/stripe-connect';
  static const consultDetail = '/consult-detail';
  static const previousConsults = '/previous-consults';
  static const videoNotesFromProvider = '/video-notes-from-provider';
  static const prescriptionDetails = '/prescription-details';
  static const patientPrescriptions = '/patient-prescriptions';
  static const visitOverview = '/visit-overview';
  static const viewPatientID = '/view-patient-id';
  static const viewPatientInfo = '/view-patient-info';
  static const visitDetailsOverview = '/visit-details-overview';
  static const visitTreatments = '/visit-treatments';
  static const visitInformation = '/visit-information';
  static const reviewMedicalHistory = '/review-medical-history';
  static const visitConsultPhotos = '/visit-consult-photos';
  static const visitDocNote = '/visit-doc-note';
  static const visitEducation = '/visit-education';
  static const visitPrescriptions = '/visit-prescriptions';
  static const visitHelp = '/visit-help';
  static const visitPoorInfo = '/visit-poor-info';
  static const visitOffice = '/visit-office';
  static const visitPatientSatisfaction = '/visit-patient-satisfaction';
  static const visitPatientConduct = '/visit-patient-conduct';
  static const visitHelpOther = '/visit-help-other';
  static const visitNonPrescriptions = '/visit-non-prescriptions';
  static const immediateMedicalCare = '/immediate-medical-care';
  static const completeVisit = '/complete-visit';
  static const reclassifyVisit = '/reclassify-visit';
  static const visitReview = '/visit-review';
  static const editNoteSection = '/edit-note-section';
  static const providerVisits = '/provider-visits';
  static const viewMedicalHistory = '/view-medical-history';
  static const chatScreen = '/chat-screen';
  static const prescriptionCheckout = '/prescription-checkout';
  static const cardSelect = '/card-select';
  static const aboutUs = '/about-us';
  static const contactUs = '/contact-us';
  static const selectServices = '/select-services';
  static const videoPlayer = '/video-player';
}

/// The word 'consult' and 'visit' are used separately, but mean the exact
/// same thing. Visit is the term we ended up going with, but haven't
/// refactored usages of consult out yet due to priorities.

class Router {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      /*********** GENERAL **********/

      case Routes.welcome:
        return MaterialPageRoute<dynamic>(
          builder: (context) => WelcomeScreen(),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.aboutUs:
        return MaterialPageRoute<dynamic>(
          builder: (context) => AboutUs(),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.aboutUs:
        return MaterialPageRoute<dynamic>(
          builder: (context) => AboutUs(),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.contactUs:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ContactUs(),
          settings: settings,
          fullscreenDialog: true,
        );

      /**** Login *****/

      case Routes.login:
        return MaterialPageRoute<dynamic>(
          builder: (context) => LoginScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.reset_password:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PasswordResetScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.terms:
        return MaterialPageRoute<dynamic>(
          builder: (context) => TermsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.privacy:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PrivacyScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.consent:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ConsentScreen(),
          settings: settings,
          fullscreenDialog: true,
        );

      /**** Visit Information *****/

      case Routes.visitInformation:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ReviewVisitInformation(consult: consult),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitConsultPhotos:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ConsultPhotos.create(context, consult),
          settings: settings,
          fullscreenDialog: true,
        );

      /**** Chat *****/

      case Routes.chatScreen:
        final Map<String, dynamic> mapArgs = args;
        final Channel channel = mapArgs['channel'];
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ChatScreen(
            channel: channel,
            consult: consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );

      /*********** PATIENT FLOW **********/

      case Routes.registration:
        return MaterialPageRoute<dynamic>(
          builder: (context) => RegistrationScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.patientAccount:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PatientAccountScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.updatePatientID:
        final Map<String, dynamic> mapArgs = args;
        final PatientUser user = mapArgs['user'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => UpdatePhotoID(user: user),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.updatePatientInfo:
        final Map<String, dynamic> mapArgs = args;
        final UpdatePatientInfoViewModel model = mapArgs['model'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => UpdatePatientInfoScreen.create(context, model),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that shows all the cards for the patient's profile
      case Routes.paymentDetail:
        final Map<String, dynamic> mapArgs = args;
        final dynamic model = mapArgs['model'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => PaymentDetail.create(context, model),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that shows the patient's medical history with the option to update it
      case Routes.viewMedicalHistory:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ViewMedicalHistory(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.patientDashboard:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PatientDashboardScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that shows all the patient's prescriptions across all their visits
      case Routes.patientPrescriptions:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PatientPrescriptions.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.previousConsults:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PreviousVisits.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.videoNotesFromProvider:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VideoNotesFromProvider.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.symptoms:
        return MaterialPageRoute<dynamic>(
          builder: (context) => SymptomsScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.cosmeticSymptoms:
        final Map<String, dynamic> mapArgs = args;
        final List<Symptom> symptoms = mapArgs['symptoms'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => CosmeticSymptomsScreen(symptoms: symptoms),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.symptomDetail:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        return MaterialPageRoute<dynamic>(
          builder: (_) => SymptomDetailScreen(symptom: symptom),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.zipCodeVerify:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ZipCodeVerifyScreen.create(context, symptom),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.selectProvider:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        final String state = mapArgs['state'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => SelectProviderScreen(
            symptom: symptom,
            state: state,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.providerDetail:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        final ProviderUser provider = mapArgs['provider'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderDetailScreen(
            symptom: symptom,
            provider: provider,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.startVisit:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => StartVisitScreen(
            consult: consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      // Questionnaire Screen, which has several sub widgets
      case Routes.questions:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final bool displayMedHistory = mapArgs['displayMedHistory'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => QuestionsScreen.create(
            context,
            displayMedHistory,
            consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that asks patient for to upload photo of their ID
      case Routes.photoID:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => PhotoIDScreen.create(context, consult),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that asks patient for their personal info. Only shown one time right after the patient's first visit is completed.
      case Routes.personalInfo:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => PersonalInfoScreen.create(context, consult),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that asks the patient to pay for the consult.
      case Routes.makePayment:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => MakePayment.create(context, consult),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that summarizes the payment.
      case Routes.paymentSummary:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => PaymentSummary(
            consult: consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      // Static screen that tells the patient that they have successfully complete their visit.
      case Routes.confirmConsult:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ConfirmConsult(),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that shows a list of buttons that give further details for a specific visit
      case Routes.visitDetailsOverview:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitDetailsOverview(consult: consult),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitTreatments:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitTreatmentRecommendations(
            consult: consult,
            visitReviewData: visitReviewData,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitDocNote:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitDocNote(
            consult: consult,
            visitReviewData: visitReviewData,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.editNoteSection:
        final Map<String, dynamic> mapArgs = args;
        final PatientNoteSection section = mapArgs['section'];
        final String sectionTitle = mapArgs['sectionTitle'];
        final Map<String, String> templateSection = mapArgs['templateSection'];
        final Map<String, String> editedSection = mapArgs['editedSection'];

        return MaterialPageRoute<Map<String, String>>(
          builder: (context) => EditNoteSection.create(
            context,
            section,
            sectionTitle,
            templateSection,
            editedSection,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitEducation:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitEducation(
            consult: consult,
            visitReviewData: visitReviewData,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitPrescriptions:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitPrescriptions(
            consult: consult,
            visitReviewData: visitReviewData,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitNonPrescriptions:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitNonPrescriptions(
            consult: consult,
            visitReviewData: visitReviewData,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitHelp:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitHelp(
            consult: consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitPoorInfo:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitPoorInfo(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitOffice:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitOffice(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitPatientSatisfaction:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitPatientSatisfaction(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitPatientConduct:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitPatientConduct(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.visitHelpOther:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitHelpOther(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.prescriptionCheckout:
        final Map<String, dynamic> mapArgs = args;
        final String consultId = mapArgs['consultId'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => PrescriptionCheckout.create(
            context,
            visitReviewData,
            consultId,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.cardSelect:
        final Map<String, dynamic> mapArgs = args;
        final dynamic model = mapArgs['model'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => CardSelect(model: model),
          settings: settings,
          fullscreenDialog: true,
        );

      /*********** PROVIDER FLOW **********/

      case Routes.providerRegistration:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderRegistrationScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.selectServices:
        final Map<String, dynamic> mapArgs = args;
        final UpdateProviderInfoViewModel model = mapArgs['model'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => SelectServices.create(context, model),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.updateProviderInfo:
        final Map<String, dynamic> mapArgs = args;
        final UpdateProviderInfoViewModel model = mapArgs['model'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => UpdateProviderInfoScreen.create(context, model),
          settings: settings,
          fullscreenDialog: true,
        );

      // Screen that asks the provider to connect their account with Stripe to receive payouts
      case Routes.stripeConnect:
        return MaterialPageRoute<dynamic>(
          builder: (context) => StripeConnect.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.providerAccount:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderAccountScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.providerDashboard:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderDashboardScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that shows all the visits for a provider
      case Routes.providerVisits:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderVisits.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen that shows an overview of a specific visit for a provider.
      // It has three buttons for reviewing the information, messaging the
      // patient, and for reviewing/signing the visit.
      case Routes.visitOverview:
        final Map<String, dynamic> mapArgs = args;
        final String consultId = mapArgs['consultId'];
        final PatientUser patientUser = mapArgs['patientUser'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitOverview(
            consultId: consultId,
            patientUser: patientUser,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.reviewMedicalHistory:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ReviewMedicalHistory(consult: consult),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.viewPatientID:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ViewPatientID(consult: consult),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.viewPatientInfo:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ViewPatientInfo(consult: consult),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.reclassifyVisit:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final List<String> totalSymptoms = mapArgs['totalSymptoms'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ReclassifyVisit.create(
            context,
            consult,
            totalSymptoms,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      // Screen where the provider reviews the visit.
      // Has several sub-widgets nested
      case Routes.visitReview:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final ConsultReviewOptions consultReviewOptions =
            mapArgs['consultReviewOptions'];
        final VisitReviewData visitReviewData = mapArgs['visitReviewData'];
        final DiagnosisOptions diagnosisOptions = mapArgs['diagnosisOptions'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => VisitReview.create(
            context,
            consult,
            consultReviewOptions,
            visitReviewData,
            diagnosisOptions,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.prescriptionDetails:
        final Map<String, dynamic> mapArgs = args;
        final TreatmentOptions treatmentOptions = mapArgs['treatmentOptions'];
        return MaterialPageRoute<TreatmentOptions>(
          builder: (context) => PrescriptionDetails.create(
            context,
            treatmentOptions,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.immediateMedicalCare:
        final Map<String, dynamic> mapArgs = args;
        final String documentation = mapArgs['documentation'];
        final PatientUser patientUser = mapArgs['patientUser'];
        return MaterialPageRoute<String>(
          builder: (context) => ImmediateMedicalCare.create(
            context,
            documentation,
            patientUser,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.completeVisit:
        return MaterialPageRoute<dynamic>(
          builder: (context) => CompleteVisit.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.videoPlayer:
        final Map<String, dynamic> mapArgs = args;
        final String title = mapArgs['title'];
        final bool fromNetwork = mapArgs['fromNetwork'];

        if (fromNetwork) {
          final String url = mapArgs['url'];
          return MaterialPageRoute<dynamic>(
            builder: (context) => VideoPlayer(
              title: title,
              url: url,
              fromNetwork: true,
            ),
            settings: settings,
            fullscreenDialog: true,
          );
        } else {
          final File file = mapArgs['file'];
          return MaterialPageRoute<dynamic>(
            builder: (context) => VideoPlayer(
              title: title,
              file: file,
              fromNetwork: false,
            ),
            settings: settings,
            fullscreenDialog: true,
          );
        }
        //never called but needed for some reason because switch statements are dumb
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
