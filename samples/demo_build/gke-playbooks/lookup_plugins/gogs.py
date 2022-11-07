# python 3 headers, required if submitting to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase

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
        k8s = kwargs.get('k8s', 'True')
        for term in terms:
            display.vvvv("Console lookup term: %s" % term)
            display.vvvv("k8s: %s" % k8s)
            if k8s == True:
                twistlock_console_addr = "https://console-" + term
                twistlock_defender_addr = "https://defender-" + term
                gogs_addr = "https://gogs-" + term
            else:
                twistlock_console_addr = "https://" + term + ":8083"
                twistlock_defender_addr = "https://" + term + ":8084"
                gogs_addr = "https://gogs-" + term


            display.vvvv(u"twistlock_defender_addr %s" % twistlock_defender_addr)
            ret.append(gogs_addr)


        return ret