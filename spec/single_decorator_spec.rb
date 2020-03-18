RSpec.describe TinyDecorator::SingleDecorator do
  class Bar2
    def attribute1
      'attribute1'
    end

    def attribute2
      'attribute2'
    end

    def sum
      100
    end
  end

  class Foo < TinyDecorator::SingleDecorator
    def attribute1
      'decorated_attribute1'
    end

    def context_attribute
      context[:attribute]
    end

    delegate :to_s, to: :sum
  end

  describe '.decorate' do
    it "responses to .decorate" do
      expect(Foo).to respond_to(:decorate)
    end

    it 'decorates method' do
      expect(Foo.decorate(Bar2.new).attribute1).to eq('decorated_attribute1')
    end

    it 'undecorated method' do
      expect(Foo.decorate(Bar2.new).attribute2).to eq('attribute2')
    end

    it 'delegates method' do
      expect(Foo.decorate(Bar2.new).to_s).to eq('100')
    end

    context 'has decorate context' do
      it 'decorates context attribute' do
        context = { attribute: 'context_attribute' }
        expect(Foo.decorate(Bar2.new, context).context_attribute).to eq('context_attribute')
      end

      it 'decorates EMPTY context attribute' do
        context = { }
        expect(Foo.decorate(Bar2.new, context).context_attribute).to eq(nil)
      end

      it 'decorates DEFAULT context attribute' do
        expect(Foo.decorate(Bar2.new).context_attribute).to eq(nil)
      end
    end
  end

  describe '.new' do
    it "responses to .new" do
      expect(Foo).to respond_to(:new)
    end

    it 'decorates method' do
      expect(Foo.new(Bar2.new).attribute1).to eq('decorated_attribute1')
    end

    it 'undecorated method' do
      expect(Foo.new(Bar2.new).attribute2).to eq('attribute2')
    end

    it 'delegates method' do
      expect(Foo.decorate(Bar2.new).to_s).to eq('100')
    end

    context 'has decorate context' do
      it 'decorates context attribute' do
        context = { attribute: 'context_attribute' }
        expect(Foo.new(Bar2.new, context).context_attribute).to eq('context_attribute')
      end

      it 'decorates EMPTY context attribute' do
        context = { }
        expect(Foo.new(Bar2.new, context).context_attribute).to eq(nil)
      end

      it 'decorates DEFAULT context attribute' do
        expect(Foo.new(Bar2.new).context_attribute).to eq(nil)
      end
    end
  end

  describe '.decorate_collection' do
    it "responses to .decorate_collection" do
      expect(Foo).to respond_to(:decorate_collection)
    end

    it 'decorates methods' do
      list = [Bar2.new, Bar2.new]
      decorated_list = Foo.decorate_collection(list)

      expect(decorated_list.count).to eq(list.count)
      expect(decorated_list[0].attribute1).to eq('decorated_attribute1')
      expect(decorated_list[1].attribute1).to eq('decorated_attribute1')
    end

    it 'undecorated methods' do
      list = [Bar2.new, Bar2.new]
      decorated_list = Foo.decorate_collection(list)

      expect(decorated_list.count).to eq(list.count)
      expect(decorated_list[0].attribute2).to eq('attribute2')
      expect(decorated_list[1].attribute2).to eq('attribute2')
    end

    it 'delegates methods' do
      list = [Bar2.new, Bar2.new]
      decorated_list = Foo.decorate_collection(list)

      expect(decorated_list.count).to eq(list.count)
      expect(decorated_list[0].to_s).to eq('100')
      expect(decorated_list[1].to_s).to eq('100')
    end

    context 'has decorate context' do
      it 'decorates context attribute' do
        context = { attribute: 'context_attribute' }
        list = [Bar2.new, Bar2.new]
        decorated_list = Foo.decorate_collection(list, context)

        expect(decorated_list.count).to eq(list.count)
        expect(decorated_list[0].context_attribute).to eq('context_attribute')
        expect(decorated_list[1].context_attribute).to eq('context_attribute')
      end

      it 'decorates EMPTY context attribute' do
        context = { }
        list = [Bar2.new, Bar2.new]
        decorated_list = Foo.decorate_collection(list, context)

        expect(decorated_list.count).to eq(list.count)
        expect(decorated_list[0].context_attribute).to eq(nil)
        expect(decorated_list[1].context_attribute).to eq(nil)
      end

      it 'decorates DEFAULT context attribute' do
        list = [Bar2.new, Bar2.new]
        decorated_list = Foo.decorate_collection(list)

        expect(decorated_list.count).to eq(list.count)
        expect(decorated_list[0].context_attribute).to eq(nil)
        expect(decorated_list[1].context_attribute).to eq(nil)
      end
    end
  end
end
