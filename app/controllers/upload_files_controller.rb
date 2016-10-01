class UploadFilesController < ApplicationController
  before_action :set_upload_file, only: [:show, :edit, :update, :destroy]

  # GET /upload_files
  # GET /upload_files.json
  def index
    @upload_files = UploadFile.all
  end

  # GET /upload_files/1
  # GET /upload_files/1.json
  def show
    @xml_file_names = []
    @content = []
    parse_zip
    render 'show_file' if params[:file_name]
  end

  # GET /upload_files/new
  def new
    @upload_file = UploadFile.new
  end

  # GET /upload_files/1/edit
  def edit
  end

  # POST /upload_files
  # POST /upload_files.json
  def create
    @upload_file = UploadFile.new(upload_file_params)

    respond_to do |format|
      if @upload_file.save
        format.html { redirect_to upload_files_path, notice: 'Upload file was successfully created.' }
        format.json { render :show, status: :created, location: @upload_file }
      else
        format.html { render :new }
        format.json { render json: @upload_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /upload_files/1
  # PATCH/PUT /upload_files/1.json
  def update
    respond_to do |format|
      if @upload_file.update(upload_file_params)
        format.html { redirect_to @upload_file, notice: 'Upload file was successfully updated.' }
        format.json { render :show, status: :ok, location: @upload_file }
      else
        format.html { render :edit }
        format.json { render json: @upload_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /upload_files/1
  # DELETE /upload_files/1.json
  def destroy
    @upload_file.destroy
    respond_to do |format|
      format.html { redirect_to upload_files_url, notice: 'Upload file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_upload_file
    @upload_file = UploadFile.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def upload_file_params
    params.require(:upload_file).permit(:zip_file_a)
  end

  def parse_zip
    Zip::File.open(@upload_file.zip_file_a.path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        # Extract to file/directory/symlink
        @xml_file_names << entry.name if (entry.name =~ /.xml$/).present?
        if params[:file_name] && params[:file_name] == entry.name
          @content << entry.get_input_stream.read && break if params[:filter].blank?
          parse_xml_string(entry) && break
        end
      end
    end
  rescue
    flash[:notice] = 'Can not read zip file.'
  end

  def parse_xml_string(entry)
    @random_string = [*('A'..'Z'),*('a'..'z')].sample(20).join
    @doc = Nokogiri::XML.parse(entry.get_input_stream.read)
    results = @doc.xpath(params[:filter])
    results.map do |x|
      node = Nokogiri::XML::Node.new @random_string, @doc
      x.add_previous_sibling(node) if @doc.root != x
      @content << x.to_s
    end
  rescue
    flash[:notice] = 'X-path are not correct.'
  end
end
