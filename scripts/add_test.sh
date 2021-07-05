perl ./add_change_plan.pl --sitename "MyTest" --changescript "- name: MyMerge-module-attributes-of-given-access-groups
 hosts: \$tc_device_hostname\$
   connection: network_cli
   gather_facts: no
 vars:
   ansible_user: \$tc_device_username\$
   ansible_password: \$tc_device_password\$
   ansible_network_os: ios
 roles:
   Merge-module-attributes-of-given-access-groups" --changeplanname MyMerge-module-attributes-of-given-access-groups --changemode "enable" --changedescription "Automated changeplan created from Ansible collection /root/.ansible/collections/ansible_collections/cisco/ios/plugins/modules/ios_acl_interfaces.py" --changetype advanced --description "Automate changescript from Ansible collection" --parameters "Here are the params" --tag "Troubleshooting Change plans" --family "Any Device Family"
