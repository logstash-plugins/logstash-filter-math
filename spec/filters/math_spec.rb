# encoding: utf-8
require_relative "../spec_helper"
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
      filter {  math { calculate => [ [ "-", "var1", "var2", "result" ] ] } }
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
      filter {  math { calculate => [ [ "*", "var1", "var2", "result" ] ] } }
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

  describe "Exponentiation" do
    # The logstash config.
    describe "verbose operation name" do
      config <<-CONFIG
        filter {  math { calculate => [ [ "to the power of", "var1", "var2", "result" ] ] } }
      CONFIG

      describe "should exponentiate two integers" do
        sample( "var1" => -2,  "var2" => 5 ) do
          expect( subject.get("result") ).to eq( -32 )
        end
      end

      describe "should exponentiate two floats" do
        sample( "var1" => 2.2,  "var2" => 1.2 ) do
          expect( subject.get("result") ).to eq( 2.5757708085227633 )
        end
      end

      describe "two huge numbers should exponentiate to infinity" do
        sample( "var1" => 1.79769313486232e+300,  "var2" => 1e+300 ) do
          expect( subject.get("result") ).to eq( Float::INFINITY )
        end
      end
    end

    describe "terse operation name" do
      config <<-CONFIG
        filter {  math { calculate => [ [ "**", "var1", "var2", "result" ] ] } }
      CONFIG

      describe "base value being negative and the exponent being fractional should result in nil" do
        sample( "var1" => -2.2,  "var2" => 7.8 ) do
          expect( subject.get("result") ).to eq( nil )
        end
      end

      describe "base value being 0 should result in 0" do
        sample( "var1" => 0,  "var2" => 7.8 ) do
          expect( subject.get("result") ).to eq( 0 )
        end
      end

      describe "exponent value being 0 should result in 1" do
        sample( "var1" => 7.8,  "var2" => 0 ) do
          expect( subject.get("result") ).to eq( 1 )
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
  end

  describe "Division" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "/", "var1", "var2", "result" ] ] } }
    CONFIG

    describe "should divide two integers" do
      sample( "var1" => -2,  "var2" => 7 ) do
        expect( subject.get("result") ).to eq( -1 )
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

  describe "FloatDiv" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "fdiv", "var1", "var2", "result" ] ] } }
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

  describe "Modulo" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [ [ "mod", "var1", "var2", "result" ] ] } }
    CONFIG

    describe "should get modulo of two integers" do
      sample( "var1" => 53,  "var2" => 13 ) do
        expect( subject.get("result") ).to eq( 1 )
      end
    end

    describe "should get modulo of two floats" do
      sample( "var1" => 53.4,  "var2" => 13.1 ) do
        expect( subject.get("result") ).to eq( 1.0 )
      end
    end

    describe "1 modulo a huge number should give 1.0" do
      sample( "var1" => 1, "var2" => 1.79769313486232e+308 ) do
        expect( subject.get("result") ).to eq( 1.0 )
      end
    end

    describe "First variable being zero should result in 0.0" do
      sample( "var1" => 0,  "var2" => 7.8 ) do
        expect( subject.get("result") ).to eq( 0.0 )
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

  describe "Literals" do
    context "how much smaller is one number than another in percent" do
      config <<-CONFIG
        filter {  math { calculate => [ [ "float divide", "var1", "var2", "result" ],[ "times", "result", 100, "percent_difference" ] ] } }
      CONFIG
      sample( "var1" => 13, "var2" => 104 ) do
        expect( subject.get("percent_difference") ).to eq(12.5)
      end
    end

    context "what is the reciprocal of a value" do
      config <<-CONFIG
        filter {  math { calculate => [ [ "float divide", 1, "var1", "result" ] ] } }
      CONFIG
      sample( "var1" => 8 ) do
        expect( subject.get("result") ).to eq(0.125)
      end
    end

    context "when specifying a zero literal, a divide by zero error is detected at plugin register" do
      it "raises a validation error" do
        pipeline = new_pipeline_from_string('filter {  math { calculate => [ [ "divide", "var1", 0, "result" ] ] } }')
        expect { pipeline.instance_eval{ @filters.each(&:register) } }.to raise_exception(LogStash::ConfigurationError, /Numeric literals are specified as in the calculation but the function invalidates with 'a divisor of zero is not permitted'/)
      end
    end

    context "when specifying literals: -2 and 1.2 with the Power function, an error is detected at plugin register" do
      it "raises a validation error" do
        pipeline = new_pipeline_from_string('filter {  math { calculate => [ [ "**", -2, 1.2, "result" ] ] } }')
        expect { pipeline.instance_eval{ @filters.each(&:register) } }.to raise_exception(LogStash::ConfigurationError, /Numeric literals are specified as in the calculation but the function invalidates with 'raising a negative number to a fractional exponent results in a complex number that cannot be stored in an event'/)
      end
    end
  end

  describe "Timestamps" do
    t1 = Time.new(2018, 06, 8, 11, 0, 0,"+00:00")
    t2 = Time.new(2018, 06, 8, 11, 0, 30,"+00:00")
    config <<-CONFIG
      filter {  math { calculate => [ [ "subtract", "[var2]", "[var1]", "result" ] ] } }
    CONFIG

    context "subtracting 2 LogStash::Timestamps" do
      sample( "var1" => LogStash::Timestamp.at(t1.to_f),  "var2" =>  LogStash::Timestamp.at(t2.to_f)) do
        expect( subject.get("result") ).to eq(30.0)
      end
    end

    context "subtracting a Time from a Timestamp" do
      sample( "var1" => t1,  "var2" =>  LogStash::Timestamp.at(t2.to_f)) do
        expect( subject.get("result") ).to eq(30.0)
      end
    end
  end

  describe "Sequence" do
    # The logstash config.
    config <<-CONFIG
      filter {  math { calculate => [
            [ "+", "var1", "var2", "r1" ],
            [ "-", "var3", "var4", "r2" ],
            [ "*", "r1", "r2", "result" ]
          ] } }
    CONFIG

    describe "results of one calculation can be used in the next calculation" do
      sample( "var1" => 3.4,  "var2" => 6.6, "var3" => 4.4, "var4" => 2.4 ) do
        # I would really expect 20.0 here... what kind of floating point error is this?!
        expect( subject.get("result") ).to eq( 20.000000000000004 )
      end
    end
  end

  describe "Sequence with registers" do
    describe "results of one calculation can be used in the next calculation" do
      config <<-CONFIG
        filter {  math { calculate => [
              [ "+", "[var1]", "[var2]", "R[0]" ],
              [ "-", "[var3]", "[var4]", "R[1]" ],
              [ "*", "R[0]", "R[1]", "[result]" ]
            ] } }
      CONFIG
      sample( "var1" => 3.4,  "var2" => 6.6, "var3" => 4.4, "var4" => 2.4 ) do
        # I would really expect 20.0 here... what kind of floating point error is this?!
        expect( subject.get("result") ).to eq( 20.000000000000004 )
      end
    end

    describe "when a register is used as the very last target, a configuration error is raised" do
      it "raises a validation error" do
        pipeline = new_pipeline_from_string('filter {  math { calculate => [ [ "**", "[var1]", "[var2]", "R[0]" ] ] } }')
        expect { pipeline.instance_eval{ @filters.each(&:register) } }.to raise_exception(LogStash::ConfigurationError, /The final target is a Register, the overall calculation result will not be set in the event/)
      end
    end
  end
end
