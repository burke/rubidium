require 'jsconcat'

use JSConcat
run lambda { |env| [404, {'Content-Type' => 'text/plain'}, '404: NOT FOUND'] }
