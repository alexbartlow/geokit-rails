class SpatialLocation < ActiveRecord::Base
  belongs_to :company
  acts_as_mappable
end