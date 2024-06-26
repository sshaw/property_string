# frozen_string_literal: true

class PropertyString
  VERSION = "0.0.2"
  KEY_NOT_FOUND = "__#{object_id}-not-found-placeholder-#{object_id}__"

  class MethodNotAllowed < StandardError
    def initialize(object, method)
      target = object.is_a?(Class) ? "#{object}.#{method}" : "#{object.class}##{method}"
      super "Access to #{target} is not allowed"
    end
  end

  def initialize(object, options = nil)
    @object = object

    @options = (options || {}).dup
    @options[:raise_if_method_missing] = true unless @options.include?(:raise_if_method_missing)
    @options[:whitelist] = @options[:whitelist] || {}
  end

  def [](property)
    value = fetch_property_chain(property)
    value = nil if value == KEY_NOT_FOUND
    value
  end

  def fetch(property, *default, &block)
    fetch_default = -> do
      raise KeyError, "property #{property} not found" unless default.any? || block_given?
      block_given? ? block[property] : default[0]
    end

    value = nil

    begin
      value = fetch_property_chain(property)
      return value unless value == KEY_NOT_FOUND
    rescue NoMethodError => e
      warn e if ENV["DEBUG"]
      return fetch_default[]
    end

    fetch_default[]
  end

  def inspect
    @object.inspect
  end

  private

  def fetch_property_chain(property)
    value = @object

    chain = String(property).split(".")
    chain.each do |prop|
      value = prop.match?(/\A\d+\z/) ? find_index_value(value, prop) : find_non_index_value(value, prop)
      break if value.nil? || value == KEY_NOT_FOUND
    end

    value
  end

  def find_non_index_value(value, prop)
    if value.is_a?(Hash)
      value = find_hash_value(value, prop)
      return value == KEY_NOT_FOUND ? nil : value
    end

    raise_if_method_not_allowed(value, prop)

    if @options[:raise_if_method_missing] || value.respond_to?(prop)
      value.public_send(prop)
    end
  end

  def find_index_value(value, prop)
    unless value.respond_to?(:[])
      raise TypeError, "Cannot access index #{prop} on #{value.class}"
    end

    if !value.is_a?(Hash)
      int_prop = prop.to_i
      av = value[int_prop]
      # Check if index even exists to determine if this should be a KEY_NOT_FOUND
      return av if !av.nil? || !value.respond_to?(:size) || int_prop < value.size
    else
      hv = find_hash_value(value, prop)
      return hv if hv != KEY_NOT_FOUND

      int_index = prop.to_i
      return value[int_index] if value.include?(int_index)
    end

    KEY_NOT_FOUND
  end

  def find_hash_value(hash, prop)
    return hash[prop] if hash.include?(prop)

    sym_prop = prop.to_sym
    return hash[sym_prop] if hash.include?(sym_prop)

    KEY_NOT_FOUND
  end

  def raise_if_method_not_allowed(value, prop)
    klass = value.is_a?(Class) ? value : value.class
    # Make sure we do not raise this if the object does not respond_to? prop
    # TODO: class hierarchy
    if @options[:whitelist].include?(klass) && !@options[:whitelist][klass].include?(prop) && value.respond_to?(prop)
      raise MethodNotAllowed.new(value, prop)
    end
  end
end
