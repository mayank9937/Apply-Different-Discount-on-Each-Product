# ================================ Customizable Settings ================================
# ================================================================
# Apply Different Discount on every Product.
# Tiered Product Discount by product Tag or from quantity comparation on every product.
#
#
#   - 'product_selector_match_type' determines whether we look for
#     products that do or don't match the entered selectors. Can
#     be:
#       - ':include' to check if the product does match
#       - ':exclude' to make sure the product doesn't match

#   - 'product_selector_type' determines how eligible products
#     will be identified. Can be either:
#       - ':tag' to find products by tag
#       - ':type' to find products by type
#       - ':vendor' to find products by vendor
#       - ':product_id' to find products by ID
#       - ':variant_id' to find products by variant ID
#       - ':subscription' to find subscription products
#       - ':all' for all products

#   - 'product_selectors' is a list of identifiers (from above) for
#     qualifying products. Product/Variant ID lists should only
#     contain numbers (ie. no quotes). If ':all' is used, this
#     can also be 'nil'.

#   - 'discount_apply' Can
#     be:
#       - ':from_tag' to apply discount from tag split of 'tag_prefix'
#       - ':from_tires' to apply discount from different tires

#   - 'tag_prefix' This will work when 'discount_apply' is ':from_tag'.
#       Ex : 
#         - Product Tag : 'item_discount_2.5'
#         - 'tag_prefix': 'item_discount_'

#   - 'discount_type' is the type of discount to provide. Can be
#     either:
#       - ':percent'
#       - ':dollar'

#   - 'tiers' is a list of tiers where:
#     - 'quantity_type' : This tires have Three Types of Quantity Type
#       1. ':compare'
#           - When you want to apply discount if item quantity is larger then your quantity and less then Your quantity, at that time you can use ':compare' Type.
#           - 'tires' This Should in Array format.
#               - 'quantity_grater_then_equal' : Add product Quantity in number format.
#               - 'quantity_less_then_equal' : Add product Quantity in number format, And this quantity should larger then 'quantity_grater_then_equal'.
#               - 'discount_type' : Add data as discribe before.
#               - 'discount_amount' : Add data as discribe before.
#               - 'discount_message' : Add data as discribe before.

#       2. ':grater_then_equal'
#           - When you want to apply discount if item  quantity larger then your quantity, at that time you can use ':grater_then_equal' Type.
#               - 'quantity' : Add quantity in Number format
#               - 'discount_type' : Add data as discribe before.
#               - 'discount_amount' : Add data as discribe before.
#               - 'discount_message' : Add data as discribe before.

#       3. ':equal'
#           - When you want to apply discount on your quantity, at that time you can use ':equal' Type.
#               - 'quantity' : Add quantity in Number format
#               - 'discount_type' : Add data as discribe before.
#               - 'discount_amount' : Add data as discribe before.
#               - 'discount_message' : Add data as discribe before.


#   - 'discount_amount' is the percentage/dollar discount to
#     apply (per item)
#     NOTE : This field no need to add when "discount_apply" is ":from_tag" because disacount will automatically apply based on tag.

#   - 'discount_message' is the message to show when a discount is applied
#     NOTE : When "discount_apply" is ":from_tag" then if you want to show dynamic Discount from Tag then just add "[discount]" text, then that text will automatically replace with Tagged Discount.
# ================================================================


APPLY_PRODUCT_DISCOUNT = [
  {
    product_selector_match_type: :include,
    product_selector_type: :vendor,
    product_selectors: ["E2M Testing Store"],
    discount_apply: :from_tires,
    tiers: [
      {
        quantity_type: :compare,
        tires:[
          {
            quantity_grater_then_equal:1,
            quantity_less_then_equal:4,
            discount_type: :percent,
            discount_amount: 5,
            discount_message: '5% off on between 1 to 4 Quantity',
          },
          {
            quantity_grater_then_equal:5,
            quantity_less_then_equal:9,
            discount_type: :percent,
            discount_amount: 10,
            discount_message: '10% off on between 5 to 9 Quantity',
          },
          {
            quantity_grater_then_equal:10,
            quantity_less_then_equal:24,
            discount_type: :percent,
            discount_amount: 15,
            discount_message: '15% off on between 10 to 24 Quantity',
          }
        ]
      },
      {
        quantity_type: :grater_then_equal,
        quantity: 25,
        discount_type: :percent,
        discount_amount: 15,
        discount_message: '15% off on 11+',
      },
      # {
      #   quantity_type: :equal,
      #   quantity: 10,
      #   discount_type: :percent,
      #   discount_amount: 10,
      #   discount_message: '10% off on 10 products',
      # }
    ],
  },
]


# APPLY_PRODUCT_DISCOUNT = [
#   {
#     product_selector_match_type: :include,
#     product_selector_type: :tag,
#     product_selectors: ["discount_30"],
#     discount_apply: :from_tag,
#     tag_prefix:'discount_',
#     tag_discount_type: :percent,
#     discount_message:'[discount]% Discount applied !!!!',
#   }
# ]

# ================================ Script Code (do not edit) ================================
# ================================================================
# ProductSelector
#
# Finds matching products by the entered criteria.
# ================================================================
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


class DiscountApplyFromTires
  def initialize(lien_item,campaign)
    @item = lien_item
    @campaign = campaign
    @tiers =  campaign[:tiers]
    self.run()
  end
  
  def run()
    @tiers.each do |tire|
      if(tire[:quantity_type] == :compare)
        self.compare(tire[:tires])
      end
      if(tire[:quantity_type] == :equal)
        self.equal(tire)
      end
      if(tire[:quantity_type] == :grater_then_equal)
        self.grater_then_equal(tire)
      end
    end
  end
  
  def compare(tires)
    tires.each do |tire|
      if(@item.quantity >= tire[:quantity_grater_then_equal] && @item.quantity <= tire[:quantity_less_then_equal])
        ApplyProductDiscount.new(@item,tire[:discount_amount],tire)
      end
    end
  end
  
  def equal(tire)
    if(@item.quantity == tire[:quantity])
      ApplyProductDiscount.new(@item,tire[:discount_amount],tire)
    end
  end
  
  def grater_then_equal(tire)
    if(@item.quantity >= tire[:quantity])
      ApplyProductDiscount.new(@item,tire[:discount_amount],tire)
    end
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
          if(campaign[:discount_apply] == :from_tires)
            DiscountApplyFromTires.new(line_item,campaign)
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
