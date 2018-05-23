# Python 2.6 RPM functionality for EL5

This repo contains patches for EL5 RPMs to support the python rpm and yum modules to work with EPEL installed python2.6

## Instructions

### Building

```
ansible-playbook -v -i hosts build.yml
```

This will download the python2.6 RPMs to `./rpm`

### Installing

Install the RPMs from the `./rpm` directory
