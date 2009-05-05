require 'lib/jsappliance'

use JSAppliance
run lambda { |env| [404, {'Content-Type' => 'text/plain'}, '404: NOT FOUND'] }
