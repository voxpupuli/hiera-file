require 'spec_helper'
require 'hiera/backend/file_backend'

class Hiera
  module Backend
    describe File_backend do
      before do
        Hiera.stubs(:debug)
        Hiera.stubs(:warn)
      end


      describe "#initialize" do
        it "should announce its creation" do # because other specs checks this
          Hiera.expects(:debug).with("Hiera File backend starting")

          File_backend.new
        end
      end

      describe "#lookup" do
        subject { File_backend.new }

        it "should look for data in all sources" do
          Backend.expects(:datasources).multiple_yields(["one"], ["two"])
          Backend.expects(:datafile).with(:file, {}, "one", "d")
          Backend.expects(:datafile).with(:file, {}, "two", "d")

          subject.lookup("key", {}, nil, :priority)
        end

        it "should pick data earliest source that has it for priority searches" do
          Backend.expects(:datasources).multiple_yields(["one"], ["two"])

          Backend.expects(:datafile).with(:file, {}, "one", "d").returns("/datadir/one.d")
          Backend.expects(:datafile).with(:file, {}, "two", "d").never

          File.expects(:exist?).with("/datadir/one.d/key").returns true
          File.expects(:read).with("/datadir/one.d/key").returns 'value'

          subject.lookup("key", {}, nil, :priority).should == 'value'
        end

        it "should build an array of all data sources for array searches" do
          Backend.expects(:datasources).multiple_yields(["one"], ["two"])

          Backend.expects(:datafile).with(:file, {}, "one", "d").returns("/datadir/one.d")
          Backend.expects(:datafile).with(:file, {}, "two", "d").returns("/datadir/two.d")

          File.expects(:exist?).with("/datadir/one.d/key").returns true
          File.expects(:read).with("/datadir/one.d/key").returns 'value one'

          File.expects(:exist?).with("/datadir/two.d/key").returns true
          File.expects(:read).with("/datadir/two.d/key").returns 'value two'

          subject.lookup("key", {}, nil, :array).should == ['value one', 'value two']
        end

        it "should parse the answer for scope variables" do
          scope = {'scope_val' => 'v'}
          Backend.expects(:datasources).multiple_yields(["one"], ["two"])

          Backend.expects(:datafile).with(:file, scope, "one", "d").returns("/datadir/one.d")
          Backend.expects(:datafile).with(:file, scope, "two", "d").never

          File.expects(:exist?).with("/datadir/one.d/key").returns true
          File.expects(:read).with("/datadir/one.d/key").returns '%{scope_val}alue'

          subject.lookup("key", scope, nil, :priority).should == 'value'
        end
      end
    end
  end
end
