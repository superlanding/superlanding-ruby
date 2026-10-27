require 'spec_helper'

describe "SuperLanding::API::Response" do
  describe "Base" do
    it "parses the JSON body and keeps raw_data and code" do
      response = SuperLanding::API::Response::Base.new('{"a":1}', 200)
      assert_equal({ "a" => 1 }, response.data)
      assert_equal '{"a":1}', response.raw_data
      assert_equal 200, response.code
    end

    it "auth? is true only for 200" do
      assert SuperLanding::API::Response::Base.new("{}", 200).auth?
      [201, 401, 403, 500].each do |code|
        assert_equal false, SuperLanding::API::Response::Base.new("{}", code).auth?, "code #{code}"
      end
    end

    it "raises JSON::ParserError for a body that is not JSON" do
      assert_raises(JSON::ParserError) { SuperLanding::API::Response::Base.new("<html>", 200) }
    end
  end

  describe "StatisticItems" do
    body = JSON.generate([
      { "code" => "A", "title" => "Tee", "owe_qty" => 1, "day3" => 2, "day7" => 3, "day30" => 4,
        "day3_avg" => 0.5, "day7_avg" => 0.4, "day30_avg" => 0.3 },
      { "code" => "B", "title" => "Cap", "owe_qty" => 0, "day3" => 0, "day7" => 0, "day30" => 0,
        "day3_avg" => 0, "day7_avg" => 0, "day30_avg" => 0 }
    ])

    it "builds one Item per row when authenticated" do
      response = SuperLanding::API::Response::StatisticItems.new(body, 200)
      assert_equal 2, response.items.length
      assert(response.items.all? { |i| i.is_a?(SuperLanding::API::Response::StatisticItems::Item) })
    end

    it "has no items when not authenticated, even if the body is a JSON array" do
      response = SuperLanding::API::Response::StatisticItems.new(body, 401)
      assert_equal [], response.items
      assert_equal 0, response.length
    end

    it "delegates length / each / each_with_index / map to items" do
      response = SuperLanding::API::Response::StatisticItems.new(body, 200)
      assert_equal response.items.length, response.length
      assert_equal response.items, response.map { |i| i }
      seen = []
      response.each { |i| seen << i }
      assert_equal response.items, seen
      indexes = []
      response.each_with_index { |_, idx| indexes << idx }
      assert_equal [0, 1], indexes
    end

    it "Item exposes the documented members in order" do
      assert_equal %i[code title owe_qty day3 day7 day30 day3_avg day7_avg day30_avg],
                   SuperLanding::API::Response::StatisticItems::Item.members
    end

    # 已知問題（與 Rails / Ruby 版本無關，所有 Ruby 版本皆如此）：
    # lib 以 `Item.new(item.values)` 建立 Item，Struct.new 收到「單一陣列」時會把整個陣列
    # 指派給第一個欄位 (code)，其餘欄位為 nil。依 Item 的欄位設計，預期是每個欄位對應一個值。
    # 依規則不為了讓測試通過而修改 lib，這裡以 skip 標註，並寫在 PR 的 finding 中。
    it "maps each JSON row onto Item members (code, title, ...)" do
      skip "KNOWN BUG: Item.new(item.values) 把整個陣列塞進 code；見 PR finding"
      item = SuperLanding::API::Response::StatisticItems.new(body, 200).items.first
      assert_equal "A", item.code
      assert_equal "Tee", item.title
      assert_equal 1, item.owe_qty
    end
  end

  describe "Order" do
    it "is a Response::Base subclass" do
      assert_operator SuperLanding::API::Response::Order, :<, SuperLanding::API::Response::Base
    end
  end
end
