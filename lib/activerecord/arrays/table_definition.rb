module ActiveRecord::Arrays::TableDefinition
  for t in %w(string integer float decimal) do
    module_eval "
      def #{t}_array name, *rest
        column name, :#{t}_array, *rest
      end", __FILE__, __LINE__
  end
end
