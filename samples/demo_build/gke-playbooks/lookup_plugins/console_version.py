from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
from ansible.parsing.splitter import parse_kv
import json
import requests
from base64 import b64encode

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

VALID_PARAMS = frozenset(('user','password'))

def _parse_parameters(term):
    """Hacky parsing of params
    See https://github.com/ansible/ansible-modules-core/issues/1968#issuecomment-136842156
    and the first_found lookup For how we want to fix this later
    """
    first_split = term.split(' ', 1)
    if len(first_split) <= 1:
        # Not enough parameters
        raise AnsibleError('Need user and password parameters')
    else:
        console_url = first_split[0]
        params = parse_kv(first_split[1])

    # Check for invalid parameters.  Probably a user typo
    invalid_params = frozenset(params.keys()).difference(VALID_PARAMS)
    if invalid_params:
        raise AnsibleError('Unrecognized parameter(s) given to console_version: %s' % ', '.join(invalid_params))

    params['user'] = params.get('user', None)

    params['password'] = params.get('password', None)

    return console_url, params

class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):


        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct 'with_'.
        ret = []
        for term in terms:
            console_url,params = _parse_parameters(term)
            display.vvvv("Console: %s" % console_url)
            display.vvvv("user: %s" % params['user'])
            user=params['user']
            display.vvvv("password: %s" % params['password'])
            password=params['password']
            settings_api = console_url + "/api/v1/settings/system"
            display.vvvv("settings_api: %s" % settings_api)
            userAndPass = b64encode(user + ":" + password)
            headers = { 'Authorization' : 'Basic %s' %  userAndPass }
            r = requests.get(settings_api, headers=headers, verify=False)
            output = json.loads(r.text) 
            twistlock_version = output['lastInitializedVersion']
            display.vvvv(u"twistlock_version %s" % twistlock_version)
            ret.append(twistlock_version)


        return ret
