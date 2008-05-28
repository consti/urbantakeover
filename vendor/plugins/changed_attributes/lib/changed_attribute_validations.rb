module ChangedAttributes
  def included(base)
    base.extend Validations
  end

  module Validations
    def validates_cannot_change(*attr_names)
      configuration = { :message => "cannot be changed." }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      validates_each(attr_names,configuration) do |record, attr_name, value|
        record.errors.add(attr_name, configuration[:message]) if record.attribute_changed?(attr_name)
      end
    end
  end
end
