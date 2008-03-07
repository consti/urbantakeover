module ClaimsHelper
  def sort_claims_to_days claims
    days = []
    return days if claims.empty?
    day = claims[0].created_at.day
    claims_at_day = []
    claims.each do |claim|
      if day != claim.created_at.day
        days << claims_at_day
        claims_at_day = [claim]
        day = claim.created_at.day
      else
        claims_at_day << claim
      end
    end

    days << claims_at_day
    days
  end
end