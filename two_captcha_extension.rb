module TwoCaptchaExtension
  API_KEY = '4e2dd9ec5dd557108068e1a3a60e90a5'
  REQUEST_URL = 'http://2captcha.com/in.php'
  RESPONSE_URL = 'http://2captcha.com/res.php'
  CAPTCHA_V2_METHOD = 'userrecaptcha'
  DEFAULT_RETRIES = 20

  # TODO: Implement rest of error codes
  def self.validate_code(code,value)
    case code
    when "OK"
      return true
    else
      return false
    end
  end

  def self.retry_in(seconds)
    time = Time.now
    puts "-> Esperando #{seconds}"
    loop_value = seconds
    until Time.now > time + seconds.seconds
      sleep 1
      loop_value -= 1
    end
    puts "-> Se terminó la espera"
  end

  def request_simple_captcha(captcha_path)
    two_captcha_request = HTTParty.post(TwoCaptcha::REQUEST_URL,
      body: TwoCaptcha.request_simple_captcha_params(captcha_path)
    ).parsed_response
    captcha_request_code,captcha_request_key = two_captcha_request.split('|')
    if !TwoCaptcha::validate_code(captcha_request_code,captcha_request_key)
      raise "-> Error de 2captcha request: #{two_captcha_request}.  Apikey: #{TwoCaptcha::API_KEY}"
    end
    return captcha_request_key
  ensure
    File.delete(captcha_path) if File.exist?(captcha_path)
  end

  def request_base64_captcha(base64)
    two_captcha_request = HTTParty.post(TwoCaptcha::REQUEST_URL,
      body: TwoCaptcha.request_base64_captcha_params(base64)
    ).parsed_response

    captcha_request_code = two_captcha_request.split('|')[0]
    captcha_request_key = two_captcha_request.split('|')[1]

    if !TwoCaptcha::validate_code(captcha_request_code,captcha_request_key)
      raise "-> Error de 2captcha request: #{two_captcha_request}.  Apikey: #{TwoCaptcha::API_KEY}"
    end

    return captcha_request_key
  end

  def request_2captcha(captcha_site_key)
    two_captcha_request = HTTParty.get(TwoCaptcha::REQUEST_URL,
      query: TwoCaptcha.request_captcha_v2_params(captcha_site_key, @target_url)
    ).parsed_response

    captcha_request_code = two_captcha_request.split('|')[0]
    captcha_request_key = two_captcha_request.split('|')[1]

    if !TwoCaptcha::validate_code(captcha_request_code,captcha_request_key)
      raise "-> Error de 2captcha request: #{two_captcha_request}.  Apikey: #{TwoCaptcha::API_KEY}"
    end
    return captcha_request_key
  end

  def solve_2captcha(captcha_request_key)
    @captcha_response_state = "CAPCHA_NOT_READY"
    puts "Trying to solve captcha with request key: #{captcha_request_key}"
    while @captcha_response_state == "CAPCHA_NOT_READY" and @captcha_retries > 0
      puts "Retries left: #{@captcha_retries}"
      TwoCaptcha.retry_in(rand(5..10))
      two_captcha_response = HTTParty.get(TwoCaptcha::RESPONSE_URL, {
        query: TwoCaptcha.response_params(captcha_request_key)
      }).parsed_response
      puts "Response from 2captcha: #{two_captcha_response}"
      @captcha_retries -= 1
      @captcha_response_state = two_captcha_response
    end
    return two_captcha_response
  end

  def self.request_simple_captcha_params(captcha_path)
    {
      key: TwoCaptcha::API_KEY,
      file: File.open(captcha_path)
    }
  end

  def self.request_base64_captcha_params(base64)
    {
      key: TwoCaptcha::API_KEY,
      method: 'base64',
      body: base64
    }
  end

  def self.request_captcha_v2_params(captcha_site_key,url)
    {
      key: TwoCaptcha::API_KEY,
      method: TwoCaptcha::CAPTCHA_V2_METHOD,
      key: TwoCaptcha::API_KEY,
      googlekey: captcha_site_key,
      pageurl: url,
      here: 'now'
    }
  end

  def self.response_params(captcha_request_key)
    {
      key: TwoCaptcha::API_KEY,
      action: 'get',
      id: captcha_request_key
    }
  end

end
