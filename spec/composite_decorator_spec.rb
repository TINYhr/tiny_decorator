class Bar
  def initialize(value1)
    @value1 = value1
  end

  attr_reader :value1

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

  def attribute5_overwritten
    "foo1:#{attribute5}"
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
  def attribute3
    'foo3 decorated_attribute3'
  end

  def context_attribute
    "foo3 #{context[:attribute]}"
  end
end

class Foo4 < TinyDecorator::SingleDecorator
  def attribute4
    'foo4 decorated_attribute4'
  end

  def context_attribute
    "foo4 #{context[:attribute]}"
  end
end

class Foo5 < TinyDecorator::SingleDecorator
  def attribute5
    'foo5 decorated_attribute5'
  end

  def context_attribute
    "foo5 #{context[:attribute]}"
  end

  def attribute1_overwritten
    "foo5:#{attribute1}"
  end
end

class MainFoo
  extend TinyDecorator::CompositeDecorator

  set_context :attribute, ->(_record, _context) { 123 }

  decorated_by :string_decorator, 'Foo1'
  decorated_by :block_decorator, ->(record) { record.value1.to_i < 0 ? 'Foo2' : 'Foo3'  }
  decorated_by :block_decorator_with_context, ->(record, context) { context[:value2].to_i < 0 ? 'Foo4' : 'Foo5' }
end

