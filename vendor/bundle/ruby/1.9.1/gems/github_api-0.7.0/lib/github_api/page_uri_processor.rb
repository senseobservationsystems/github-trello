module Github
  class PageUriProcessor
    include Github::Constants
    include Github::Utils::Url

    attr_reader :link, :query_string

    def initialize(uri)
      @link = uri.split(QUERY_STR_SEP).first
      @query_string = uri.split(QUERY_STR_SEP).last
    end

    def resource_link
      link
    end

    def query_hash
      parsed_query = parse_query(query_string)
      params = {}
      if parsed_query.include? :last_sha
        params[:sha] = parsed_query[:last_sha]

    end
  end
end
