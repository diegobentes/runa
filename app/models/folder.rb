class Folder < ApplicationRecord

  has_many :notes, dependent: :destroy

  has_many :subfolders, class_name: "Folder", foreign_key: "previous_id", dependent: :destroy
  belongs_to :previous, class_name: "Folder", required: false

  def self.with_subfolders(options = {})
    objeto_retorno = [] if not defined?(@objeto_retorno)

    with_notes =  options.key?(:with_notes) ? options[:with_notes] : true

    if options[:folder] then
      if options[:folder].kind_of?(Array) then
        folders = options[:folder]
      else
        folders = self.where(previous_id: options[:folder].id)
      end
    else
      folders = self.where(previous_id: nil)
    end

    folders.each do |folder|
      if folder.subfolders.any? then
        objeto_retorno.push(
          folder.attributes.merge!(
            type: folder.class.name,
            location: obj.location,
            children: self::with_subfolders({ folder: folder, with_notes: with_notes })
          )
        )  
      else
        objeto_retorno.push(
          folder.attributes.merge!(
            type: folder.class.name,
            location: obj.location
          )
        )
      end

      if with_notes then
        if folder.notes.any? then
          folder.notes.each do |note|
            objeto_retorno.push({
              name: note.title, 
              id: note.id,
              file: true,
              children: []
            })
          end
        end
      end

    end

    return objeto_retorno

  end

  def self.where_hash(options)
    return_arr = []
    objects = self.where(options)
    objects.each do |obj|
      return_arr.push(
        obj.attributes.merge!(
          type: obj.class.name.downcase,
          location: obj.location
        )
      )
    end    
    return return_arr
  end

  def subfolders_hash
    return_arr = []
    objects = self.subfolders
    objects.each do |obj|
      return_arr.push(
        obj.attributes.merge!(
          type: obj.class.name.downcase,
          location: obj.location
        )
      )
    end    
    return return_arr
  end

  def notes_hash
    return_arr = []
    objects = self.notes
    objects.each do |obj|
      return_arr.push(
        obj.attributes.merge!(
          type: obj.class.name.downcase,
          name: obj.title,
          location: obj.location
        )
      )
    end    
    return return_arr
  end

  def location
    location = ""
    location += self.previous.location if self.previous
    return location + '/' + self.name
  end

end
