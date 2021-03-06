Paperclip Rounded Corners
=============

This processor generates rounded corners.


Usage
=============
Just tell your style how to treat the borders (the syntax is based on CSS3), and add 
the 'round_corners' processor, either to the attached file or to specific styles. 
You probably want to make sure the output format can handle transparency.

    class Image < ActiveRecord::Base
      has_attachached_file :avatar, :processors => [:round_corners], :styles => {
        :style1 => {:border_radius => 10, :format => :png, :geometry => '200x200'}
      }

The radius values should be in pixels and will be applied _after_ the geometry transformation.

Required: paperclip modification
=============
In order for the plugin to work, also apply the patch proposed here:
http://stackoverflow.com/questions/3382443/paperclip-error-no-decode-delegate-for-this-image-format


Limitations
=============
* No elliptical borders
* No shorthand syntax parsing (:border_radius => '10 5 10 0') as defined in CSS3
* Only pixel values allowed as input
