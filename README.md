# Install some additional tools for sync'ing the repo.
```
$ mkdir ~/bin (this step may not be needed if the bin folder already exists)
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
``` 

Add the following line to the .bashrc file to ensure that the ~/bin folder is in your PATH variable.
```
$ export PATH=~/bin:$PATH
```

# Clone the ReneSOM Yocto meta-data using repo

Create Build Directory

```
$ mkdir ReneSOM-yocto-bsp
$ cd ReneSOM-yocto-bsp
```

Initialize the repo and sync with our server
```
$ repo init -u ssh://git@bitbucket.logicpd.com:7999/logyo/beacon-manifests.git -b renesas-linux-rocko -m rzg-4.19.y-0.0.1.xml
$ repo sync -j1
```

# Setup Build Target

Return to  ReneSOM-yocto-bsp root directory.

## Do this ONLY ONCE and only the first time:

```
$ (cd sources/meta-rzg2/;./docs/sample/copyscript/copy_proprietary_softwares.sh -f ../renesas-proprietary)
$ TEMPLATECONF=../sources/meta-beacon-rzg/conf source sources/poky/oe-init-build-env rzg2-m-rocko
``` 

After running the above command the current directory will be your build directory.  This directory will be the location to executing the build and the above instruction create new files and/or overwrite old ones.  

 ## Skip this step if the above step was done.

Only After a reboot or in a different shell instance do the following if the above step has already been completed and a rebuild is needed:

```
$ source sources/poky/oe-init-build-env rzg2-m-rocko
```

# Edit Caching to speed building

Using an editor of your choice, edit conf/local.conf in your build directory. These settings will allow you to share downloads between many Yocto builds for different SOMs. Replace <yourdir> with your home directory name.

Locate DL_DIR in the file and edit it to read the following:

```
DL_DIR="/home/<your_dir>/yocto-cache/download"
``` 

Locate or add one addition line just after the previous

```
SSTATE_DIR="/home/<your_dir>/yocto-cache/sstate-cache"
```

## Build

There are a variety of build options built into the images defined by NXP/Freescale build:

 

**core-image-minimal:**  A small image that only allows a device to boot.

**core-image-base:**   A console-only image that fully supports the target device hardware.

**core-image-sato:** An image with Sato, a mobile environment and visual style for mobile devices. The image supports a Sato theme and uses Pimlico applications. It contains a terminal, an editor and a file manager.

**core-image-weston:** An image using the Wayland/Weston compositor for GUI

 **core-image-hmi:** An image with a lot of user interface examples/demos

To kick off build run with the full image. Substitute the name of the build below with one of the options above.

$ bitbake core-image-hmi

# Programming the Bootloader for QSPI on ReneSOM
```
xls2
starting value on device is 0
starting value in RAM is 50000000
```

# Instructions for programming the EMMC using the flashwriter

## Step 1: download files to files to program and run Renesom platform 

AArch64_Flash_writer_SCIF_DUMMY_CERT_E6300400_beacon.mot
beacon-rzg2n-flashbin.srec
core-image-hmi-beacon-rzg2n.wic.bz2

***************************************************************
Prepare the hardware for programming 
## Step 2:  
        2.1  Set S26 to 11110101b (on beta)
        2.2  Power on System (connect 12V power to J53 & press S28 [PWR switch])
        2.3  At the serial terminal (115200,8,N,1) look for the SCIF prompt
```
 SCIF Download mode (w/o verification)
 (C) Renesas Electronics Corp.

-- Load Program to SystemRAM ---------------
please send !

         2.4  Sent download AArch64...._beacon.mot to the board through terminal as ASCII file
```
## Step 3: Read values of PARTITION_CONFIG and BOOT_BUS_CONDITIONS using the 
EM_DECSD command.  
```
> EM_DECSD
[179:179]  PARTITION_CONFIG                           0x00
[177:177]  BOOT_BUS_CONDITIONS                        0x00

where decimal 179 => to hex 0x0b3 for PARTITION_CONFIG
where decimal 177 => to hex 0x0b1 for BOOT_BUS_CONDITIONS
```

## Step 4: Write the values of PARTITION_CONFIG and BOOT_BUS_CONDITIONS using the 
EM_SECSD command.  
The parameter PARTITION_CONFIG must be set to 0x8
and the parameter BOOT_BUS_CONDITIONS must be set to 0xa 
```
>EM_SECSD
  Please Input EXT_CSD Index(H'00 - H'1FF) :0b1
  EXT_CSD[B1] = 0x00
  Please Input Value(H'00 - H'FF) :0a
  EXT_CSD[B1] = 0x0A
>EM_SECSD
  Please Input EXT_CSD Index(H'00 - H'1FF) :0b3
  EXT_CSD[B3] = 0x00
  Please Input Value(H'00 - H'FF) :08
  EXT_CSD[B3] = 0x08
>h
        SPI Flash write command
 XCS            erase program to SPI Flash
 XLS2           write program to SPI Flash
 XLS3           write program to SPI Flash(Binary)

        eMMC write command
 EM_DCID        display register CID
 EM_DCSD        display register CSD
 EM_DECSD       display register EXT_CSD
 EM_SECSD       change register EXT_CSD byte
 EM_W           write program to eMMC
 EM_WB          write program to eMMC (Binary)
 EM_E           erase program to eMMC
 SUP            Scif speed UP (Change to speed up baud rate setting)
 H              help


******************* now the hardware is ready to program *******  
```
## Step 5: It is advised to type SUP (Speed UP) at this point and switch the baud to 921000
```
>SUP
Scif speed UP
Please change to 921.6Kbps baud rate setting of the terminal.

To Program eMMC
>em_w
EM_W Start --------------
---------------------------------------------------------
Please select,eMMC Partition Area.
 0:User Partition Area   : 30535680 KBytes
  eMMC Sector Cnt : H'0 - H'03A3DFFF
 1:Boot Partition 1      : 4096 KBytes
  eMMC Sector Cnt : H'0 - H'00001FFF
 2:Boot Partition 2      : 4096 KBytes
  eMMC Sector Cnt : H'0 - H'00001FFF
---------------------------------------------------------
  Select area(0-2)>1
-- Boot Partition 1 Program -----------------------------
Please Input Start Address in sector :0
Please Input Program Start Address : 50000000
Work RAM(H'50000000-H'50FFFFFF) Clear....
please send ! ('.' & CR stop load)

send the file beacon_flashbin.srec as ASCII file

SAVE -FLASH.......
EM_W Complete!
>
```
## Step 6:  Change terminal back to 115200,8,N,1

## Step 7:  Booting U-Boot from eMMC with kernel and rootfs on SD
To boot from eMMC set S26 to 10110101b

For more information see the RZ/G2 UG table 24.1