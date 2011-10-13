enable :sessions
disable :flash
use Rack::Flash, :sweep=>true

Compass.add_project_configuration(ROOT + '/config/compass.config')  

DataMapper.setup :default, ENV['DATABASE_URL'] || "postgres://lucidrains:caC1tuS23@localhost/calc"

JS = {
  :jquery     => "https://ajax.googleapis.com/ajax/libs/jquery/1.6.3/jquery.min.js",
  :jquery_ui  => 'https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js',
  :json       => 'http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js',
  :spine      => 'http://cdnjs.cloudflare.com/ajax/libs/spinejs/0.0.4/spine.min.js',
  :raphael    => 'http://cdnjs.cloudflare.com/ajax/libs/raphael/1.5.2/raphael-min.js',
  :handlebar  => "http://cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.0.0.beta2/handlebars.min.js",
  :jquery_validate => 'http://ajax.microsoft.com/ajax/jquery.validate/1.7/jquery.validate.min.js',
  :require    => 'http://cdnjs.cloudflare.com/ajax/libs/require.js/0.26.0/require.min.js',
  :mathjax    => 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML.js'
}

CSS = {
  :jquery_css => 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/smoothness/jquery-ui.css',
}