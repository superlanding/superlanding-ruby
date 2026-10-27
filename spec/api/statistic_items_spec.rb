require 'spec_helper'

describe "SuperLanding::API::StatisticItems" do
  it "params exposes the ids as member_base_ids" do
    api = SuperLanding::API::StatisticItems.new("M", "K")
    api.ids = [1, 2]
    assert_equal({ member_base_ids: [1, 2] }, api.params)
  end

  it "get! remembers the ids and returns a Response::StatisticItems" do
    FakeServer.run(body: "[]") do |server|
      api = SuperLanding::API::StatisticItems.new("M", "K", server.url)
      response = api.get!([7])
      assert_equal [7], api.ids
      assert_kind_of SuperLanding::API::Response::StatisticItems, response
      assert_equal 200, response.code
      assert_equal 0, response.length
    end
  end
end
