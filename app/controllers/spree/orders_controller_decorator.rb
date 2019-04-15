Spree::OrdersController.class_eval do
    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      order    = current_order(create_order_if_necessary: true)
      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].to_i
      options  = params[:options] || {}


      # 2,147,483,647 is crazy. See issue #2695.
      if quantity.between?(1, 2_147_483_647)
        begin
          order.contents.add(variant, quantity, options)
      if params[ :order ].present? and params[ :order ][ "comment" ].present?
	last_line_item = Spree::LineItem.where( :order_id => order.id, :variant_id => params[ :variant_id ].to_i  ).last

	comment = order.comments.where( "comment LIKE '%CUSTOM LABEL " + last_line_item.id.to_s + "%'" ).first
	if comment.nil?
	        comment = Spree::Comment.new( :commentable_type => "Spree::Order", :commentable_id => order.id, :comment => "CUSTOM LABEL " + last_line_item.id.to_s + ": " + params[ :order ][ "comment" ] )
	else
		comment.comment = "CUSTOM LABEL " + last_line_item.id.to_s + ": " + params[ :order ][ "comment" ]
	end
        comment.save
      end

        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
      else
        error = Spree.t(:please_enter_reasonable_quantity)
      end



      if error
        flash[:error] = error
        redirect_back_or_default(spree.root_path)
      else
        respond_with(order) do |format|
          format.html { redirect_to cart_path }
        end
      end
    end
end
