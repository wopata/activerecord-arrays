module ActiveRecord
  module Arrays
    if defined? Rails
      class Railtie < Rails::Railtie
        config.before_initialize do
          if defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
            require 'activerecord/arrays/postgresql_adapter'
            require 'activerecord/arrays/postgresql_column'
            ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :include, PostgreSQLAdapter
            ActiveRecord::ConnectionAdapters::PostgreSQLColumn.send :include, PostgreSQLColumn
          end
        end
      end
    end

    def self.convert_array str
      array_nesting = 0  # nesting level of the array
      in_string = false  # currently inside a quoted string ?
      escaped = false    # if the character is escaped
      sbuffer = ''       # buffer for the current element
      result_array = []  # the resulting Array

      str.each_char do |char|  # parse character by character
        if escaped then        # if this character is escaped, just add it to the buffer
          sbuffer += char
          escaped = false
          next
        end

        case char              # let's see what kind of character we have
          #------------- {: beginning of an array ----#
        when '{'
          if in_string then    # ignore inside a string
            sbuffer += char
            next
          end

          if array_nesting >= 1 then # if it's an nested array, defer for recursion
            sbuffer += char
          end
          array_nesting += 1         # inside another array

        #------------- ": string deliminator --------#
        when '"'
          in_string = !in_string   

          #------------- \: escape character, next is regular character #
        when "\\"   # single \, must be extra escaped in Ruby
          if array_nesting > 1
            sbuffer += char
          else
            escaped = true
          end

          #------------- ,: element separator ---------#
        when ','
          if in_string or array_nesting > 1 then # don't care if inside string or
            sbuffer += char            # nested array
          else
            # if !sbuffer.is_a? ::Array then
            #   sbuffer = @base_type.parse(sbuffer)
            # end
            result_array << sbuffer        # otherwise, here ends an element
            sbuffer = ''
          end

        #------------- }: End of Array --------------#
        when '}' 
          if in_string then        # ignore if inside quoted string
            sbuffer += char
            next
          end

          array_nesting -=1        # decrease nesting level

          if array_nesting == 1      # must be the end of a nested array 
            sbuffer += char
            sbuffer = convert_array( sbuffer ) # recurse, using the whole nested array
          elsif array_nesting > 1     # inside nested array, keep it for later
            sbuffer += char
          else               # array_nesting = 0, must be the last 
            # if !sbuffer.is_a? ::Array then
            #   sbuffer = @base_type.parse( sbuffer )
            # end

            result_array << sbuffer unless sbuffer.nil? # upto here was the last element
          end

          #------------- all other characters ---------#
        else
          sbuffer += char         # simply append
        end
      end
      result_array
    end
  end
end
