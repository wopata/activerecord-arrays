module ActiveRecord::Arrays::TableDefinition
  for t in %w(string integer float decimal)
    module_eval "def #{t}_array *args; array_column '#{t}', *args; end", __FILE__, __LINE__
  end

  protected

  def array_column type, *rest
    type, opts = "#{type}_array", rest.extract_options!
    rest.each { |name| column name, type, opts }
  end
end
