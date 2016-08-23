class Client
  class NullClient < Client
    def name
      'Nobody'
    end

    def blank?
      true
    end

    def empty?
      true
    end

    def nil?
      true
    end
  end
end
