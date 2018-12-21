module SuperLanding
  module API
    module Response
      class Base
        attr_accessor :code, :raw_data, :data

        def initialize(raw_data, code)
          @raw_data = raw_data
          @code = code
          @data = JSON.parse(raw_data)
        end

        def auth?
          code == 200
        end
      end
    end
  end
end
