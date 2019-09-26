class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :update, :destroy, :notes, :previous_notes]

  # GET /folders
  def index
    #@folders = Folder.with_subfolders
    @folders = Folder.where_hash(previous_id: nil)
    render json: @folders
  end

  # GET /folders/:previous_id/subfolders
  def subfolders
    previous_id = params[:previous_id] == 'null' ? nil : params[:previous_id]
    @folders = Folder.where_hash(previous_id: previous_id)
    render json: @folders
  end

  def previous_folders
    previous_id = params[:previous_id]
    if previous_id == 'null' then
      @folders = Folder.where_hash(previous_id: nil)
    else
      folder = Folder.where(id: previous_id).first
      if folder then
        @folders = folder.previous ? folder.previous.subfolders_hash : Folder.where_hash(previous_id: nil)
      end
    end
    render json: @folders
  end

  def notes
    if @folder then
      render json: @folder.notes_hash
    else
      render json: []
    end
  end

  def previous_notes
    if @folder then
      if @folder.previous then
        render json: @folder.previous.notes_hash
      else
        render json: []
      end
    else
      render json: []
    end
  end

  def search_folders
    search = params[:search]
    if search && search != "" then
      search = "%#{search}%"
      #@folders = Folder.with_subfolders(folder: Folder.where("name like ?", search).to_a, with_notes: false)
      @folders = []
      folders = Folder.where("name like ?", search)
      folders.each do |folder|
        @folders.push(
          folder.attributes.merge!({
            location: folder.location,
            type: folder.class.name.downcase
          })
        )
      end
    else
      @folders= Folder.where_hash(previous_id: nil)
    end

    render json: @folders
  end
  
  def search_notes
    search = params[:search]
    if search && search != "" then
      search = "%#{search}%"
      @notes = []
      notes = Note.where("title like ?", search)
      notes.each do |note|
        @notes.push(
          note.attributes.merge!({
            location: note.location,
            type: note.class.name.downcase,
            name: note.title
          })
        )
      end
    else
      @notes= Note.where_hash(folder_id: nil)
    end

    render json: @notes
  end

  # GET /folders/1
  def show
    render json: @folder
  end

  # POST /folders
  def create
    @folder = Folder.new(folder_params)

    if @folder.save
      @folder = @folder.attributes.merge!({
        location: @folder.location,
        type: @folder.class.name.downcase
      })
      render json: @folder, status: :created, location: @folder
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /folders/1
  def update
    if @folder.update(folder_params)
      render json: @folder
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  # DELETE /folders/1
  def destroy
    @folder.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.where(id: params[:id]).first
    end

    # Only allow a trusted parameter "white list" through.
    def folder_params
      params.require(:folder).permit(:name, :previous_id)
    end
end
