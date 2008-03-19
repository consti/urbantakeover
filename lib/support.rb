# blatantly taken from soup. thanks esad!

# Allows for params[:foo].empty? instead of having params[:foo] && params[:foo].empty?
class NilClass
  def empty?
    return true
  end
end