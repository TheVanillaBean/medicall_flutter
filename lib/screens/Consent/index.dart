import 'package:Medicall/models/medicall_user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String _returnString(user) {
  var fullName = user.displayName;
  var loc = user.address;
  var dob = user.dob;
  var now = DateTime.now();
  var formatter = DateFormat('MM-dd-yyyy');
  String formatted = formatter.format(now);
  String consent = ''' 
Before we begin, we need your consent to provide medical services online.
____

iNFORMED CONSENT REGARDING USE OF TELEHEALTH TO DELIVER CARE

BY CLICK “I AGREE,” CHECKING A RELATED BOX TO SIGNIFY YOUR ACCEPTANCE, USING ANY OTHER ACCEPTANCE PROTOCOL PRESENTED THROUGH THE SERVICE OR OTHERWISE AFFIRMATIVELY ACCEPTING THIS CONSENT, YOU ACKNOWLEDGE THAT YOU HAVE READ, ACCEPTED, AND AGREED TO BE BOUND BY THIS CONSENT. IF YOU DO NOT AGREE TO THIS CONSENT, DO NOT CREATE AN ACCOUNT OR USE THE SERVICE. YOU HEREBY GRANT AGENCY AUTHORITY TO ANY PARTY WHO CLICKS ON THE “I AGREE” BUTTON OR OTHERWISE INDICATES ACCEPTANCE TO THIS CONSENT ON YOUR BEHALF.

PURPOSE
The purpose of this consent form (“consent”) is to provide you with information about telehealth and to obtain your informed consent to the use of telehealth in the delivery of healthcare services to you by physicians, physician assistants and nurse practitioners (“Providers” using the online platforms owned and operated by Medicall, Inc. (the “Service”)

USE OF TELEHEALTH
Telehealth involves the delivery of healthcare services using electronic communications, information technology or other means between a healthcare provider and a patient who are not in the same physical location. Telehealth may be used for diagnosis, treatment, follow-up and/or patient education, and may include, but is not limited to, one or more of the following: electronic transmission of medical records, photo images, personal health information or other data between a patient and a healthcare provider; interactions between a patient and healthcare providers via audio, video and/or data communications (such as secure messaging); use of output data from medical devices, sound and video files. Alternative methods of care may be available to you, such as in-person services, and you may choose an alternative at any time. Always discuss alternative options with your provider.

ANTICIPATED BENEFITS
The use of telehealth may have the following possible benefits: Making it easier and more efficient for you to access medical care and treatment for the conditions treated by your Provider(s); allowing you to obtain medical care and treatment by Provider(s) at times that are convenient for you; and enabling you to interact with Provider(s) without the necessity of an in-office appointment.


POTENTIAL RISKS
While the use of telehealth in the delivery of care can provide potential benefits for you, there are also potential risks associated with the use of telehealth and other technology. These risks include, but may not be limited to the following: the quality, accuracy or effectiveness of the services you receive from your Provider could be limited as the technology, including the Service, may contain bugs or other errors, including ones which may limit functionality, produce erroneous results, rendering part or all of such technology, including the Service, unavailable or inoperative, produce incorrect records, transmissions, data or consent, or cause records, transmissions, data or content to be corrupted or lost; failures of technology may also impact your Provider(s) ability to correctly diagnose or treat your medical condition; the inability of your Provider(s) to conduct certain tests or assess vital signs in-person may in some cases prevent the Provider(s) from providing a diagnosis or treatment or from identifying the need for emergency medical care or treatment for you; your Providers(s) may not be able to provide medical treatment for your particular condition and you may be required to seek alternative health care or emergency care services; delays in medical evaluation/treatment could occur due to unavailability of your Provider(s) or deficiency or failures of the technology oro electronic equipment used; the electronic systems or other security protocols or safeguards used could fail, causing a breach of the privacy of your medical or other information; given regularly requirements in certain jurisdictions, your Provider(s) diagnosis and/or treatment options, especially pertaining to certain prescriptions, may be limited; a lack of access to all of your medical records may result in adverse drug interactions or allergic reactions or other judgment errors.

FOLLOW-UP CARE; EMERGENCY SITUATIONS
If the situation is an emergency, call 911. In some situations, telehealth is not an appropriate method of care. If you require immediate or urgent care, you must seek care at an emergency room facility or other provider equipped to deliver urgent or emergent care. If you are not experiencing an emergency or do not require immediate or urgent care, you can communicate with Providers through the secure message service in the Platforms. If a technical failure prevents you from communicating with your Providers through the Platforms, you should call their office number.

DATA PRIVACY AND PROTECTION
The electronic systems used in the Service will incorporate network and software security protocols to protect the privacy and security of your information, and will include measures to safeguard data against intentional or unintentional corruption. Personal information that identifies you or contains protected health information will not be disclosed to any third party without your consent, except as authorized by law for the purposes of consultation, treatment, payment/billing, and certain administrative purposes, or as otherwise set forth in your Provider’s Privacy Policy.

YOUR ACKNOWLEDGEMENTS
By clicking “I Agree”, checking a related box to signify your acceptance, using any other acceptance protocol presented through the Service or otherwise affirmatively accepting this consent, you are agreeing and providing your consent with respect to the following: Healthcare services provided to you by Providers via the Service will be provided by telehealth. Certain technology, including the Service, may be used while still in a beta testing and development phase, and before such technology is a final and finished product. Technology used to deliver care, including the Service, may contain bugs or other errors, including ones which may limit functionality, produce erroneous results, render part or all of such technology unavailable or inoperable, produce incorrect records, transmissions, data or content, or cause records, transmissions, data or content too be corrupted or lost, and or all of which could limit or otherwise impact the quality, accuracy and/or effectiveness of the medical care or other services that you receive from your Provider(s). The delivery of healthcare services via telehealth is an evolving field and the use of telehealth or other technology in your medical care and treatment from Provider(s) may include uses of technology different from those described in this Consent or not specifically described in this Consent. No potential benefits from the use of telehealth or other technology  or specific results can be guaranteed. Your conditions may not be cured or improved, and in some cases, may get worse. There are limitations in the provision of medical care and treatment via telehealth and technology, including the Service, and you may not be able to receive diagnosis and/or treatment through telehealth for every condition for which you seek diagnosis and/or treatment. There are potential risks to the use of telehealth and other technology, including but not limited to the risks described in this Consent. You have the opportunity to discuss the use of telehealth, including the Service, with your Provider(s), including the benefits and risks of such use and the alternatives to the use of telehealth. You have the right to withdraw your consent to the use of telehealth in the course of your care, without prejudice to any future care or treatment and without risking the loss or withdrawal of any health benefits to which you or entitled. Any withdrawal of your content will be effective upon receipt of written notice to your Providers, except that such withdrawal will not have any effect on any action taken by Medicall, Inc. or your Provider(s) in reliance on this Consent before it received your written notice of withdrawal. Any withdrawal of your consent will not  void any other provision of this Consent, and you will continue to be bound by this Consent. You understand that the use of telehealth involves electronic communication of your personal medical information to Provider(s). You understand that it is your duty to provide Medicall, Inc. and your Provider(s) truthful, accurate and complete information, including all relevant information regarding care that you may have received or may be receiving from healthcare providers. You understand that each of your Provider(s) may determine in his or her sole discretion that you condition is not suitable for diagnosis and/or treatment using telehealth technology, including the Service, and that you may need to be evaluated by the Provider(s), or other healthcare providers, outside of such telehealth technology. 


Additional State-Specific Consents: The following consents apply to users accessing the Medicall, Inc. website for the purposes of participating in a telehealth consultation as required by the states listed below:
Alaska: I understand my primary care provider may obtain a copy of my records of my telehealth encounter. (Alaska Stat. § 08.64.364).
Arizona: I understand I am entitled to all existing confidentiality protections pursuant to A.R.S. § 12-2292. I also understand all medical reports resulting from the telemedicine consultation are part of my medical record as defined in A.R.S. § 12-2291. I also understand dissemination of any images or information identifiable to me for research or educational purposes shall not occur without my consent, unless authorized by state or federal law. (Ariz. Rev. Stat. Ann. § 36-3602).
Connecticut: I understand that my primary care provider may obtain a copy of my records of my telehealth encounter. (Conn. Gen. Stat. Ann. § 19a-906).
District of Columbia: I have been informed of alternate forms of communication between me and a provider or other treating physician for urgent matters. (D.C. Mun. Regs. tit. 17, § 4618.10).
Georgia: I have been given clear, appropriate, accurate instructions on follow-up in the event of needed emergent care related to the treatment. (Ga. Comp. R. & Regs. 360-3-.07(7)).
Kansas: I understand that if I have a primary care provider or other treating physician, the person providing telemedicine services must send within three business days a report to such primary care provider or other treating physician of the treatment and services rendered to me during the telemedicine encounter. (Kan. Stat. Ann. § 40-2,212(2)(d)(1)(A)).
Kentucky: If I am a Medicaid recipient, I recognize I have the option to refuse the telehealth consultation at any time without affecting the right to future care or treatment and without risking the loss or withdrawal of a Medicaid benefit to which I am entitled. I understand that I have the right to be informed of any party who will be present at the site during the telehealth consult and I have the right to exclude anyone from being present. I also understand that I have the right to object to the videotaping of the telehealth consultation. (907 Ky. Admin. Regs. 3:170).
Louisiana: I understand the role of other health care providers that may be present during the consultation other than the Medicall, Inc. provider. (46 La. Admin. Code Pt XLV, § 7511).
Maryland: Regarding audiologists, speech language pathologists, and hearing aid dispensers, I recognize the inability to have direct, physical contact with the patient is a primary difference between telehealth and direct in-person service delivery. The knowledge, experiences, and qualifications of the consultant providing data and information to the provider of the telehealth services need not be completely known to and understood by the provider. The quality of transmitted data may affect the quality of services provided by the provider. Changes in the environment and test conditions could be impossible to make during delivery of telehealth services. Telehealth services may not be provided by correspondence only. (Md. Code Regs. 10.41.06.04).
Nebraska: If I am a Medicaid recipient, I retain the option to refuse the telehealth consultation at any time without affecting my right to future care or treatment and without risking the loss or withdrawal of any program benefits to which the patient would otherwise be entitled. All existing confidentiality protections shall apply to the telehealth consultation. I shall have access to all medical information resulting from the telehealth consultation as provided by law for access to my medical records. Dissemination of any patient identifiable images or information from the telehealth consultation to researchers or other entities shall not occur without my written consent. I understand that I have the right to request an in-person consult immediately after the telehealth consult and I will be informed if such consult is not available. (Neb. Rev. Stat. Ann. § 71-8505; 471 Neb. Admin. Code § 1-006.05).
New Hampshire: I understand that the Medicall, Inc. provider may forward my medical records to my primary care or treating provider. (N.H. Rev. Stat. § 329:1-d).
New Jersey: I understand I have the right to request a copy of my medical information and I understand my medical information may be forwarded directly to my primary care provider or health care provider of record, or upon my request, to other health care providers. (N.J. Rev. Stat. Ann. § 45:1-62).
Pennsylvania: I understand that I may be asked to confirm my consent to behavioral health or tele-psych services.
Rhode Island: If I use e-mail or text-based technology to communicate with my Medicall, Inc. provider, then I understand the types of transmissions that will be permitted and the circumstances when alternate forms of communication or office visits should be utilized. I have also discussed security measures, such as encryption of data, password protected screen savers and data files, or utilization of other reliable authentication techniques, as well as potential risks to privacy. I acknowledge that my failure to comply with this agreement may result in the Medicall, Inc. provider terminating the e-mail relationship. (Rhode Island Medical Board Guidelines).
South Carolina: I understand my medical records may be distributed in accordance with applicable law and regulation to other treating health care practitioners. (S.C. Code Ann. § 40-47-37).
South Dakota: I have received disclosures regarding the delivery models and treatment methods or limitations. I have discussed with the Medicall, Inc. provider the diagnosis and its evidentiary basis, and the risks and benefits of various treatment options. (S.D. SB136 (not yet codified)).
Tennessee: I understand that I may request an in-person assessment before receiving a telehealth assessment if I am a Medicaid recipient.
Texas: II understand that my medical records may be sent to my primary care provider. (Tex. Occ. Code Ann. § 111.005).
Utah: I understand (i) any additional fees charged for telehealth services, if any, and how payment is to be made for those additional fees, if the fees are charged separately from any fees for face-to-face services provided in combination with the telehealth services; (ii) to whom my health information may be disclosed and for what purpose, and have received information on any consent governing release of my patient-identifiable information to a third-party; (iii) my rights with respect to patient health information; (iv) appropriate uses and limitations of the site, including emergency health situations. I understand that the telehealth services Medicall, Inc. provides meets industry security and privacy standards, and comply with all laws referenced in Subsection 26-60-102(8)(b)(ii). I was warned of: potential risks to privacy notwithstanding the security measures and that information may be lost due to technical failures, and agree to hold the provider harmless for such loss. I have been provided with the location of Medicall, Inc.’s website and contact information. I was able to select my provider of choice, to the extent possible. I was able to select my pharmacy of choice. I am able to a (i) access, supplement, and amend my patient-provided personal health information; (ii) contact my provider for subsequent care; (iii) obtain upon request an electronic or hard copy of my medical record documenting the telemedicine services, including the informed consent provided; and (iv) request a transfer to another provider of my medical record documenting the telemedicine services. (Utah Admin. Code r. 156-1-602).
Virginia: I acknowledge that I have received details on security measures taken with the use of telemedicine services, such as encrypting date of service, password protected screen savers, encrypting data files, or utilizing other reliable authentication techniques, as well as potential risks to privacy notwithstanding such measures; I agree to hold harmless Medicall, Inc. for information lost due to technical failures; and I provide my express consent to forward patient-identifiable information to a third party. (Virginia Board of Medicine Guidance Document 85-12).
Vermont: I understand that I have the right to receive a consult with a distant-site provider and will receive one upon request immediately or within a reasonable time after the results of the initial consult. I understand that receiving tele-dermatology or tele-ophthalmology services via Medicall, Inc. does not preclude me from receiving real-time telemedicine or face-to-face services with the distant provider at a future date. (Vt. Stat. Ann. § 9361).

If you have a concern about a medical professional, you may contact the Medical Board in your state regarding your concerns. For applicable contact information see the list available here.

Patient’s Legal Name
$fullName

Location
$loc

Date of birth
$dob

Date of consent
$formatted
____
By tapping “I Agree” below, I understand and consent to the above and the Terms of Service and Privacy Policy.

Thanks again for using Medicall!''';
  return consent;
}

class ConsentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Telemedicine Consent'),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            children: <Widget>[
              Text(
                _returnString(medicallUser),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.all(20),
                      onPressed: () {
                        medicallUser.consent = true;

                        Navigator.of(context)
                            .pushReplacementNamed('/phoneAuth');
                      },
                      color: Colors.green,
                      child: Text(
                        'I AGREE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
