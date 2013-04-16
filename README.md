Chocolatey Devbox Package Repository
====================================

Packages in this repository are public tools, well known to everybody.
We are using these packages for internal purposes in FirstBeatMedia
Devbox development environment.

After researching other package managers like [Npackd][npackd], CoApp or
0install, we decided to use [Chocolatey][choco] as an application
manager for Windows.

## Install Chocolatey package manager

Chocolatey is installed with a simple copy-paste procedure from their
home page. It's installed in `C:\Chocolatey` directory, by default. The
reasoning for that is [explained here][dir], but just remember that the
folder name must not contain spaces.

I decided to use more appropriate subdirectory - I want it to be
installed in `C:\Tools\Choco` and later we will install all the Linux-
like applications in sub-folders under `C:\Tools`.

To force that installation directory, you must set a environment
variable `ChocolateyInstall`, so this is our complete copy-paste
installation sequence:

    :: Set user's permanent environment variables
    set ChocolateyInstall="%SystemDrive%\Tools\Choco"
    setx ChocolateyInstall "%ChocolateyInstall%"

    :: Create that directory
    mkdir "%ChocolateyInstall%"

    :: Install Chocolatey
    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ChocolateyInstall%\bin

Note that modifying environment variables can take a while, so please be
patient. Chocolatey should automatically and permanently set
`%ChocolateyInstall%` environment variable.

[dir]: https://github.com/chocolatey/chocolatey/wiki/Installation

## Basic package manipulation

Command examples are shown for package named __Devbox-Vagrant__.

##### Installing packages

    cinst Devbox-Vagrant

##### Search for a package

    cver Devbox-Vagrant

##### Uninstall a package

    cuninst Devbox-Vagrant

##### List installed packages

    cver all -localonly

or even shorter:

    cver all -lo

## Complete Devbox install

    :: We assume that Choco is already installed
    cinst Devbox-Common.extension
    cinst Devbox-Common
    cinst Devbox-VirtualBox
    cinst Devbox-Vagrant
    :: Now exit and re-enter command shell 

## Conclusion

Chicolatey could become very usable package manager for Windows.

[choco]: http://chocolatey.org/
[npackd]: https://code.google.com/p/windows-package-manager/

