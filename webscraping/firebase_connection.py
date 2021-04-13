import firebase_admin
from firebase_admin import firestore

cred = firebase_admin.credentials.Certificate('./webscraping/database_admin_key.json')
default_app = firebase_admin.initialize_app(cred)

db = firestore.client()

doc_ref = db.collection(u'users').document(u'Obama')
doc_ref.set({
    u'name: ' : 'Barack Obama'
})


ref = db.collection(u'food').stream()
for doc in ref:
    print(f'{doc.id} => {doc.to_dict()}')

ref_2 = db.collection(u'food').document(u'Apple').get()
ref_3 = db.collection(u'food').document(u'Cocaine').get()

if ref_2.exists:
    print(f'Document data: {ref_2.to_dict()}')
else:
    print("Didn't get data for 2")

if ref_3.exists:
    print(f'Document data: {ref_3.to_dict()}')
else:
    print("Didn't get data for 2")