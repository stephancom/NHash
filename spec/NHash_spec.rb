# frozen_string_literal: true

RSpec.describe NHash do
  it "has a version number" do
    expect(NHash::VERSION).not_to be nil
  end

  context 'basics' do
    subject(:nhash) { described_class.new }

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

    it { expect(nhash.is_a?(Hash)).to be false }
    it { expect(nhash.to_h.is_a?(Hash)).to be true }

    context 'with data stored' do
      before do
        nhash[:a, :b, :c] = 42
        nhash[:red, :green, :blue] = 69        
      end

      it { expect(nhash[:a, :b, :c]).to eq 42 }
      it { expect(nhash[:red, :green, :blue]).to eq 69 }

      it 'to_h returns a nested hash with the data' do
        expect(nhash.to_h).to match( a: { b: { c: 42 } },
                                   red: { green: { blue: 69 } })
      end
    end
  end
end
