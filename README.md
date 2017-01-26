# opal-router

A simple router for Opal applications.

## Installation

Add to your Gemfile:

```ruby
gem 'opal-router', :git => 'git://github.com/adambeynon/opal-router.git'
```

Then, anywhere in your opal code:

```ruby
require "opal-router"
```

## Usage

```ruby
require "opal-router"

Router.configure do |r|
  r.add 'login',        :auth
  r.add 'signup',       :public
  r.add 'user_contact', :default
  r.add 'foobar'
  r.add 'donation'
  r.add 'cast'
  r.add 'settings'
end
```

```:auth```    if you define an ```:auth``` route, this will be the default route when you are not logged in, every other route (unless ```:public```) will redirect here
```:public```  this is a public route, you can reach it even if you are not logged in
```:default``` this is the default route, every wrong route will redirect here. If you define an ```:auth``` route and you are not logged in, it will redirect to the ```:auth``` route

Into any opal file you now can do:
```ruby
class FooView

  def initialize
  	Router.add_path_observer self
  end

  # the route has been updated, called by Route Observable
  def path_update(path)
    frames = Element.find('.frame')
    frames.each do |frame|
      if(frame.id == path)
        frame.show() # jQuery equivalent of frame.css('display', 'block')
      else
        frame.hide() # jQuery equivalent of frame.css('display', 'none')
      end
    end
  end

end

FooView.new
```


## TODO

* Support older browsers which do not support `onhashchange`.
* Support not-hash style routes with HTML5 routing.
* Better documentation
* single page application example based on this router

## License

MIT
