require 'spec_helper'

describe "SuperLanding::API::Base" do
  # Base 的 get / post 是 protected；用子類別公開，並可自訂 params / post_data
  class ExposedAPI < SuperLanding::API::Base
    attr_writer :query_params, :form

    def do_get(path) = get(path)
    def do_post(path) = post(path)
    def params = @query_params || super
    def post_data = @form || super
  end

  it "defaults base_url to SuperLanding::BASE_URL" do
    assert_equal "https://www.super-landing.com/api", SuperLanding::BASE_URL
    assert_equal SuperLanding::BASE_URL, ExposedAPI.new("M", "K").base_url
  end

  it "uses the given base_url" do
    assert_equal "http://example.test", ExposedAPI.new("M", "K", "http://example.test").base_url
  end

  it "builds the GET url from base_url + path + auth params + params" do
    FakeServer.run(body: "{}") do |server|
      api = ExposedAPI.new("M 1", "K&1", server.url)
      api.query_params = { page: 2 }
      api.do_get("/some/path.json")

      request = server.requests.first
      assert_equal "/some/path.json", request.path
      assert_equal({ "merchant_no" => "M 1", "access_key" => "K&1", "page" => "2" },
                   URI.decode_www_form(request.query).to_h)
      # 特殊字元必須被編碼，不能直接出現在 query string
      refute_includes request.query, "K&1"
    end
  end

  it "POSTs post_data as form fields and still sends auth params in the query" do
    FakeServer.run(body: "{}") do |server|
      api = ExposedAPI.new("M", "K", server.url)
      api.form = { name: "x" }
      api.do_post("/orders.json")

      request = server.requests.first
      assert_equal "POST", request.method
      assert_equal "/orders.json", request.path
      assert_equal "M", URI.decode_www_form(request.query).to_h["merchant_no"]
      assert_equal({ "name" => "x" }, URI.decode_www_form(request.body).to_h)
    end
  end

  it "returns the error response for 4xx/5xx on both GET and POST" do
    FakeServer.run(status: 401, body: "{}") do |server|
      api = ExposedAPI.new("M", "K", server.url)
      assert_equal 401, api.do_get("/a").code
      assert_equal 401, api.do_post("/a").code
    end
  end

  it "has empty default params and post_data" do
    api = SuperLanding::API::Base.new("M", "K")
    assert_equal({}, api.send(:params))
    assert_equal({}, api.send(:post_data))
  end

  it "Order is a Base subclass" do
    assert_operator SuperLanding::API::Order, :<, SuperLanding::API::Base
  end
end
