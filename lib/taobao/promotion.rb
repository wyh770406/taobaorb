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
    to_object result[:item_get_response][:item]
    @all_properties_fetched = true
    convert_types
  end

  def convert_types
    @price = @price.to_f
    @cid = @cid.to_i
    @num_iid = @num_iid.to_i
    @auction_point = @auction_point.to_i
    @delist_time = DateTime.parse @delist_time
  end
end