RSpec.describe TinyDecorator::CompositeDecorator do
  describe '#decorate' do
    context 'no context' do
      it 'decorates correct' do
        expect(MainFoo.decorate(Bar.new(1)).attribute1).to eq('foo1 decorated_attribute1')
        expect(MainFoo.decorate(Bar.new(1)).attribute2).to eq('attribute2')
        expect(MainFoo.decorate(Bar.new(1)).attribute3).to eq('foo3 decorated_attribute3')
        expect(MainFoo.decorate(Bar.new(1))).not_to respond_to(:attribute4)
        expect(MainFoo.decorate(Bar.new(1)).attribute5).to eq('foo5 decorated_attribute5')

        expect(MainFoo.decorate(Bar.new(-1)).attribute1).to eq('foo1 decorated_attribute1')
        expect(MainFoo.decorate(Bar.new(-1)).attribute2).to eq('foo2 decorated_attribute2')
        expect(MainFoo.decorate(Bar.new(-1)).attribute3).to eq('attribute3')
        expect(MainFoo.decorate(Bar.new(-1))).not_to respond_to(:attribute4)
        expect(MainFoo.decorate(Bar.new(-1)).attribute5).to eq('foo5 decorated_attribute5')
      end
    end
    context 'with context' do
      it 'decorates correct' do
        expect(MainFoo.decorate(Bar.new(1), {value2: 1}).attribute1).to eq('foo1 decorated_attribute1')
        expect(MainFoo.decorate(Bar.new(1), {value2: 1}).attribute2).to eq('attribute2')
        expect(MainFoo.decorate(Bar.new(1), {value2: 1}).attribute3).to eq('foo3 decorated_attribute3')
        expect(MainFoo.decorate(Bar.new(1), {value2: 1})).not_to respond_to(:attribute4)
        expect(MainFoo.decorate(Bar.new(1), {value2: 1}).attribute5).to eq('foo5 decorated_attribute5')

        expect(MainFoo.decorate(Bar.new(1), {value2: -1}).attribute1).to eq('foo1 decorated_attribute1')
        expect(MainFoo.decorate(Bar.new(1), {value2: -1}).attribute2).to eq('attribute2')
        expect(MainFoo.decorate(Bar.new(1), {value2: -1}).attribute3).to eq('foo3 decorated_attribute3')
        expect(MainFoo.decorate(Bar.new(1), {value2: -1}).attribute4).to eq('foo4 decorated_attribute4')
        expect(MainFoo.decorate(Bar.new(1), {value2: -1})).not_to respond_to(:attribute5)
      end
    end

    it 'does not allow query on decorators below, to avoid loop' do
      expect(MainFoo.decorate(Bar.new(1)).attribute5).to eq('foo5 decorated_attribute5')
      expect {
        MainFoo.decorate(Bar.new(1)).attribute5_overwritten
      }.to raise_exception(NameError)
    end

    it 'allows query on decorators above' do
      expect(MainFoo.decorate(Bar.new(1)).attribute1).to eq('foo1 decorated_attribute1')
      expect(MainFoo.decorate(Bar.new(1)).attribute1_overwritten).to eq('foo5:foo1 decorated_attribute1')
    end
  end

  describe '#decorate_collection' do
    context 'no context' do
      it 'decorates as single ones' do
        list = [
          Bar.new(1),
          Bar.new(-1)
        ]

        decorated_list = MainFoo.decorate_collection(list)

        expect(decorated_list[0].attribute1).to eq('foo1 decorated_attribute1')
        expect(decorated_list[0].attribute2).to eq('attribute2')
        expect(decorated_list[0].attribute3).to eq('foo3 decorated_attribute3')
        expect(decorated_list[0]).not_to respond_to(:attribute4)
        expect(decorated_list[0].attribute5).to eq('foo5 decorated_attribute5')

        expect(decorated_list[1].attribute1).to eq('foo1 decorated_attribute1')
        expect(decorated_list[1].attribute2).to eq('foo2 decorated_attribute2')
        expect(decorated_list[1].attribute3).to eq('attribute3')
        expect(decorated_list[1]).not_to respond_to(:attribute4)
        expect(decorated_list[1].attribute5).to eq('foo5 decorated_attribute5')
      end
    end

    context 'positive context' do
      it 'decorates as single ones' do
        list = [
          Bar.new(1),
          Bar.new(-1)
        ]

        decorated_list = MainFoo.decorate_collection(list, {value2: 1})

        expect(decorated_list[0].attribute1).to eq('foo1 decorated_attribute1')
        expect(decorated_list[0].attribute2).to eq('attribute2')
        expect(decorated_list[0].attribute3).to eq('foo3 decorated_attribute3')
        expect(decorated_list[0]).not_to respond_to(:attribute4)
        expect(decorated_list[0].attribute5).to eq('foo5 decorated_attribute5')

        expect(decorated_list[1].attribute1).to eq('foo1 decorated_attribute1')
        expect(decorated_list[1].attribute2).to eq('foo2 decorated_attribute2')
        expect(decorated_list[1].attribute3).to eq('attribute3')
        expect(decorated_list[1]).not_to respond_to(:attribute4)
        expect(decorated_list[1].attribute5).to eq('foo5 decorated_attribute5')
      end
    end

    context 'negative context' do
      it 'decorates as single ones' do
        list = [
          Bar.new(1),
          Bar.new(-1)
        ]

        decorated_list = MainFoo.decorate_collection(list, {value2: -1})

        expect(decorated_list[0].attribute1).to eq('foo1 decorated_attribute1')
        expect(decorated_list[0].attribute2).to eq('attribute2')
        expect(decorated_list[0].attribute3).to eq('foo3 decorated_attribute3')
        expect(decorated_list[0].attribute4).to eq('foo4 decorated_attribute4')
        expect(decorated_list[0]).not_to respond_to(:attribute5)

        expect(decorated_list[1].attribute1).to eq('foo1 decorated_attribute1')
        expect(decorated_list[1].attribute2).to eq('foo2 decorated_attribute2')
        expect(decorated_list[1].attribute3).to eq('attribute3')
        expect(decorated_list[1].attribute4).to eq('foo4 decorated_attribute4')
        expect(decorated_list[1]).not_to respond_to(:attribute5)
      end
    end
  end

  it 'return context value' do
    expect(MainFoo.decorate(Bar.new(-1)).context_attribute).to eq('foo5 123')
  end
end
