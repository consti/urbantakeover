class StickerController < ApplicationController

  def index
    @order = Order.new(params[:order])
    return unless request.post?
    @order.save!
    redirect_to :action => 'get'
  rescue ActiveRecord::RecordInvalid
    render :action => 'index'
  end
  
  def get
  end
end
