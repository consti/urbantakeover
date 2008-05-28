module ActiveRecord
  class Base
    class << self
      public
        def has_attribute?(key)
          columns_hash.has_key?(key.to_s)
        end

      private
        # Finder methods must instantiate through this method to work with the
        # single-table inheritance model that makes it possible to create
        # objects of different types from the same table.
        def instantiate(record)
          object =
            if subclass_name = record[inheritance_column]
              # No type given.
              if subclass_name.empty?
                allocate

              else
                # Ignore type if no column is present since it was probably
                # pulled in from a sloppy join.
                unless columns_hash.include?(inheritance_column)
                  allocate

                else
                  begin
                    compute_type(subclass_name).allocate
                  rescue NameError
                    raise SubclassNotFound,
                      "The single-table inheritance mechanism failed to locate the subclass: '#{record[inheritance_column]}'. " +
                      "This error is raised because the column '#{inheritance_column}' is reserved for storing the class in case of inheritance. " +
                      "Please rename this column if you didn't intend it to be used for storing the inheritance class " +
                      "or overwrite #{self.to_s}.inheritance_column to use another column for that information."
                  end
                end
              end
            else
              allocate
            end

          object.instance_variable_set("@attributes", record)
          object.instance_variable_set("@changed_attributes", {})
          object
        end
    end

    public
      def initialize(attributes = nil)
        @attributes = attributes_from_column_definition
        @changed_attributes = {} #Or should we pretend that all default values are modified attributes?
        @new_record = true
        ensure_proper_type
        self.attributes = attributes unless attributes.nil?
        self.class.send(:scope, :create).each { |att,value| self.send("#{att}=", value) } if self.class.send(:scoped?, :create)
        yield self if block_given?
      end

      def exists?
        return false if new_record?
        self.class.find(self.id)
        return true
      rescue ActiveRecord::RecordNotFound
        return false
      end

      def clone
        attrs = self.attributes_before_type_cast
        changed_attrs = self.changed_attributes
        attrs.delete(self.class.primary_key)
        self.class.new do |record|
          record.send :instance_variable_set, '@attributes', attrs
          record.send :instance_variable_set, '@changed_attributes', changed_attrs
        end
      end

      # Resets the changed attributes to the original state of the object,
      # without reloading the object from the database.
      def reset(options = nil)
        clear_aggregation_cache
        clear_association_cache
        @changed_attributes = {}
        self
      end
      alias :revert :reset

      def reset_attribute(attribute)
        @changed_attributes.delete(attribute)
      end
      alias :revert_attribute :reset_attribute

      def attribute_changed?(attribute)
        @changed_attributes.has_key?(attribute.to_s)
      end
      alias :attr_changed? :attribute_changed?

      # Returns a hash of all the default attributes with their names as keys and clones of their objects as values.
      def default_attributes(options = nil)
        default_attributes = clone_attributes :read_attribute_default
        
        if options.nil?
          default_attributes
        else
          if except = options[:except]
            except = Array(except).collect { |attribute| attribute.to_s }
            except.each { |attribute_name| default_attributes.delete(attribute_name) }
            default_attributes
          elsif only = options[:only]
            only = Array(only).collect { |attribute| attribute.to_s }
            default_attributes.delete_if { |key, value| !only.include?(key) }
            default_attributes
          else
            raise ArgumentError, "Options does not specify :except or :only (#{options.keys.inspect})"
          end
        end
      end

      # Returns a hash of all the original attributes with their names as keys and clones of their objects as values.
      def original_attributes(options = nil)
        attributes = clone_attributes :read_original_attribute

        if options.nil?
          attributes
        else
          if except = options[:except]
            except = Array(except).collect { |attribute| attribute.to_s }
            except.each { |attribute_name| attributes.delete(attribute_name) }
            attributes
          elsif only = options[:only]
            only = Array(only).collect { |attribute| attribute.to_s }
            attributes.delete_if { |key, value| !only.include?(key) }
            attributes
          else
            raise ArgumentError, "Options does not specify :except or :only (#{options.keys.inspect})"
          end
        end
      end

      # Returns a hash of all the original attributes with their names as keys and clones of their objects as values.
      def changed_attributes(options = nil)
        attributes = clone_changed_attributes :read_attribute

        if options.nil?
          attributes
        else
          if except = options[:except]
            except = Array(except).collect { |attribute| attribute.to_s }
            except.each { |attribute_name| attributes.delete(attribute_name) }
            attributes
          elsif only = options[:only]
            only = Array(only).collect { |attribute| attribute.to_s }
            attributes.delete_if { |key, value| !only.include?(key) }
            attributes
          else
            raise ArgumentError, "Options does not specify :except or :only (#{options.keys.inspect})"
          end
        end
      end

      def modified?
        (new_record? || @changed_attributes.keys.length > 0) ? true : false
      end

      def save_if_modified
        save if modified?
      end

      def attribute_names
        attributes_from_column_definition.keys.sort
      end

      def changed_attribute_names
        @changed_attributes.keys.sort
      end

      def freeze
        @attributes.freeze
        @changed_attributes.freeze
        self
      end

      def frozen?
        @attributes.frozen?
      end
    private
      def create_or_update
        raise ReadOnlyRecord if readonly?
        result = new_record? ? create : update
        @attributes, @changed_attributes = @attributes.merge(@changed_attributes), {} if result != false
        result != false
      end

      def method_missing(method_id, *args, &block)
        method_name = method_id.to_s
        all_attrs = @attributes.merge(@changed_attributes)
        if all_attrs.include?(method_name) or
            (md = /\?$/.match(method_name) and
            all_attrs.include?(query_method_name = md.pre_match) and
            method_name = query_method_name)
          if self.class.read_methods.empty? && self.class.generate_read_methods
            define_read_methods
            # now that the method exists, call it
            self.send method_id.to_sym
          else
            md ? query_attribute(method_name) : read_attribute(method_name)
          end
        elsif self.class.primary_key.to_s == method_name
          id
        elsif md = self.class.match_attribute_method?(method_name)
          attribute_name, method_type = md.pre_match, md.to_s
          if all_attrs.include?(attribute_name)
            __send__("attribute#{method_type}", attribute_name, *args, &block)
          else
            super
          end
        else
          super
        end
      end

      def read_attribute(attr_name)
        attr_name = attr_name.to_s
        if !( value = (@changed_attributes[attr_name] || @attributes[attr_name]) ).nil?
          if column = column_for_attribute(attr_name)
            if unserializable_attribute?(attr_name, column)
              unserialize_attribute(attr_name)
            else
              column.type_cast(value)
            end
          else
            value
          end
        else
          nil
        end
      end
      
      def read_attribute_default(attr_name)
        attr_name = attr_name.to_s
        if column = column_for_attribute(attr_name)
          if unserializable_attribute?(attr_name, column)
            unserialize_value_for_attribute(column.default, column.name)
          else
            column.type_cast(column.default)
          end
        else
          column.default
        end
      end

      def unserialize_value_for_attribute(value, attr_name)
        unserialized_object = object_from_yaml(value)
        if unserialized_object.is_a?(self.class.serialized_attributes[attr_name]) || unserialized_object.nil?
          unserialized_object
        else
          raise SerializationTypeMismatch,
            "#{attr_name} was supposed to be a #{self.class.serialized_attributes[attr_name]}, but was a #{unserialized_object.class.to_s}"
        end
      end
      
      # Returns the value of the attribute identified by <tt>attr_name</tt> after it has been typecast (for example,
      # "2004-12-12" in a data column is cast to a date object, like Date.new(2004, 12, 12)).
      # Check for a changed_attribute first, then for original.
      def read_original_attribute(attr_name)
        attr_name = attr_name.to_s
        if !(value = @attributes[attr_name]).nil?
          if column = column_for_attribute(attr_name)
            if unserializable_attribute?(attr_name, column)
              unserialize_attribute(attr_name)
            else
              column.type_cast(value)
            end
          else
            value
          end
        else
          nil
        end
      end

      def define_read_method(symbol, attr_name, column)
        cast_code = column.type_cast_code('v') if column
        access_code = cast_code ? "(v = (@changed_attributes['#{attr_name}'] || @attributes['#{attr_name}'])) && #{cast_code}" : "(@changed_attributes['#{attr_name}'] || @attributes['#{attr_name}'])"
        
        unless attr_name.to_s == self.class.primary_key.to_s
          access_code = access_code.insert(0, "raise NoMethodError, 'missing attribute: #{attr_name}', caller unless @attributes.merge(@changed_attributes).has_key?('#{attr_name}'); ")
          self.class.read_methods << attr_name
        end
        
        evaluate_read_method attr_name, "def #{symbol}; #{access_code}; end"
      end

      def unserialize_attribute(attr_name)
        if(@changed_attributes.has_key?(attr_name))
          unserialized_object = unserialize_value_for_attribute(@changed_attributes[attr_name], attr_name)
          @changed_attributes.frozen? ? unserialized_object : @changed_attributes[attr_name] = unserialized_object
        else
          unserialized_object = unserialize_value_for_attribute(@attributes[attr_name], attr_name)
          @attributes.frozen? ? unserialized_object : @attributes[attr_name] = unserialized_object
        end
      end

      def write_attribute(attr_name, value)
        attr_name = attr_name.to_s
        column = self.class.columns_hash[attr_name == 'id' ? self.class.primary_key : attr_name]
        type_casted = column.type_cast(convert_number_column_value(value))
        if type_casted != read_attribute(attr_name) && type_casted.to_s != read_attribute(attr_name).to_s
          if type_casted != read_original_attribute(attr_name) && type_casted.to_s != read_original_attribute(attr_name).to_s
            # Attribute has been updated.
            if (column = column_for_attribute(attr_name)) && column.number?
              @changed_attributes[attr_name] = convert_number_column_value(value)
            else
              @changed_attributes[attr_name] = value
            end
          else
            # Attribute has been set to the original value.
            @changed_attributes.delete(attr_name)
          end
        else
          # Attribute remains unchanged
        end
      end

      def clone_changed_attributes(reader_method = :read_attribute, attributes = {})
        self.changed_attribute_names.inject(attributes) do |attributes, name|
          attributes[name] = clone_attribute_value(reader_method, name)
          attributes
        end
      end

      def evaluate_read_method(attr_name, method_definition)
        begin
          self.class.class_eval(method_definition)
        rescue SyntaxError => err
          self.class.read_methods.delete(attr_name)
          puts "Exeption occurred during reader method compilation."
          if logger
            logger.warn "Exception occurred during reader method compilation."
            logger.warn "Maybe #{attr_name} is not a valid Ruby identifier?"
            logger.warn "#{err.message}"
          end
        end
      end
  end
end
