class NotifyMailer < ActionMailer::Base
  def message( user, message )
    # Email header info MUST be added here
    recipients user.email
    from  '"Urban Takeover" <team@72dpiarmy.com>'
    subject "uto:// #{message}"

    # Email body substitutions go here
    body :user => user, :message => message
  end
end
