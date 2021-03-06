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
      return url if path.include?(url) || path.size > 30

      path << url

      ret = UrlNormalization.find_by(original_url: url)
      return ret.normalized_url if ret

      parsed = URI.parse(url)
      query = parsed.query && URI.decode_www_form(parsed.query).to_h
      case
      when parsed.host == 'htn.to'
        resp = head(parsed)
        normalize_internal(resp['x-redirect-to'] || url, path: path)
      when parsed.host == 'b.hatena.ne.jp' && query.dig('url')
        normalize_internal(query['url'], path: path)
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
      path = [uri.path, uri.query].compact.join('?').presence || '/'
      http.request_head(path)
    end
  end
end
