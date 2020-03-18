require 'tiny_decorator/delegatable'

module TinyDecorator
  # Single decorator. Inherite, then define methods to use.
  # This base decorator delegates all. To limit delegation to source object.
  #
  # ```
  # class NewDecorator < TinyDecorator::SingleDecorator
  #   def new_method
  #     'decorated'
  #   end
  # end
  #
  # NewDecorator.decorate(Object.new).new_method # 'decorated'
  # NewDecorator.decorate_collection([Object.new, Object.new])[1].new_method # 'decorated'
  # ```
  #
  # Use in case source has only 1 decorator.
  # In case more than 1 decorator or conditional decorate, we prefer using `TinyDecorator::CompositeDecorator`
  class SingleDecorator < SimpleDelegator
    # Initialize, use `.decorate` or `.new` are the same
    # @param delegatee [Object] source object to decorate
    # @param context [Hash] context as hash, could read within decorator scope by `context[]`
    def initialize(delegatee, context = {})
      @context = context
      __setobj__(delegatee)
    end
    attr_reader :context

    class << self
      # Decorate a collection, collection must extend Enum behavior
      # @param delegatees [Array] collection of source object to decorate
      # @param context [Hash] context as hash, could read within decorator scope by `context[]`
      def decorate_collection(delegatees, context = {})
        delegatees.map do |delegatee|
          new(delegatee, context)
        end
      end

      alias decorate new

      include TinyDecorator::Delegatable
    end
  end
end
