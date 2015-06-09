require_relative '../services/flipkart_service'
class Device < ActiveRecord::Base
  belongs_to :user
  has_one :order_configuration
  before_create :assign_user

  def set_threshold(value)
    print "\n### Starting To Set Threshold ###\n"
    value = sanitize_value(value)
    self.order_configuration = OrderConfiguration.new(:user_id => self.user_id) if self.order_configuration.nil?
    self.order_configuration.threshold = value
    self.order_configuration.save
    print "\n### Threshold Is Set Successfully ###\n"
    self.save
  end

  def process_sonar(value)
    return false if self.order_configuration.nil? || self.order_configuration.listing_id.nil?
    print "\n### Starting To Process Sensor Reading ###\n"
    value = sanitize_value(value)
    if self.order_active && self.order_configuration.inventory_replenished?(value)
      print "\n### Inventory Has Been Replenished ###\n"
      self.order_active = false
      self.save
    elsif !self.order_active && self.order_configuration.inventory_exhausted?(value)
      print "\n### Starting Order Placement ###\n"
      flipkart_service = ::FlipkartService.new self.user_id
      flipkart_service.add_to_kart self.order_configuration.listing_id
      print "\n### Order Placed Successfully ###\n"
      self.order_active = true
      self.save
    end
    print "\n### Sensor Reading Processed Successfully ###\n"
  end

  def process_pressure(value)
    self.order_configuration = OrderConfiguration.new(:user_id => self.user_id) if self.order_configuration.nil?
    return false if self.order_configuration.listing_id.nil?
    if self.order_active && self.order_configuration.pressure_increased?(value)
      print "\n### Inventory Has Been Replenished ###\n"
      self.order_active = false
      self.save
    elsif !self.order_active && self.order_configuration.pressure_decreased?(value)
      print "\n### Starting Order Placement ###\n"
      flipkart_service = ::FlipkartService.new self.user_id
      flipkart_service.add_to_kart self.order_configuration.listing_id
      print "\n### Order Placed Successfully ###\n"
      self.order_active = true
      self.save
    end
  end

  private
  def assign_user
    self.order_active = false if self.order_active.nil?
    self.user = User.last if self.user.nil?
  end

  def sanitize_value(value)
    return value.to_f if value.is_a? String
    value
  end
end
