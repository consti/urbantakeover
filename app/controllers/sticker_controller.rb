class StickerController < ApplicationController

  def index
    @order = Order.new    
  end

  def order
    @order = Order.new(params[:order])
    @order.save
  end
end
