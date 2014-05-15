=begin
/*

The MIT License (MIT)

Copyright (c) 2014 Zhussupov Zhassulan zhzhussupovkz@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
=end

require "net/http"
require "net/https"
require "openssl"
require "json"

#GroovesharkApi - simple class for working with Grooveshark Public API
class GroovesharkApi

  def initialize key, secret
    @key, @secret = key, secret
    @api_url = 'https://api.grooveshark.com/ws3.php'
    @session_id = nil
  end

  #create hash
  def generate_hash key, message
    OpenSSL::HMAC.hexdigest('md5', key, message)
  end

  #send request
  def send_request method, params
    header = { 'wsKey' => @key, 'sessionID' => @session_id }
    params = { 'method' => method, 'parameters' => params, 'header' => header }
    post_data = params.to_json
    sig = generate_hash @key, post_data
    url = @api_url + "?sig=#{sig}"
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = params
    res = http.request(req)
    if res.code == "200"
      data = res.body
      result = JSON.parse(data)
    else
      puts "Invalid getting data from server"
      exit
    end
  end
end
