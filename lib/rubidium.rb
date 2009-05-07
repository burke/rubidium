class Rubidium
  F = ::File # I still don't understand why Rack overrides File.
  
  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"]

    # We obviously only deal with javascript files here.
    return @app.call(env) unless path.match(/\.js$/)

    begin
      javascripts, domains = parse_path(path)
    rescue SecurityError
      return error_403
    end

    full_javascript = build_javascript(javascripts, domains)

    path = generate_cache_file(path, full_javascript)

    # We're done! Send off the file. This is probably the last time
    # rack will ever handle this particular file.
    return send_file(path)

  end

  private #####################################################################

  def parse_path(path)

    # Stop any errant jackasses that manage to figure out the password and
    # figure they'll serve up /etc/passwd or something...
    raise SecurityError if path.include?("..")

    # Our "command" string is everything between the final '/' and the '.js'.
    cmd = path.sub(/^.*\//,'').sub(/\.js$/,'')

    # command is of the form "script1+script2+++domain1+domain2"
    # split into [script1,script2] and [domain1,domain2].
    javascripts, domains = cmd.split('+++').map do |list|
      list.split('+')
    end

    (domains||=[]) << "localhost" # Ensure that domains contains "localhost".
    
    # Make sure that each source script actually exists.
    javascripts.each do |script|
      raise SecurityError if !F.readable?(real_path_for_script(script))
    end

    return [javascripts, domains]
    
  end

  def build_javascript(javascripts, domains)
    # concatenate all the javascript files.
    full_js = javascripts.inject("") do |full,nxt|
      full << File.read(real_path_for_script(nxt))
      full
    end

    # Add domain restriction, if requested.
    if domains
      full_js << check_for_domain(domains)
    end
    full_js
  end
  
  # Use YUI compressor to minify generated javascript.
  # We have to use a temporary file here since we're shelling out to a jar.
  # It takes AGES to run, but files are cached semi-permanently, so it's not
  # really a big deal.
  def generate_cache_file(path, javascript)
    command = path.sub(/^.*\//,'').sub(/\.js$/,'')

    tmp_path = "public/#{rand.to_s}.js"
    output_path = "public/#{command}.js"

    F.open(tmp_path,'w') do |file|
      file.puts javascript
    end

    `java -jar yuicompressor-2.4.2.jar #{tmp_path} -o #{output_path} --line-break 0`

    F.delete(tmp_path)

    return output_path
  end

  # Build up a response suitable for rack to process
  def send_file(path)

    [200, {
       "Last-Modified"  => F.mtime(path).httpdate,
       "Expires" => Time.at((2**31)-1).httpdate,
       "Content-Type"   => "text/javascript",
       "Content-Length" => F.size(path).to_s
     }, F.new(path, "r")]

  end
  
  # the actual filesystem path for a given script name
  def real_path_for_script(script)
    "scripts/#{script}.js"
  end

  # The user tried to access something they don't have permission to.
  # Apparently they got the hash auth right, if they even made it to rack,
  # but there's not much we can do. 
  def error_403
    body = "Forbidden\n"
    size = body.respond_to?(:bytesize) ? body.bytesize : body.size
    return [403, {"Content-Type" => "text/plain","Content-Length" => size.to_s}, [body]]
  end

  # Return a chunk of javascript to check where this javascript is being loaded to.
  # If it's not one of the domains specified, pop up an alert.
  # People freeloading on this could potentially suck, a lot.
  def check_for_domain(domains=[])
    domains << 'localhost' # Always allow running on localhost.

    # Build a string to check if location.host matches any of the provided hostnames.
    domains.map! do |domain| 
      "location.host.match('#{domain}')"
    end
    negated_cond = domains.join('||')
    cond = "!(#{negated_cond})"
    
    "if(#{cond}){alert('JavaScript hotlinked from Chromium 53. Check out Rubidium, our JavaScript appliance, at http://github.com/burke/rubidium.')};"
  end

end
