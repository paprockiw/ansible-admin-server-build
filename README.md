# ansible_admin_server_build

This repository contains an Ansible playbook that provisions an admin or developer
server on Amazon Linux 2023. It installs key utilities like Git, Python (from
source), Terraform, and sets up shell profiles and optional SSH keys.

## Table of Contents

- [Project Structure](#project-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#-usage)

## Project Structure
```
ansible_admin_server_build/
├── files/ # Optional: .bashrc, .bash_profile, SSH config/public keys
├── roles/
│ ├── common_tools/ # Installs basic CLI tools and updates system
│ ├── python/ # Installs Python from source with logging
│ └── terraform/ # Installs Terraform and optionally tfswitch
├── hosts.yml # Example inventory file
├── Makefile # Builds virtual env, manages pip dependencies
├── playbook.yml # Main Ansible playbook
├── requirements.txt # Pip dependencies (e.g., ansible)
└── README.md # This file
```


# Features

- Creates a target user and sets up home directory
- Installs:
  - Python (configurable version, built from source)
  - Terraform (via zip download)
  - Common CLI tools: `curl`, `git`, `jq`, `vim`, etc.
- Installs `.bashrc` and `.bash_profile` files. 
- Optionally installs SSH public key for access.
- Adds logging to long-running compile steps
- Related tasks are tagged for easy replay of task sets 

## Prerequisites

- Python ≥3.9 and Ansible installed on the control node
- SSH access to the target EC2/Linux instance

To install Ansible locally, use the Makefile:

```bash
make venv
make dependencies
```

Note: that the Makefile looks for a galaxy_requirements.yml file to install any 
outside dependencies. It will throw an error message if it's not there, but it 
doesn't matter if it is not in use.


# Usage

### Set up hosts.yml
Modify your hosts.yml file to include the proper variables:
```
all:
  children:
    admin_servers:
      hosts:
        <YOUR IP HERE>:
          ansible_user: ec2-user
          ansible_ssh_private_key_file: ~/.ssh/<YOUR SSH KEY HERE>
          ansible_connection: ssh
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o PreferredAuthentications=publickey'
```                                                                                                        

### Modify vars
You can change the values of variables in this playbook. 
You may want to set them in group_vars/all.yml
You can also set role variables under a role in a playbook:
```
  vars:
    target_user: admin-user
    bash_profile_file: bash_profile # Name of file in files/ directory
    bash_rc_file: bash_rc           # Name of file in files/ directory
  
  roles:
  ### Install utilities
    - role: common_tools
    - role: python3
       python_version: "3.10.0"
       python_major_version: "3.10"
       python_link_name: python3-10
```

### Run the playbook:
```
# Test first:
ansible-playbook -i inventory.ini playbook.yml --check

# Run for real:
ansible-playbook -i inventory.ini playbook.yml

# Use tags to run only some tasks:
ansible-playbook -i inventory.ini playbook.yml --tags=user-setup,install-python
```

NOTE: each role has its own set of tags that will run JUST that role.
