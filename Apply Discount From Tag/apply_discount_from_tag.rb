APPLY_PRODUCT_DISCOUNT = [
  {
    product_selector_match_type: :include,
    product_selector_type: :tag,
    product_selectors: ["discount_30"],
    discount_apply: :from_tag,
    tag_prefix:'discount_',
    tag_discount_type: :percent,
    discount_message:'[discount]% Discount applied !!!!',
  }
]


class ProductSelector
  def initialize(match_type, selector_type, selectors)
    @match_type = match_type
    @comparator = match_type == :include ? 'any?' : 'none?'
    @selector_type = selector_type
    @selectors = selectors
  end

  def match?(line_item)
    if self.respond_to?(@selector_type)
      self.send(@selector_type, line_item)
    else
      raise RuntimeError.new('Invalid product selector type')
    end
  end

  def tag(line_item)
    product_tags = line_item.variant.product.tags.map { |tag| tag.downcase.strip }
    @selectors = @selectors.map { |selector| selector.downcase.strip }
    (@selectors & product_tags).send(@comparator)
  end

  def type(line_item)
    @selectors = @selectors.map { |selector| selector.downcase.strip }
    (@match_type == :include) == @selectors.include?(line_item.variant.product.product_type.downcase.strip)
  end

  def vendor(line_item)
    @selectors = @selectors.map { |selector| selector.downcase.strip }
    (@match_type == :include) == @selectors.include?(line_item.variant.product.vendor.downcase.strip)
  end

  def product_id(line_item)
    (@match_type == :include) == @selectors.include?(line_item.variant.product.id)
  end

  def variant_id(line_item)
    (@match_type == :include) == @selectors.include?(line_item.variant.id)
  end

  def subscription(line_item)
    !line_item.selling_plan_id.nil?
  end

  def all(line_item)
    true
  end
end

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


class DiscountApplyFromtag
  def initialize(lien_item,campaign)
    @item = lien_item
    @campaign = campaign
    self.run()
  end
  
  def run()
    if(@campaign[:tag_prefix] == nil || @campaign[:tag_prefix] == '')
      return
    end
    
    PRODUCT_DISCOUNT = @item.variant.product.tags.select{ |tag|
      tag.include?(@campaign[:tag_prefix])
    }[0].sub(@campaign[:tag_prefix],'').to_f
    
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
        
        product_selector = ProductSelector.new(
          campaign[:product_selector_match_type],
          campaign[:product_selector_type],
          campaign[:product_selectors],
        )
        
        if product_selector.match?(line_item)
          if(campaign[:discount_apply] == :from_tag)
            DiscountApplyFromtag.new(line_item,campaign)
          end
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