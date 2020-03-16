require 'ruby-prof'
require 'spec_helper'

klasses = ""
main_decorator = <<-MAIN_DECORATOR

class MainDecorator
  extend TinyDecorator::CompositeDecorator

MAIN_DECORATOR
NUM_DECORATOR.times do |n|
  klasses += "class Decorator#{n} < TinyDecorator::SingleDecorator\n"
  NUM_ATTRIBUTE.times do |m|
    klasses += <<-ATTRIBUTES_DESC
  def attribute_#{n}_#{m}
    value
  end
    ATTRIBUTES_DESC
  end
  klasses += "\nend\n"

  main_decorator += <<-DECORATOR
  decorated_by :decorator_#{n}, 'Decorator#{n}'
  DECORATOR
end
main_decorator += "\nend\n"

eval(klasses)
eval(main_decorator)

class SourceObject
  def initialize(value)
    @value = value
  end

  attr_reader :value
end

# =============================================================================
# Let's test
# =============================================================================
RSpec.describe "Profiler" do
  it 'Wall time' do
    sources = 100.times.map { |i| SourceObject.new(i) }
    keys = []
    NUM_DECORATOR.times do |n|
      NUM_ATTRIBUTE.times do |m|
        keys << "attribute_#{n}_#{m}".to_sym
      end
    end
    i = 0

    RubyProf.start
    MainDecorator.decorate_collection(sources).each do |decorated|
      keys.each do |key|
        expect(decorated.send(key)).to eq(i)
      end

      i += 1
    end

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, min_percent: 2)
  end

  it 'Allocation' do
    sources = 100.times.map { |i| SourceObject.new(i) }
    keys = []
    NUM_DECORATOR.times do |n|
      NUM_ATTRIBUTE.times do |m|
        keys << "attribute_#{n}_#{m}".to_sym
      end
    end
    i = 0

    RubyProf.measure_mode = RubyProf::ALLOCATIONS
    RubyProf.start
    MainDecorator.decorate_collection(sources).each do |decorated|
      keys.each do |key|
        expect(decorated.send(key)).to eq(i)
      end

      i += 1
    end

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, min_percent: 2)
  end
end
