class DevicesController < ApplicationController
  def add
    @device = Device.where(:name => params[:name]).first_or_create
    @device.save
    render :nothing => true, :status => :ok
  end

  def threshold
    @device = Device.where(:name => params[:name]).first_or_create
    @device.set_threshold(params[:value])
    render :nothing => true, :status => :ok
  end

  def trigger_sonar
    @device = Device.where(:name => params[:name]).first_or_create
    @device.process_sonar(params[:value])
    render :nothing => true, :status => :ok
  end

  def trigger_pressure
    @device = Device.where(:name => params[:name]).first_or_create
    @device.process_pressure(params[:value])
    render :nothing => true, :status => :ok
  end
end
