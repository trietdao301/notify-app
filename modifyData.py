import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import json

# Initialize Firebase Admin SDK with your service account key
cred = credentials.Certificate('notification-app-123456-firebase-adminsdk-fbsvc-caf496290a.json')  # Update this path if needed
firebase_admin.initialize_app(cred)

# Get a reference to Firestore
db = firestore.client()

# Sample property object
property = {
    'recordingDate': '20050923',
    'lastNameOrCorpName': 'SCOFIELD',
    'firstName': 'MICHAEL',
    'middleName': 'S',
    'generation': None,
    'role': None,
    'partyType': 'I',
    'grantorOrGrantee': 'E',
    'book': '438',
    'page': '1',
    'itemNumber': 0,
    'instrumentTypeCode': 1,
    'instrumentTypeName': 'DEED',
    'parcelId': 'MD-2005-438-1-001',
    'referenceBook': '0',
    'referencePage': '0',
    'remark1': 'ED1 GALENA TM8PN167',
    'remark2': '26852',
    'instrumentId': None,
    'returnCode': 0,
    'numberOfAttempts': 0,
    'insertTimestamp': datetime.strptime('2005-09-27 10:41:00', '%Y-%m-%d %H:%M:%S'),
    'editFlag': False,
    'documentId': '5',
    'version': 1,
    'attempts': 0,
}

# Import the house object into Firestore
def import_house():
    try:
        # Use the documentId as the document ID
        doc_id = property['documentId']
        db.collection('properties').document(doc_id).set(property)
        
        print(f"Imported property with ID: {doc_id}")
    except Exception as e:
        print(f"Error importing house: {e}")

# Update editFlag and book fields for a property with documentId = '4'
def update_property():
    try:
        # Directly update the document with ID '4'
        db.collection('properties').document('4').update({
            'editFlag': True,
            'book': '450'  # Stored as string to match your sample data
        })
        print("Updated property with ID: '4'")
    except Exception as e:
        print(f"Error updating property: {e}")

# Run the import and test the update function
if __name__ == "__main__":
    # Update the property with documentId = '4'
    update_property()