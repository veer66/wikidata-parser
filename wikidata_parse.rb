require 'json/stream'
#require 'zlib'

module WikiData

  BUFSIZE = 1000000
  
  class Parser
    # def self.parse_from_gz(path)
    #   puts path
    #   Zlib::GzipReader.open(path) do |gz|
    #     while true
    #       puts "!!! #{gz.gets}"
    #     end
                 
    #   end
    # end
    
    def self.parse(stream)
      parser = JSON::Stream::Parser.new do
        state = :INIT
        stack = []
        k = nil
        
        start_document do
          state = :DOC
        end
        
        end_document do
          if state == :DOC
            state = :INIT
          end
        end
        
        start_object do
          new_obj = {}
          if stack.last.kind_of?(Array)
            stack.last << new_obj
          else
            stack.last[k] = new_obj
            k = nil
          end
          stack.push(new_obj)
        end
        
        end_object do
          if stack.length == 1
            yield stack.pop
          else
            stack.pop
          end
        end
        
        start_array do
          if state == :DOC
            state = :ITEM
          else
            new_arr = []
            if stack.last.kind_of?(Array)
              stack.last << new_arr
            else
              stack.last[k] = new_arr
              k = nil
            end
            stack.push(new_arr)
          end
        end
        
        end_array do
          arr = stack.pop      
        end
        
        key do |k_|
          k = k_
        end
        
        value do |v|
          if stack.last.kind_of?(Array)
            stack.last << v
          else
            stack.last[k] = v
            k = nil
          end

        end
      end

      while stream.gets(BUFSIZE)
        parser << $_
      end
    end
  end
end
