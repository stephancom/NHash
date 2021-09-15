# frozen_string_literal: true

# require 'forwardable'
require_relative 'NHash/version'

class NHash #< DelegateClass(Hash)
  # extend Forwardable
  class DimensionError < StandardError; end

  # def_delegators :@hash
  attr_reader :dimensions

  def initialize(dimensions = 3)
    raise DimensionError unless dimensions.positive?

    @dimensions = dimensions.to_i
    @hash = if dimensions == 1
              {}
            else
              Hash.new { |hash, key| hash[key] = self.class.new(dimensions - 1) }
            end
  end

  def [](*indices)
    raise DimensionError.new(indices.inspect) if indices.count > @dimensions

    index = indices.shift
    if index.nil?
      if @dimensions < 2
        self
      else
        newhash = self.class.new(@dimensions - 1)
        # @hash.each_with_object(newhash) { |h, (k, v)| h[k] = @hash[k][*indices]}
        @hash.each do |k, v|
          r = v[*indices]
          newhash[k] = r unless r.nil? || r.empty?
        end
        newhash
      end
    else
      index = index.to_sym if index.respond_to?(:to_sym)
      if indices.empty?
        @hash[index]
      else
        @hash[index][*indices]
      end
    end
  end

  def []=(*params)
    value = params.pop
    raise DimensionError.new(params.inspect) if params.count > @dimensions || params.any?(&:nil?)

    index = params.shift
    index = index.to_sym if index.respond_to?(:to_sym)
    if params.count.positive?
      @hash[index][*params] = value
    else
      @hash[index] = value
    end
  end

  def to_h
    @hash.transform_values { |v| v.respond_to?(:to_h) ? v.to_h : v }
  end

  def empty?
    @hash.empty?
  end
end
