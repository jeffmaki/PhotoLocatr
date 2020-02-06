PhotoLocatr
===========

PhotoLocatr records your path as you take photos, and after you upload them to Flickr, it will geotag them with the location at which they were taken.

## Update as of 2/6/2020
Obviously this code is very old at this point--APIs have changed and computer security has evolved--be sure to verify things if you use this codebase! 

## Theory of Operation
The app records periodic GPS coordinates (along with a timestamp) that a photographer takes, and saves them to disk/memory. 
Once back at home, the app scans Flickr for photos that have "capture" timestamps that fall between any two points that are saved in memory. If it finds a point earlier/later, it interpolates the distance between the two points linearly, placing the photographer in 2D space at that given time. The photo is then updated on Flickr with the coordinates of that location. 

This is all to say, the more often points are recorded, the more accurate of a location you'll have later on--at the expense of battery/memory of course. This also assumes synchronization between the clocks on the phone (which is usually set via LTE/GPS) and the camera. So be sure to set your camera clock to match your phone! 
