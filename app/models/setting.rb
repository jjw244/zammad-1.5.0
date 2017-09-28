# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Setting < ApplicationModel
  store         :options
  store         :state_current
  store         :state_initial
  store         :preferences
  before_create :state_check, :set_initial, :check_broadcast
  before_update :state_check, :check_broadcast
  after_create  :reset_cache
  after_update  :reset_cache
  after_destroy :reset_cache

  attr_accessor :state

  @@current        = {} # rubocop:disable Style/ClassVars
  @@change_id      = nil # rubocop:disable Style/ClassVars
  @@lookup_at      = nil # rubocop:disable Style/ClassVars
  @@lookup_timeout = if ENV['ZAMMAD_SETTING_TTL'] # rubocop:disable Style/ClassVars
                       ENV['ZAMMAD_SETTING_TTL'].to_i.seconds
                     elsif Rails.env.production?
                       2.minutes
                     else
                       15.seconds
                     end

=begin

set config setting

  Setting.set('some_config_name', some_value)

=end

  def self.set(name, value)
    setting = Setting.find_by(name: name)
    if !setting
      raise "Can't find config setting '#{name}'"
    end
    setting.state_current = { value: value }
    setting.save
    logger.info "Setting.set(#{name}, #{value.inspect})"
  end

=begin

get config setting

  value = Setting.get('some_config_name')

=end

  def self.get(name)
    load
    @@current[:settings_config][name]
  end

=begin

reset config setting to default

  Setting.reset('some_config_name')

=end

  def self.reset(name)
    setting = Setting.find_by(name: name)
    if !setting
      raise "Can't find config setting '#{name}'"
    end
    setting.state_current = setting.state_initial
    setting.save
    logger.info "Setting.reset(#{name}, #{setting.state_current.inspect})"
    load
    @@current[:settings_config][name]
  end

=begin

reload config settings

  Setting.reload

=end

  def self.reload
    load(true)
  end

  private

  # load values and cache them
  def self.load(force = false)

    # check if config is already generated
    if !force && @@current[:settings_config]
      return false if cache_valid?
    end

    # read all config settings
    config = {}
    Setting.select('name, state_current').order(:id).each { |setting|
      config[setting.name] = setting.state_current[:value]
    }

    # config lookups
    config.each { |key, value|
      next if value.class.to_s != 'String'

      config[key].gsub!(/\#\{config\.(.+?)\}/) {
        config[$1].to_s
      }
    }

    # store for class requests
    cache(config)
    true
  end
  private_class_method :load

  # set initial value in state_initial
  def set_initial
    self.state_initial = state_current
  end

  # set new cache
  def self.cache(config)
    @@change_id = Cache.get('Setting::ChangeId') # rubocop:disable Style/ClassVars
    @@current[:settings_config] = config
    logger.debug "Setting.cache: set cache, #{@@change_id}"
    @@lookup_at = Time.zone.now # rubocop:disable Style/ClassVars
  end
  private_class_method :cache

  # reset cache
  def reset_cache
    @@change_id = rand(999_999_999).to_s # rubocop:disable Style/ClassVars
    logger.debug "Setting.reset_cache: set new cache, #{@@change_id}"

    Cache.write('Setting::ChangeId', @@change_id, { expires_in: 24.hours })
    @@current[:settings_config] = nil
  end

  # check if cache is still valid
  def self.cache_valid?
    if @@lookup_at && @@lookup_at > Time.zone.now - @@lookup_timeout
      #logger.debug 'Setting.cache_valid?: cache_id has beed set within last 2 minutes'
      return true
    end
    change_id = Cache.get('Setting::ChangeId')
    if change_id == @@change_id
      @@lookup_at = Time.zone.now # rubocop:disable Style/ClassVars
      logger.debug "Setting.cache_valid?: cache still valid, #{@@change_id}/#{change_id}"
      return true
    end
    logger.debug "Setting.cache_valid?: cache has changed, #{@@change_id}/#{change_id}"
    false
  end
  private_class_method :cache_valid?

  # convert state into hash to be able to store it as store
  def state_check
    return if !state
    return if state && state.respond_to?('has_key?') && state.key?(:value)
    self.state_current = { value: state }
  end

  # notify clients about public config changes
  def check_broadcast
    return if frontend != true
    value = state_current
    if state_current.key?(:value)
      value = state_current[:value]
    end
    Sessions.broadcast(
      {
        event: 'config_update',
        data: { name: name, value: value }
      },
      'public'
    )
  end
end