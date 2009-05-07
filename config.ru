require 'lib/rubidium'

use Rubidium
run lambda { |env| [404, {'Content-Type' => 'text/plain'}, '404: NOT FOUND'] }
