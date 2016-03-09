CAPPING SPENDING ON A GIVEN DEVICE
Using a Fibaro Wall Plug, the exact amount of power being used by a device can be monitored.  Using a virtual device and Lua on a Home Center 2, we are able to communicate with the energy panel and calculate the exact monetary cost this device has incurred today.  Using this, we can automatically turn off the device if we have spent too much on it today.
HOW TO DO IT
WHAT YOU NEED

1 x Fibaro Wall Plug

1 x Fibaro Home Center 2

You will need to download the Power Consumption Virtual Device.

THE VIRTUAL DEVICE

Download the virtual device and import it:

PowerConsumptionVirtualDevice

Unzip the Virtual Device you have downloaded and locate the .vfib file inside it.
Log into your Home Center 2 in your browser.
Click Devices.
Click Add or remove device.
Scroll down to the third section and click Browse under Import virtual device.
Select the .vfib file you unzipped from the download.
Click the Import virtual device button.
Give you new virtual device a meaningful name and room.
Click the Advanced tab.
Scroll down to the Main loop at the bottom of the page.
Scroll to line 24 and change 137 to the device id of your wall plug.
Scroll to line 25 and change 0.16 to the cost of your energy per kWh.
Scroll to line 26 and change 2.00 to the maximum cost allowed for the device.
Click Save.
 SOME NOTES AND FURTHER IDEAS

This virtual device will turn off a wall plug automatically.  It will not turn it on again automatically.

The virtual device measures energy used from midnight each day, not within a 24 hour period.  If the wall plug turns off due to over use, it will reset at midnight.