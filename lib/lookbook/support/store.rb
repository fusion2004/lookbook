module Lookbook
  class Store < ActiveSupport::OrderedOptions
    def initialize(initial_data = nil, opts = {})
      @recursive = opts[:recursive] || false
      super()
      initial_data.to_h.each { |k, v| self[k] = v }
    end

    def []=(key, value)
      super(key, normalize_value(value))
    end

    def fetch(name, *args)
      super(name.to_sym, *args)
    end

    def method_missing(name, *args)
      if name.to_s.end_with?("=")
        args[0] = normalize_value(args[0])
      end
      super(name, *args)
    end

    def respond_to_missing?(name, include_private)
      true
    end

    def to_h
      transform_values do |value|
        value.is_a?(Store) ? value.to_h : value
      end
    end

    def to_hash
      to_h
    end

    protected

    def normalize_value(value)
      (@recursive && !value.is_a?(Store) && value.is_a?(Hash)) ? Store.new(value, recursive: @recursive) : value
    end
  end
end
