module SuperLanding
  module API
    class StatisticItems < Base

      attr_accessor :ids

      def get!(ids)
        @ids = ids
        response = get('/statistic/items.json')
        Response::StatisticItems.new(response.body, response.code)
      end

      def params
        { member_base_ids: ids }
      end
    end
  end
end
