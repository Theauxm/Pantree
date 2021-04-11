import firebase_admin


cred = firebase_admin.credentials.Certificate('../../CS4000/pantree-4347e-firebase-adminsdk-4neb9-82918d559e.json')
default_app = firebase_admin.initialize_app(cred)

