# Test that class hooks work as expected.


test "extends hook is called", ->
  extendsCalled = false
  class Base 
    @__extends__ = (child, name)->
      extendsCalled = true
      # This is the CoffeeScript compiler's extends function translated into CoffeeScript 
      # minus hte logic I added to invoke the extends function!
      for own key of this
        child[key] = this[key]
      ctor = ()->
        @constructor = child
        return  
      ctor.prototype = this.prototype
      child.prototype = new ctor()
      # need __super__ for coffeescript's super() call to work properly.
      child.__super__ = this.prototype
      child 

    alice: ()->
      'Base::alice'

    bob: ()-> 
      'Base::bob'


  class Derived extends Base 
    bob: ()->
      'Derived::bob'

  ok extendsCalled 
  d = new Derived() 

  ok d.alice() is 'Base::alice'
  ok d.bob() is 'Derived::bob'


test "finalise hook is called", -> 
  finaliseCalled = false

  class ToBeFinalised
    @__finalise__ = (name)->
      finaliseCalled = true
      ok @::alice is "alice"
      ok @::bob is "bob"
      @__name__ = name
      return this

    # Just define some properties and make sure that they exist on the ctor's 
    # prototype. This shows that it was called after their definition.
    alice: "alice"
    bob: "bob"

  ok finaliseCalled
  ok ToBeFinalised.__name__ is "ToBeFinalised"


test "metaclass declaration is hoisted", ->
  # In the generated code, CoffeeScript relies on the fact that all function delcaratiosn are hoisted to call
  # __extends() on the contructor before it is defined.
  # Given that the value of the __metaclass__ will be processed by the __extends() call and has to be as
  # defined for the current class (not a parent)
  extendsCalled = false

  class Base
    @__metaclass__ = 'baseMeta'

    # This will get called when Foo is defined
    @__extends__ = (child, name)->
      ok name is 'Foo'
      ok child.__metaclass__ is 'FooMeta'
      extendsCalled = true

  class Foo extends Base
    @__metaclass__ = "FooMeta"

  ok extendsCalled




  
