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

  def whatever
    999
  end

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

    it "raises an error when the property does not exist" do
      ps = PropertyString.new(Obj.new)

      expect(ps.fetch("an_array.1")).to eq 2
      expect { ps.fetch("an_array.9999") }.to raise_error(KeyError, "property an_array.9999 not found")

      expect(ps.fetch("foo.bar.a_hash")).to be_a Hash
      expect { ps.fetch("foo.bar.does_not_exist") }.to raise_error(KeyError, "property foo.bar.does_not_exist not found")
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

    context "when provided a whitelist" do
      it "raises a NoMethodError when :raise_if_method_missing is true and an unknown, non whitelisted method is called" do
        ps = PropertyString.new(
          Obj.new,
          :raise_if_method_missing => true,
          :whitelist => { Obj => %w[foo] }
        )

        expect { ps["foo"] }.to_not raise_error
        expect { ps["bar"] }.to raise_error(NoMethodError, /bar/)
      end

      it "raises a MethodNotAllowed error for a nested property containing a restricted method" do
        ps = PropertyString.new(
          Obj.new,
          :whitelist => { Obj => %w[foo], Foo => %w[bar], Bar => %w[baz] }
        )

        expect { ps["foo"] }.to_not raise_error
        expect { ps["foo.bar"] }.to_not raise_error
        expect { ps["foo.bar.baz"] }.to_not raise_error
        expect { ps["foo.bar.whatever"] }.to raise_error(described_class::MethodNotAllowed, "Access to Bar#whatever is not allowed")
      end

      it "does not raise a MethodNotAllowed error for an unknown Hash key" do
        ps = PropertyString.new(
          Obj.new,
          :whitelist => { Obj => %w[a_hash] }
        )

        expect(ps["a_hash.a"]).to eq 123
        expect { ps["a_hash.does_not_exist"] }.to_not raise_error
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
