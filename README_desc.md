# DESCRIPTION:

Manages installations of the NetApp Docker Volume Plug-in (nDVP) including the creation of configuration files, plug-in installation and dependencies.

For full details on the NetApp Docker Volume Plugin visit the [official documentation](http://netappdvp.readthedocs.io/en/latest/index.html)

# REQUIREMENTS:

nDVP is supported on the following operating systems:

- Debian
- Ubuntu, 14.04+ if not using iSCSI multipathing, 15.10+ with iSCSI multipathing.
- CentOS, 7.0+
- RHEL, 7.0+

Verify your storage system meets the minimum requirements:
- ONTAP: 8.3 or greater
- SolidFire: ElementOS 7 or greater
- E-Series: Santricity
