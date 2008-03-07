# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def format_interval(timestamp)
    
    granularity = 1
    units =   [ ['year', 31536000],
                ['week', 604800],
                ['day', 86400],
                ['hour', 3600],
                ['min', 60],
                ['second', 1] ]
    output = '';
    
    for unit in units
      if timestamp >= unit[1]
        count = (timestamp / unit[1]).floor
        output += pluralize(count, unit[0]) + ' '
        timestamp %= unit[1]
        granularity -= 1
      end
      
      break if granularity == 0
    end
    
    output.empty? ? '0 seconds' : output.strip
  end
  
  def interval_to_now timestamp
    return "#{format_interval(Time.now - timestamp)} ago"
  end
end
