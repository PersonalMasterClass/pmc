class Subject < ActiveRecord::Base
	validates :name, presence: true
end
