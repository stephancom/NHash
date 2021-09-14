# frozen_string_literal: true

RSpec.describe NHash do
  it "has a version number" do
    expect(NHash::VERSION).not_to be nil
  end

  let(:dimensions) { 3 }
  let(:nhash) { described_class.new(dimensions) }

  shared_context 'it has data' do
    before do
      nhash[:a, :b, :c] = 42
      nhash[:red, :green, :blue] = 69        
    end    
  end

  context 'dimensions' do
    it 'defaults to 3' do
      expect(described_class.new.dimensions).to eq 3
    end
  end

  context 'assignment' do    
    it 'allows assignment to n dimensions' do
      expect {
        nhash[:a, :b, :c] = 4
      }.not_to raise_error
    end

    it 'fails on too many dimensions' do
      expect {
        nhash[:a, :b, :c, :d] = 5
      }.to raise_error ArgumentError
    end

    it 'fails on too few dimensions' do
      expect {
        nhash[:a, :b] = 3
      }.to raise_error ArgumentError
    end
  end

  context 'retrieval' do
    include_context 'it has data'

    it { expect(nhash[:a, :b, :c]).to eq 42 }
    it { expect(nhash[:red, :green, :blue]).to eq 69 }
  end

  context '#to_h' do
    include_context 'it has data'

    it { expect(nhash.to_h.is_a?(Hash)).to be true }
    it 'returns a nested hash with the data' do
      expect(nhash.to_h).to match( a: { b: { c: 42 } },
                                 red: { green: { blue: 69 } })
    end
  end
end
