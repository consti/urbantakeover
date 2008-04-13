class OrdersController < ApplicationController
  before_filter :login_required

  def authorized?
    current_user.is_admin?
  end

  def open
    @orders = Order.find(:all, :conditions => ["is_done = ?", false], :order => 'created_at asc')
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
