require 'benchmark'
require 'draper'
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
# Use draper
# =============================================================================
klasses = ""
NUM_DECORATOR.times do |n|
  klasses += "\nclass DraperDecorator#{n} < Draper::Decorator\n"
  klasses += "  delegate_all\n\n"

  NUM_ATTRIBUTE.times do |m|
    klasses += <<-ATTRIBUTES_DESC
  def attribute_#{n}_#{m}
    value
  end
    ATTRIBUTES_DESC
  end

  klasses += "\nend\n"
end

eval(klasses)

# =============================================================================
# Use draper 1 decorator
# =============================================================================
klasses = "\nclass BigDraperDecorator < Draper::Decorator\n"
NUM_DECORATOR.times do |n|
  NUM_ATTRIBUTE.times do |m|
    klasses += <<-ATTRIBUTES_DESC
  def attribute_#{n}_#{m}
    object.value
  end
    ATTRIBUTES_DESC
  end
end
klasses += "\nend\n"

eval(klasses)

# =============================================================================
# Let's test
# =============================================================================
RSpec.describe "Performance" do
  it 'works' do
    decorators = NUM_DECORATOR.times.map do |n|
      "DraperDecorator#{n}".constantize
    end
    Benchmark.bm do |x|
      x.report('Draper multiple decorators') do
        sources = 100.times.map { |i| SourceObject.new(i) }
        decorators.each do |decorator|
          sources = decorator.decorate_collection(sources)
        end
        i = 0
        sources.each do |decorated|
          NUM_DECORATOR.times do |n|
            NUM_ATTRIBUTE.times do |m|
              expect(decorated.send("attribute_#{n}_#{m}")).to eq(i)
            end
          end

          i += 1
        end
      end

      x.report('Draper Single decorator') do
        sources = 100.times.map { |i| SourceObject.new(i) }
        sources = BigDraperDecorator.decorate_collection(sources)
        i = 0
        sources.each do |decorated|
          NUM_DECORATOR.times do |n|
            NUM_ATTRIBUTE.times do |m|
              expect(decorated.send("attribute_#{n}_#{m}")).to eq(i)
            end
          end

          i += 1
        end
      end

      x.report('tiny_decorator') do
        sources = 100.times.map { |i| SourceObject.new(i) }
        i = 0
        MainDecorator.decorate_collection(sources).each do |decorated|
          NUM_DECORATOR.times do |n|
            NUM_ATTRIBUTE.times do |m|
              expect(decorated.send("attribute_#{n}_#{m}")).to eq(i)
            end
          end

          i += 1
        end
      end
    end
  end
end
