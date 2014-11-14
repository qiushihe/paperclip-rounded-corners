module Paperclip
  class RoundCorners < Paperclip::Thumbnail

    def self.round(source, destination, radius)
      geometry = Paperclip::Geometry.from_file(source)

      width = geometry.width
      height = geometry.height

      # Need to `-1` becuase when drawing, the coordinates start from 0
      radius -= 1
      center_x = (width.to_f / 2).ceil - 1
      center_y = (height.to_f / 2).ceil - 1

      # Manuall create a blank, transparent canvas (instead of using -clone) to ensure the canvas
      # always has a proper alpha channel
      transformation = " \\( -size #{width}x#{height} xc:none "

      # Draw a quarter of the mask
      transformation << "-draw 'fill black circle #{radius},#{radius} #{radius},0' "
      transformation << "-draw 'fill black polygon #{radius},0 #{center_x},0 #{center_x},#{center_y} 0,#{center_y} 0,#{radius}' "

      # Flip/flop the 1 quarter to cover the other 3 quarters
      transformation << "\\( +clone -flip \\) -compose Multiply -composite "
      transformation << "\\( +clone -flop \\) -compose Multiply -composite "

      # Invert the mask so the part we want to preserve is transparent
      # Also ensure that there is always a alpha channel present
      transformation << "-channel a -negate +channel "

      # Use `-compose Dst_Out` (instead of `-compose CopyOpacity`) because it does a better job
      # at working both both the alpha channel of the mask as well as alpha channel of the
      # origin image
      transformation << "\\) -compose Dst_Out -composite "

      Paperclip.run('convert', [
        "#{File.expand_path(source.path)}[0]",
        transformation,
        "#{File.expand_path(destination.path)}"
      ].flatten.compact.join(" "))

      destination
    end

    def initialize(file, options = {}, attachment = nil)
      super file, options, attachment

      @options = options
      @border_radius = options[:border_radius]
    end

    def make
      @thumbnail = super

      if @border_radius
        destination = Tempfile.new([@basename, @format].compact.join("."))
        destination.binmode

        return Paperclip::RoundCorners.round(@thumbnail, destination, @border_radius)
      else
        return @thumbnail
      end
    end
  end
end
