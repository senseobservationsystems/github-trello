module Github
  class ParamsHash < ::Hash

    def initialize(*args, &block)
      hash = args.extract_options!
      debugger
      # debugger
      # normalize_keys!(hash)
      # debugger
      super[hash]
    end

    def normalize_keys!(params)
      case params
      when Hash
        params.keys.each do |k|
          params[k.to_s] = params.delete(k)
          normalize_keys!(params[k.to_s])
        end
      when Array
        params.map! do |el|
          normalize_keys!(el)
        end
      else
        params.to_s
      end
      return params
    end

  end # ParamsHash
end # Github
