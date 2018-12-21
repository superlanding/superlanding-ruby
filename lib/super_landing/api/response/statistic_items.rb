module SuperLanding
  module API
    module Response
      class StatisticItems < Base
        attr_accessor :items

        delegate :length, to: :items
        delegate :each, to: :items
        delegate :each_with_index, to: :items
        delegate :map, to: :items

        Item = Struct.new(:code, :title, :owe_qty, :day3, :day7, :day30, :day3_avg, :day7_avg, :day30_avg)

        def initialize(*)
          super
          @items = auth? ? data.map { |item| Item.new(item.values) } : []
        end
      end
    end
  end
end
