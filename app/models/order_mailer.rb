class OrderMailer < ActionMailer::Base
  def mailorder( order )
    # Email header info MUST be added here
    recipients "team@72dpiarmy.com"
    subject "[UTO Mailorder] by #{order.name}" 

    # Email body substitutions go here
    body :order => order
  end
  
  def order_sent(order)
    recipients order.email
    from  '"Urban Takeover" <team@72dpiarmy.com>'
    subject "[UTO Mailorder] order sent for #{order.name}"

    body :order => order
  end
end
