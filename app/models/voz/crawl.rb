module Voz::Crawl
  extend ActiveSupport::Concern

  included do
    include Voz::Crawl::Users
  end

  module ClassMethods
    def crawl
      %w[crawl_users].each do |x|
        begin
          send(x)
        rescue Exception => e
          puts e
        end
      end
    end
  end
end