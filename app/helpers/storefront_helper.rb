module StorefrontHelper
  def circle_points(center_x, center_y, radius, quality = 3)

    points = []
    radians = Math::PI / 180

    0.step(360, quality) do |i|
      x = center_x + (radius * Math.cos(i * radians))
      y = center_y + (radius * Math.sin(i * radians))
      points << [x,y]
    end
    points
  end
end
