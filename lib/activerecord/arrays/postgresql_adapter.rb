module ActiveRecord::Arrays::PostgreSQLAdapter
  def self.included other
    # return if other.public_method_defined? :quote_with_arrays
    other.class_eval do
      for method in %w(quote native_database_types type_to_sql) do
        alias_method_chain method, :arrays
      end
      if instance_methods.include? :type_cast
        alias_method_chain :type_cast, :arrays
      end
    end
  end

  def stringify_array a
    a.any? ?
    ('{"' + a.map { |s| quote_string(s.to_s).gsub('"', '\\"') }.join('","') + '"}') :
    '{}'
  end

  def type_cast_with_arrays val, col
    if val && col && col.array?
      stringify_array val
    else
      type_cast_without_arrays val, col
    end
  end

  def quote_with_arrays value, column=nil
    if value.kind_of?(Array) && column && column.array?
      "E'#{stringify_array(value)}'"
    else
      quote_without_arrays value, column
    end
  end

  def native_database_types_with_arrays
    sup = native_database_types_without_arrays
    sup.merge({
      :string_array => { :name => "character varying(#{sup[:string][:limit]})[]" },
      :integer_array => { :name => 'integer[]' },
      :float_array => { :name => 'float[]' },
      :decimal_array => { :name => 'decimal[]' }})
  end

  def type_to_sql_with_arrays type, limit=nil, precision=nil, scale=nil
    if type.to_s =~ /\A(.+)_array\Z/
      type_to_sql_without_arrays($1, limit, precision, scale) + '[]'
    else
      type_to_sql_without_arrays type, limit, precision, scale
    end
  end
end
