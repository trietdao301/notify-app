import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String documentId;
  final String?
  recordingDate; // Stored as String (YYYYMMDD), parsed to DateTime when needed
  final String lastNameOrCorpName;
  final String? firstName;
  final String? middleName;
  final String? generation; // e.g., JR, III
  final String? role; // e.g., TRUSTEE, POA
  final String partyType; // 'C' (Corporation) or 'I' (Individual)
  final String grantorOrGrantee; // 'R' (Grantor) or 'E' (Grantee)
  final String book;
  final String page;
  final int itemNumber;
  final int instrumentTypeCode;
  final String instrumentTypeName;
  final String parcelId;
  final String referenceBook;
  final String referencePage;
  final String? remark1;
  final String? remark2;
  final String? instrumentId; // Optional
  final int returnCode;
  final int numberOfAttempts;
  final DateTime insertTimestamp; // Converted to DateTime
  final bool editFlag; // 0 or 1 as boolean
  final int version;
  final int attempts;

  Property({
    this.recordingDate,
    required this.lastNameOrCorpName,
    this.firstName,
    this.middleName,
    this.generation,
    this.role,
    required this.partyType,
    required this.grantorOrGrantee,
    required this.book,
    required this.page,
    required this.itemNumber,
    required this.instrumentTypeCode,
    required this.instrumentTypeName,
    required this.parcelId,
    required this.referenceBook,
    required this.referencePage,
    this.remark1,
    this.remark2,
    this.instrumentId,
    required this.returnCode,
    required this.numberOfAttempts,
    required this.insertTimestamp,
    required this.editFlag,
    required this.documentId,
    required this.version,
    required this.attempts,
  });

  // Parse recordingDate String (YYYYMMDD) to DateTime if needed
  DateTime? get parsedRecordingDate {
    if (recordingDate == null || recordingDate!.length != 8) return null;
    try {
      return DateTime.parse(
        '${recordingDate!.substring(0, 4)}-${recordingDate!.substring(4, 6)}-${recordingDate!.substring(6, 8)}',
      );
    } catch (e) {
      return null;
    }
  }

  // From Firestore map
  factory Property.fromFirestore(Map<String, dynamic> data, String id) {
    return Property(
      recordingDate: data['recording_date'] as String?,
      lastNameOrCorpName: data['last_name_or_corp_name'] ?? '',
      firstName: data['first_name'] as String?,
      middleName: data['middle_name'] as String?,
      generation: data['generation'] as String?,
      role: data['role'] as String?,
      partyType: data['party_type'] ?? 'I', // Default to Individual
      grantorOrGrantee: data['grantor_or_grantee'] ?? 'E', // Default to Grantee
      book: data['book']?.toString() ?? '0',
      page: data['page']?.toString() ?? '0',
      itemNumber: data['item_number'] as int? ?? 0,
      instrumentTypeCode: data['instrument_type_code'] as int? ?? 0,
      instrumentTypeName: data['instrument_type_name'] ?? '',
      parcelId: data['parcel_id'] ?? id, // Use doc ID if parcel_id missing
      referenceBook: data['reference_book']?.toString() ?? '0',
      referencePage: data['reference_page']?.toString() ?? '0',
      remark1: data['remark_1'] as String?,
      remark2: data['remark_2'] as String?,
      instrumentId: data['instrument_id'] as String?,
      returnCode: data['return_code'] as int? ?? 0,
      numberOfAttempts: data['number_of_attempts'] as int? ?? 0,
      insertTimestamp:
          (data['insert_timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editFlag: (data['edit_flag'] as int? ?? 0) == 1,
      documentId: data['document_id']?.toString() ?? id,
      version: data['version'] as int? ?? 1,
      attempts: data['attempts'] as int? ?? 0,
    );
  }

  // To Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'recording_date': recordingDate,
      'last_name_or_corp_name': lastNameOrCorpName,
      'first_name': firstName,
      'middle_name': middleName,
      'generation': generation,
      'role': role,
      'party_type': partyType,
      'grantor_or_grantee': grantorOrGrantee,
      'book': book,
      'page': page,
      'item_number': itemNumber,
      'instrument_type_code': instrumentTypeCode,
      'instrument_type_name': instrumentTypeName,
      'parcel_id': parcelId,
      'reference_book': referenceBook,
      'reference_page': referencePage,
      'remark_1': remark1,
      'remark_2': remark2,
      'instrument_id': instrumentId,
      'return_code': returnCode,
      'number_of_attempts': numberOfAttempts,
      'insert_timestamp': Timestamp.fromDate(insertTimestamp),
      'edit_flag': editFlag ? 1 : 0,
      'document_id': documentId,
      'version': version,
      'attempts': attempts,
    };
  }
}
