require 'spec_helper'
require 'hiera/backend/file_backend'

class Hiera
  module Backend
    describe File_backend do
      before do
        Hiera.stubs(:debug)
        Hiera.stubs(:warn)

        Hiera::Config.load(:backends => :file)
      end

      describe "#initialize" do
        it "should announce its creation" do # because other specs checks this
          Hiera.expects(:debug).with("Hiera File backend starting")

          File_backend.new
        end
      end

      describe "#lookup" do
        before :each do
          Backend.stubs(:datasources).multiple_yields(["one"], ["two"])
        end

        it "should look for data in all sources" do
          Backend.expects(:datafile).with(:file, {}, "one", "d")
          Backend.expects(:datafile).with(:file, {}, "two", "d")

          subject.lookup("key", {}, nil, :priority)
        end

        describe 'when searching' do

          before :each do
            Backend.stubs(:datafile).with(:file, {}, "one", "d").returns("/datadir/one.d")
            Backend.stubs(:datafile).with(:file, {}, "two", "d").returns("/datadir/two.d")
          end

          it "should pick data earliest source that has it for priority searches" do
            File.expects(:exist?).with("/datadir/one.d/key").returns true
            IO.expects(:binread).with("/datadir/one.d/key").returns 'value'

            File.expects(:exist?).with("/datadir/two.d/key").never
            IO.expects(:binread).with("/datadir/two.d/key").never

            subject.lookup("key", {}, nil, :priority).should == 'value'
          end

          it "should build an array of all data sources for array searches" do
            File.expects(:exist?).with("/datadir/one.d/key").returns true
            IO.expects(:binread).with("/datadir/one.d/key").returns 'value one'

            File.expects(:exist?).with("/datadir/two.d/key").returns true
            IO.expects(:binread).with("/datadir/two.d/key").returns 'value two'

            subject.lookup("key", {}, nil, :array).should == ['value one', 'value two']
          end

          describe "With interpolation" do
            after do
              Hiera::Config.load({:file => {}})
            end

            describe "explicitly enabled" do
              before do
                Hiera::Config.load({:file => {:interpolate => true}})
              end

              it "should parse the answer for scope variables" do
                scope = {'scope_val' => 'v'}

                Backend.expects(:datafile).with(:file, scope, "one", "d").returns("/datadir/one.d")
                Backend.expects(:datafile).with(:file, scope, "two", "d").never

                File.expects(:exist?).with("/datadir/one.d/key").returns true
                IO.expects(:binread).with("/datadir/one.d/key").returns '%{scope_val}alue'

                subject.lookup("key", scope, nil, :priority).should == 'value'
              end
            end

            describe "set to default" do
              it "should parse the answer for scope variables" do
                scope = {'scope_val' => 'v'}

                Backend.expects(:datafile).with(:file, scope, "one", "d").returns("/datadir/one.d")
                Backend.expects(:datafile).with(:file, scope, "two", "d").never

                File.expects(:exist?).with("/datadir/one.d/key").returns true
                IO.expects(:binread).with("/datadir/one.d/key").returns '%{scope_val}alue'

                subject.lookup("key", scope, nil, :priority).should == 'value'
              end
            end

            describe "explicitly disabled" do
              before do
                Hiera::Config.load({:file => {:interpolate => false}})
              end

              it "should not parse the answer for scope variables" do
                scope = {'scope_val' => 'v'}

                Backend.expects(:datafile).with(:file, scope, "one", "d").returns("/datadir/one.d")
                Backend.expects(:datafile).with(:file, scope, "two", "d").never

                File.expects(:exist?).with("/datadir/one.d/key").returns true
                IO.expects(:binread).with("/datadir/one.d/key").returns '%{scope_val}alue'

                subject.lookup("key", scope, nil, :priority).should == '%{scope_val}alue'
              end
            end
          end

          it "should prevent directory traversal attacks" do
            File.expects(:exist?).never
            IO.expects(:binread).never

            expect do
              subject.lookup("../../../../../etc/passwd", {}, nil, :priority)
            end.to raise_error
          end
        end
      end
    end
  end
end
