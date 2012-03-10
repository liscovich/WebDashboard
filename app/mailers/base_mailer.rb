class BaseMailer < ActionMailer::Base
  default :from => "no_reply@klikker.net"

  layout 'mailer'
end
