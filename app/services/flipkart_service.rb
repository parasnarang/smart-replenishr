require 'rest-client'
require 'watir-webdriver'
class FlipkartService
  def initialize(user_id = nil)
    print "\n### Initializing Flipkart Service ###\n"
    @user = User.find_by_id(user_id) || User.last
  end

  def add_to_kart(listing_id)
    print "\n### Initializing Add to Kart ###\n"
    populate_user_session
    print "\n### User Session Populated Successfully ###\n"
    url = FlipkartUrl.where(:name => 'add_to_kart').last.url
    # headers = {}
    # params = {}
    response = RestClient.post(url, params, headers)
    print "\n### Added to Cart Successfully ###\n"
    get_added_to_kart(JSON.parse(response))
  end

  def fetch_listing_id(flipkart_url)
    params_hash = Rack::Utils.parse_query URI(flipkart_url).query
    pid = params_hash['pid']
    url = FlipkartUrl.where(:name => 'product_info').last.url + pid.to_s
    response = RestClient.get(url)
    "\n### Fetched Listing Id Successfully ###\n"
    get_listing_id(JSON.parse(response))
  end

  def attempt_cod_checkout
    b = Watir::Browser.new
    b.goto 'https://flipkart.com/account/login'
    b.text_field(:placeholder => 'Enter email/mobile').set(User.last.email)
    b.text_field(:placeholder => 'Enter password').set(User.last.password)
    b.button(:value => 'LOGIN').click
    sleep 1
    b.link(:href => '/viewcart').click
    sleep 1
    b.button(:class => 'place-order-button').click
    sleep 1
    b.p(:class => 'select_btn btn btn-white').click
    sleep 1
    b.link(:class => 'btn btn-orange btn-large btn-continue no-underline').click
    sleep 2
    b.link(:text => 'COD').click
  end

  def clear_cart
    b = Watir::Browser.new
    b.goto 'https://flipkart.com/account/login'
    b.text_field(:placeholder => 'Enter email/mobile').set(User.last.email)
    b.text_field(:placeholder => 'Enter password').set(User.last.password)
    b.button(:value => 'LOGIN').click
    sleep 1
    b.link(:href => '/viewcart').click
    sleep 1
    b.link(:class => 'cart-remove-item').click
  end

  private

  def populate_user_session
    print "\n### Populating User Session ###\n"
    # return true if @user.session
    url = FlipkartUrl.where(:name => 'login').last.url
    params = {:email => @user.try(:email), :password => @user.try(:password)}
    response = RestClient.post(url, params)
    @user.session = get_session(JSON.parse(response))
    @user.save
  end
end