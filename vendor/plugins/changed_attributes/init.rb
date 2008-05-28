# NOTE: Originally I had tried including all of these again because they have their whole weird "alias_method_chains" all built on top of each other,
#       and changed_attributes needed to work straight off the base methods, because there's no way of knowing which alias_method_chain is the bottom
#       level modification of that base. This didn't work, however, so if you want to use this plugin it is required to copy the alt/base.rb over
#       ActiveRecord's base.rb.

require 'changed_attributes'
ActiveRecord::Base.class_eval do
  # include ChangedAttributes
  # include ActiveRecord::Validations
  # include ActiveRecord::Locking::Optimistic
  # include ActiveRecord::Locking::Pessimistic
  include ActiveRecord::Callbacks
  # include ActiveRecord::Observing
  # include ActiveRecord::Timestamp
  # include ActiveRecord::Associations
  # include ActiveRecord::Aggregations
  # include ActiveRecord::Transactions
  # include ActiveRecord::Reflection
  # include ActiveRecord::Acts::Tree
  # include ActiveRecord::Acts::List
  # include ActiveRecord::Acts::NestedSet
  # include ActiveRecord::Calculations
  # include ActiveRecord::XmlSerialization
  # include ActiveRecord::AttributeMethods
end
require 'changed_attribute_validations'
