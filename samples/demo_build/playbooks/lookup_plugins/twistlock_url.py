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


class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):


        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct 'with_'.
        ret = []
        for term in terms:
            auth_url = 'https://docs.twistlock.com/api/v1/authenticate'
            display.vvvv("auth_url: %s" % auth_url)
            version_url = 'https://docs.twistlock.com/docs/latest/download/version.json'
            display.vvvv("version_url: %s" % version_url)
            auth_json = '{"accessToken":"' + term + '"}'
            display.vvvv("auth_json: %s" % auth_json)
            token_json = requests.post(auth_url, data=auth_json)
            display.vvvv("token_json: %s" % token_json.text)
            parsed_token = json.loads(token_json.text)
            cookies = dict(token=parsed_token['token'])

            version_json = requests.get(version_url, cookies=cookies)

            ret.append(version_json.text)


        return ret