# Axiom-Local

This is an update fork of [pry0cc](https://github.com/pry0cc)'s [axiom-local](https://github.com/pry0cc/axiom-local) repository that aims to making it easier to install tools used by [axiom](https://github.com/pry0cc/axiom) on a self-hosted fleet

## Installation

clone this repository on a machine and distribute it to the fleet machines

```bash
git clone https://github.com/asempire/axiom-local.git
```
## Usage

```bash
./axiom-local-install.sh -u <user password> -r <root password>
```
## Deployment
the ```deploy.sh``` is an automated solution to deploy and install the tools on all available hosts simultaneously

* first create a CSV of all hosts file in the following format:
    ```Host,username,IP,user pass,root pass```
* Second run:
```./deploy.sh -f <csv file>```
* Third wait for the installation to finish and keep ssh_config in the same directory untill it does
* You can check when installation finishes by using progress.sh
```./progress.sh -f <csv file>```


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

## Latest Bug fixes
* Moved all tools to a directory called `/home/op` to provide compatability with axiom interact scripts
* fixed a bug where installing tools with apt on debian hung
* improved the deployment script so that running it multiple times produce less errors
* added rsync to debian installs

## License

[MIT](https://choosealicense.com/licenses/mit/)
