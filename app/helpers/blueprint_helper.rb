module BlueprintHelper
  # actually those are just our html helpers
  def div_magic
    '<div class="span-24 lrborder">'
  end
  
  def div_second_magic
    '<div class="span-23 push-1 last">'
  end
  
  def blueprint_map spots, c
    '<div class="span-24 map-border">' +
      show_map(spots, c) +
    '</div>'
  end  
end