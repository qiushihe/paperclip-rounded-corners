module Paperclip
  class RoundCorners < Paperclip::Thumbnail

    def self.round(source, destination, topleft, topright, bottomleft, bottomright)
      geometry = Paperclip::Geometry.from_file(source)

      width = geometry.width
      height = geometry.height

      # Need to `-1` becuase when drawing, the coordinates start from 0
      left = width.to_i - 1
      bottom = height.to_i - 1

      transformation = " \\( -size #{width}x#{height} xc:none "
      transformation << "-draw 'fill white circle #{topleft},#{topleft} #{topleft},0' "
      transformation << "-draw 'fill white circle #{left-topright},#{topright} #{left},#{topright}' "
      transformation << "-draw 'fill white circle #{bottomleft},#{bottom-bottomleft} #{bottomleft},#{bottom}' "
      transformation << "-draw 'fill white circle #{left-bottomright},#{bottom-bottomright} #{left},#{bottom-bottomright}' "
      transformation << "-draw 'fill white rectangle #{topleft},0 #{left-topright},#{bottom}' "
      transformation << "-draw 'fill white rectangle 0,#{bottomleft} #{left},#{bottom-bottomright}' "
      transformation << "-channel a -negate +channel -fill white -colorize 100% "
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

      @topleft      = parse_opts 'top_left'
      @topright     = parse_opts 'top_right'
      @bottomleft   = parse_opts 'bottom_left'
      @bottomright  = parse_opts 'bottom_right'

      @process = @topleft || @topright || @bottomleft || @bottomright
    end

    def parse_opts(key)
      opt = @options["border_radius_#{key}".to_sym] || @options["border_radius_#{key.delete('_')}".to_sym] || @options[:border_radius]
      opt.nil? ? nil : opt.to_i
    end

    def make
      @thumbnail = super

      if @process
        destination = Tempfile.new([@basename, @format].compact.join("."))
        destination.binmode

        return Paperclip::RoundCorners.round(@thumbnail, destination, @topleft, @topright, @bottomleft, @bottomright)
      else
        return @thumbnail
      end
    end
  end
end
