module BlueprintHelper
  # actually those are just our html helpers
  def div_magic
    '<div class="span-24 lrborder">'
  end
  
  def div_second_magic
    '<div class="span-23 push-1 last">'
  end
  
  def div_map spots, c
    '<div class="span-24 map-border">' +
      show_map(spots, c) +
    '</div>'
  end  
  
  def div_spacer
    '<div class="span-24 lrborder">
       <br/>
    </div>'
  end
end