# Booting Linux through USB on the i.MX6 Series   
====
  
  
## Get imx_usb_loader sources
----
We will use git to fetch imx_usb_loader sources:
```
$ git clone git://github.com/boundarydevices/imx_usb_loader.git
```

## Compile imx_usb_loader
----
Assuming your Linux development environment has the necessary libusb-1.0 headers and libraries, you can simply build by doing:
```
$ cd imx_usb_loader
$ make
```
This should compile an imx_usb tool in the current folder.
