module Admin
class SourceRefsController < ApplicationController
  before_action :set_source_ref, only: [:show, :edit, :update, :destroy]

  # GET /source_refs
  # GET /source_refs.json
  def index
    @source_refs = SourceRef.all
  end

  # GET /source_refs/1
  # GET /source_refs/1.json
  def show
  end

  # GET /source_refs/new
  def new
    @source_ref = SourceRef.new
  end

  # GET /source_refs/1/edit
  def edit
  end

  # POST /source_refs
  # POST /source_refs.json
  def create
    @source_ref = SourceRef.new(source_ref_params)

    respond_to do |format|
      if @source_ref.save
        format.html { redirect_to @source_ref, notice: 'Source ref was successfully created.' }
        format.json { render :show, status: :created, location: @source_ref }
      else
        format.html { render :new }
        format.json { render json: @source_ref.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /source_refs/1
  # PATCH/PUT /source_refs/1.json
  def update
    respond_to do |format|
      if @source_ref.update(source_ref_params)
        format.html { redirect_to @source_ref, notice: 'Source ref was successfully updated.' }
        format.json { render :show, status: :ok, location: @source_ref }
      else
        format.html { render :edit }
        format.json { render json: @source_ref.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /source_refs/1
  # DELETE /source_refs/1.json
  def destroy
    @source_ref.destroy
    respond_to do |format|
      format.html { redirect_to source_refs_url, notice: 'Source ref was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source_ref
      @source_ref = SourceRef.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_ref_params
      params.require(:source_ref).permit(:individual_uid, :union_uid, :source_id)
    end
end
end
