# encoding: utf-8
require 'spec_helper'
require 'hiera/backend/file_backend'

class Hiera
  module Backend
    describe File_backend do
      before do
        Hiera.stubs(:debug)
        Hiera.stubs(:warn)

        Hiera::Config.load(
          :backends => :file,
          :hierarchy => %w[common],
          :file => {:datadir => File.join(PROJECT_ROOT, 'spec', 'fixtures', 'hieradata')}
        )
      end

      describe "performing lookups" do

        describe "with US-ASCII data" do
          let(:result) { subject.lookup('ascii', {}, nil, :priority) }

          it "reads the string correctly" do
            result.should eq("0l6MJfGDiiTQBejb6E1TiUBMgqMQcXXyvNu7CXetJHcdZnNAkGYxGW3qoPk1eFmlXZMlUcRTQBBljxCDtgRaH85F9oEOmP[cf6WTctTTFMWbc3H3mVEm3EYS4KVubZP]")
          end

          it "sets the encoding to a valid superset of ASCII", :if => RUBY_VERSION > '1.8.7' do
            result.encoding.should eq(Encoding::UTF_8)
          end
        end

        describe "with UTF-8 data" do
          let(:result) { subject.lookup('utf-8', {}, nil, :priority) }

          it "reads the string correctly" do
            result.should eq("¯\\_(ツ)_/¯\n")
          end

          it "sets the encoding to UTF-8", :if => RUBY_VERSION > '1.8.7' do
            result.encoding.should eq(Encoding::UTF_8)
          end
        end

        describe "with binary data" do
          let(:result) { subject.lookup('binary', {}, nil, :priority) }

          it "reads the string correctly", :if => (RUBY_VERSION == '1.8.7') do
            bytes = [
              0x71, 0x7d, 0xdc, 0xec, 0x6a, 0x84, 0x2a, 0xc3,
              0x70, 0x07, 0xe7, 0x5d, 0x55, 0x7a, 0xb2, 0xf2,
              0x51, 0x59, 0x4d, 0x41, 0x0b, 0xf8, 0xec, 0xf7,
              0x59, 0x59, 0x34, 0x89, 0xb7, 0x53, 0xaa, 0xe1,
              0xb5, 0x1d, 0x8f, 0x73, 0xac, 0x0e, 0xf5, 0xa,
              0xb2, 0xaa, 0xd4, 0x72, 0x4b, 0x41, 0xcf, 0x4d,
              0x08, 0x18, 0x61, 0xb4, 0xfe, 0xf1, 0x0e, 0xe9,
              0xd3, 0xfc, 0x89, 0xa1, 0x28, 0xc5, 0x76, 0x83,
              0x92, 0x20, 0x34, 0x45, 0xdd, 0x85, 0x72, 0x65,
              0xa7, 0xed, 0x59, 0xff, 0x82, 0x48, 0xbd, 0x99,
              0x98, 0xf2, 0x1e, 0x1a, 0x5b, 0xdd, 0xfb, 0x87,
              0x21, 0xa5, 0x77, 0x4a, 0xb3, 0xb2, 0xd8, 0x55,
              0xff, 0x8d, 0xf1, 0x9b, 0x21, 0xd2, 0xbb, 0x7d,
              0xaa, 0xe1, 0x8b, 0x0a, 0xaa, 0x7d, 0xa6, 0x31,
              0x03, 0x62, 0x01, 0xe0, 0xeb, 0x39, 0x4f, 0x72,
              0xd7, 0x1d, 0x0a, 0xe0, 0xeb, 0xea, 0x41, 0xfe
            ]

            result.each_byte.map(&:ord).should eq bytes
          end

          it "sets the encoding to ASCII-8BIT", :if => RUBY_VERSION > '1.8.7' do
            pending "Binary data not yet supported"
            result.encoding.should eq(Encoding::ASCII_8BIT)
          end
        end
      end
    end
  end
end
