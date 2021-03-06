from debug import *
from zoodb import *
import rpclib

sockname = "/banksvc/sock"
# c = rpclib.client_connect(sockname)


def new_account(username):
    data = {}
    data['username'] = username
    c = rpclib.client_connect(sockname)
    return c.call('new_account',**data)

def get_log(username):
    data = {}
    data['username'] = username
    c = rpclib.client_connect(sockname)
    return c.call('get_log',**data)
    
def transfer(sender, recipient, zoobars, token):
    data = {}
    data['sender'] = sender
    data['recipient'] = recipient
    data['zoobars'] = zoobars
    data['token'] = token
    c = rpclib.client_connect(sockname)

    return c.call('transfer', **data)

def balance(username):
    data = {}
    data['username'] = username
    c = rpclib.client_connect(sockname)
    return c.call('balance',**data)
