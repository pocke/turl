module Turl
  module Normalizer
    extend self

    def normalize(url)
      path = []
      normalize_internal(url, path: path).tap do |result|
        path.each do |before|
          record = UrlNormalization.find_or_initialize_by(original_url: before)
          record.update!(normalized_url: result)
        end
      end
    end

    private def normalize_internal(url, path:)
      path << url

      ret = UrlNormalization.find_by(original_url: url)
      return ret.normalized_url if ret

      parsed = URI.parse(url)
      case
      when parsed.host == 'htn.to'
        resp = head(parsed)
        normalize_internal(resp['x-redirect-to'] || url, path: path)
      else
        resp = head(parsed)
        if resp.is_a?(Net::HTTPRedirection) && resp['location']
          normalize_internal(resp['location'], path: path)
        else
          url
        end
      end
    end

    private def head(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.request_head([uri.path, uri.query].compact.join('?'))
    end
  end
end
