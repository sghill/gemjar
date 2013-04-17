require 'spec_helper'
require 'gemjars/deux/specifications'

include Gemjars::Deux

describe Specifications do
  let(:specifications) { Specifications.new(io) }
  let(:io) { Marshal.dump([["zzzzzz", Gem::Version.new("0.0.3"), "ruby"]]) }

  it "should have a single spec" do
    specifications["zzzzz"].should == ["0.0.3"]
  end

  context "many versions for gem" do
    let(:io) { Marshal.dump([
      ["zzzzzz", Gem::Version.new("0.3"), "ruby"],
      ["zzzzzz", Gem::Version.new("1.0"), "ruby"],
      ["zzzzzz", Gem::Version.new("0.2"), "ruby"]
    ])}
    
    it "should return the minimum version for gem" do
      specifications.minimum_version("zzzzz", "~> 0.1").should == "0.2"
    end
  end
end