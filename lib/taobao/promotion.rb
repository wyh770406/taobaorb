class Taobao::Promotion

  include Taobao::Util

  BASIC_PROPERTIES = [:item_id, :promotion_id, :name, :desc, :start_time, :end_time, :item_promo_price]
  OTHER_PROPERTIES = []

  attr_reader *BASIC_PROPERTIES
  alias :id :item_id

  def initialize(product_properties)
    if Hash === product_properties
      to_object product_properties
      @all_properties_fetched = false
      convert_types
    else
      @item_id = product_properties.to_s
      fetch_full_data
    end
  end

  def user
    Taobao::User.new @nick
  end

  def method_missing(method_name, *args, &block)
    if instance_variable_defined? "@#{method_name}"
      fetch_full_data unless @all_properties_fetched
      self.instance_variable_get "@#{method_name}"
    else
      super
    end
  end

  private

  def fetch_full_data
    fields = (BASIC_PROPERTIES + OTHER_PROPERTIES).join ','
    params = {method: 'taobao.ump.promotion.get', fields: fields, item_id: id}
    result = Taobao.api_request(params)
    unless result[:ump_promotion_get_response][:promotions].empty?
      promotion_in_item = result[:ump_promotion_get_response][:promotions][:promotion_in_item] 
      unless promotion_in_item.nil? || promotion_in_item.empty?
        processed_promotion_in_item = promotion_in_item[:promotion_in_item].map{|promotion| promotion.except(:sku_id_list, :sku_price_list, :other_need, :other_send, :desc).merge(:item_id=>id)}
      end
      @processed_promotion_in_item = processed_promotion_in_item rescue nil
      #to_object promotion_in_item[:promotion_in_item].first if promotion_in_item && !promotion_in_item.empty?
    end
    @all_properties_fetched = true
  end

end
