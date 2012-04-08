require 'gnuplot'

module CollectdPlot
  module Plot

    def self.rand_filename()
      "/tmp/#{(0...10).map{65.+(rand(25)).chr}.join}.png"
    end


    def self.render(data, props)
      cmd = ''
      png_file = rand_filename
      Gnuplot::Plot.new(cmd) do |plot|
        plot.terminal 'png'
        plot.output png_file

        #plot.xrange '[0:10]'
        plot.title "#{props.metric} for #{props.host}"
        plot.grid
        plot.xrange "[#{props.start}:#{props.finish}]"
        x = (props.start.to_i..props.finish.to_i).to_a

        data.each_pair do |h, d|
          plot.data << Gnuplot::DataSet.new( [x, d] ) do |ds|
            ds.linewidth = 4
            ds.title = props.host
          end
        end
      end
      cmd << "\n\n\n"

      script = rand_filename
      File.open(script, 'w') { |f| f.write cmd }
      puts `gnuplot #{script}`
      puts `cat #{script} > gnuplot`
      f = File.open(png_file, "rb")
      png = f.read
      f.close
      File.delete png_file
      File.delete script
      png
    end


    def self.example
      cmd = ''
      png_file = rand_filename
      Gnuplot::Plot.new(cmd) do |plot|
        plot.terminal "png"
        plot.output png_file

        plot.xrange "[0:10]"
        plot.title  "Sin Wave Example"
        plot.xlabel "x"
        plot.ylabel "y"
        plot.grid

        x = (0..50).collect { |v| v.to_f }
        y = x.collect { |v| v ** 2 }
        z = x.collect { |v| v * Math.sin(v) }

        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "linespoints"
          ds.title = "quadratic"
          ds.linewidth = 4
        end 
        plot.data << Gnuplot::DataSet.new( [x, z] ) do |ds|
          ds.with = "linespoints"
          ds.title = "linear"
          ds.linewidth = 4
        end 
#      plot.data << Gnuplot::DataSet.new( "sin(x)" ) do |ds|
#        ds.with = "lines"
#      end
      end
      cmd << "\n\n\n"

      script = rand_filename
      File.open(script, 'w') { |f| f.write cmd }
      puts `gnuplot #{script}`
      puts `cat #{script} > gnuplot`
      f = File.open(png_file, "rb")
      png = f.read
      f.close
      File.delete png_file
      File.delete script
      png
    end
  end
end
