# frozen_string_literal: true

require_relative 'NHash/version'

# 888b      88 88        88                      88
# 8888b     88 88        88                      88
# 88 `8b    88 88        88                      88
# 88  `8b   88 88aaaaaaaa88 ,adPPYYba, ,adPPYba, 88,dPPYba,
# 88   `8b  88 88""""""""88 ""     `Y8 I8[    "" 88P'    "8a
# 88    `8b 88 88        88 ,adPPPPP88  `"Y8ba,  88       88
# 88     `8888 88        88 88,    ,88 aa    ]8I 88       88
# 88      `888 88        88 `"8bbdP"Y8 `"YbbdP"' 88       88
#
# pre-initialized n-dimensional hash with slicing
class NHash
  class DimensionError < StandardError; end

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
    raise DimensionError.new(indices.inspect), 'too many indices' if indices.count > @dimensions

    index = indices.shift
    return slice_below(*indices) if index.nil?

    index = index.to_sym if index.respond_to?(:to_sym)
    if indices.empty?
      @hash[index]
    else
      @hash[index][*indices]
    end
  end

  def []=(*params)
    value = params.pop
    raise DimensionError.new(params.inspect), 'too many indices' if params.count > @dimensions
    raise DimensionError.new(params.inspect), 'nil indices forbidden for assignment' if params.any?(&:nil?)

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

  private

  def slice_below(*indices)
    return self if @dimensions < 2

    @hash.each_with_object(self.class.new(@dimensions - 1)) do |(k, v), h|
      r = v[*indices]
      h[k] = r unless r.nil? || r.empty?
    end
  end
end
