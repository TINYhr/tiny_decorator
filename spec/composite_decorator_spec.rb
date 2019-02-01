class Bar
  def attribute1
    'attribute1'
  end

  def attribute2
    'attribute2'
  end

  def attribute3
    'attribute3'
  end
end

class Foo1 < TinyDecorator::SingleDecorator
  def attribute1
    'foo1 decorated_attribute1'
  end

  def context_attribute
    "foo1 #{context[:attribute]}"
  end

  def attribute3_clone
    "#{attribute3} cloned"
  end
end

class Foo2 < TinyDecorator::SingleDecorator
  def attribute2
    'foo2 decorated_attribute2'
  end

  def context_attribute
    "foo2 #{context[:attribute]}"
  end
end

class Foo3 < TinyDecorator::SingleDecorator
  def attribute1
    'foo3 decorated_attribute1'
  end

  def context_attribute
    "foo3 #{context[:attribute]}"
  end
end
