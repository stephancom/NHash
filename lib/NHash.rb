# frozen_string_literal: true

require_relative "NHash/version"

class NHash
  class Error < StandardError; end

  attr_reader :dimensions

  def initialize(dimensions = 3)
    @dimensions = dimensions
    raise Error, 'Wrong number of dimensions' unless dimensions == 3
    @hash = Hash.new { |hash, key| hash[key] = Hash.new { |inhash, inkey| inhash[inkey] = {} } }
  end

  # it may be useful to extend this to allow for params to be omitted
  def [](one, two, three)
    one, two, three = symbolize(one, two, three)
    @hash[one][two][three]
  end

  def []=(one, two, three, value)
    one, two, three = symbolize(one, two, three)
    @hash[one][two][three] = value
  end

  def to_h
    @hash
  end

  private

  def symbolize(*inputs)
    inputs.map { |n| n.respond_to?(:to_sym) ? n.to_sym : n }
  end
end
