require 'logstash/filters/base'
require 'logstash/namespace'

class LogStash::Filters::SourceMap < LogStash::Filters::Base

  config_name 'sourcemap'
  
  # Replace the message with this value.
  config :message, :validate => :string, :default => "Hello World!"

  public
  def register
    # Add instance variables 
  end

  public
  def filter(event)

    if @message
      # Replace the event message with our message as configured in the
      # config file.
      event['message'] = @message
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end
end
