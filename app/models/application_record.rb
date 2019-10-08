class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # ActiveRecord::Base.logger.level = 1
end
