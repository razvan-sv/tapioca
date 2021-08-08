# typed: strict
# frozen_string_literal: true

module Tapioca
  module Reflection
    extend T::Sig
    extend self

    CLASS_METHOD = T.let(Kernel.instance_method(:class), UnboundMethod)
    CONSTANTS_METHOD = T.let(Module.instance_method(:constants), UnboundMethod)
    NAME_METHOD = T.let(Module.instance_method(:name), UnboundMethod)
    SINGLETON_CLASS_METHOD = T.let(Object.instance_method(:singleton_class), UnboundMethod)
    ANCESTORS_METHOD = T.let(Module.instance_method(:ancestors), UnboundMethod)
    SUPERCLASS_METHOD = T.let(Class.instance_method(:superclass), UnboundMethod)
    OBJECT_ID_METHOD = T.let(BasicObject.instance_method(:__id__), UnboundMethod)
    EQUAL_METHOD = T.let(BasicObject.instance_method(:equal?), UnboundMethod)
    PUBLIC_INSTANCE_METHODS_METHOD = T.let(Module.instance_method(:public_instance_methods), UnboundMethod)
    PROTECTED_INSTANCE_METHODS_METHOD = T.let(Module.instance_method(:protected_instance_methods), UnboundMethod)
    PRIVATE_INSTANCE_METHODS_METHOD = T.let(Module.instance_method(:private_instance_methods), UnboundMethod)

    sig { params(object: BasicObject).returns(Class).checked(:never) }
    def class_of(object)
      CLASS_METHOD.bind(object).call
    end

    sig { params(constant: Module).returns(T::Array[Symbol]) }
    def constants_of(constant)
      CONSTANTS_METHOD.bind(constant).call(false)
    end

    sig { params(constant: Module).returns(T.nilable(String)) }
    def name_of(constant)
      NAME_METHOD.bind(constant).call
    end

    sig { params(constant: Module).returns(Class) }
    def singleton_class_of(constant)
      SINGLETON_CLASS_METHOD.bind(constant).call
    end

    sig { params(constant: Module).returns(T::Array[Module]) }
    def ancestors_of(constant)
      ANCESTORS_METHOD.bind(constant).call
    end

    sig { params(constant: Class).returns(T.nilable(Class)) }
    def superclass_of(constant)
      SUPERCLASS_METHOD.bind(constant).call
    end

    sig { params(object: BasicObject).returns(Integer).checked(:never) }
    def object_id_of(object)
      OBJECT_ID_METHOD.bind(object).call
    end

    sig { params(object: BasicObject, other: BasicObject).returns(T::Boolean).checked(:never) }
    def are_equal?(object, other)
      EQUAL_METHOD.bind(object).call(other)
    end

    sig { params(constant: Module).returns(T::Array[Symbol]) }
    def public_instance_methods_of(constant)
      PUBLIC_INSTANCE_METHODS_METHOD.bind(constant).call
    end

    sig { params(constant: Module).returns(T::Array[Symbol]) }
    def protected_instance_methods_of(constant)
      PROTECTED_INSTANCE_METHODS_METHOD.bind(constant).call
    end

    sig { params(constant: Module).returns(T::Array[Symbol]) }
    def private_instance_methods_of(constant)
      PRIVATE_INSTANCE_METHODS_METHOD.bind(constant).call
    end

    sig { params(constant: Module).returns(T::Array[Module]) }
    def inherited_ancestors_of(constant)
      if Class === constant
        ancestors_of(superclass_of(constant) || Object)
      else
        Module.ancestors
      end
    end

    sig { params(constant: Module).returns(T.nilable(String)) }
    def qualified_name_of(constant)
      name = name_of(constant)
      return if name.nil?

      if name.start_with?("::")
        name
      else
        "::#{name}"
      end
    end

    sig { params(method: T.any(UnboundMethod, Method)).returns(T.untyped) }
    def signature_of(method)
      T::Private::Methods.signature_for_method(method)
    rescue LoadError, StandardError
      nil
    end

    sig { params(constant: Module).returns(String) }
    def type_of(constant)
      constant.to_s.gsub(/\bAttachedClass\b/, "T.attached_class")
    end
  end
end
