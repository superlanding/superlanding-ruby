require 'spec_helper'

describe "SueprLanding::Client" do
  it "Development Test (200 OK)" do
    @client = SuperLanding::Client.new("FT095000010", "2962feca90b5930f0e1c40f04303be4e", "http://api.landing.test")

    @response = @client.statistic_items!([28])
    assert_equal 200, @response.code
    assert_equal true, @response.length > 0
    assert_equal true, @response.auth?
  end

  it "Development Test (401 Permission deny)" do
    @client = SuperLanding::Client.new("FAKE", "FAKE", "http://api.landing.test")

    @response = @client.statistic_items!([28])
    assert_equal 401, @response.code
    assert_equal 0, @response.length
    assert_equal false, @response.auth?
  end
end
