# frozen_string_literal: true

RSpec.describe NHash do
  it 'has a version number' do
    expect(NHash::VERSION).not_to be nil
  end

  let(:dimensions) { 3 }
  let(:nhash) { described_class.new(dimensions) }

  shared_context 'it has data' do
    before do
      nhash[:a, :b, :c] = 42
      nhash[:red, :green, :blue] = 69
      nhash[:same1, :same2, :same3] = :samesame
      nhash[:same1, :diff2, :same3] = :samediff
      nhash[:diff1, :same2, :same3] = :diffsame
      nhash[:diff1, :diff2, :same3] = :diffdiff
      nhash[:same1, :same2, :diff3] = :samesamed
      nhash[:same1, :diff2, :diff3] = :samediffd
      nhash[:diff1, :same2, :diff3] = :diffsamed
      nhash[:diff1, :diff2, :diff3] = :diffdiffd
      nhash[:a, :b, :same] = 'neljäkymmentäkaksi'
    end
  end

  context 'dimensions' do
    it 'defaults to 3' do
      expect(described_class.new.dimensions).to eq 3
    end

    it 'fails on 0' do
      expect { described_class.new(0) }.to raise_error NHash::DimensionError
    end

    it 'fails on negative' do
      expect { described_class.new(-1) }.to raise_error NHash::DimensionError
    end

    describe 'for a positive integer' do
      let(:dimensions) { 10 }

      it 'returns the value given' do
        expect(described_class.new(dimensions).dimensions).to eq dimensions
      end
    end
  end

  context 'assignment' do
    it 'allows assignment to n dimensions' do
      expect { nhash[:a, :b, :c] = 4 }.not_to raise_error
      expect(nhash[:a, :b, :c]).to eq 4
    end

    it 'fails on too many dimensions' do
      expect {
        nhash[:a, :b, :c, :d] = 5
      }.to raise_error NHash::DimensionError
    end

    it 'succeeds on too few dimensions' do
      expect { nhash[:a, :b] = 3 }.not_to raise_error
      expect(nhash[:a, :b]).to eq(3)
    end

    it 'fails on nil dimensions' do
      expect { nhash[:a, nil, :c] = 3 }.to raise_error NHash::DimensionError
    end

    it 'allows interchangeable string and symbol indices' do
      nhash['red', 23, :blue] = 'fred'
      expect(nhash[:red, 23, 'blue']).to eq 'fred'
    end

    context 'with > 3 dimensions' do
      let(:dimensions) { 5 }

      it 'works as expected' do
        nhash[:up, :left, :forward, :strange, :bottom] = :charm
        expect(nhash[:up, :left, :forward, :strange, :bottom]).to eq :charm
      end
    end
  end

  context 'retrieval' do
    include_context 'it has data'

    it { expect(nhash[:a, :b, :c]).to eq 42 }
    it { expect(nhash[:red, :green, :blue]).to eq 69 }

    context 'with wildcards' do
      it { expect(nhash[nil, :same2, :same3].to_h).to match(same1: :samesame, diff1: :diffsame) }
      it { expect(nhash[:same1, nil, :same3].to_h).to match(same2: :samesame, diff2: :samediff) }
      it { expect(nhash[:same1, :same2, nil].to_h).to match(same3: :samesame, diff3: :samesamed) }
      it { expect(nhash[:same1, :same2].to_h).to match(same3: :samesame, diff3: :samesamed) }

      it { expect(nhash[nil, nil, :same3].to_h).to match(same1: { same2: :samesame, diff2: :samediff }, diff1: { same2: :diffsame, diff2: :diffdiff }) }
      it { expect(nhash[nil, :same2, nil].to_h).to match(same1: { same3: :samesame, diff3: :samesamed }, diff1: { same3: :diffsame, diff3: :diffsamed }) }
      it { expect(nhash[:same1, nil, nil].to_h).to match(same2: { same3: :samesame, diff3: :samesamed }, diff2: { same3: :samediff, diff3: :samediffd }) }

      it { expect(nhash[:same1, :same2, nil].to_h).to match(nhash[:same1, :same2].to_h) }
      it { expect(nhash[:same1, nil].to_h).to match(nhash[:same1].to_h) }
      it { expect(nhash[nil, :same2, nil].to_h).to match(nhash[nil, :same2].to_h) }
    end
  end

  context '#to_h' do
    include_context 'it has data'

    it { expect(nhash.to_h.is_a?(Hash)).to be true }
    it 'returns a nested hash with the data' do
      expect(nhash.to_h).to match(a:     { b:     { c: 42, same: 'neljäkymmentäkaksi' } },
                               red:   { green: { blue: 69 } },
                               same1: { same2: { same3: :samesame, diff3: :samesamed }, diff2: { same3: :samediff, diff3: :samediffd } },
                               diff1: { same2: { same3: :diffsame, diff3: :diffsamed }, diff2: { same3: :diffdiff, diff3: :diffdiffd } })
    end
  end
end
