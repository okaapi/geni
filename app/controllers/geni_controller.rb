class GeniController < ApplicationController

  FONT = 15
  MINFONT = 10
  
  def index
    @surnames = Individual.surnames( params[:term])
  end
  
  def names
    @surname = params[:surname]
	@term = params[:term]    
	is_user = ( @current_user and ( @current_user.role == 'user' or
                                    @current_user.role == 'admin' ) )
    @names = Individual.names_for_surname( @surname, @term, is_user )
  end
  
  def search    
	@surname = params["surnames-search-txt"]
	@term = params[:term]
	if @surname
      is_user = ( @current_user and ( @current_user.role == 'user' or
                                    @current_user.role == 'admin' ) )	
	  @individuals = Individual.names_for_surname( @surname, @term, is_user )
	end
	render :search
  end
  
  def search_results
    @font = FONT
    @minfont = MINFONT
    @individual = Individual.by_uid( params[:'names-search-uid'] )
    render :tree
  end
    
  def tree
    @font = FONT
    @minfont = MINFONT
    @individual = Individual.by_uid( params[:uid] )
  end
  
  def import
    @default_tree = 'wido'       
  end
  
  def file_upload
    ignored = params[ :ignored ]
    
    stored_file = params[:stored_file]  
    if ! stored_file || ! stored_file[:stored_file]      
      flash[:notice] = "Select file to upload first."
      redirect_to :action => :index
      return
    end
        
    treename = params[:tree]['name']
	original_file = stored_file[:stored_file].original_filename
    gedfile = stored_file[:stored_file].tempfile.path

    ignored = Import.from_gedfile( treename, gedfile, original_file )
    
    flash[:notice] = ignored
    redirect_to action: :index, params: { ignored: ignored }
  end  
    
end
