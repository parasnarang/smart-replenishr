class OrderConfiguration < ActiveRecord::Base
  belongs_to :user
  belongs_to :device
  before_create :set_default_values
  before_save :fetch_listing_id

  SENSOR_READINGS_THRESHOLD_COUNT = 5

  def inventory_exhausted?(value)
    "\n### Checking Exhaustion ###\n"
    if value > self.threshold
      "\n### Might Be Exhausted ###\n"
      self.times_called += 1
      if self.times_called >= SENSOR_READINGS_THRESHOLD_COUNT
        self.times_called = 0
        self.save
        return true
      end
    else
      self.times_called = 0
    end
    self.save
    false
  end

  def inventory_replenished?(value)
    "\n### Checking Replenishment ###\n"
    if value < self.threshold
      "\n### Can be Replenished ###\n"
      self.times_called += 1
      if self.times_called >= SENSOR_READINGS_THRESHOLD_COUNT
        self.times_called = 0
        self.save
        return true
      end
    else
      self.times_called = 0
    end
    self.save
    false
  end

  def pressure_increased?(value)
    "\n### Checking Replenishment ###\n"
    unless value
      "\n### Can be Replenished ###\n"
      self.times_called += 1
      if self.times_called >= SENSOR_READINGS_THRESHOLD_COUNT
        self.times_called = 0
        self.save
        return true
      end
    else
      self.times_called = 0
    end
    self.save
    false
  end

  def pressure_decreased?(value)
    "\n### Checking Exhaustion ###\n"
    if value
      "\n### Might Be Exhausted ###\n"
      self.times_called += 1
      if self.times_called >= SENSOR_READINGS_THRESHOLD_COUNT
        self.times_called = 0
        self.save
        return true
      end
    else
      self.times_called = 0
    end
    self.save
    false
  end

  private
  def set_default_values
    self.times_called = 0 if self.times_called.nil?
  end

  def fetch_listing_id
    print "\n### Checking for Listing Id ###\n"
    return if self.url.nil? || self.user_id.nil?
    print "\n### Fetching Listing ID ###\n"
    flipkart_service = FlipkartService.new(self.user_id)
    listing_id = flipkart_service.fetch_listing_id(self.url)
    self.listing_id = listing_id
  end
end
