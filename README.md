Crop Image HQ
==============

This is a simple MacOSX Automator Action for cropping image in high quality,  the idea is to replace  the builtin "crop image" action which doesn't let select image quality.
It only generates jpg files.  It was created in Objective-C.


Installations
=============

1. Download  Crop Image HQ.action
2. open Automator
3. in the menu File > import actions and select the file.


Usage
=====

The action will be under the Photos category as "Crop image HQ".  I use it as a service for quick image edition. 

Inputs:

1. width and height inputs.
2. 4 scale modes:
 2.1. No scale: it crops the center rect with the desired dimension, no scaling.

 2.2. scale to width:  it scales the image to the width and then crops.
 
 2.3. scale to height: it scales the image to the height and then crops.
 
 2.4. scale to biggest side:  it scales the image so it occupies the biggest side of the desired dimension.
 
    
    
  if the specified width or height is longer than the actual image size, it will leave the side as it is , no black or extra region is added.



Thanks to
=========
The icon is taken from the imageoptim app,  this is a kind of tribute for a great and useful app https://imageoptim.com/.

LM.



