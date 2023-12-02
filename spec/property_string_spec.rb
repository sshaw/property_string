# frozen_string_literal: true

require "spec_helper"

module Collections
  def a_hash
    {:a => 123}
  end

  def an_array
    [1, 2, 3]
  end
end

class Obj
  include Collections

  def foo
    ::Foo.new
  end
end

class Foo
  include Collections

  def bar
    ::Bar.new
  end
end

class Bar
  include Collections

  def baz
    123
  end
end

RSpec.describe PropertyString do
  describe "#fetch" do
    it "returns the default value for properties that do not exist" do
      ps = PropertyString.new(Obj.new)

      expect(ps.fetch("noey!", 999)).to eq 999
      expect(ps.fetch("an_array.1000", 999)).to eq 999
      expect(ps.fetch("foo.bar.nope", 999)).to eq 999
    end

    it "returns the value from a block for properties that do not exist" do
      ps = PropertyString.new(Obj.new)

      expect(ps.fetch("noey!") { "X" }).to eq "X"
      expect(ps.fetch("an_array.1000") { "X" }).to eq "X"
    end

    it "passes the missing key as an argument to the block" do
      ps = PropertyString.new(Obj.new)

      expect(ps.fetch("noey!") { |key| key + "X" }).to eq "noey!X"
      expect(ps.fetch("an_array.1000") { |key| key + "X" }).to eq "an_array.1000X"
    end

    it "does not return the default value for properties that do exist" do
      ps = PropertyString.new(Obj.new)

      expect(ps.fetch("an_array.1", 999)).to eq 2
      expect(ps.fetch("foo.bar.baz")).to eq 123
      expect(ps.fetch("foo.bar.a_hash.a", 999)).to eq 123
    end
  end

  describe "#[]" do
    context "when :raise_if_method_missing is true" do
      it "raises an error for a property containing a method that does not exist" do
        ps = PropertyString.new(Obj.new, :raise_if_method_missing => true)

        expect { ps["xxx"] }.to raise_error(NoMethodError, /xxx/)
        expect { ps["foo.does_not_exist"] }.to raise_error(NoMethodError, /does_not_exist/)
      end
    end

    context "when :raise_if_method_missing is false" do
      it "returns nil for a property containing a method that does not exist" do
        ps = PropertyString.new(Obj.new, :raise_if_method_missing => false)

        expect(ps["xxx"]).to be_nil
        expect(ps["foo.does_not_exist"]).to be_nil
      end
    end

    it "raises an error for a property containing a method that does not exist" do
      ps = PropertyString.new(Obj.new)

      expect { ps["xxx"] }.to raise_error(NoMethodError, /xxx/)
      expect { ps["foo.does_not_exist"] }.to raise_error(NoMethodError, /does_not_exist/)
    end

    it "returns the object's value for foo" do
      ps = PropertyString.new(Obj.new)
      expect(ps["foo"]).to be_a Foo
    end

    it "returns the object's value for foo.bar" do
      ps = PropertyString.new(Obj.new)
      expect(ps["foo.bar"]).to be_a Bar
    end

    it "returns the object's value for foo.bar.baz" do
      ps = PropertyString.new(Obj.new)
      expect(ps["foo.bar.baz"]).to eq 123
    end

    it "returns the object's value for an array index" do
      ps = PropertyString.new(Obj.new)

      expect(ps["an_array"]).to eq [1,2,3]
      expect(ps["an_array.0"]).to eq 1
      expect(ps["an_array.2"]).to eq 3
      expect(ps["an_array.100"]).to be_nil
    end
  end
end
