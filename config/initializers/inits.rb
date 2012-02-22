AWS_KEY = 'AKIAJU5ZLYKXW4HJHOSQ'
AWS_SECRET = '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'

RTurk.setup(AWS_KEY, AWS_SECRET, :sandbox => true)
RTurk::logger.level = Logger::DEBUG if Rails.env.development?
MTURK_SUBMIT_URL = RTurk.sandbox? ? "https://workersandbox.mturk.com/mturk/externalSubmit" : "http://www.mturk.com/mturk/externalSubmit"

HIT_TYPE = RTurk::RegisterHITType.create(:title => "Come play a card's game!") do |hit_type|
  hit_type.description = "More card games!"
  hit_type.keywords = 'card, game, economics'
  hit_type.reward = 0.01
end

DOMAINS = {:researcher => 'researcher', :home => 'http://klikker.net'}

JS = {
  :json       => 'http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js',
  :spine      => 'http://cdnjs.cloudflare.com/ajax/libs/spinejs/0.0.4/spine.min.js',
  :raphael    => 'http://cdnjs.cloudflare.com/ajax/libs/raphael/1.5.2/raphael-min.js', #TODO remove
  :handlebar  => "http://cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.0.0.beta2/handlebars.min.js", #TODO remove
  :jquery_validate => 'http://ajax.microsoft.com/ajax/jquery.validate/1.7/jquery.validate.min.js', #TODO remove
  :require    => 'http://cdnjs.cloudflare.com/ajax/libs/require.js/0.26.0/require.min.js', #TODO remove
  :mathjax    => 'http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML.js',
  :unity3d_object => 'http://webplayer.unity3d.com/download_webplayer-3.x/3.0/uo/UnityObject.js'
}

CSS = {
  :jquery_css => 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/smoothness/jquery-ui.css',
  :twitter_bootstrap => 'http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css'
}