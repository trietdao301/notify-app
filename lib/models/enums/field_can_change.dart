import 'package:flutter/foundation.dart';

enum FieldCanChange {
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

  const FieldCanChange(this.name);

  factory FieldCanChange.fromString(String input_field) {
    for (FieldCanChange field in FieldCanChange.values) {
      if (field.name == input_field) {
        return field;
      }
    }
    throw Exception("Error in FieldCanChange fromString");
  }
}
