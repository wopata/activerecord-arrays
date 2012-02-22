module ActiveRecord::Arrays::PostgreSQLColumn
  def self.included other
    # return if other.public_method_defined? :klass_with_arrays
    other.class_eval do
      for method in %w(simplified_type klass type_cast type_cast_code) do
        alias_method_chain method, :arrays
      end
    end
  end

  def array?
    @i_am_an_array ||= !!(type.to_s =~ /_array\Z/)
  end

  def simplified_type_with_arrays field_type
    if field_type =~ /\[\]/
      "#{simplified_type_without_arrays(field_type.gsub(/[\[\]]/, ''))}_array".intern
    else
      simplified_type_without_arrays field_type
    end
  end

  def klass_with_arrays
    array? ? Array : klass_without_arrays
  end

  def type_cast_with_arrays value
    if array?
      return value if value.nil?
      unless value.kind_of? Array
        value = ActiveRecord::Arrays.convert_array(value)
      end
      inner = self.dup
      inner.instance_variable_set :@type, self.type.to_s.sub(/_array\Z/, '').intern
      value.map { |i| inner.type_cast_without_arrays i }
    else
      type_cast_without_arrays value
    end
  end

  def type_cast_code_with_arrays var_name
    if array?
      inner = self.dup
      inner.instance_variable_set :@type, self.type.to_s.sub(/_array\Z/, '').intern
      "(return nil if #{var_name}.nil?
       unless #{var_name}.kind_of? Array
         #{var_name} = ActiveRecord::Arrays.convert_array(#{var_name})
       end
       #{var_name}.map { |i| #{inner.type_cast_code_without_arrays('i') || 'i'} })"
    else
      type_cast_code_without_arrays var_name
    end
  end
end
