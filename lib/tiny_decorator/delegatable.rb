module TinyDecorator
  module Delegatable
    RUBY_RESERVED_KEYWORDS = %w(alias and BEGIN begin break case class def defined? do
                             else elsif END end ensure false for if in module next nil not or redo rescue retry
                             return self super then true undef unless until when while yield)
    DELEGATION_RESERVED_KEYWORDS = %w(_ arg args block)
    DELEGATION_RESERVED_METHOD_NAMES = Set.new(RUBY_RESERVED_KEYWORDS + DELEGATION_RESERVED_KEYWORDS).freeze

    unless defined?(delegate)
      # =========================================================
      # File activesupport/lib/active_support/core_ext/module/delegation.rb, line 154
      # In case we don't use rails, include their well known `delegate`
      # I have no idea of how to write it better
      # =========================================================
      def delegate(*methods, to: nil, prefix: nil, allow_nil: nil)
        unless to
          raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, to: :greeter)."
        end

        if prefix == true && /^[^a-z_]/.match?(to)
          raise ArgumentError, "Can only automatically set the delegation prefix when delegating to a method."
        end

        method_prefix = if prefix
            "#{prefix == true ? to : prefix}_"
          else
            ""
          end

        location = caller_locations(1, 1).first
        file, line = location.path, location.lineno

        to = to.to_s
        to = "self.#{to}" if TinyDecorator::Delegatable::DELEGATION_RESERVED_METHOD_NAMES.include?(to)

        methods.map do |method|
          # Attribute writer methods only accept one argument. Makes sure []=
          # methods still accept two arguments.
          definition = /[^\]]=$/.match?(method) ? "arg" : "*args, &block"

          # The following generated method calls the target exactly once, storing
          # the returned value in a dummy variable.
          #
          # Reason is twofold: On one hand doing less calls is in general better.
          # On the other hand it could be that the target has side-effects,
          # whereas conceptually, from the user point of view, the delegator should
          # be doing one call.
          if allow_nil
            method_def = [
              "def #{method_prefix}#{method}(#{definition})",
              "_ = #{to}",
              "if !_.nil? || nil.respond_to?(:#{method})",
              "  _.#{method}(#{definition})",
              "end",
            "end"
            ].join ";"
          else
            exception = %(raise DelegationError, "#{self}##{method_prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")

            method_def = [
              "def #{method_prefix}#{method}(#{definition})",
              " _ = #{to}",
              "  _.#{method}(#{definition})",
              "rescue NoMethodError => e",
              "  if _.nil? && e.name == :#{method}",
              "    #{exception}",
              "  else",
              "    raise",
              "  end",
              "end"
            ].join ";"
          end

          module_eval(method_def, file, line)
        end
      end
    end
  end
end
