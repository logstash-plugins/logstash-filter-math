# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/math"

describe LogStash::Filters::Math do
   
  describe "Additions" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "add", "var1", "var2", "result" ] ] } }
    CONFIG
  
    describe "should add two integers" do
      sample( "var1" => -2,  "var2" => 7 ) do
        expect( subject.get("result") ).to eq( 5 )
      end
    end
    
    describe "should add two floats" do
      sample( "var1" => -2.4,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( 5.4  )
      end
    end
    
    describe "two huge numbers should add to infinity" do
      sample( "var1" => 1.79769313486232e+308,  "var2" => 1e+308 ) do
        expect( subject.get("result") ).to eq( Float::INFINITY )
      end
    end

    describe "one value being 0 should work" do
      sample( "var1" => 0,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( 7.8 )
      end
    end

    describe "first value missing should result in nil" do
      sample( "var2" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
  
    describe "Second value missing should result in nil" do
      sample( "var1" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
  end

  describe "Subtractions" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "sub", "var1", "var2", "result" ] ] } }
    CONFIG
  
    describe "should subtract two integers" do
      sample( "var1" => -2,  "var2" => 7 ) do
        expect( subject.get("result") ).to eq( -9 )
      end
    end
    
    describe "should subtract two floats" do
      sample( "var1" => -2.4,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( -10.2  )
      end
    end
    
    describe "two huge negative numbers should subtract to negative infinity" do
      sample( "var1" => -1.79769313486232e+308,  "var2" => -1e+308 ) do
        expect( subject.get("result") ).to eq( -Float::INFINITY )
      end
    end
    
    describe "one value being 0 should work" do
      sample( "var1" => 0,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( -7.8 )
      end
    end

    describe "first value missing should result in nil" do
      sample( "var2" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
    
    describe "Second value missing should result in nil" do
      sample( "var1" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
  end

  describe "Multiplication" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "mpx", "var1", "var2", "result" ] ] } }
    CONFIG
  
    describe "should multiply two integers" do
      sample( "var1" => -2,  "var2" => 7 ) do
        expect( subject.get("result") ).to eq( -14 )
      end
    end
    
    describe "should multiply two floats" do
      sample( "var1" => -2.4,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( -18.72 )
      end
    end
    
    describe "two huge numbers should multiply to infinity" do
      sample( "var1" => 1.79769313486232e+300,  "var2" => 1e+300 ) do
        expect( subject.get("result") ).to eq( Float::INFINITY )
      end
    end
    
    describe "one value being 0 should result in 0" do
      sample( "var1" => 0,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( 0 )
      end
    end

    describe "first value missing should result in nil" do
      sample( "var2" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
    
    describe "Second value missing should result in nil" do
      sample( "var1" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
  end

  describe "Division" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "div", "var1", "var2", "result" ] ] } }
    CONFIG
  
    describe "should divide two integers" do
      sample( "var1" => -2,  "var2" => 7 ) do
        expect( subject.get("result") ).to eq( -0.2857142857142857 )
      end
    end
    
    describe "should divide two floats" do
      sample( "var1" => -2.4,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( -0.3076923076923077 )
      end
    end
    
    describe "1 divided by a huge number should give zero" do
      sample( "var1" => 1, "var2" => 1.79769313486232e+308 ) do
        expect( subject.get("result") ).to eq( 0 )
      end
    end
    
    describe "First variable being zero should result in 0" do
      sample( "var1" => 0,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( 0 )
      end
    end
    
    describe "Second variable being zero should result in nil (would be infinity, but this can't be represented in JSON)" do
      sample( "var1" => 2,  "var2" => 0 ) do
        expect( subject.get("result") ).to be_nil
      end
    end

    describe "first value missing should result in nil" do
      sample( "var2" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
    
    describe "Second value missing should result in nil" do
      sample( "var1" => 3 ) do
        expect( subject.get("result") ).to be_nil
      end
    end
  end
  
  describe "Sequence" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ 
          [ "add", "var1", "var2", "r1" ],
          [ "sub", "var3", "var4", "r2" ],
          [ "mpx", "r1", "r2", "result" ]
          ] } }
    CONFIG
  
    describe "results of one calculation can be used in the next calculation"
      sample( "var1" => 3.4,  "var2" => 6.6, "var3" => 4.4, "var4" => 2.4 ) do
        # I would really expect 20.0 here... what kind of floating point error is this?!
        expect( subject.get("result") ).to eq( 20.000000000000004 )
      end
    end

end
