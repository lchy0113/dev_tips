# Booting Linux through USB on the i.MX6 Series   
====
  
  
## Get imx_usb_loader sources
----
We will use git to fetch imx_usb_loader sources:
```bash
$ git clone git://github.com/boundarydevices/imx_usb_loader.git
```

## Compile imx_usb_loader
----
Assuming your Linux development environment has the necessary libusb-1.0 headers and libraries, you can simply build by doing:
```bash
$ cd imx_usb_loader
$ make
```
This should compile an imx_usb tool in the current folder.

## Prepare your payload and configuration
----
First, copy all the necessary items(u-boot.imx, uImage, dtb file, ramdisk image) to the imx_usb_loader. 
Now we need to explain to imx_usb what we want to download to the i.MX romcode through USB. 
Add the following lines in the end of the mx6_usb_work.conf:

```
...
u-boot.imx:dcd,plug
uImage:load 0x12000000
ramdisk-apsi.gz:load 0x12C00000
imx6dl-sabresd.dtb:load 0x18000000
u-boot.imx:clear_dcd,jump header
```

The first line with dcd,plug uses u-boot header to configure the DDR3 memory, allowing us to download contents to the iMX6 series board SD memory.
This is exactly what the three subsequent lines with load directives do. 
The last line re-ueses u-boot one more time to find out the address where to jump(jump header directive), but not touching the DDR configuration any more thanks to the clear_dcd directive.
Look at the comments in mx6_usb_work.conf for (a bit) more details on the various directives available. 

Also, note that all the absolute addresses mentioned above are what u-boot needed at the time of writing. 
Hopefully this should be fairly stable. 
