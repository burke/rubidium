require 'jsconcat'

use JSConcat
run lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'OK'] }
