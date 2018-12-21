module SuperLanding
  class Client
    attr_accessor :base_url, :merchant_no, :access_key

    def initialize(merchant_no, access_key, base_url=nil)
      @merchant_no = merchant_no
      @access_key = access_key
      @base_url = base_url
    end

    def statistic_items!(ids)
      API::StatisticItems.new(merchant_no, access_key, base_url).get!(ids)
    end
  end
end
