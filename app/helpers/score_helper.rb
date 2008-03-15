module ScoreHelper
  def format_score score
    if score.points > 0
      message = "#{score.description}, get #{score.points} points!"
    elsif score.points < 0
      message = "#{score.description}, loose #{score.points.abs} points!"
    else
      message = description
    end
    
    message
  end
end
