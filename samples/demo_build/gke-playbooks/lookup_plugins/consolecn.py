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
        # 20181203 - pfox
        #  modified to grab just the consoleCN, for the deployment of Defenders external to the K8S environment
        # for example, Windows Defender deployment. It will default to 8084, we should somehow supply that as an 
        # input variable for Consoles not listening on 8084. 
        ret = []
        k8s = kwargs.get('k8s', 'True')
        for term in terms:
            display.vvvv("Console lookup term: %s" % term)
            display.vvvv("k8s: %s" % k8s)
            if k8s == True:
                twistlock_defender_cn = "defender-" + term
            else:
                twistlock_defender_cn = "defender-" + term


            display.vvvv(u"twistlock_defender_cn %s" % twistlock_defender_cn)
            ret.append(twistlock_defender_cn)


        return ret