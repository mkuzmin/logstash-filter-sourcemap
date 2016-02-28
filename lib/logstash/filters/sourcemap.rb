require 'logstash/filters/base'
require 'logstash/namespace'
# TODO: is it secure? http://sakurity.com/blog/2015/02/28/openuri.html
require 'open-uri'
require 'sourcemap'

class LogStash::Filters::SourceMap < LogStash::Filters::Base

  config_name 'sourcemap'

  config :server, :validate => :string, :required => true

  public
  def register
    # Add instance variables

    # TODO: validate if @server contains URL
  end

  public
  def filter(event)
    return unless event['exception']

    values = event['exception']['values']
    # TODO: handle reports with multiple exception values. examples?
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
        if frame['filename'] == nil
          @logger.warn('SourceMap filter cannot parse stacktrace frame. Filename is empty.', :frame=> frame)
          event.tag('_sourcemapparsefailure')
          next
        end

        if remap!(frame) == false
          @logger.warn('SourceMap filter cannot remap stacktrace frame.', :frame=> frame)
          event.tag('_sourcemapparsefailure')
        end

        # TODO: catch exception on malformed url
        # TODO: duplicate validations here and inside remap!() method
        script_url = URI.parse(frame['filename'])
        # TODO: does it work if request.url is empty?
        if script_url.route_from(event['request']['url']).relative?
          filename = script_url.path.to_s
        else
          # TODO: example with error in script from other domain?
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
    # TODO: catch exception on malformed url
    script_url = URI.parse(frame['filename'])
    return false unless script_url.absolute?
    return false unless script_url.scheme=='http' || script_url.scheme=='https'
    # TODO: read only headers
    if script_url.open.content_type != 'application/javascript'
      return true
    end

    map_name = nil
    script_url.open.each_line do |line|
      if %r{^//# sourceMappingURL=(.+)} =~ line
        # TODO: catch exception on malformed url
        map_name = URI.parse $1
        break
      end
    end
    return false unless map_name.relative?

    # TODO: validate if @server contains URL
    map_url = URI.join(@server, map_name)
    # TODO: validate for correct json
    map = SourceMap::Map.from_json(map_url.read)

    mapping = map.bsearch(SourceMap::Offset.new(frame['lineno'], frame['colno']))
    return false unless mapping

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

    return true
  end

end
