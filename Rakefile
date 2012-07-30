require 'rubygems'
require 'rspec/core/rake_task'
require 'RRD'

# convert fixture RRD files to current CPU arch, if they are not already.
task :convert_fixture_rrds do
  begin
    RRD.fetch('./spec/fixtures/rrd/host_a/load/load.rrd', 'AVERAGE')
  rescue RRDError => e
    if e.message =~ /This RRD was created on another architecture/
      puts "converting RRD files to current architecture"
      system('for f in `find spec -name "*.rrd" -print`; do rrdtool dump $f > /tmp/rrd_conv.xml; rrdrestore /tmp/rrd_conv.xml $f;done')
    end
  end
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--color'
end
