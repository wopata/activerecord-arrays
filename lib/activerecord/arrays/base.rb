module ActiveRecord::Arrays::Base
  def self.extended klass
    class << klass
      alias_method_chain :update_all, :arrays
    end
  end

  def update_all_with_arrays updates, conditions=nil, options={}
    if updates.respond_to? :stringify_keys
      updates = updates.stringify_keys
      updates.each do |k,v|
        if v && columns_hash[k].array?
          updates[k] = connection.stringify_array v 
        end
      end
    end
    update_all_without_arrays updates, conditions, options
  end
end
