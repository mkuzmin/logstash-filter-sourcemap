require 'logstash/filters/base'
require 'logstash/namespace'

class LogStash::Filters::SourceMap < LogStash::Filters::Base

  config_name 'sourcemap'

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
      if exception['module']
        message += " (#{exception['module']})"
      end
      message += ': '
    end
    message += exception['value']

    event['message'] = message

    filter_matched(event)
  end
end
