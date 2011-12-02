enable :sessions
disable :flash
use Rack::Flash, :sweep=>true

Compass.add_project_configuration(ROOT + '/config/compass.config')  

db_string = if DEV then "mysql://root:@localhost/econ" else "mysql://root:hcpLab180@localhost/econ" end
DataMapper.setup :default, db_string
DataMapper::Logger.new($stdout, :debug)

AWS_KEY = 'AKIAJU5ZLYKXW4HJHOSQ'
AWS_SECRET = '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'

RTurk.setup(AWS_KEY, AWS_SECRET, :sandbox => true)
RTurk::logger.level = Logger::DEBUG if DEV
MTURK_SUBMIT_URL = RTurk.sandbox? ? "https://workersandbox.mturk.com/mturk/externalSubmit" : "http://www.mturk.com/mturk/externalSubmit"

HIT_TYPE = RTurk::RegisterHITType.create(:title => "Come play a card's game!") do |hit_type|
  hit_type.description = "More card games!"
  hit_type.keywords = 'card, game, economics'
  hit_type.reward = 0.01
end

DOMAIN_NAME = "klikker.net"
WINDOWS_IP = "50.57.141.31"
WINDOWS_PHOTON_PORT = "5055"
WINDOWS_SERVER_IP = "#{WINDOWS_IP}:4567"
TARGET_SERVER_IP = "50.57.187.207"

JS = {
  :jquery     => "https://ajax.googleapis.com/ajax/libs/jquery/1.6.3/jquery.min.js",
  :jquery_ui  => 'https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js',
  :json       => 'http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js',
  :spine      => 'http://cdnjs.cloudflare.com/ajax/libs/spinejs/0.0.4/spine.min.js',
  :raphael    => 'http://cdnjs.cloudflare.com/ajax/libs/raphael/1.5.2/raphael-min.js',
  :handlebar  => "http://cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.0.0.beta2/handlebars.min.js",
  :jquery_validate => 'http://ajax.microsoft.com/ajax/jquery.validate/1.7/jquery.validate.min.js',
  :require    => 'http://cdnjs.cloudflare.com/ajax/libs/require.js/0.26.0/require.min.js',
  :mathjax    => 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML.js',
  :unity3d    => 'http://webplayer.unity3d.com/download_webplayer-3.x/3.0/uo/UnityObject.js'
}

CSS = {
  :jquery_css => 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/smoothness/jquery-ui.css',
  :twitter_bootstrap => 'http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css'
}