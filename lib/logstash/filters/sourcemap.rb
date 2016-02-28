require 'logstash/filters/base'
require 'logstash/namespace'
require 'open-uri'
require 'sourcemap'

class LogStash::Filters::SourceMap < LogStash::Filters::Base

  config_name 'sourcemap'

  config :server, :validate => :string, :required => true

  public
  def register
    # Add instance variables 
  end

  public
  def filter(event)
    return unless event['exception']

    values = event['exception']['values']
    if values==nil || values.is_a?(Array)==false || values.length!=1 || values[0]['value']==nil
      @logger.warn('SourceMap filter cannot parse exception', :values => values)
      event.tag('_sourcemapparsefailure')
      return
    end
    exception = values.first

    message = ''
    if exception['type']
      message += exception['type']
      # if exception['module']
      #   message += " (#{exception['module']})"
      # end
      message += ': '
    end
    message += exception['value']

    if exception['stacktrace'] && exception['stacktrace']['frames']
      exception['stacktrace']['frames'].each do |frame|

        remap!(frame)

        script_url = URI.parse(frame['filename'])
        if script_url.route_from(event['request']['url']).relative?
          filename = script_url.path.to_s
        else
          filename = frame['filename']
        end
        message += "\n  at #{frame['function']}(#{filename}:#{frame['lineno']}:#{frame['colno']})"
      end
    end

    event['stacktrace'] = message
    filter_matched(event)
  end

  private
  def remap!(frame)
    script_url = URI.parse(frame['filename'])
    return unless script_url.open.content_type == 'application/javascript'

    map_filename = nil
    script_url.open.each do |line|
      if %r{^//# sourceMappingURL=(.+)} =~ line
        map_filename = $1
        break
      end
    end
    return unless map_filename

    map_url = URI.join(@server, map_filename)
    map = SourceMap::Map.from_json(map_url.read)
    return unless map

    mapping = map.bsearch(SourceMap::Offset.new(frame['lineno'], frame['colno']))
    return unless mapping

    frame['raw_filename'] = frame['filename']
    frame['filename'] = URI.join(frame['filename'], mapping.source).to_s

    frame['raw_lineno'] = frame['lineno']
    frame['lineno'] = mapping.original.line

    frame['raw_colno'] = frame['colno']
    frame['colno'] = mapping.original.column

    if mapping.name
      frame['raw_function'] = frame['function']
      frame['function'] = mapping.name
    end
  end

end
