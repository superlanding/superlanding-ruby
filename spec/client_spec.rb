require 'spec_helper'

# 以下兩個測試需要本機開發用的 API server（http://api.landing.test），
# 預設略過；要跑請設定環境變數 SUPERLANDING_LIVE=1。
describe "SueprLanding::Client (live development server)" do
  before do
    skip "需要本機開發 server api.landing.test；設定 SUPERLANDING_LIVE=1 才會執行" unless ENV["SUPERLANDING_LIVE"] == "1"
  end

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

describe "SuperLanding::Client (stubbed local HTTP server)" do
  ITEMS_JSON = JSON.generate([
    { "code" => "SKU-1", "title" => "Tee", "owe_qty" => 2, "day3" => 3, "day7" => 7, "day30" => 30,
      "day3_avg" => 1.0, "day7_avg" => 1.0, "day30_avg" => 1.0 },
    { "code" => "SKU-2", "title" => "Cap", "owe_qty" => 0, "day3" => 0, "day7" => 1, "day30" => 5,
      "day3_avg" => 0.0, "day7_avg" => 0.14, "day30_avg" => 0.17 }
  ])

  it "stores credentials and an optional base_url" do
    client = SuperLanding::Client.new("M1", "K1")
    assert_equal "M1", client.merchant_no
    assert_equal "K1", client.access_key
    assert_nil client.base_url

    client = SuperLanding::Client.new("M1", "K1", "http://example.test")
    assert_equal "http://example.test", client.base_url
  end

  it "statistic_items! GETs /statistic/items.json with auth params and ids" do
    FakeServer.run(body: ITEMS_JSON) do |server|
      client = SuperLanding::Client.new("M1", "K1", server.url)
      response = client.statistic_items!([28])

      assert_equal 1, server.requests.length
      request = server.requests.first
      assert_equal "GET", request.method
      assert_equal "/statistic/items.json", request.path
      query = URI.decode_www_form(request.query)
      assert_includes query, ["merchant_no", "M1"]
      assert_includes query, ["access_key", "K1"]
      assert_includes query, ["member_base_ids", "28"]

      assert_equal 200, response.code
      assert response.auth?
      assert_equal 2, response.length
    end
  end

  it "statistic_items! sends every id when given several" do
    FakeServer.run(body: ITEMS_JSON) do |server|
      SuperLanding::Client.new("M1", "K1", server.url).statistic_items!([28, 29])
      ids = URI.decode_www_form(server.requests.first.query).select { |k, _| k == "member_base_ids" }.map(&:last)
      assert_equal %w[28 29], ids
    end
  end

  it "returns an empty, unauthenticated response on 401 instead of raising" do
    FakeServer.run(status: 401, body: JSON.generate("error" => "permission deny")) do |server|
      response = SuperLanding::Client.new("FAKE", "FAKE", server.url).statistic_items!([28])

      assert_equal 401, response.code
      assert_equal false, response.auth?
      assert_equal 0, response.length
      assert_equal({ "error" => "permission deny" }, response.data)
    end
  end

  it "returns the response (not an exception) for other HTTP error statuses" do
    FakeServer.run(status: 500, body: JSON.generate("error" => "boom")) do |server|
      response = SuperLanding::Client.new("M1", "K1", server.url).statistic_items!([1])

      assert_equal 500, response.code
      assert_equal false, response.auth?
      assert_equal [], response.items
    end
  end

  it "lets connection errors propagate" do
    port = FakeServer.new.tap(&:stop).port # 已關閉的 port
    assert_raises(Errno::ECONNREFUSED) do
      SuperLanding::Client.new("M1", "K1", "http://127.0.0.1:#{port}").statistic_items!([1])
    end
  end
end
