# Axiom-Local

This is an update fork of [pry0cc](https://github.com/pry0cc)'s [axiom-local](https://github.com/pry0cc/axiom-local) repository that aims to making it easier to install tools used by [axiom](https://github.com/pry0cc/axiom) on a self-hosted fleet

## Installation

clone this repository on a machine and distribute it to the fleet machines

```bash
git clone #link
```
## Usage

```bash
./axiom-local-install.sh -u <user password> -r <root password>
```
## Important notes

* This is tested on 64-bit latest Ubuntu server/Desktop
* This is compatible with both 32 and 64 bit versions of Debian buster and up
* 32 bit installation will omit massdns installation since it relies on features not supported for 32-bit C compilers
* make sure any personal data is extracted from fleet machines to avoid any data loss
* it is preferable to create a separate new user for this installation
* make sure fleet machines aren't directly exposed to the internet to avoid any security risks
* The developers of this project are not responsible for any damage done. 

## To do
* add support for more distributions and architectures
* make a deployment script that distributes and installs axiom-local on all fleet machines simultaneously 



## License

[MIT](https://choosealicense.com/licenses/mit/)