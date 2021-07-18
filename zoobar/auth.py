from zoodb import *
from debug import *
from pbkdf2 import PBKDF2

import os
import hashlib
import random

def newtoken(db, cred):
    hashinput = "%s%.10f" % (cred.password, random.random())
    cred.token = hashlib.md5(hashinput).hexdigest()
    db.commit()
    return cred.token

# Exercise 5 & 6
def login(username, password):
    db = cred_setup()
    cred = db.query(Cred).get(username)
    if not cred:
        return None
    password = PBKDF2(password, cred.salt).hexread(32)
    if cred.password == password:
        return newtoken(db, cred)
    else:
        return None

# Exercise 5 & 6
def register(username, password):
    person_db = person_setup()
    cred_db = cred_setup()
    person = person_db.query(Person).get(username)
    if person:
        return None
    newperson = Person()
    newperson.username = username
    person_db.add(newperson)
    person_db.commit()


    newcred = Cred()
    newcred.username = username
    salt = os.urandom(8)
    newcred.salt = salt.encode('base-64')
    password = PBKDF2(password, newcred.salt).hexread(32)
    newcred.password = password
    cred_db.add(newcred)
    cred_db.commit()
    return newtoken(cred_db, newcred)

def check_token(username, token):
    db = cred_setup()
    cred = db.query(Cred).get(username)
    if cred and cred.token == token:
        return True
    else:
        return False

