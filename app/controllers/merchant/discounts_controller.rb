class Merchant::DiscountsController < Merchant::BaseController
  def new
    @merchant = Merchant.find(current_user.merchant_id)
    @discount = Discount.new
  end

  def create
    discount = Merchant.find(params[:format]).discounts.create(discount_params)
    redirect_to merchant_dashboard_path
  end

  private 

  def discount_params
    params[:discount].permit(:percent, :min_qty)
  end
end