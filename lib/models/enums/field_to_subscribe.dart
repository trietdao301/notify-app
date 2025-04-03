import 'package:flutter/foundation.dart';

enum FieldToSubscribe {
  all("all"),
  recordingDate("recordingDate"),
  lastNameOrCorpName("lastNameOrCorpName"),
  firstName("firstName"),
  middleName("middleName"),
  generation("generation"),
  role("role"),
  partyType("partyType"),
  grantorOrGrantee("grantorOrGrantee"),
  book("book"),
  page("page"),
  itemNumber("itemNumber"),
  instrumentTypeCode("instrumentTypeCode"),
  instrumentTypeName("instrumentTypeName"),
  parcelId("parcelId"),
  referenceBook("referenceBook"),
  referencePage("referencePage"),
  remark1("remark1"),
  remark2("remark2"),
  instrumentId("instrumentId"),
  returnCode("returnCode"),
  numberOfAttempts("numberOfAttempts"),
  insertTimestamp("insertTimestamp"),
  editFlag("editFlag"),
  version("version"),
  attempts("attempts");

  final String name;

  const FieldToSubscribe(this.name);

  factory FieldToSubscribe.fromString(String inputField) {
    for (FieldToSubscribe field in FieldToSubscribe.values) {
      if (field.name == inputField) {
        return field;
      }
    }
    throw Exception("Error in FieldCanChange fromString");
  }
}
