module Admin

	class UnionsController < ApplicationController
	  before_action :set_union, only: [:show, :edit, :update, :destroy]
	  before_action :only_if_admin
	  	  
	  # GET /unions
	  # GET /unions.json
	  def index
	    @unions = Union.all
	  end
	
	  # GET /all_unions_by_uid
	  def all_unions_by_uid
	    @unions = Union.all_by_uid
	    
	    if params[:marriage_sorted] 
	      session[:union_marriage_sort] = !session[:union_marriage_sort] 
	      @unions.sort! { |a,b| 
	          Event.compare_dates( a.marriage, b.marriage, session[:union_marriage_sort] ) } 
	    end
	        
	  end
	  
	  # GET /union_by_uid
	  def union_by_uid
	    @union = Union.by_uid( params[:uid] )
        @sources = @union.sources
	  end  
	  
	  # GET /unions/1
	  # GET /unions/1.json
	  def show
	  end
	
	  # GET /unions/new
	  def new
	    @union = Union.new
	  end
	
	  # GET /unions/1/edit
	  def edit
	  end
	
	  # POST /unions
	  # POST /unions.json
	  def create
	    @union = Union.new(union_params)
	
	    respond_to do |format|
	      if @union.save
	        format.html { redirect_to @union, notice: 'Union was successfully created.' }
	        format.json { render :show, status: :created, location: @union }
	      else
	        format.html { render :new }
	        format.json { render json: @union.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # PATCH/PUT /unions/1
	  # PATCH/PUT /unions/1.json
	  def update
	    respond_to do |format|
	      if @union.update(union_params)
	        format.html { redirect_to @union, notice: 'Union was successfully updated.' }
	        format.json { render :show, status: :ok, location: @union }
	      else
	        format.html { render :edit }
	        format.json { render json: @union.errors, status: :unprocessable_entity }
	      end
	    end
	  end
	
	  # DELETE /unions/1
	  # DELETE /unions/1.json
	  def destroy
	    @union.destroy
	    respond_to do |format|
	      format.html { redirect_to unions_url, notice: 'Union was successfully destroyed.' }
	      format.json { head :no_content }
	    end
	  end
	
	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_union
	      @union = Union.find(params[:id])
	    end
	
	    # Never trust parameters from the scary internet, only allow the white list through.
	    def union_params
	      params.require(:union).permit(:uid, :husband_uid, :wife_uid, :marriage_id, :divorce_id, :tree, :note)
	    end
	end
	
end	
