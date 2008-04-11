# blatantly taken from soup. thanks esad!

# Allows for params[:foo].empty? instead of having params[:foo] && params[:foo].empty?
class NilClass
  def empty?
    return true
  end
end

class String
  def uppercase
    upcase
  end
 
  def uppercase!
    upcase!
  end
  
  def starts_with? what
    self[0...what.size] == what
  end
  
  def ends_with? what
    self[-what.size, what.size] == what
  end
  
end