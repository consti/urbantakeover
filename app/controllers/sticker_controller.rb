class StickerController < ApplicationController

  def create
    10.times do
      Sticker.create
    end
  end
end
