class Note < ApplicationRecord
  belongs_to :folder

  def location
    location = ""
    folder = self.folder
    location += folder.previous.location if folder.previous
    return location + '/' + folder.name
  end

end
