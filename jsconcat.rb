require 'jsmin'

class JSConcat
  F = ::File
  
  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"]

    unless path.match(/\.js$/)
      return @app.call(env)
    end

    cmd = path.sub(/^.*\//,'').sub(/\.js$/,'')

    javascripts, domain = cmd.split('+++')
    javascripts = javascripts.split('+')
    
    javascripts.each do |script|
      send_403 if !F.readable?(real_path_for_script(script))
    end
    
    send_403 if env["PATH_INFO"].include?("..")
    
    full_js = javascripts.inject("") do |full,nxt|
      full << File.read(real_path_for_script(nxt))
      full
    end

    if domain
      full_js << check_for_domain(domain)
    end

    tmp_path = "public/#{rand.to_s}.js"
    output_path = "public/#{cmd}.js"
    
#     F.open(tmp_path,'w'){|f|f.puts full_js}
    
#     F.open(tmp_path, "r") do |file|
#       F.open(output_path, "w") { |f| f.puts JSMin.minify(file) }
#     end
#     F.delete(tmp_path)

    F.open(output_path,'w'){|f|f.puts full_js}
    
    [200, {
       "Last-Modified"  => F.mtime(output_path).httpdate,
       "Expires" => Time.at((2**31)-1).httpdate,
       "Content-Type"   => "text/javascript",
       "Content-Length" => F.size(output_path).to_s
     }, F.new(output_path, "r")]

  end

  private
  def real_path_for_script(script)
    "scripts/#{script}.js"
  end

  def send_403
    body = "Forbidden\n"
    size = body.respond_to?(:bytesize) ? body.bytesize : body.size
    return [403, {"Content-Type" => "text/plain","Content-Length" => size.to_s}, [body]]
  end

  def check_for_domain(domain)
    "if(!location.host.match('#{domain}')){alert('JavaScript hotlinked from Chromium 53. Check out our JSAppliance at http://github.com/burke/jsappliance.')};"
  end

end
