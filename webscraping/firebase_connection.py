import firebase_admin
from firebase_admin import firestore

cred = firebase_admin.credentials.Certificate('./webscraping/database_admin_key.json')
default_app = firebase_admin.initialize_app(cred)

db = firestore.client()

doc_ref = db.collection(u'users').document(u'Obama')
doc_ref.set({
    u'name: ' : 'Barack Obama'
})