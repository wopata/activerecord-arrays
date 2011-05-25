module ActiveRecord::Arrays::PostgreSQLAdapter
  def self.included other
    # return if other.public_method_defined? :quote_with_arrays
    other.class_eval do
      for method in %w(quote native_database_types type_to_sql) do
        alias_method_chain method, :arrays
      end
    end
  end

  def stringify_array a
    '{"' + a.map { |s| quote_string(s.to_s).gsub('"', '\\"') }.join('","') + '"}'
  end

  def quote_with_arrays value, column=nil
    if value.kind_of?(Array) && column && column.array?
      "E'#{stringify_array(value)}'"
    else
      quote_without_arrays value, column
    end
  end

  def native_database_types_with_arrays
    native_database_types_without_arrays.merge({
      :string_array => 'character varying(255)[]',
      :integer_array => 'integer[]',
      :float_array => 'float[]',
      :decimal_array => 'decimal[]'
    })
  end

  def type_to_sql_with_arrays type, limit=nil, precision=nil, scale=nil
    if type.to_s =~ /\A(.+)_array\Z/
      type_to_sql_without_arrays($1, limit, precision, scale) + '[]'
    else
      type_to_sql_without_arrays type, limit, precision, scale
    end
  end
end
