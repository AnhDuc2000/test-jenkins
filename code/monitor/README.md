Confluence URL Monitor Ansible Playbook
=======================================

This playbook sets up URL monitor for Confluence. See [roles](roles) for
configuration details.

The playbook requires Ansible to be installed and operational. Moreover, at the
time of this writing AWS Ansible modules do not work properly with Python 3,
and so the playbooks need to be run using Python 2.

The playbook has inventory per environment, located in [inventory](inventory)
folder, e.g.: `PENTEST`, `PROD`. The inventory contains the
environment-specific configurations. Check the roles' `README.md` for details
about configuration parameters.

To run the playbook for PenTest use the following command:
```
ansible-playbook -i inventory/PENTEST/hosts main.yml
```

If `/usr/bin/python` is Python 3, to run the playbook with Python 2, assuming
it is located in `/usr/bin/python2` use the following command:
```
ansible-playbook -i inventory/PENTEST/hosts main.yml -e 'ansible_python_interpreter=/usr/bin/python2'
```

The playbook is configured to check Confluence `/status` URL. [The following
comment](https://community.atlassian.com/t5/Jira-questions/Re-Status-URL-for-monitoring/qaq-p/146537/comment-id/61583#M61583)
lists all possible values (talks about JIRA but works similarly for confluence).

This playbook assumes that acceptable responses are HTTP 200 with content
`{"state":"RUNNING"}` or `{"state":"MAINTENANCE"}`. It therefore checks the
response for HTTP 200 and text `state`.
