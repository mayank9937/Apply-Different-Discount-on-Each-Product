APPLY_PRODUCT_DISCOUNT = [
  {
    property_name:"_discount",
    property_value_prefix:'discount_',
    tag_discount_type: :percent,
    discount_message:'[discount]% Discount applied !!!!',
  }
]

class ApplyProductDiscount
  def initialize(line_item,discount,campaign)
    @item = line_item
    @campaign = campaign
    @discount = discount
    @discount_amount = if @campaign[:tag_discount_type] == :percent
      1 - (@discount * 0.01)
    else
      Money.new(cents: 100) * @discount
    end
    self.apply()
  end
  
  def apply()
    
     new_line_price = if @campaign[:tag_discount_type] == :percent
        @item.line_price * @discount_amount
      else
        [@item.line_price - (@discount_amount * @item.quantity), Money.zero].max
      end
      
    MESSAGE = @campaign[:discount_message].sub('[discount]',@discount.to_s)
    
    @item.change_line_price(new_line_price, message: MESSAGE)
    
  end
end


class DiscountApplyFromProperty
  def initialize(lien_item,campaign)
    @item = lien_item
    @campaign = campaign
    self.run()
  end
  
  def run()

    PRODUCT_DISCOUNT = @item.properties.fetch(@campaign[:property_name]).sub(@campaign[:property_value_prefix]).to_f
    ApplyProductDiscount.new(@item,PRODUCT_DISCOUNT,@campaign)
    
  end
end


class ApplyDifferentDiscountEachProduuct
  def initialize(campaigns)
    @campaigns = campaigns
  end

  def run(cart)
    cart.line_items.each do |line_item|
      @campaigns.each do |campaign|
        
        if(campaign[:property_prefix] != "" && campaign[:property_prefix] != nil)
          DiscountApplyFromProperty.new(line_item,campaign)
        end

      end
    end
  end
end


CAMPAIGNS = [
  ApplyDifferentDiscountEachProduuct.new(APPLY_PRODUCT_DISCOUNT),
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart