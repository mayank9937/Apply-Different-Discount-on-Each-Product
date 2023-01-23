# Shopify Line Item Plus Script

## Apply different Discount on every Line Item Product

- `product_selector_match_type` : determines whether we look for products that do or don't match the entered selectors. Can be:
  - `:include` to check if the product does match.
  - `:exclude` to make sure the product doesn't match.
 
- `product_selector_type` : determines how eligible products will be identified. Can be either :
  - `:tag` : to find products by tag.
  - `:type` : to find products by type.
  - `:vendor` : to find products by vendor.
  - `:product_id` : to find products by ID.
  - `:variant_id` : to find products by variant ID.
  - `:subscription` : to find subscription products.
  - `:all` : for all products.
  
- `product_selectors` is a list of identifiers (from above) for qualifying products. Product/Variant ID lists should only contain numbers (ie. no quotes). If `:all` is used, this can also be `nil`.

- `discount_apply` Can be:
  - `:from_tag` to apply the discount from tag splitting of `tag_prefix`
  - `:from_tires` to apply discount from different tires

- `discount_amount` is the percentage/dollar discount to apply (per item).
  - ***NOTE : This field no need to add when `discount_apply` is `:from_tag` because disacount will automatically apply based on tag.***

- `discount_message` is the message to show when a discount is applied.
  - ***NOTE : When "discount_apply" is ":from_tag" then if you want to show dynamic Discount from Tag then just add "[discount]" text, then that text will automatically replace with Tagged Discount.***
  
- `tag_prefix`: This will work when `discount_apply` is `:from_tag`.
- Example :
  
   |    Product Tag    | Tag Prefix (tag_prefix) | Discount |
   |-------------------|-------------------------|----------|
   | item_discount_2.5 | item_discount_          | 2.5%     |


- `discount_type` is the type of discount to provide. Can be either:
    - `:percent`
    - `:dollar`
    
- `tiers` is a list of tiers where:
  - `quantity_type` : This tires have Three Types of Quantity Type.
    - `:compare` : When you want to apply discount if item quantity is larger then your quantity and less then Your quantity, at that time you can use this Type.
    - `:grater_then_equal`: When you want to apply discount if item  quantity larger then your quantity, at that time you can use this Type.
    - `:equal` : When you want to apply discount on your quantity, at that time you can use ':equal' Type.
    
---

### `:compare` :
- `tires`: This Should in Array format.

  #### We can add Bellow data in `tires` Array

| Command | Description |
| :--- | :--- |
| `quantity_grater_then_equal` | Add product Quantity in number format. |
| `quantity_less_then_equal` | Add product Quantity in number format, And this quantity should larger then `quantity_grater_then_equal`. |
| `discount_type` | Add data as discribe before. |
| `discount_amount` | Add data as discribe before. |
| `discount_message` | Add data as discribe before. |

### `:grater_then_equal` And `:equal`
| Command | Description |
| :--- | :--- |
| `quantity` | Add quantity in Number format. |
| `discount_type` | Add data as discribe before. |
| `discount_amount` | Add data as discribe before. |
| `discount_message` | Add data as discribe before. |

---

#### Example For `discount_apply` is `:from_tag`
```ruby
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
```

#### Example For `discount_apply` is `:from_tires`
```ruby
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
      {
        quantity_type: :equal,
        quantity: 10,
        discount_type: :percent,
        discount_amount: 10,
        discount_message: '10% off on 10 products',
      }
    ],
  },
]
```


---
Developed by `Mayank Solanki`
