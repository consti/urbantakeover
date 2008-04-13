class OrdersController < ApplicationController

  def open
    @orders = Order.find(:all, :conditions => ["is_done = ?", false])
  end
  
  def send_order
    @order = Order.find(params[:id])

    # return unless request.post? # FUCK YOU RAILS! WHY DOESN'T THIS WORK LIKE IT SHOULD?
    return unless params[:order]

    @order.is_done = true
    if @order.update_attributes(params[:order])
      flash[:notice] = 'Order was marked as sent.'
      redirect_to :action => :open 
    else
      render :action => "send_order"
    end
  end
end
