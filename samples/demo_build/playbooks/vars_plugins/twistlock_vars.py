# (c) 2012, Michael DeHaan <michael.dehaan@gmail.com>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

import os
import glob
from ansible import constants as C
from ansible.errors import AnsibleParserError
from ansible.module_utils._text import to_bytes, to_native, to_text
from ansible.plugins.vars import BaseVarsPlugin
from ansible.inventory.host import Host
from ansible.inventory.group import Group
from ansible.utils.vars import combine_vars


FOUND = {}


class VarsModule(object):


    def get_vars(self, loader, path, entities):
        # return the inventory variables for the host
        
        inventory = self.inventory
        #hostrec = inventory.get_host(host)

        console = inventory.playbook.inventory.groups['console'].get_hosts()[0]
        console_name = console.name

        basedir = inventory.basedir()

        group_vars_dir = os.path.join(basedir, "group_vars")
        all_vars_file = os.path.join(group_vars_dir, "all.yml")
        all_vars = utils.parse_yaml_from_file(all_vars_file)

        k8s = all_vars.get('k8s_enabled', 'True')

        if k8s == 'True':
            twistlock_console_addr = "https://console-" + console_name
            twistlock_defender_addr = "https://defender-" + console_name
        else:
            twistlock_console_addr = "https://" + console_name + ":8083"
            twistlock_defender_addr = "https://" + console_name + ":8084"
        
        results = {}

        results[twistlock_console_addr] = twistlock_console_addr
        results[twistlock_defender_addr] = twistlock_defender_addr

        return results