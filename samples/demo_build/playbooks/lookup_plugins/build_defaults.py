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

        dictionary = {
              "region": "us-central1",
              "zone": "us-central1-c",
              "project_id": "cto-sandbox",
              "dns_project_id": "cto-sandbox",
              "image": "demo-build",
              "prebuilt_image": "true",
              "windowsimage": "https://www.googleapis.com/compute/v1/projects/cto-sandbox/global/images/windows2019-demo-build-v2",
              "dns_zone": "lab.twistlock.com",
              "twistlock_install_prerelease": "false",
              "k8s_cni": "Weave"
        }
        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct 'with_'.
        ret = []
        for term in terms:
            ret.append(dictionary[term])


        return ret
