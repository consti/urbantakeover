class StickerController < ApplicationController

  def index
    @order = Order.new(params[:order])
    return unless request.post?
    @order.save!
    OrderMailer.deliver_mailorder(@order)
    redirect_to :action => 'get'
  rescue ActiveRecord::RecordInvalid
    render :action => 'index'
  end
  
  def get
  end
end
